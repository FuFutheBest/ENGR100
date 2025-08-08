module Scenes.Script.C.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color exposing (Color(..))
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL
import REGL.BuiltinPrograms exposing (centeredTexture, rectCentered, textbox)
import REGL.Common exposing (Renderable, group)
import Scenes.Script.SceneBase exposing (..)


type alias Data =
    { count : Int

    --, speaker : List String
    , dialogue : List ( String, List String )
    }



-- init dialogue/script here
-- todo: add cg pics for plot


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { count = 0

    --, speaker = [ "X", "Y", "Z" ]
    , dialogue =
        let
            dialoguePart1 =
                [ ( "", [ "Story begins..." ] ) --0
                , ( ""
                  , [ "It's another evening of overworking and coding. Citrus is exhausted by the computer."
                    , "She gets stuck on a function, gradually falling into sleep..."
                    ]
                  )
                ]

            dialoguePart2 =
                [ ( "Citrus", [ "" ] ) --2
                , ( "Citrus"
                  , [ "[Sleepy] Wait... Bugs are still out there... I have to... Keep working... "
                    , "         How I wish I could become x to debug myself... %#$*;&@!<..."
                    ]
                  )
                ]

            dialoguePart3 =
                [ ( "Citrus", [ "Zzz..." ] ) --4
                , ( "", [ "Citrus falls asleep very soon. " ] ) --5
                , ( "?", [ "" ] ) --6
                , ( "?", [ "...As you wish." ] )
                ]

            --7
            dialoguePart4 =
                [ ( "", [ "" ] ) --8
                , ( "X", [ "" ] ) --9
                , ( "X"
                  , [ "To her surprise, she finds herself transformed into the code - variable x! "
                    , "In this digital world, Citrus, as tiny ball, floats through a maze built from \"code bricks\"."
                    ]
                  )
                ]

            dialoguePart5 =
                [ ( "", [ "" ] ) --11
                , ( ""
                  , [ "Now, help her fix the bug of variable x and solve the problem through a breakout game! "
                    ]
                  )

                --12
                ]
        in
        -- [ ( "", [ "Story begins..." ] ) --0
        -- , ( ""
        --   , [ "It's another evening of overworking and coding. Citrus is exhausted by the computer."
        --     , "She gets stuck on a function, gradually falling into sleep..."
        --     ]
        --   )
        --
        -- --1
        -- --, ( "Y", [ "Another piece of random text. Debug only." ] )
        -- , ( "Citrus", [ "" ] ) --2
        -- , ( "Citrus"
        --   , [ "[Sleepy] Wait... Bugs are still out there... I have to... Keep working... "
        --     , "         How I wish I could become x to debug myself... %#$*;&@!<..."
        --     ]
        --   )
        --
        -- --3
        -- , ( "Citrus", [ "Zzz..." ] ) --4
        -- , ( "", [ "Citrus falls asleep very soon. " ] ) --5
        -- , ( "?", [ "" ] ) --6
        -- , ( "?", [ "...As you wish." ] ) --7
        -- , ( "", [ "" ] ) --8
        -- , ( "X", [ "" ] ) --9
        -- , ( "X"
        --   , [ "To her surprise, she finds herself transformed into the code - variable x! "
        --     , "In this digital world, Citrus, as tiny ball, floats through a maze built from \"code bricks\"."
        --     ]
        --   )
        --
        -- --10
        -- , ( "", [ "" ] ) --11
        -- , ( ""
        --   , [ "Now, help her fix the bug of variable x and solve the problem through a breakout game! "
        --     ]
        --   )
        --
        -- --12
        -- ]
        dialoguePart1
            ++ dialoguePart2
            ++ dialoguePart3
            ++ dialoguePart4
            ++ dialoguePart5
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        newCount =
            data.count + 1

        newDialogue =
            data.dialogue |> List.drop 1

        ( changeScene, newData ) =
            case evt of
                KeyDown 13 ->
                    -- press enter
                    case data.dialogue of
                        [] ->
                            ( [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], data )

                        _ ->
                            ( [], { data | count = newCount, dialogue = newDialogue } )

                _ ->
                    ( [], data )
    in
    ( newData, changeScene, ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


viewText : ( String, List String ) -> Renderable
viewText ( sp, d ) =
    group []
        (textbox ( 200, 640 ) 80 sp "consolas" Color.lightYellow :: viewMulti d 0)



-- view multi lines of script


viewMulti : List String -> Int -> List Renderable
viewMulti l x =
    case l of
        [] ->
            []

        lh :: ls ->
            textbox ( 150, 820 + 60 * x |> toFloat ) 40 lh "consolas" Color.white :: viewMulti ls (x + 1)


view : LayerView SceneCommonData UserData Data
view env data =
    group []
        [ rectCentered ( 960, 540 ) ( 1920, 1080 ) 0.0 Color.black -- black background
        , if data.count == 1 then
            centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "script1"
            -- script1 image

          else if data.count == 2 || data.count == 3 then
            centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "script2"
            -- script2 image

          else if data.count == 4 || data.count == 5 || data.count == 6 then
            centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "script3"
            -- script3 image

          else if data.count == 9 || data.count == 10 then
            centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "script4"
            -- script4 image

          else if data.count == 11 || data.count == 12 then
            centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "script5"
            -- script5 image

          else
            REGL.empty
        , rectCentered ( 960, 750 ) ( 1920, 4 ) 0.0 Color.blue -- blue line
        , case data.dialogue of
            d :: _ ->
                viewText d

            [] ->
                REGL.empty
        , textbox ( 1400, 1000 ) 40 "Press Enter to continue." "consolas" Color.lightRed
        ]



--REGL.empty


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "C"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
