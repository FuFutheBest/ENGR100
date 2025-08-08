module SceneProtos.GameProto.Components.Character.Weapon exposing
    ( Weapon(..), LightBeamFan, CannonBall, CannonState(..), ChargeState
    , createFan, renderSingleCannon, renderCannonChargePreview
    , calculateChargeLevel, getDirection, switchWeapon
    , weaponConfig
    )

{-| Weapon system module for character combat.

This module defines the weapon types, states, and functionality available to the character
including fan light beams and cannon projectiles. It handles weapon rendering, charging
mechanics, projectile physics, and weapon switching functionality.

The weapon system supports:

  - Fan weapons with light beam effects for area damage
  - Cannon weapons with charging mechanics and projectile physics
  - Weapon configuration settings for damage, speed, and visual effects
  - Rendering functions for all weapon types and charge previews


# Weapon Types

@docs Weapon, LightBeamFan, CannonBall, CannonState, ChargeState


# Weapon Functions

@docs createFan, renderSingleCannon, renderCannonChargePreview
@docs calculateChargeLevel, getDirection, switchWeapon


# Configuration

@docs weaponConfig

-}

import Color
import Lib.Utils.Vec as Vec
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)


{-| Main weapon union type representing different weapon types.

  - `Fan (Maybe LightBeamFan)` - Fan weapon that shoots light beams in a cone pattern. The Maybe type indicates whether the fan is currently active (Just LightBeamFan) or inactive (Nothing)
  - `Cannon (List CannonBall)` - Cannon weapon that fires projectiles. The list contains all active cannon balls currently in flight

-}
type Weapon
    = Fan (Maybe LightBeamFan)
    | Cannon (List CannonBall)


{-| Light beam fan weapon data structure.

  - `startCoordinate` - Origin point where the fan beam starts (character position)
  - `startRayDir` - Direction vector indicating where the fan is aimed
  - `angle` - Angular spread of the fan beam in radians (wider angle = larger cone)
  - `length` - Maximum range of the fan beam in pixels

-}
type alias LightBeamFan =
    { startCoordinate : Vec.Vec
    , startRayDir : Vec.Vec
    , angle : Float
    , length : Float
    }


{-| Cannon ball projectile data structure.

  - `startCoordinate` - Initial firing position of the cannon ball
  - `direction` - Movement direction vector (normalized)
  - `size` - Visual and collision size of the projectile
  - `velocity` - Speed of movement in pixels per second
  - `state` - Current cannon state (charging, firing, or inactive)
  - `damage` - Amount of damage this projectile deals to targets
  - `wearLevel` - Durability level, decreases with use until cannon breaks

-}
type alias CannonBall =
    { startCoordinate : Vec.Vec
    , direction : Vec.Vec
    , size : Float
    , velocity : Float
    , state : CannonState
    , damage : Int
    , wearLevel : Int
    }


{-| Cannon state representing different phases of cannon operation.

  - `Charging ChargeState (Maybe CannonBall)` - Cannon is being charged up. Contains charge information and optionally a prepared cannon ball
  - `Firing Float` - Cannon ball has been fired. Float represents the timestamp when firing occurred
  - `None` - Cannon is inactive and ready to be used

-}
type CannonState
    = Charging ChargeState (Maybe CannonBall)
    | Firing Float -- Time when the cannon was fired
    | None


{-| Charge state data for cannon weapons during charging phase.

  - `chargeStartTime` - Timestamp when charging began
  - `chargeTime` - Duration the cannon has been charging
  - `chargeLevel` - Charge completion level from 0.0 (no charge) to 1.0 (fully charged)

-}
type alias ChargeState =
    { chargeStartTime : Float
    , chargeTime : Float
    , chargeLevel : Float
    }


{-| Weapon configuration constants defining behavior and appearance.

Contains all the configurable parameters for weapon systems including
mana costs, damage values, visual properties, and timing constraints.

-}
weaponConfig :
    { minManatoShoot : Float
    , fanLength : Float
    , fanAngle : Float
    , fanColor : Color.Color
    , fanConsumeManaRate : Float
    , cannonMinSize : Float
    , cannonMaxSize : Float
    , cannonMinVelocity : Float
    , cannonMaxVelocity : Float
    , maxChargeTime : Float
    , cooldown : Float
    , cannonDuration : Float
    , maxDamage : Int
    , minDamage : Int
    , cannonChargeManaRate : Float
    , defaultminManaCost : Float
    }
weaponConfig =
    { minManatoShoot = 10.0

    -- fan configuration
    , fanLength = 400
    , fanAngle = 1
    , fanColor = Color.rgba 1 0.9 0 0.2
    , fanConsumeManaRate = 10.0

    -- cannon configuration
    , cannonMinSize = 20
    , cannonMaxSize = 60
    , cannonMinVelocity = 700
    , cannonMaxVelocity = 1400
    , maxChargeTime = 2.0
    , cooldown = 0.2
    , cannonDuration = 3.0
    , maxDamage = 10
    , minDamage = 1
    , cannonChargeManaRate = 8.0
    , defaultminManaCost = 5.0
    }


{-| Creates a `LightBeamFan` type when given the current position and orientation of the player.
-}
createFan : Vec.Vec -> Vec.Vec -> LightBeamFan
createFan position direction =
    { startCoordinate = position
    , startRayDir = Vec.normalize direction
    , angle = weaponConfig.fanAngle
    , length = weaponConfig.fanLength
    }


{-| Takes a `CannonBall` and the current time, and generates the correct frame of the animation.
-}
renderSingleCannon : CannonBall -> Float -> List Renderable
renderSingleCannon cannon currentTime =
    let
        center =
            Vec.toTuple cannon.startCoordinate

        size =
            cannon.size * 4

        duration =
            case cannon.state of
                Firing firedAt ->
                    currentTime - firedAt

                _ ->
                    0

        renderSize =
            size

        size2 =
            renderSize + 8 * sin (duration * 28 * 2)

        size1 =
            renderSize + 60 * sin ((duration + 1) * 12 * 2)

        size0 =
            renderSize + 30 + 70 * sin ((duration + 2) * 16 * 2)
    in
    [ P.centeredTexture center ( size2, size2 ) 0 "charge2"
    , P.centeredTexture center ( size1, size1 ) 0 "charge1"
    , P.centeredTexture center ( size0, size0 ) 0 "charge0"
    ]


{-| Takes the position and the orientation of the player, plus the chargeTime, and render the correct cannon charge frame.
-}
renderCannonChargePreview : Vec.Vec -> Vec.Vec -> Float -> List Renderable
renderCannonChargePreview position direction chargeTime =
    let
        maxChargeTime =
            weaponConfig.maxChargeTime

        chargeLevel =
            min 1.0 (chargeTime / maxChargeTime)

        chargePos =
            Vec.add position (Vec.scale 30 direction) |> Vec.toTuple

        chargeSize =
            0.4 + chargeLevel * 3

        renderSize =
            50 * chargeSize

        size2 =
            renderSize + 40 * sin (chargeTime * 4 * 2)

        size1 =
            renderSize + 60 * sin ((chargeTime + 1) * 12 * 2)

        size0 =
            renderSize + 30 + 70 * sin ((chargeTime + 2) * 16 * 2)
    in
    [ P.centeredTexture chargePos ( size2, size2 ) 0 "charge2"
    , P.centeredTexture chargePos ( size1, size1 ) 0 "charge1"
    , P.centeredTexture chargePos ( size0, size0 ) 0 "charge0"
    ]


{-| Takes the current charge time and the maximum charge time possible, and linearly maps that
information into the charge level indicated by a `Float`.
-}
calculateChargeLevel : Float -> Float -> Float
calculateChargeLevel chargeTime maxChargeTime =
    min 1.0 (chargeTime / maxChargeTime)


{-| Takes the current position of the mouse, and calculate the corresponding orientation of the player.
-}
getDirection : ( Float, Float ) -> Vec.Vec -> Vec.Vec
getDirection ( mouseX, mouseY ) coordinate =
    let
        mousePos =
            Vec.genVec mouseX mouseY

        direction =
            Vec.normalize (Vec.subtract mousePos coordinate)
    in
    direction


{-| Takes a `Weapon` type, and switch it to the other `Weapon` type.
-}
switchWeapon : Weapon -> Weapon
switchWeapon weaponType =
    case weaponType of
        Fan _ ->
            Cannon []

        Cannon _ ->
            Fan Nothing
