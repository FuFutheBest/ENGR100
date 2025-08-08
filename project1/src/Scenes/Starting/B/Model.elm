module Scenes.Starting.B.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color exposing (Color(..))
import Lib.Base exposing (SceneMsg)
import Lib.Resources exposing (resources)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms exposing (centeredTexture, rectCentered, textbox)
import REGL.Common exposing (Effect, group)
import REGL.Effects as E
import Scenes.Starting.SceneBase exposing (..)


type alias Data =
    { initTime : Float -- time stamp
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { initTime = env.globalData.currentTimeStamp
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    if env.globalData.currentTimeStamp - data.initTime > 8000.0 || evt == KeyDown 13 then
        let
            changeScene =
                [ Parent (SOMMsg (SOMChangeScene Nothing "Script")) ]

            -- change scene to "Home"
        in
        ( data, changeScene, ( env, False ) )

    else
        ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )



-- fade-in, fade-out effect


calcEffect : Float -> List Effect
calcEffect d =
    if d < 2000.0 then
        E.gblur (2 - d / 1000)
        -- fade in

    else if d < 5000.0 then
        []

    else if d < 6999.9 then
        [ 0.5 * (7 - d / 1000) |> E.alphamult ]
        -- fade out

    else
        [ E.alphamult 0 ]


view : LayerView SceneCommonData UserData Data
view env data =
    let
        curTime =
            env.globalData.currentTimeStamp

        delta =
            curTime - data.initTime

        effect =
            calcEffect delta
    in
    group (E.gblur 0)
        [ --textbox ( 0, 0 ) 50 (String.fromFloat curTime) "consolas" Color.green
          --,
          rectCentered ( 960, 540 ) ( 1920, 1080 ) 0.0 Color.black -- black background
        , group effect
            [ centeredTexture ( 960, 540 ) ( 990, 550 ) 0 "logo3" -- team logo
            ]
        ]


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "B"


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
