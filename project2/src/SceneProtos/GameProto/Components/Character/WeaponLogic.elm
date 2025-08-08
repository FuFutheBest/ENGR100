module SceneProtos.GameProto.Components.Character.WeaponLogic exposing (updateWeapon, handleFanWeapon, handleCannonWeapon)

{-| Character weapon logic module.

This module handles the core weapon update logic including input processing,
mana consumption, and weapon state management. It serves as the main interface
for weapon updates and delegates to specialized logic for different weapon types.

The module provides:

  - Main weapon update coordination based on weapon type
  - Fan weapon firing and mana consumption logic
  - Cannon weapon charging, firing, and projectile management
  - Input event processing for weapon controls
  - Mana management for all weapon operations


# Core Weapon Logic

@docs updateWeapon, handleFanWeapon, handleCannonWeapon

-}

import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import SceneProtos.GameProto.Components.Character.Weapon as Weapon exposing (getDirection)
import SceneProtos.GameProto.Components.Character.WeaponExtraLogic exposing (..)
import Set


{-| Main weapon update function that handles all weapon types and input events.

Routes weapon updates to appropriate handlers based on weapon type, processes
user input events, and manages mana consumption for all weapon operations.
Returns updated weapon state and remaining mana after operations.

-}
updateWeapon :
    Vec.Vec
    -> Weapon.Weapon
    -> Set.Set Int
    -> ( Float, Float )
    -> UserEvent
    -> Float
    -> Float
    -> Float
    -> ( Weapon.Weapon, Float )
updateWeapon characterPos weapon mouseButtons mousePos evnt currentTime dt mana =
    case weapon of
        Weapon.Fan _ ->
            handleFanWeapon characterPos weapon mouseButtons mousePos dt mana

        Weapon.Cannon _ ->
            handleCannonWeapon characterPos weapon evnt mousePos currentTime dt mana


{-| Handles the fan weapon logic including firing, mana consumption, and state management.
-}
handleFanWeapon :
    Vec.Vec
    -> Weapon.Weapon
    -> Set.Set Int
    -> ( Float, Float )
    -> Float
    -> Float
    -> ( Weapon.Weapon, Float )
handleFanWeapon characterPos weapon mouseButtons mousePos dt mana =
    let
        direction =
            getDirection mousePos characterPos

        isMousePressed =
            Set.member 0 mouseButtons

        hasEnoughMana =
            mana >= Weapon.weaponConfig.minManatoShoot

        hasAnyMana =
            mana > 0
    in
    case weapon of
        Weapon.Fan (Just fan) ->
            if isMousePressed && hasAnyMana then
                -- Continue firing only if we have mana
                let
                    updatedFan =
                        { fan | startRayDir = direction, startCoordinate = characterPos }

                    consumedMana =
                        max 0 (mana - Weapon.weaponConfig.fanConsumeManaRate * dt)
                in
                if consumedMana <= 0 then
                    ( Weapon.Fan Nothing, 0 )

                else
                    ( Weapon.Fan (Just updatedFan), consumedMana )

            else
                -- Stop firing - either no mouse press or no mana
                ( Weapon.Fan Nothing, mana )

        Weapon.Fan Nothing ->
            if isMousePressed && hasEnoughMana then
                -- Create new fan only if we have sufficient mana
                let
                    newFan =
                        Weapon.createFan characterPos direction
                in
                ( Weapon.Fan (Just newFan), mana )

            else
                ( Weapon.Fan Nothing, mana )

        _ ->
            if isMousePressed && hasEnoughMana then
                let
                    newFan =
                        Weapon.createFan characterPos direction
                in
                ( Weapon.Fan (Just newFan), mana )

            else
                ( weapon, mana )


{-| Handles the cannon weapon logic including charging, firing, and projectile management.
-}
handleCannonWeapon :
    Vec.Vec
    -> Weapon.Weapon
    -> UserEvent
    -> ( Float, Float )
    -> Float
    -> Float
    -> Float
    -> ( Weapon.Weapon, Float )
handleCannonWeapon characterPos weapon evnt mousePos currentTime _ mana =
    case evnt of
        MouseDown 0 _ ->
            -- Start charging the cannon only if we have enough mana
            if mana >= Weapon.weaponConfig.minManatoShoot then
                ( cannonStartCharge weapon characterPos mousePos currentTime, mana )

            else
                ( weapon, mana )

        MouseUp 0 _ ->
            -- Shoot the cannon
            ( stopCannonCharge weapon currentTime, mana - Weapon.weaponConfig.defaultminManaCost )

        Tick deltaTime ->
            let
                dSec =
                    deltaTime / 10 ^ 3
            in
            case weapon of
                Weapon.Cannon cannons ->
                    let
                        ( chargingCannons, firingCannons ) =
                            List.partition
                                (\c ->
                                    case c.state of
                                        Weapon.Charging _ _ ->
                                            True

                                        _ ->
                                            False
                                )
                                cannons
                    in
                    case List.head chargingCannons of
                        Just cannon ->
                            case cannon.state of
                                Weapon.Charging chargeState _ ->
                                    -- Update charge and consume mana if not at max level
                                    let
                                        isMaxCharge =
                                            chargeState.chargeLevel >= 1.0

                                        -- Only consume mana if not at max charge
                                        manaConsumption =
                                            if isMaxCharge then
                                                0

                                            else
                                                Weapon.weaponConfig.cannonChargeManaRate * dSec

                                        newMana =
                                            max 0 (mana - manaConsumption)

                                        updatedFiringCannons =
                                            if List.isEmpty firingCannons then
                                                []

                                            else
                                                case updateCannonProjectile (Weapon.Cannon firingCannons) currentTime dSec of
                                                    Weapon.Cannon updatedCannons ->
                                                        updatedCannons

                                                    _ ->
                                                        []

                                        updatedWeapon =
                                            if newMana <= 0 then
                                                Weapon.Cannon updatedFiringCannons

                                            else
                                                case updateCannonCharge (Weapon.Cannon chargingCannons) characterPos dSec mousePos of
                                                    Weapon.Cannon updatedChargingCannons ->
                                                        Weapon.Cannon (updatedChargingCannons ++ updatedFiringCannons)

                                                    _ ->
                                                        Weapon.Cannon updatedFiringCannons
                                    in
                                    ( updatedWeapon, newMana )

                                _ ->
                                    ( weapon, mana )

                        Nothing ->
                            if List.isEmpty firingCannons then
                                ( weapon, mana )

                            else
                                ( updateCannonProjectile weapon currentTime dSec, mana )

                _ ->
                    -- If no weapon matches, return unchanged
                    ( weapon, mana )

        _ ->
            ( weapon, mana )
