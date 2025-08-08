module SceneProtos.GameProto.Components.Door.Init exposing
    ( InitData
    , DoorMsg(..)
    , doorConfig
    )

{-| Door component initialization module.

This module defines the data types and configurations needed to initialize and operate the door component
in the game. Doors are interactive objects that allow the character to progress between different levels.


# Types

@docs InitData
@docs DoorMsg


# Configuration

@docs doorConfig

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize a door component.

  - id - Unique identifier for the door instance
  - position - Initial position vector of the door in the game world

The position determines where the door will appear in the game, and the id is used to
track and reference this specific door instance.

Example:

    doorInitData =
        { id = 1
        , position = Vec.genVec 500 300 -- Places door at x=500, y=300
        }

-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| Message types for door component communication.

  - DoorInitMsg - Initializes a new door with the provided initialization data
  - NullDoorMsg - A placeholder message that does not trigger any action

These messages facilitate communication between the door component and other
components in the game system, particularly for initialization and scene transitions.

-}
type DoorMsg
    = DoorInitMsg InitData
    | NullDoorMsg


{-| Configuration settings for door components.

  - size - The dimensions of the door in the game world (width and height)

This configuration is used to define common properties that apply to all door instances.
The size is used for rendering and collision detection with the player character.

-}
doorConfig : { size : Vec.Vec }
doorConfig =
    { size = Vec.genVec 180 80
    }
