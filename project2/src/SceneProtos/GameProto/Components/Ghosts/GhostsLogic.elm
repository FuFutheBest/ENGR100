module SceneProtos.GameProto.Components.Ghosts.GhostsLogic exposing (handleWeaponNormal, handleCPosNormal)

{-| Ghost interaction and behavior logic.

This module provides functions for handling ghost interactions with weapons
and character position updates, managing ghost behavior and state changes.


# Ghost-Character Interaction

@docs handleWeaponNormal, handleCPosNormal

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentUpdateRec)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import SceneProtos.GameProto.Components.Character.Init exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.Character.Weapon as Weapon
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing (Data, GType(..))
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Handles weapon interactions with ghost entities.

Processes character weapon messages to determine ghost visibility, damage,
and state changes based on weapon type (fan detection, cannon damage, etc.).

-}
handleWeaponNormal : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleWeaponNormal env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp / 1000

        handleWeaponExposure weapon =
            -- 1 handle the weapon exposure
            case weapon of
                Weapon.Fan (Just fan) ->
                    let
                        ghostPos =
                            basedata.position

                        ghostBBox =
                            { centerCoordinate = ghostPos, size = basedata.size }

                        fanBBox =
                            { startCoordinate = fan.startCoordinate
                            , startRayDir = fan.startRayDir
                            , angle = fan.angle
                            , length = fan.length
                            }

                        isExposedToFan =
                            Collision.isRecinFan fanBBox ghostBBox

                        newData =
                            if isExposedToFan then
                                { data
                                    | state = GhostsInit.Visible currentTime False
                                }

                            else
                                data
                    in
                    ( ( newData, basedata ), [], env )

                Weapon.Cannon cannons ->
                    let
                        ghostPos =
                            basedata.position

                        ghostBBox =
                            { centerCoordinate = ghostPos, size = basedata.size }

                        firingCannons =
                            List.filter
                                (\c ->
                                    case c.state of
                                        Weapon.Firing _ ->
                                            True

                                        _ ->
                                            False
                                )
                                cannons

                        hitCannons =
                            List.filter
                                (\cannon -> Collision.isPointinRec ghostBBox cannon.startCoordinate)
                                firingCannons

                        hitCannonResult =
                            case List.head hitCannons of
                                Just cannon ->
                                    let
                                        hitCannonId =
                                            List.indexedMap
                                                (\idx c ->
                                                    if c == cannon then
                                                        Just idx

                                                    else
                                                        Nothing
                                                )
                                                cannons
                                                |> List.filterMap identity
                                                |> List.head

                                        -- _ =
                                        --     Debug.log ("Ghost id :" ++ String.fromInt basedata.id ++ " new HP:" ++ String.fromInt (data.healthPoint - cannon.damage)) ()
                                    in
                                    ( cannon.damage, hitCannonId )

                                Nothing ->
                                    ( 0, Nothing )

                        ( totalDamage, maybeCannonId ) =
                            hitCannonResult

                        cannonHitMsg =
                            case maybeCannonId of
                                Just cannonId ->
                                    [ Other <| ( "Character", GhostsMsg <| GhostsInit.HitByCannonMsg cannonId basedata.id ) ]

                                Nothing ->
                                    []

                        newHP =
                            data.healthPoint - totalDamage

                        newData =
                            if totalDamage > 0 then
                                case data.state of
                                    GhostsInit.Visible startTime False ->
                                        { data | healthPoint = newHP, state = GhostsInit.Visible startTime True }

                                    _ ->
                                        data

                            else
                                case data.state of
                                    GhostsInit.Visible startTime _ ->
                                        { data | state = GhostsInit.Visible startTime False }

                                    _ ->
                                        data

                        newBasedata =
                            if newData.healthPoint <= 0 then
                                { basedata | alive = False }

                            else
                                basedata
                    in
                    ( ( newData, newBasedata ), cannonHitMsg, env )

                _ ->
                    case data.state of
                        GhostsInit.Visible time _ ->
                            -- If mushroom consumed, stay visible forever, otherwise use normal timer
                            if data.mushroomConsumed then
                                ( ( data, basedata ), [], env )

                            else if (currentTime - time) >= GhostsInit.ghostsConfig.common.visibleDuration then
                                ( ( { data | state = GhostsInit.Invisible }, basedata ), [], env )

                            else
                                ( ( data, basedata ), [], env )

                        GhostsInit.Invisible ->
                            -- If mushroom consumed, become visible automatically
                            if data.mushroomConsumed then
                                ( ( { data | state = GhostsInit.Visible currentTime False }, basedata ), [], env )

                            else
                                ( ( data, basedata ), [], env )
    in
    case msg of
        CharacterMsg (ToGhostsMsg weapon _) ->
            handleWeaponExposure weapon

        _ ->
            ( ( data, basedata ), [], env )


{-| Handles character position interactions with normal ghosts.

Processes character position updates to control ghost movement, attack behavior,
and collision detection for normal ghost types.

-}
handleCPosNormal : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleCPosNormal env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp / 1000

        handleCPos data1 bdata1 pos cnt =
            -- 2 handle the character position
            let
                distance =
                    Vec.subtract pos bdata1.position
                        |> Vec.length

                velocity =
                    data.velocity

                speed =
                    Vec.length velocity

                newVelocity =
                    if distance < GhostsInit.ghostsConfig.normal.normalAttackDistance * (1 - data.skillTree.desensitivity) && (currentTime - data1.lastHitCharacterTime) > GhostsInit.ghostsConfig.normal.durationafterAttack then
                        Vec.subtract pos bdata1.position
                            |> Vec.normalize
                            |> Vec.scale speed

                    else
                        velocity

                isCollided =
                    Collision.isPointinRec
                        { centerCoordinate = bdata1.position, size = bdata1.size }
                        pos

                updatedCnt =
                    if isCollided then
                        cnt + 1

                    else
                        0

                newMsg =
                    if isCollided && modBy GhostsInit.ghostsConfig.normal.attackFrames updatedCnt == 3 then
                        [ Other <| ( "Character", GhostsMsg <| GhostsInit.AttackCharacterMsg GhostsInit.ghostsConfig.normal.normalAttackDamage ) ]

                    else
                        []

                newLastHitCharacterTime =
                    if isCollided then
                        currentTime

                    else
                        data1.lastHitCharacterTime
            in
            ( ( { data1 | velocity = newVelocity, lastHitCharacterTime = newLastHitCharacterTime, gtype = NormalGhost updatedCnt }, bdata1 ), newMsg, env )
    in
    case msg of
        CharacterMsg (ToGhostsMsg _ pos) ->
            case data.gtype of
                NormalGhost cnt ->
                    handleCPos data basedata pos cnt

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )
