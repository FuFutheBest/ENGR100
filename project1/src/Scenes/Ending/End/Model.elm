module Scenes.Ending.End.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.GeneralModel exposing (Matcher)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import REGL
import REGL.BuiltinPrograms exposing (centeredTexture, rectCentered, textboxCentered)
import REGL.Common exposing (Renderable, group)
import Scenes.Ending.SceneBase exposing (..)


type alias Data =
    {}


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    {}


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    group []
        [ centeredTexture ( 960, 540 ) ( 1920, 1080 ) 0 "result"
        , textboxCentered ( 960, 540 - 160 ) 40 "Citrus slowly wakes up from dreams." "consolas" Color.white
        , textboxCentered ( 960, 540 - 80 ) 40 "On the screen: \"Bug Fixed\" -- and peace within." "consolas" Color.white
        , textboxCentered ( 960, 540 ) 40 "Loops, conditions each is just another puzzle waiting to be solved." "consolas" Color.white
        , textboxCentered ( 960, 540 + 80 ) 40 "Citrus smiles, ready to face the coming challenge." "consolas" Color.white
        , textboxCentered ( 960, 540 + 160 ) 80 "The end." "consolas" Color.lightOrange
        ]


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "End"


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
