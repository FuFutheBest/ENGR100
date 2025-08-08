module Scenes.Intro.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-| Scene base module for the Intro scene

This module defines the basic data types and message types used throughout the Intro scene.
It provides the foundation for layer communication and scene-wide data management.


# SceneBase

Basic data types for scene communication and coordination.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}


{-| Layer target type

A string identifier used to target specific layers within the Intro scene.
This allows the scene system to route messages and updates to the correct layer.

Example:

  - "Storymode" -> targets the storymode layer
  - "Menu" -> targets a menu layer (if present)

-}
type alias LayerTarget =
    String


{-| Common data shared across all layers in the Intro scene

Currently empty but can be extended to hold scene-wide state that all layers need access to.
This might include shared animation states, global scene flags, or cross-layer communication data.

Example:

    SceneCommonData {} -- Currently just an empty record

-}
type alias SceneCommonData =
    {}


{-| General message type for layer communication

Defines the message types that can be sent between layers within the Intro scene.

  - `NullLayerMsg` -- A placeholder message with no effect, used when no specific message is needed

-}
type LayerMsg
    = NullLayerMsg
