module SceneProtos.GameProto.Components.Chest.Init exposing
    ( InitData
    , ChestMsg(..)
    , chestConfig
    )

{-| Initialization module for the Chest component.

This module provides the necessary types and configurations for initializing chest objects
in the game. Chests can be interacted with by the player to gain skill points.


# Init Data

@docs InitData


# Messages

@docs ChestMsg


# Configuration

@docs chestConfig

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize a chest component.

  - `id` - Unique identifier for the chest instance
  - `position` - Position vector of the chest in the game world

-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| Messages that can be sent to the Chest component.

  - `ChestInitMsg` - Initializes a chest with the given initialization data
  - `NullKeyMsg` - Placeholder message that performs no action (used as a default)

-}
type ChestMsg
    = ChestInitMsg InitData
    | ToCharacterMsg Vec.Vec -- the position of the chest
    | NullKeyMsg


{-| Configuration settings for chest objects.

  - `size` - Dimensions of the chest in pixels (width and height)

-}
chestConfig : { size : Vec.Vec }
chestConfig =
    { size = Vec.genVec 60 60
    }
