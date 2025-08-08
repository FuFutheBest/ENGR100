module SceneProtos.GameProto.Components.Mushrooms.Init exposing
    ( InitData
    , MushroomMsg(..)
    , mushroomConfig
    )

{-| Mushroom component initialization module.

This module defines the data types and configurations needed to initialize and operate
the mushroom component in the game. Mushrooms are interactive objects that can be consumed
by the player to produce special effects, like revealing ghosts or altering game mechanics.


# Types

@docs InitData
@docs MushroomMsg


# Configuration

@docs mushroomConfig

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize a mushroom component.

  - id - Unique identifier for the mushroom instance
  - position - Initial position vector of the mushroom in the game world

The position determines where the mushroom will appear in the game, and the id is used to
track and reference this specific mushroom instance.

Example:

    mushroomInitData =
        { id = 1
        , position = Vec.genVec 500 300 -- Places mushroom at x=500, y=300
        }

-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| Message types for mushroom component communication.

  - MushroomInitMsg - Initializes a new mushroom with the provided initialization data
  - NullMushroomMsg - A placeholder message that does not trigger any action

These messages facilitate communication between the mushroom component and other
components in the game system, particularly for initialization.

-}
type MushroomMsg
    = MushroomInitMsg InitData
    | NullMushroomMsg


{-| Configuration settings for mushroom components.

  - size - The default dimensions of the mushroom in the game world (width and height)

This configuration is used to define common properties that apply to all mushroom instances.
The size is used for rendering and collision detection with the player character.

-}
mushroomConfig : { size : Vec.Vec }
mushroomConfig =
    { size = Vec.genVec 50 50
    }
