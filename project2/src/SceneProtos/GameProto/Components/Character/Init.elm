module SceneProtos.GameProto.Components.Character.Init exposing
    ( InitData, CharacterMsg(..)
    , characterConfig
    )

{-| Character initialization module.

This module defines the data structures and configuration needed to initialize
character entities in the game, including character messages and configuration.


# Data Types

@docs InitData, CharacterMsg


# Configuration

@docs characterConfig

-}

import Lib.Utils.Vec as Vec
import SceneProtos.GameProto.Components.Character.Weapon as Weapon


{-| Initialization data for creating a character component.

  - `id` - Unique identifier for the character instance
  - `position` - Starting position vector of the character in the game world

-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| Messages that can be sent to or from the Character component.

  - `CharacterInitMsg InitData` - Initializes a character with the given initialization data
  - `ToGhostsMsg Weapon.Weapon Vec.Vec` - Sends weapon and position information to ghosts
  - `ToBossMsg Weapon.Weapon Vec.Vec` - Sends weapon and position information to boss
  - `GotKeyMsg` - Character has obtained a key
  - `TryGetChestMsg Vec.Vec` - Character attempts to interact with chest at position
  - `ToDoorMsg Vec.Vec` - Character attempts to interact with door at position
  - `ToggleMushroomEffectMsg` - Toggles mushroom consumption state for character
  - `CharacterDeathMsg` - Triggered when character dies
  - `ToGhostSkillTreeMsg Int` - Sends skill tree upgrade option to ghosts
  - `NullCharacterMsg` - Placeholder message that performs no action

-}
type CharacterMsg
    = CharacterInitMsg InitData
    | ToGhostsMsg Weapon.Weapon Vec.Vec -- the position of the character
    | ToBossMsg Weapon.Weapon Vec.Vec -- the position of the character
    | GotKeyMsg
    | TryGetChestMsg Vec.Vec -- the position of character
    | ToDoorMsg Vec.Vec -- the position of character
    | ToggleMushroomEffectMsg -- toggle mushroom consumed state
    | CharacterDeathMsg -- trigger when character dies
    | ToGhostSkillTreeMsg Int -- options
    | ShakeMsg Float -- intensity
    | NullCharacterMsg


{-| Configuration settings for character behavior and properties.

  - `defaultSpeed` - Base movement speed in pixels per second (300)
  - `size` - Character's collision box size for gameplay mechanics (50x64 pixels)
  - `renderSize` - Character's visual rendering size on screen (128x128 pixels)
  - `maxHealth` - Maximum health points the character can have (100)
  - `maxMana` - Maximum mana points for using abilities (100)
  - `manaRegenRate` - Rate of mana regeneration per second (2.0 points/second)
  - `mushroomConsumed` - Default mushroom consumption state (False)

-}
characterConfig :
    { defaultSpeed : Float
    , size : Vec.Vec
    , renderSize : Vec.Vec
    , maxHealth : Int
    , maxMana : Float
    , manaRegenRate : Float
    , mushroomConsumed : Bool
    }
characterConfig =
    { defaultSpeed = 300
    , size = Vec.genVec 50 64
    , renderSize = Vec.genVec 128 128
    , maxHealth = 100
    , maxMana = 100.0
    , manaRegenRate = 4.0
    , mushroomConsumed = False
    }
