module SceneProtos.GameProto.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-|


# SceneBase

Basic data for the scene.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}

import SceneProtos.GameProto.MainLayer.Init as MainInit


{-| Layer target type
-}
type alias LayerTarget =
    String


{-| Common data
-}
type alias SceneCommonData =
    { level : String
    , canGetKey : Bool
    , skillPoints : Int
    }


{-| General message for layers
-}
type LayerMsg scenemsg
    = MainInitData (MainInit.InitData SceneCommonData scenemsg)
    | NullLayerMsg
