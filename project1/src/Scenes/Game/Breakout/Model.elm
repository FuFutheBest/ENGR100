module Scenes.Game.Breakout.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Lib.Base exposing (SceneMsg)
import Lib.Breakout.Ball exposing (UpdateBallMsg(..), initBall, updateBall, viewBall)
import Lib.Breakout.BallCollideWithBricks exposing (Ball)
import Lib.Breakout.BricksInit exposing (Brick, initBricks)
import Lib.Breakout.BricksView exposing (viewBricks)
import Lib.Breakout.DemoConfig exposing (demoBCA, demoTR)
import Lib.Breakout.Game exposing (State(..), stateToggle, viewX)
import Lib.Breakout.Layer exposing (GameMsg(..), viewLayer)
import Lib.Breakout.LevelsBrickConfig exposing (..)
import Lib.Breakout.Paddle exposing (Paddle, PaddleType(..), initPaddle, movePaddle, viewPaddle)
import Lib.Breakout.Program exposing (..)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import REGL.Common exposing (Renderable, group)
import Scenes.Game.SceneBase exposing (..)
import Set


type alias Data =
    { bricks : List Brick
    , paddle : Paddle
    , ball : Ball
    , state : State
    , program : ProgramData
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { bricks = initBricks (round env.globalData.currentTimeStamp) level3BCA level3TR
    , paddle = initPaddle
    , ball = initBall
    , state = Playing
    , program = defaultInitProgram
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        newState =
            case evt of
                KeyDown 32 ->
                    stateToggle data.state

                KeyDown 27 ->
                    -- ESC key pressed, return to Home scene
                    data.state

                KeyDown 13 ->
                    -- Enter key pressed, go to Result scene
                    data.state

                _ ->
                    data.state
    in
    if data.state == Playing then
        let
            -- move the ball and check for collisions with bricks
            ( newball, newbricks, updateBallMsg ) =
                updateBall data.ball data.paddle data.bricks

            ( finalState, endedProgram ) =
                case updateBallMsg of
                    GameState StopGame ->
                        ( Won, Just (defaultEnd data.program) )

                    GameState LoseGame ->
                        ( Ended, Just (defaultEnd data.program) )

                    _ ->
                        ( newState, Nothing )

            seed =
                round env.globalData.currentTimeStamp

            updatedProgram =
                case updateBallMsg of
                    BrickType tRA ->
                        appendBrickToProgram data.program seed tRA

                    _ ->
                        data.program

            newProgram =
                case endedProgram of
                    Just _ ->
                        defaultEnd updatedProgram

                    Nothing ->
                        updatedProgram

            -- update the paddle
            movedPaddle =
                if env.globalData.pressedKeys == Set.singleton 39 then
                    movePaddle data.paddle 1

                else if env.globalData.pressedKeys == Set.singleton 37 then
                    movePaddle data.paddle -1

                else
                    data.paddle

            newPaddle =
                case evt of
                    KeyDown 38 ->
                        -- if the up arrow is pressed, change the paddle type to Return
                        { movedPaddle | paddleType = Return }

                    KeyDown 40 ->
                        -- if the down arrow is pressed, change the paddle type to Normal
                        { movedPaddle | paddleType = Normal }

                    _ ->
                        movedPaddle
        in
        case evt of
            KeyDown 27 ->
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            _ ->
                ( { data
                    | paddle = newPaddle
                    , ball = newball
                    , bricks = newbricks
                    , state = finalState
                    , program = newProgram
                  }
                , []
                , ( env, False )
                )

    else if data.state == Won then
        case evt of
            KeyDown 13 ->
                --Pressed Enter key to go to the ending scene
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Ending")) ], ( env, False ) )

            KeyDown 27 ->
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            _ ->
                ( { data | state = newState }, [], ( env, False ) )

    else if data.state == Paused then
        case evt of
            KeyDown 27 ->
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            KeyDown 32 ->
                ( { data | state = Playing }, [], ( env, False ) )

            _ ->
                ( data, [], ( env, False ) )

    else
        let
            dataReinit state1 data1 config1 config2 =
                { data1
                    | state = state1
                    , bricks = initBricks (round env.globalData.currentTimeStamp) config1 config2
                    , paddle = initPaddle
                    , ball = initBall
                    , program = defaultInitProgram
                }
        in
        case evt of
            KeyDown 27 ->
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            KeyDown 68 ->
                -- Pressed D, enter the demo mode
                -- ( { data
                --     | state = Playing
                --     , bricks = initBricks (round env.globalData.currentTimeStamp) demoBCA demoTR
                --     , paddle = initPaddle
                --     , ball = initBall
                --     , program = defaultInitProgram
                --   }
                ( dataReinit Playing data demoBCA demoTR
                , []
                , ( env, False )
                )

            _ ->
                -- ( { data
                --     | state = newState
                --     , bricks = initBricks (round env.globalData.currentTimeStamp) level3BCA level3TR
                --     , paddle = initPaddle
                --     , ball = initBall
                --     , program = defaultInitProgram
                --   }
                ( dataReinit newState data level3BCA level3TR
                , []
                , ( env, False )
                )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    group []
        (List.concat
            [ viewLayer
            , viewBricks data.bricks
            , viewPaddle data.paddle
            , viewBall data.ball
            , getProgramRenderables data.program
            , [ viewX data.ball data.state 3 ]
            ]
        )


{-| Match layer target for scene management
-}
matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "Breakout"


{-| Concrete layer implementation
-}
layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator for game scene
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
