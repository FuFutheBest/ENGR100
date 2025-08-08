module SceneProtos.GameProto.Components.Ghosts.GhostModel exposing
    ( moveGhost
    , updateSingleGhost
    , handleCPosLobber
    )

{-| Ghost model and movement logic.

This module handles ghost movement mechanics, collision detection, and
behavioral updates for different ghost types within the game environment.


# Ghost Movement

@docs moveGhost


# Ghost Updates

@docs updateSingleGhost


# Ghost Type Handlers

@docs handleCPosLobber

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Collision as Collision
import Lib.Utils.Passages exposing (Room)
import Lib.Utils.Rooms exposing (..)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import SceneProtos.GameProto.Components.Character.Init exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.GhostsExtraLogic exposing (handleBulletUpdate, handleCPosDashing)
import SceneProtos.GameProto.Components.Ghosts.GhostsLogic exposing (handleCPosNormal, handleWeaponNormal)
import SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing (..)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit exposing (ghostsConfig)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Moves a ghost entity based on its type and current state.

Handles movement logic including random direction changes, boundary checking, and special movement behaviors for different ghost types (normal, dashing, lobber).

-}
moveGhost : Data -> BaseData -> Float -> Float -> List Room -> ( Data, BaseData )
moveGhost data bdata seed dt roomList =
    let
        direction =
            if randomProbabilityGenerator (3 * bdata.position.x + 7 * bdata.position.y + 5 * seed) 90 then
                Vec.normalize data.velocity

            else
                randomDirectionGenerator (toFloat (modBy 1003 (modBy 109 (round seed) ^ 7)) ^ toFloat bdata.id + 5 * seed)

        candidate =
            Vec.add bdata.position (Vec.scale dt (Vec.scale GhostsInit.ghostsConfig.common.speed direction))

        legalMove =
            List.any
                (\room -> isWithinBoundForGhost room candidate)
                roomList

        newPos =
            case data.gtype of
                DashingGhost (Accumulating _) ->
                    bdata.position

                DashingGhost (Attacking _ _) ->
                    let
                        candidate2 =
                            Vec.add bdata.position (Vec.scale dt data.velocity)

                        legalMove1 =
                            List.any
                                (\room -> isWithinBoundForGhost room candidate2)
                                roomList
                    in
                    if legalMove1 then
                        candidate2

                    else
                        bdata.position

                _ ->
                    if legalMove then
                        candidate

                    else
                        bdata.position

        curAnim =
            data.anim

        currentFrameName =
            Anim.getCurFrameName data.anim

        newAnim =
            case data.gtype of
                DashingGhost (Accumulating _) ->
                    if String.length currentFrameName == 5 then
                        Anim.Loop "dash_charge" 8 0.6 0 0

                    else
                        Anim.updateLoop curAnim 0.016

                DashingGhost (None _ _) ->
                    if String.length currentFrameName == 12 then
                        Anim.Loop "dash" 3 0.6 0 0

                    else
                        Anim.updateLoop curAnim 0.016

                _ ->
                    Anim.updateLoop curAnim 0.016

        newData =
            { data
                | velocity = direction
                , anim = newAnim
            }

        newBaseData =
            { bdata
                | position = newPos
            }
    in
    ( newData, newBaseData )


{-| Updates a single ghost entity based on received messages.

Processes character messages including weapon interactions, position updates, skill tree modifications, and ghost-specific messages like mushroom effects. Delegates to appropriate handlers based on ghost type.

-}
updateSingleGhost : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updateSingleGhost env msg data basedata =
    case msg of
        CharacterMsg (ToGhostsMsg weapon pos) ->
            let
                ( ( data1, bdata1 ), msg1, env1 ) =
                    handleWeaponNormal env msg data basedata

                ( ( data2, bdata2 ), msg2, env2 ) =
                    case data.gtype of
                        DashingGhost _ ->
                            handleCPosDashing env1 msg data1 bdata1

                        LobberGhost _ _ _ ->
                            handleCPosLobber env1 msg data1 bdata1

                        _ ->
                            handleCPosNormal env1 msg data1 bdata1
            in
            ( ( data2, bdata2 ), msg1 ++ msg2, env2 )

        CharacterMsg (ToGhostSkillTreeMsg options) ->
            case options of
                3 ->
                    let
                        oldSkillTree =
                            data.skillTree

                        newData =
                            { data | skillTree = { oldSkillTree | desensitivity = oldSkillTree.desensitivity + 0.1 } }
                    in
                    ( ( newData, basedata ), [], env )

                4 ->
                    let
                        oldSkillTree =
                            data.skillTree

                        newData =
                            { data | skillTree = { oldSkillTree | emitLevel = oldSkillTree.emitLevel + 1 } }
                    in
                    ( ( newData, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        GhostsMsg gmsg ->
            case gmsg of
                GhostsInit.ToggleMushroomEffectMsg ->
                    let
                        newData =
                            { data | mushroomConsumed = not data.mushroomConsumed }
                    in
                    ( ( newData, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Handles character position interactions for lobber-type ghosts.
-}
handleCPosLobber : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleCPosLobber env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp / 1000

        handleCPos data1 bdata1 pos cnt =
            let
                distance =
                    Vec.length (Vec.subtract pos bdata1.position)

                ( velocity, speed ) =
                    ( data.velocity, Vec.length data.velocity )

                newVelocity =
                    if distance < GhostsInit.ghostsConfig.lobber.lobberAttackDistance * (1 - data.skillTree.desensitivity) && (currentTime - data1.lastHitCharacterTime) > GhostsInit.ghostsConfig.normal.durationafterAttack then
                        Vec.scale speed (Vec.normalize (Vec.subtract pos bdata1.position))

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
                        [ Other <| ( "Character", GhostsMsg <| GhostsInit.AttackCharacterMsg GhostsInit.ghostsConfig.lobber.lobberAttackDamage ) ]

                    else
                        []

                newLastHitCharacterTime =
                    if isCollided then
                        currentTime

                    else
                        data1.lastHitCharacterTime

                updatedGtype =
                    case data1.gtype of
                        LobberGhost _ lastLaunchTime bulletList ->
                            LobberGhost updatedCnt lastLaunchTime bulletList

                        _ ->
                            data1.gtype
            in
            ( ( { data1 | velocity = newVelocity, lastHitCharacterTime = newLastHitCharacterTime, gtype = updatedGtype }, bdata1 ), newMsg, env )
    in
    case msg of
        CharacterMsg (ToGhostsMsg _ pos) ->
            case data.gtype of
                LobberGhost cnt lastLaunchTime bulletList ->
                    let
                        ( ( data1, bdata1 ), msg1, env1 ) =
                            handleCPos data basedata pos cnt

                        ( ( data2, bdata2 ), msg2, env2 ) =
                            let
                                ( newData, isCollied ) =
                                    handleBulletUpdate data1 bdata1 currentTime lastLaunchTime bulletList pos

                                appendedMsg =
                                    if isCollied then
                                        [ Other <| ( "Character", GhostsMsg <| GhostsInit.CharacterSlowDownMsg ghostsConfig.lobber.lobberSlowDownPercent ghostsConfig.lobber.lobberSlowDownDuration ) ]

                                    else
                                        []
                            in
                            ( ( {- { data1 | gtype = newGtype } -} newData
                              , bdata1
                              )
                            , msg1 ++ appendedMsg
                            , env1
                            )
                    in
                    ( ( data2, bdata2 ), msg2, env2 )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )
