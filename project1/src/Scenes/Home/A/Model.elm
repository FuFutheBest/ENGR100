module Scenes.Home.A.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color exposing (Color(..))
import Duration exposing (Duration)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (..)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import REGL
import REGL.BuiltinPrograms exposing (textbox)
import REGL.Common exposing (Renderable, group)
import Scenes.Home.A.Background exposing (viewBackground)
import Scenes.Home.SceneBase exposing (..)


type alias Data =
    { text : String
    , position : Int -- y:0,1,2,3 (x is fixed)
    , picIndex : Int
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { text = ">>"
    , position = 0
    , picIndex = 0
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        position =
            data.position

        delta =
            case evt of
                KeyDown 40 ->
                    1

                KeyDown 38 ->
                    -1

                _ ->
                    0

        newPosition =
            position + delta |> modBy 4

        newPicIndex =
            if delta /= 0 then
                modBy 6 (data.picIndex + 1)

            else
                data.picIndex

        changeScene =
            case evt of
                KeyDown 13 ->
                    let
                        sceneName =
                            case newPosition of
                                0 ->
                                    "Level1"

                                1 ->
                                    "Level2"

                                2 ->
                                    "Game"

                                _ ->
                                    "Starting"

                        -- should be ending; not set yet.
                    in
                    [ Parent (SOMMsg (SOMChangeScene Nothing sceneName)) ]

                _ ->
                    []

        audioMessage =
            [ Parent (SOMMsg (SOMPlayAudio 1 "default" (ALoop Nothing Nothing))) ]
    in
    case env.globalData.sceneStartFrame of
        0 ->
            ( { data | position = newPosition, picIndex = newPicIndex }, [ Parent <| SOMMsg <| SOMStopAudio AllAudio ], ( env, True ) )

        1 ->
            ( { data | position = newPosition, picIndex = newPicIndex }, audioMessage, ( env, True ) )

        _ ->
            ( { data | position = newPosition, picIndex = newPicIndex }, changeScene, ( env, False ) )



--( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


viewCursor : Data -> Renderable
viewCursor data =
    textbox ( 320, 400 + 120 * data.position |> toFloat ) 80 data.text "consolas" Color.gray


viewTutor : List Renderable
viewTutor =
    [ textbox ( 960, 540 ) 40 "Press Up, Down to switch" "consolas" Color.blue
    , textbox ( 960, 600 ) 40 "Press Enter to start or quit" "consolas" Color.blue
    ]


view : LayerView SceneCommonData UserData Data
view env data =
    let
        pictures =
            REGL.BuiltinPrograms.centeredTexture ( 960, 540 )
                ( 1920, 1080 )
                0
                (case data.picIndex of
                    0 ->
                        "menu1"

                    1 ->
                        "menu2"

                    2 ->
                        "menu3"

                    3 ->
                        "menu4"

                    4 ->
                        "menu5"

                    5 ->
                        "menu6"

                    _ ->
                        "menu1"
                )
    in
    group []
        ([ pictures
         , viewBackground
         , viewCursor data
         ]
            ++ viewTutor
        )


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "A"


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
