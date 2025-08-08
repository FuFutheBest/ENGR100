module SceneProtos.GameProto.Components.Character.Buff exposing
    ( Data, SkillTree, InteractState(..), InteractResult(..)
    , Buff, BuffInfluenced
    , defaultSkillTree, emptyData
    , updateBuffs, applyBuff, applyBuffs
    )

{-| Character data types and buff system.

This module defines the main character data model and buff/debuff system
that can temporarily modify character properties like speed and other attributes.


# Core Data Types

@docs Data, SkillTree, InteractState, InteractResult


# Buff System

@docs Buff, BuffInfluenced


# Default Values

@docs defaultSkillTree, emptyData


# Buff Management

@docs updateBuffs, applyBuff, applyBuffs

-}

import Lib.Utils.Anim as Anim
import Lib.Utils.Spring as Spring
import Lib.Utils.Vec as Vec
import SceneProtos.GameProto.Components.Character.Weapon as Weapon


{-| Main character data model containing all character state and properties.

This record represents the complete state of a game character including movement,
combat, interaction capabilities, and buff system integration.

  - `speed`: Current movement speed of the character (affected by buffs)
  - `anim`: Animation loop state for character rendering
  - `weapon`: Currently equipped weapon and its state
  - `healthPoint`: Current health points (integer value)
  - `manaPoint`: Current mana/magic points (float for precision)
  - `buffs`: Tuple containing active buffs and original unbuffed stats
  - `cameraSpring`: Spring system for smooth camera following
  - `hasKey`: Current interaction state with objects like doors
  - `skillTree`: Character's skill progression and unlocked abilities
  - `mushroomConsumed`: Boolean flag indicating if a special mushroom has been consumed

-}
type alias Data =
    { speed : Float
    , anim : Anim.Loop
    , weapon : Weapon.Weapon
    , healthPoint : Int
    , manaPoint : Float
    , buffs : ( List Buff, BuffInfluenced )
    , cameraSpring : Spring.Spring
    , hasKey : InteractState
    , skillTree : SkillTree
    , mushroomConsumed : Bool
    }


{-| Character skill progression system representing unlocked abilities and their levels.

This record tracks the character's developed skills and magical capabilities.

  - `resilience`: Damage reduction multiplier (0.0 = no reduction, 1.0 = 50% reduction, 2.0 = 66% reduction)
  - `regeneration`: Health regeneration rate per second (e.g., 0.5 means 0.5 HP recovered per second)
  - `desensitivity`: Reduced sensitivity to negative effects like poison or debuffs (0.0 = full effect, 1.0 = no effect)
  - `emitLevel`: Magic emission level determining spell power and mana efficiency (0 = basic, higher = more powerful)

Example:

    expertSkillTree =
        { resilience = 2.5 -- 71% damage reduction
        , regeneration = 1.2 -- Regenerates 1.2 HP per second
        , desensitivity = 0.8 -- 80% resistance to debuffs
        , emitLevel = 5 -- Master level magic
        }

-}
type alias SkillTree =
    { resilience : Float
    , regeneration : Float
    , desensitivity : Float
    , emitLevel : Int
    }


{-| Creates a default skill tree with base values for new characters.

All skills start at minimal levels representing an untrained character.

-}
defaultSkillTree : SkillTree
defaultSkillTree =
    { resilience = 0.0
    , regeneration = 0.0
    , desensitivity = 0.0
    , emitLevel = 0
    }


{-| Represents the current state of character interaction with game objects.

This type tracks whether the character is attempting to interact with objects
like doors, chests, or other interactive elements in the game world.

  - `NoneInteraction`: Character is not interacting with anything
  - `TryingInteracte`: Character is attempting to interact (e.g., trying to open a door)
  - `Result InteractResult`: Interaction completed with a specific result

Example usage:

    -- Character approaches a locked door
    characterData.hasKey == TryingInteracte

    -- After checking inventory, character has the key
    characterData.hasKey == Result HasKey

-}
type InteractState
    = NoneInteraction
    | TryingInteracte
    | Result InteractResult


{-| Represents the outcome of an interaction attempt.

This type specifies what happened when the character tried to interact with an object.

  - `HasKey`: Character possesses the required key or item to complete the interaction
  - `None`: Interaction failed or character lacks required items

Example:

    -- Character has the key to open a door
    interactionResult == HasKey

    -- Character doesn't have what's needed
    interactionResult == None

-}
type InteractResult
    = HasKey
    | None


{-| Represents a temporary effect (buff or debuff) applied to a character.

Buffs can enhance or diminish character properties for a limited duration.
This system allows for temporary power-ups, magical effects, or status ailments.

  - `tar`: Target property to modify (e.g., "speed", "damage", "health")
  - `per`: Percentage multiplier for the effect (1.0 = no change, 1.5 = 50% increase, 0.8 = 20% decrease)
  - `duration`: Remaining time in seconds before the buff expires

Example:

    speedBoost =
        { tar = "speed"
        , per = 1.5 -- 50% speed increase
        , duration = 10.0 -- Lasts for 10 seconds
        }

    poisonEffect =
        { tar = "health"
        , per = 0.95 -- 5% health drain
        , duration = 5.0 -- Poison lasts 5 seconds
        }

-}
type alias Buff =
    -- buff can be debuff or lifted buff
    { tar : String
    , per : Float
    , duration : Float
    }


{-| Stores the original character statistics before any buff modifications.

This record preserves the base character stats that are unaffected by temporary buffs,
allowing the system to correctly calculate and restore original values when buffs expire.

  - `speed`: The character's base movement speed without any buff modifications

Example:


    originalStats =
        { speed = 100.0 }

    -- Character's natural speed
    -- Even if buffs increase speed to 150.0, originalStats.speed remains 100.0

-}
type alias BuffInfluenced =
    -- record the origin data that doesn't influence by buffs
    { speed : Float }


{-| Creates a default character data record with initial values.
-}
emptyData : Data
emptyData =
    { speed = 0
    , anim = Anim.Loop "idle" 4 0.25 0 0
    , weapon = Weapon.Fan Nothing
    , healthPoint = 0
    , manaPoint = 0
    , buffs = ( [], { speed = 0 } )
    , cameraSpring = Spring.createSpring 2.0 0.8 (Vec.genVec 0 0) (Vec.genVec 0 0)
    , hasKey = NoneInteraction
    , skillTree = defaultSkillTree
    , mushroomConsumed = False
    }


{-| Updates a list of buffs by decreasing their duration and removing expired ones.

Takes a list of active buffs and a time delta, then:

1.  Reduces each buff's duration by the time delta
2.  Filters out buffs that have expired (duration <= 0)

Parameters:

  - `buffs`: List of currently active buffs
  - `dt`: Time delta in seconds since last update

Returns the updated list with only non-expired buffs.

-}
updateBuffs : List Buff -> Float -> List Buff
updateBuffs buffs dt =
    List.map (\buff -> { buff | duration = buff.duration - dt }) buffs
        |> List.filter (\buff -> buff.duration > 0)


{-| Applies a single buff effect to character data.

Modifies the specified character property based on the buff's target and percentage.
Currently supports speed modification, with extensibility for other properties.

Parameters:

  - `buff`: The buff to apply with target property and modification percentage
  - `data`: Character data to modify

Returns updated character data with the buff effect applied.

-}
applyBuff : Buff -> Data -> Data
applyBuff buff data =
    let
        ( _, originalData ) =
            data.buffs

        newSpeed =
            case buff.tar of
                "speed" ->
                    originalData.speed * buff.per

                _ ->
                    data.speed
    in
    { data | speed = newSpeed }


{-| Applies all buffs in a list to character data in sequence.

Resets the character to original unbuffed state, then applies each buff
in the provided list. This ensures consistent buff application regardless
of previous character state.

Returns character data with all buffs applied and the buff list updated.

-}
applyBuffs : Data -> List Buff -> Data
applyBuffs data buffs =
    let
        ( _, originalData ) =
            data.buffs

        resetData =
            { data | speed = originalData.speed, buffs = ( buffs, originalData ) }
    in
    List.foldl applyBuff resetData buffs
