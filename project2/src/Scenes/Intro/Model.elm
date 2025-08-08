module Scenes.Intro.Model exposing (scene)

{-| Intro scene configuration module

This module defines the main Intro scene which serves as the game's opening sequence.
The scene is implemented as a layered scene containing the Storymode layer which displays
the animated intro story with logos, house, phone call, and dialogue.

The Intro scene:

  - Initializes with empty common data
  - Contains a single Storymode layer for the animated sequence
  - Automatically transitions to MainMenu after story completion
  - Supports manual skip functionality via space key


# Scene Configuration

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneInit, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.Intro.SceneBase exposing (..)
import Scenes.Intro.Storymode.Model as Storymode


{-| Initialize common data for the Intro scene

Creates an empty SceneCommonData record since the Intro scene doesn't require
any shared state between layers.

Parameters:

  - env: Environment data (unused)
  - msg: Optional scene message (unused)

Returns:

  - SceneCommonData: Empty record for scene-wide data

-}
commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


{-| Initialize the layered scene structure

Sets up the Intro scene with its layers and configuration.
Creates the Storymode layer and configures the scene environment.

Parameters:

  - env: Environment data containing global state
  - msg: Optional initialization message

Returns:

  - LayeredScene configuration with:
      - renderSettings: Empty list (no special render settings)
      - commonData: Empty scene-wide data
      - layers: List containing the Storymode layer

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
        [ Storymode.layer NullLayerMsg envcd
        ]
    }


{-| Configure scene effect settings

Defines any special effects or settings for the Intro scene.
Currently returns an empty list as no special effects are needed.

Parameters:

  - All parameters unused as no effects are configured

Returns:

  - Empty list of effects

-}
settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget LayerMsg SceneMsg
settings _ _ _ =
    []


{-| Scene generator for the Intro scene

Creates the complete Intro scene by combining initialization and settings functions.
This scene handles the game's opening animated sequence and transitions to the main menu.

-}
scene : SceneStorage UserData SceneMsg
scene =
    genLayeredScene init settings
