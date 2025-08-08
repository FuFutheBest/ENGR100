module SceneProtos.GameProto.Components.Ghosts.Init exposing
    ( InitData
    , GhostState(..)
    , GhostsMsg(..)
    , ghostsConfig
    )

{-| Initialization module for ghost components.

This module provides types, messages, and configuration for ghost entities in the game.


# Init Data

@docs InitData


# Ghost States

@docs GhostState


# Messages

@docs GhostsMsg


# Configuration

@docs ghostsConfig

-}

import Lib.Utils.Vec as Vec


{-| Data used to initialize a ghost component.

  - `id` - Unique identifier for the ghost instance
  - `gtype` - Ghost type indicator (0=Normal, 1=Dashing, 2=Lobber)
  - `position` - Starting position vector of the ghost in the game world

```elm
-- Example: Creating a dashing ghost at position (100, 200) with ID 42
initData =
    { id = 42, gtype = 1, position = Vec.genVec 100 200 }
```

-}
type alias InitData =
    { id : Int
    , gtype : Int

    {- Ghost Type
       0: Normal Ghost
       1: Dashing Ghost
       2: Lobber Ghost
    -}
    , position : Vec.Vec
    }


{-| Represents the visibility state of a ghost.

  - `Invisible` - Ghost is currently invisible to the player
  - `Visible Float Bool` - Ghost is visible, with parameters:
      - Float: The time (in seconds) when the ghost became visible
      - Bool: Whether the ghost has been attacked during this visible period

-}
type GhostState
    = Invisible
    | Visible Float Bool -- The visble start time in seconds && is the ghost Attacked this shoot


{-| Messages that can be sent to the Ghost component.

  - `GhostInitMsg` - Initializes a ghost with the given initialization data
  - `AttackCharacterMsg` - Ghost attacks the character, dealing specified damage (Int: damage amount)
  - `CharacterSlowDownMsg` - Applies a slow effect to the character (Float: damage, Float: duration in seconds)
  - `ToggleMushroomEffectMsg` - Toggles whether the ghost is affected by mushroom consumption
  - `HitByCannonMsg` - Ghost is hit by a cannon shot (Int: cannon ID, Int: ghost ID)
  - `NullGhostMsg` - Placeholder message that performs no action

-}
type GhostsMsg
    = GhostInitMsg InitData
    | AttackCharacterMsg Int -- damge to the character
    | CharacterSlowDownMsg Float Float -- the damage and the duration of the slowdown effect
    | ToggleMushroomEffectMsg -- toggle mushroom consumed state
    | HitByCannonMsg Int Int -- cannonId and ghost ID
    | NullGhostMsg


{-| Configuration settings for all ghost types.

This record contains configuration for:

  - `common` - Settings shared by all ghost types:
      - `defaultSize` - Default size vector for ghost rendering (96x96 pixels)
      - `speed` - Base movement speed in pixels per second (50)
      - `visibleDuration` - How long ghost stays visible after being seen (10.0 seconds)
      - `defaultHealthPoint` - Starting health points for all ghosts (10)
      - `mushroomConsumed` - Whether ghost is affected by mushroom power-ups (False by default)
  - `normal` - Settings specific to normal ghosts:
      - `normalAttackDistance` - Maximum distance to attack character (300.0 pixels)
      - `normalAttackDamage` - Damage dealt to character per attack (7 points)
      - `durationafterAttack` - Cooldown time after attacking before next attack (10.0 seconds)
      - `attackFrames` - Number of frames in attack animation cycle (100 frames)
  - `dashing` - Settings specific to dashing ghosts:
      - `accumulatingTime` - Time to charge up before dash attack (3.0 seconds)
      - `dashingAttackDistance` - Maximum distance to trigger dash attack (300.0 pixels)
      - `dashingAttackDamage` - Damage dealt during dash attack (15 points)
      - `dashingSpeed` - Movement speed during dash attack (200 pixels/second)
      - `dashingCoolDown` - Cooldown time after dash attack (10.0 seconds)
  - `lobber` - Settings specific to lobber ghosts:
      - `lobberAttackDamage` - Damage per projectile hit (1 point)
      - `lobberAttackDistance` - Maximum distance to launch projectiles (300.0 pixels)
      - `lobberDeteckDistance` - Maximum distance to detect character (500.0 pixels)
      - `lobberBulletSize` - Size vector for projectile rendering (20x20 pixels)
      - `shootCooldown` - Time between projectile launches (3.0 seconds)
      - `assumeScreenHalfSize` - Boundary for valid projectile positions (2000 pixels from center)
      - `lobberBulletVelocity` - Speed of projectiles in pixels per second (300)
      - `lobberSlowDownDuration` - Duration of slow effect on character (1.0 second)
      - `lobberSlowDownPercent` - Percentage of speed reduction (0.5 = 50% slower)

-}
ghostsConfig :
    { common : { defaultSize : Vec.Vec, speed : Float, visibleDuration : Float, defaultHealthPoint : Int, mushroomConsumed : Bool }
    , normal : { normalAttackDistance : Float, normalAttackDamage : Int, durationafterAttack : Float, attackFrames : Int }
    , dashing : { accumulatingTime : Float, dashingAttackDistance : Float, dashingAttackDamage : Int, dashingSpeed : Float, dashingCoolDown : Float }
    , lobber :
        { lobberAttackDamage : Int
        , lobberAttackDistance : Float
        , lobberDeteckDistance : Float
        , lobberBulletSize : Vec.Vec
        , shootCooldown : Float
        , assumeScreenHalfSize : Float
        , lobberBulletVelocity : Float
        , lobberSlowDownDuration : Float
        , lobberSlowDownPercent : Float
        }
    , monk : { maxHp : Int }
    }
ghostsConfig =
    let
        commonConfig =
            { defaultSize = Vec.genVec (32 * 3) (32 * 3)
            , speed = 100
            , visibleDuration = 10.0
            , defaultHealthPoint = 20
            , mushroomConsumed = False
            }

        normalConfig =
            { -- Normal Ghost Config
              normalAttackDistance = 300.0
            , normalAttackDamage = 7
            , durationafterAttack = 10.0 -- the time the ghost won't attack the character again after attacking
            , attackFrames = 100
            }

        dashingConfig =
            { -- Dashing Ghost Config
              accumulatingTime = 3.0
            , dashingAttackDistance = 300.0
            , dashingAttackDamage = 15
            , dashingSpeed = 300
            , dashingCoolDown = 10.0 -- the time the ghost won't dash again after dashing attacking
            }

        lobberConfig =
            { -- Lobber Ghost Config
              lobberAttackDamage = 1
            , lobberAttackDistance = 300.0
            , lobberDeteckDistance = 500.0
            , lobberBulletSize = Vec.genVec 20 20
            , shootCooldown = 1.5
            , assumeScreenHalfSize = 2000 -- which means assume the valid bullet position is within a rectangle with vertices at (-2000, -2000) and (2000, 2000)
            , lobberBulletVelocity = 300
            , lobberSlowDownDuration = 1.0
            , lobberSlowDownPercent = 0.5
            }

        monkCondig =
            { maxHp = 100 }
    in
    { common = commonConfig, normal = normalConfig, dashing = dashingConfig, lobber = lobberConfig, monk = monkCondig }
