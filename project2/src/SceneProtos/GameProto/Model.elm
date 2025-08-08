module SceneProtos.GameProto.Model exposing (genScene)

{-| Game Prototype Scene Configuration Module

This module manages the initialization and configuration of the game prototype scene.
It handles the setup of scene layers, common data, and component initialization.

@docs genScene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneLevelInit, LayeredSceneProtoInit, genLayeredScene, initCompose)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.GameProto.Init exposing (InitData)
import SceneProtos.GameProto.MainLayer.Model as MainLayer
import SceneProtos.GameProto.SceneBase exposing (..)


{-| Initializes the common data for the game scene.

This function creates the SceneCommonData structure that will be shared across all layers
of the game scene. It extracts initialization values from the provided data or uses defaults.

Parameters:

  - env - The environment containing UserData
  - data - Optional initialization data for the scene
      - If present, uses the level specified in the data
      - If absent, defaults to "Level1"

Returns a SceneCommonData record with:

  - level: The current game level identifier (e.g., "Level1", "Level2")
  - canGetKey: Whether the player can currently pick up keys (initially false)
  - skillPoints: The player's accumulated skill points (initially 0)

-}
commonDataInit : Env () UserData -> Maybe (InitData SceneMsg) -> SceneCommonData
commonDataInit _ data =
    let
        levelValue =
            case data of
                Just d ->
                    d.level

                Nothing ->
                    "Level1"
    in
    { level = levelValue
    , canGetKey = False
    , skillPoints = 0
    }


{-| Initializes the scene with common data and layers.
-}
init : LayeredSceneProtoInit SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg (InitData SceneMsg)
init env data =
    let
        cd =
            commonDataInit env data

        envcd =
            addCommonData cd env

        comps =
            List.map (\x -> x envcd)
                (case data of
                    Just d ->
                        d.objects

                    Nothing ->
                        []
                )
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ MainLayer.layer (MainInitData { components = comps }) envcd
        ]
    }


{-| Provides the scene's effect settings.

This function defines special effects or behaviors that should be applied to the scene.
Currently, it returns an empty list as the game prototype doesn't require any special
effect settings.

Parameters:

  - Three parameters that are not currently used by the implementation

Returns an empty list, indicating no special effect settings for this scene.

-}
settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
settings _ _ _ =
    []


{-| Scene generator for the game prototype.

This is the main entry point for creating a game prototype scene. It composes the scene
initialization with the provided initialization data and settings to generate a complete,
functional scene ready for rendering and interaction.

Parameters:

  - initd - The scene level initialization data containing level-specific parameters
      - Used to initialize the scene with correct level, components, and state

Returns a SceneStorage instance that contains the complete scene structure and behavior,
ready to be used by the game engine.

-}
genScene : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg) -> SceneStorage UserData SceneMsg
genScene initd =
    genLayeredScene (initCompose init initd) settings
