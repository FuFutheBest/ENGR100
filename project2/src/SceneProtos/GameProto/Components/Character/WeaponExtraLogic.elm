module SceneProtos.GameProto.Components.Character.WeaponExtraLogic exposing
    ( cannonStartCharge, updateCannonCharge, stopCannonCharge, updateCannonProjectile
    , renderFan, renderCannon
    )

{-| Character weapon extra logic module.

This module provides specialized weapon mechanics and logic that extend the basic weapon
functionality. It handles advanced weapon behaviors including cannon charging mechanics,
projectile movement, and weapon state transitions.

The module provides:

  - Cannon charging and firing mechanics with variable charge levels
  - Projectile physics and movement calculations
  - Weapon state management during different phases of operation
  - Advanced weapon upgrade and configuration systems


# Cannon Mechanics

@docs cannonStartCharge, updateCannonCharge, stopCannonCharge, updateCannonProjectile


# Rendering Related

@docs renderFan, renderCannon

-}

import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.GameProto.Components.Character.Weapon as Weapon exposing (..)


{-| Start charging a cannon weapon at the specified position and direction.

Creates a new cannon ball in charging state with initial parameters based on character
position and mouse position. If weapon is already a cannon, preserves any existing
fired cannon balls while adding the new charging one.

-}
cannonStartCharge : Weapon.Weapon -> Vec.Vec -> ( Float, Float ) -> Float -> Weapon.Weapon
cannonStartCharge weapon characterPos mousePos currentTime =
    let
        newCannonBall =
            { startCoordinate = characterPos
            , direction = getDirection mousePos characterPos
            , size = Weapon.weaponConfig.cannonMinSize
            , velocity = Weapon.weaponConfig.cannonMinVelocity
            , state =
                Weapon.Charging
                    { chargeStartTime = currentTime
                    , chargeTime = 0.0
                    , chargeLevel = 0
                    }
                    Nothing
            , damage = Weapon.weaponConfig.minDamage
            , wearLevel = 1
            }

        defaultStart =
            Weapon.Cannon [ newCannonBall ]

        newWeapon =
            case weapon of
                Weapon.Cannon cannons ->
                    -- We are charging a new cannonball, keep any existing fired ones
                    let
                        firedCannons =
                            List.filter
                                (\c ->
                                    case c.state of
                                        Weapon.Firing _ ->
                                            True

                                        _ ->
                                            False
                                )
                                cannons
                    in
                    Weapon.Cannon (newCannonBall :: firedCannons)

                _ ->
                    defaultStart
    in
    newWeapon


{-| Update the cannon charge state based on character position and mouse input.
-}
updateCannonCharge :
    Weapon.Weapon
    -> Vec.Vec
    -> Float
    -> ( Float, Float )
    -> Weapon.Weapon
updateCannonCharge weapon characterPos dt mousePos =
    case weapon of
        Weapon.Cannon cannons ->
            let
                updateChargingCannon cannon =
                    case cannon.state of
                        Weapon.Charging chargeState _ ->
                            let
                                newPos =
                                    characterPos

                                newChargeTime =
                                    chargeState.chargeTime + dt

                                newChargeLevel =
                                    Weapon.calculateChargeLevel newChargeTime Weapon.weaponConfig.maxChargeTime

                                newVelocity =
                                    Weapon.weaponConfig.cannonMinVelocity + (newChargeLevel * (Weapon.weaponConfig.cannonMaxVelocity - Weapon.weaponConfig.cannonMinVelocity))

                                newSize =
                                    Weapon.weaponConfig.cannonMinSize + (newChargeLevel * (Weapon.weaponConfig.cannonMaxSize - Weapon.weaponConfig.cannonMinSize))

                                newDamage =
                                    Weapon.weaponConfig.minDamage + round (newChargeLevel * toFloat (Weapon.weaponConfig.maxDamage - Weapon.weaponConfig.minDamage))

                                newWearLevel =
                                    if newChargeLevel < 0.33 then
                                        1

                                    else if newChargeLevel < 0.66 then
                                        2

                                    else
                                        3

                                direction =
                                    getDirection mousePos newPos
                            in
                            -- Return updated charging cannon
                            { cannon
                                | velocity = newVelocity
                                , size = newSize
                                , direction = direction
                                , startCoordinate = newPos
                                , damage = newDamage
                                , wearLevel = newWearLevel
                                , state =
                                    Weapon.Charging
                                        { chargeState
                                            | chargeTime = newChargeTime
                                            , chargeLevel = newChargeLevel
                                        }
                                        Nothing
                            }

                        _ ->
                            -- For flying cannonballs, keep them as is
                            cannon

                chargingCannons =
                    List.filter
                        (\c ->
                            case c.state of
                                Weapon.Charging _ _ ->
                                    True

                                _ ->
                                    False
                        )
                        cannons

                updatedChargingCannons =
                    List.map updateChargingCannon chargingCannons
            in
            Weapon.Cannon updatedChargingCannons

        _ ->
            Weapon.Cannon []


{-| Stop charging a cannon weapon and transition to firing state.
-}
stopCannonCharge : Weapon.Weapon -> Float -> Weapon.Weapon
stopCannonCharge weapon currentTime =
    case weapon of
        Weapon.Cannon cannons ->
            let
                updateCannonState cannon =
                    case cannon.state of
                        Weapon.Charging _ _ ->
                            { cannon | state = Weapon.Firing currentTime }

                        _ ->
                            cannon

                updatedCannons =
                    List.map updateCannonState cannons
            in
            Weapon.Cannon updatedCannons

        _ ->
            Weapon.Cannon []


{-| Update the position and state of cannon projectiles based on elapsed time.
-}
updateCannonProjectile : Weapon.Weapon -> Float -> Float -> Weapon.Weapon
updateCannonProjectile weapon currentTime dt =
    case weapon of
        Weapon.Cannon cannons ->
            let
                updateProjectile cannon =
                    case cannon.state of
                        Weapon.Firing firedAt ->
                            let
                                elapsedTime =
                                    currentTime - firedAt

                                deltaTime =
                                    dt

                                movement =
                                    Vec.scale (cannon.velocity * deltaTime) cannon.direction

                                newPos =
                                    Vec.add cannon.startCoordinate movement
                            in
                            if elapsedTime < Weapon.weaponConfig.cannonDuration && cannon.wearLevel > 0 then
                                Just { cannon | startCoordinate = newPos }

                            else
                                Nothing

                        _ ->
                            Just cannon

                updatedCannons =
                    List.filterMap updateProjectile cannons
            in
            Weapon.Cannon updatedCannons

        _ ->
            weapon


{-| Render the `LightBeamFan` into a polygon `Renderable`.
-}
renderFan : LightBeamFan -> Renderable
renderFan fan =
    let
        center =
            Vec.toTuple fan.startCoordinate

        startDir =
            Vec.normalize fan.startRayDir
                |> Vec.rotate (-fan.angle / 2)

        segments =
            20

        angleStep =
            fan.angle / toFloat segments

        edgePoints =
            List.range 0 segments
                |> List.map
                    (\i ->
                        let
                            angle =
                                toFloat i * angleStep

                            dir =
                                Vec.rotate angle startDir

                            point =
                                Vec.add fan.startCoordinate (Vec.scale fan.length dir)
                        in
                        Vec.toTuple point
                    )

        allPoints =
            center :: edgePoints
    in
    P.poly allPoints weaponConfig.fanColor


{-| Takes a `List` of `CannonBall` and the current time, and generates the correct frame of the animation.
-}
renderCannon : List CannonBall -> Float -> List Renderable
renderCannon cannons currentTime =
    List.concatMap (\cannon -> renderSingleCannon cannon currentTime) cannons
