module SceneProtos.GameProto.Components.Key.Init exposing
    ( InitData
    , KeyMsg(..)
    , keyConfig
    )

{-| Key component initialization module.

This module defines the data types and configurations needed to initialize and operate the key component
in the game. Keys are collectible objects that can be picked up by the character.


# Types

@docs InitData
@docs KeyMsg


# Configuration

@docs keyConfig

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize a key component.

  - id - Unique identifier for the key instance
  - position - Initial position vector of the key in the game world

The position determines where the key will appear in the game, and the id is used to
track and reference this specific key instance.

Example:

    keyInitData =
        { id = 1
        , position = Vec.genVec 500 300 -- Places key at x=500, y=300
        }

-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| Message types for key component communication.

  - KeyInitMsg - Initializes a new key with the provided initialization data
  - ToCharacterMsg - Notifies the character that a key is available at the specified position
  - NullKeyMsg - A placeholder message that does not trigger any action

These messages facilitate communication between the key component and other
components in the game system, particularly the character component.

-}
type KeyMsg
    = KeyInitMsg InitData
    | ToCharacterMsg Vec.Vec -- the position of the key
    | NullKeyMsg


{-| Configuration settings for key components.

  - size - The dimensions of the key in the game world (width and height)

This configuration is used to define common properties that apply to all key instances.
The size is used for rendering and collision detection.

-}
keyConfig : { size : Vec.Vec }
keyConfig =
    { size = Vec.genVec 60 60
    }
