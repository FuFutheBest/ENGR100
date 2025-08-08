module Scenes.MainMenu.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-| Module defining the basic types and data structures for the MainMenu scene.

This module contains the common data structures shared across all layers in the MainMenu scene.
It defines the messages that can be passed between layers and the common data structure.


# Type Definitions

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}


{-| Layer target type identifier.

This type defines a string identifier for targeting specific layers within the scene.
Each layer can be identified and addressed using this string.

-}
type alias LayerTarget =
    String


{-| Common data shared between all layers in the MainMenu scene.

This is an empty record as the MainMenu scene currently doesn't require
any shared data between its layers. If additional data needs to be shared
across layers in the future, it should be added here.

-}
type alias SceneCommonData =
    {}


{-| Message types that can be sent between layers in the MainMenu scene.

  - SceneTransMsg - Used to trigger a scene transition. The String parameter contains the target scene identifier.
  - NullLayerMsg - A placeholder message that doesn't trigger any action. Used when a message is required but no action should be taken.

-}
type LayerMsg
    = SceneTransMsg String
    | NullLayerMsg
