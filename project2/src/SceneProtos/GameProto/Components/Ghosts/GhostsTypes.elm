module SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing
    ( Data, GType(..), DashingState(..), LobberBullet, SkillTree
    , defaultSkillTree, emptyData
    , generateSeed, randomDirectionGenerator, randomProbabilityGenerator
    )

{-| Ghost data types and utility functions.

This module defines the core data structures for ghost entities and provides
utility functions for random generation and default value creation.


# Core Data Types

@docs Data, GType, DashingState, LobberBullet, SkillTree


# Default Values

@docs defaultSkillTree, emptyData


# Random Utility Functions

@docs generateSeed, randomDirectionGenerator, randomProbabilityGenerator

-}

import Lib.Utils.Anim as Anim
import Lib.Utils.Vec as Vec
import Random
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit


{-| Main data structure for a ghost entity.

  - `gtype` - Ghost type (Normal, Dashing, or Lobber)
  - `velocity` - Current movement velocity vector
  - `state` - Visibility state (Invisible or Visible)
  - `anim` - Current animation state
  - `healthPoint` - Current health points remaining
  - `lastHitCharacterTime` - Timestamp when ghost last hit the character
  - `skillTree` - Ghost's skill tree configuration
  - `mushroomConsumed` - Whether ghost is affected by mushroom consumption

-}
type alias Data =
    { gtype : GType
    , velocity : Vec.Vec
    , state : GhostsInit.GhostState
    , anim : Anim.Loop
    , healthPoint : Int
    , lastHitCharacterTime : Float
    , skillTree : SkillTree
    , mushroomConsumed : Bool
    }


{-| Represents different types of ghosts and their specific states.

  - `NormalGhost Int` - A standard ghost with an attack frame counter
  - `DashingGhost DashingState` - A dashing ghost with its specific dashing behavior state
  - `LobberGhost Int Float (Maybe (List LobberBullet))` - A lobber ghost that can throw projectiles
    (attack counter, last emit time, optional bullet list)

-}
type GType
    = NormalGhost Int
    | DashingGhost DashingState
    | LobberGhost Int Float (Maybe (List LobberBullet))


{-| Represents the different states of a dashing ghost's behavior.

  - `None Int Float` - Not dashing (attack counter, last update time)
  - `Accumulating Float` - Building up charge for a dash (charge start time)
  - `Attacking Bool Int` - Currently attacking (is attacking flag, attack frame count)

-}
type DashingState
    = None Int Float
    | Accumulating Float
    | Attacking Bool Int


{-| Represents a projectile bullet fired by a lobber ghost.

  - `position` - Current position of the bullet in the game world
  - `size` - Dimensions of the bullet's collision box
  - `velocity` - Movement velocity vector of the bullet
  - `lastUpdateTime` - Timestamp of when the bullet was last updated

-}
type alias LobberBullet =
    { position : Vec.Vec
    , size : Vec.Vec
    , velocity : Vec.Vec
    , lastUpdateTime : Float
    , anim : Anim.Loop
    }


{-| Configuration for ghost skill abilities and behavior modifiers.

  - `desensitivity` - Reduced sensitivity to character detection (0.0 = normal, higher = less sensitive)
  - `emitLevel` - Level of projectile emission capability for lobber ghosts
  - `lastEmitTime` - Timestamp when the ghost last emitted a projectile

-}
type alias SkillTree =
    { desensitivity : Float
    , emitLevel : Int
    , lastEmitTime : Float
    }


{-| Creates a default skill tree configuration with standard values.

Returns a SkillTree with zero desensitivity, no emission level, and no previous emit time.

-}
defaultSkillTree : SkillTree
defaultSkillTree =
    { desensitivity = 0.0
    , emitLevel = 0
    , lastEmitTime = 0.0
    }


{-| Creates an empty ghost data structure with default values.

Returns a Data record initialized with a normal ghost type, zero velocity,
invisible state, default animation, zero health, and default skill tree.

-}
emptyData : Data
emptyData =
    { gtype = NormalGhost 0
    , velocity = Vec.genVec 0 0
    , state = GhostsInit.Invisible
    , anim = Anim.Loop "normal" 3 0.3 0 0
    , healthPoint = 0
    , lastHitCharacterTime = 0.0
    , skillTree = defaultSkillTree
    , mushroomConsumed = False
    }


{-| Generates a random seed from a float value.

Converts a float timestamp or value into a Random.Seed for use with
random number generation functions.

-}
generateSeed : Float -> Random.Seed
generateSeed seedFloat =
    Random.initialSeed (round seedFloat)


{-| Generates a random unit direction vector.

Takes a seed float and returns a normalized vector pointing in a random direction.
Useful for creating random movement patterns for ghosts.

-}
randomDirectionGenerator : Float -> Vec.Vec
randomDirectionGenerator seedFloat =
    let
        seed =
            generateSeed seedFloat

        ( randomAngle, _ ) =
            Random.step (Random.float 0 (2 * pi)) seed
    in
    Vec.genVec (cos randomAngle) (sin randomAngle)


{-| Generates a random boolean based on probability.

Takes a seed float and probability percentage (0-100), returns True if
the random value falls within the probability range.

-}
randomProbabilityGenerator : Float -> Int -> Bool
randomProbabilityGenerator seedFloat p =
    let
        seed =
            generateSeed seedFloat

        ( randomVal, _ ) =
            Random.step (Random.int 0 100) seed
    in
    randomVal <= p
