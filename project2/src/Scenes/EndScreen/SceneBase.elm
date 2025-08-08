module Scenes.EndScreen.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-| Scene base module for the EndScreen scene

This module defines the basic data types and message types used throughout the EndScreen scene.
It provides the foundation for layer communication and scene-wide data management for
screens that appear when the game ends (such as after player death).


# SceneBase

Basic data types for EndScreen scene communication and coordination.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}


{-| Layer target type

A string identifier used to target specific layers within the EndScreen scene.
This allows the scene system to route messages and updates to the correct layer.

Example:

  - "AfterDeath" -> targets the after-death layer shown when player dies
  - "Victory" -> targets a victory screen layer (if implemented)
  - "GameOver" -> targets a general game over layer (if implemented)

-}
type alias LayerTarget =
    String


{-| Common data shared across all layers in the EndScreen scene

Currently empty but can be extended to hold scene-wide state that all layers need access to.
This might include shared game over statistics, final scores, or cross-layer communication data.

Example:

    SceneCommonData {} -- Currently just an empty record

-}
type alias SceneCommonData =
    {}


{-| General message type for layer communication

Defines the message types that can be sent between layers within the EndScreen scene.

  - `NullLayerMsg` -- A placeholder message with no effect, used when no specific message is needed

-}
type LayerMsg
    = NullLayerMsg
