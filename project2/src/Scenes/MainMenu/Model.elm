module Scenes.MainMenu.Model exposing (scene)

{-| MainMenu scene configuration module.

This module defines and configures the MainMenu scene of the game.
It sets up the layered scene structure and initializes the Home layer.


# Scene

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneInit, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.MainMenu.Home.Model as Home
import Scenes.MainMenu.SceneBase exposing (..)


{-| Initializes the common data shared across all layers in the MainMenu scene.

This function is called when the scene is first created or when it receives a message.
Currently, it returns an empty record as no common data is needed.

-}
commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


{-| Initializes the MainMenu scene with its layers and settings.

This function sets up the initial state of the scene with:

  - Empty render settings (no special rendering configuration needed)
  - Common data initialized with commonDataInit
  - The Home layer as the only layer in the scene

The Home layer is initialized with a NullLayerMsg indicating no initial action is needed.

-}
init : LayeredSceneInit SceneCommonData UserData LayerTarget LayerMsg SceneMsg
init env msg =
    let
        cd =
            commonDataInit env msg

        envcd =
            addCommonData cd env
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ Home.layer NullLayerMsg envcd ]
    }


{-| Defines any special effects or behaviors for the MainMenu scene.

This function returns an empty list as the MainMenu scene doesn't require
any special effects or behaviors at the scene level.
Effects specific to individual layers would be defined within those layers.

-}
settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget LayerMsg SceneMsg
settings _ _ _ =
    []


{-| Scene generator for the MainMenu scene.

Creates and returns a complete scene for the main menu using the init function
for initialization and the settings function for any special effects.
This scene consists of the Home layer which displays the game's main menu interface.

-}
scene : SceneStorage UserData SceneMsg
scene =
    genLayeredScene init settings
