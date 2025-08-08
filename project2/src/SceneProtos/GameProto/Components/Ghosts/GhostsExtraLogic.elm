module SceneProtos.GameProto.Components.Ghosts.GhostsExtraLogic exposing
    ( handleCPosDashing
    , appendBullet, moveBullet, handleBulletsCollision, renderLobberBullets
    , handleBulletUpdate
    )

{-| Extended ghost logic for specialized ghost behaviors.

This module contains advanced behavioral logic for dashing ghosts and lobber ghosts,
including bullet management, collision detection, and specialized movement patterns.


# Dashing Ghost Logic

@docs handleCPosDashing


# Bullet Management

@docs appendBullet, moveBullet, handleBulletsCollision, renderLobberBullets


# Lobber Ghost Logic

@docs handleBulletUpdate

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentUpdateRec)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.GameProto.Components.Character.Init exposing (CharacterMsg(..), characterConfig)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing (DashingState(..), Data, GType(..), LobberBullet)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit exposing (ghostsConfig)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Handles character position interactions for dashing-type ghosts.

Manages dashing ghost states including accumulation phase, attacking phase,
and cooldown periods. Controls dash movement, collision detection, and
damage dealing during dash attacks.

-}
handleCPosDashing : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleCPosDashing env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp / 1000
    in
    case msg of
        CharacterMsg (ToGhostsMsg _ pos) ->
            case data.gtype of
                DashingGhost (None cnt lastDashTime) ->
                    let
                        distance =
                            Vec.subtract basedata.position pos
                                |> Vec.length

                        isCollided =
                            Collision.isPointinRec { centerCoordinate = basedata.position, size = basedata.size } pos

                        updatedCnt =
                            if isCollided then
                                cnt + 1

                            else
                                0

                        newMsg =
                            if isCollided && modBy GhostsInit.ghostsConfig.normal.attackFrames updatedCnt == 3 then
                                [ Other <| ( "Character", GhostsMsg <| GhostsInit.AttackCharacterMsg GhostsInit.ghostsConfig.dashing.dashingAttackDamage ) ]

                            else
                                []

                        newGtype =
                            if distance <= GhostsInit.ghostsConfig.dashing.dashingAttackDistance * (1 - data.skillTree.desensitivity) && (currentTime - lastDashTime) >= GhostsInit.ghostsConfig.dashing.dashingCoolDown then
                                DashingGhost (Accumulating currentTime)

                            else
                                DashingGhost (None updatedCnt lastDashTime)
                    in
                    ( ( { data | gtype = newGtype }, basedata ), newMsg, env )

                DashingGhost (Accumulating startTime) ->
                    if (currentTime - startTime) >= GhostsInit.ghostsConfig.dashing.accumulatingTime then
                        let
                            newGtype =
                                DashingGhost (Attacking False 0)
                        in
                        ( ( { data | gtype = newGtype }, basedata ), [], env )

                    else
                        ( ( data, basedata ), [], env )

                DashingGhost (Attacking isAttacked cnt) ->
                    let
                        newVelocity =
                            Vec.subtract pos basedata.position
                                |> Vec.normalize
                                |> Vec.scale GhostsInit.ghostsConfig.dashing.dashingSpeed

                        isCollided =
                            Collision.isPointinRec { centerCoordinate = basedata.position, size = basedata.size } pos

                        newMsg =
                            if not isAttacked && isCollided then
                                [ Other <| ( "Character", GhostsMsg <| GhostsInit.AttackCharacterMsg GhostsInit.ghostsConfig.dashing.dashingAttackDamage ) ]

                            else
                                []

                        newGtype =
                            if cnt >= GhostsInit.ghostsConfig.normal.attackFrames then
                                DashingGhost (None 0 currentTime)

                            else if isCollided then
                                DashingGhost (Attacking True (cnt + 1))

                            else
                                DashingGhost (Attacking isAttacked cnt)
                    in
                    ( ( { data | gtype = newGtype, velocity = newVelocity }, basedata ), newMsg, env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Appends a new bullet to the bullet list.

Creates a new LobberBullet with specified position, velocity, and timestamp,
then adds it to the existing bullet list. If no list exists, creates a new one.

-}
appendBullet : Maybe (List LobberBullet) -> Vec.Vec -> Vec.Vec -> Float -> Maybe (List LobberBullet)
appendBullet maybeBullets position velocity time =
    let
        newBullet =
            { position = position
            , size = ghostsConfig.lobber.lobberBulletSize
            , velocity = velocity
            , lastUpdateTime = time
            , anim = Anim.Loop "lb" 3 0.6 0 0
            }
    in
    case maybeBullets of
        Just bullets ->
            Just (bullets ++ [ newBullet ])

        Nothing ->
            Just [ newBullet ]


{-| Updates bullet positions and filters out off-screen bullets.

Moves all bullets in the list based on their velocity and elapsed time,
then removes bullets that have moved outside the valid screen area
relative to the given position.

-}
moveBullet : Maybe (List LobberBullet) -> Float -> Vec.Vec -> Maybe (List LobberBullet)
moveBullet maybeBullets time pos =
    case maybeBullets of
        Just bullets ->
            let
                updatedBullets =
                    List.map
                        (\bullet ->
                            { bullet
                                | position = Vec.add bullet.position (Vec.scale (time - bullet.lastUpdateTime) bullet.velocity)
                                , lastUpdateTime = time
                                , anim = Anim.updateLoop bullet.anim 0.016
                            }
                        )
                        bullets
                        |> List.filter
                            (\bullet ->
                                bullet.position.x
                                    > -ghostsConfig.lobber.assumeScreenHalfSize
                                    + pos.x
                                    && bullet.position.x
                                    < ghostsConfig.lobber.assumeScreenHalfSize
                                    + pos.x
                                    && bullet.position.y
                                    > -ghostsConfig.lobber.assumeScreenHalfSize
                                    + pos.y
                                    && bullet.position.y
                                    < ghostsConfig.lobber.assumeScreenHalfSize
                                    + pos.y
                            )
            in
            Just updatedBullets

        Nothing ->
            Nothing


{-| Checks for bullet collisions with a target entity.
-}
handleBulletsCollision : Maybe (List LobberBullet) -> Vec.Vec -> Vec.Vec -> ( Maybe (List LobberBullet), Bool )
handleBulletsCollision maybeBullets position size =
    case maybeBullets of
        Just bullets ->
            let
                isCollided bullet =
                    Collision.isPointinRec
                        { centerCoordinate = position, size = size }
                        bullet.position

                ( collided, notCollided ) =
                    List.partition isCollided bullets
            in
            ( Just notCollided, not (List.isEmpty collided) )

        Nothing ->
            ( Nothing, False )


{-| Renders all lobber bullets as orange rectangles.
-}
renderLobberBullets : Maybe (List LobberBullet) -> List Renderable
renderLobberBullets maybeBullets =
    case maybeBullets of
        Just bullets ->
            List.map
                (\bullet ->
                    P.centeredTexture (Vec.toTuple bullet.position) (Vec.toTuple (Vec.scale 3 bullet.size)) 0 (Anim.getCurFrameName bullet.anim)
                )
                bullets

        Nothing ->
            []


{-| Updates bullet system for lobber ghosts including firing and collision detection.

Manages bullet movement, firing new bullets based on detection distance and cooldown,
collision checking with character, and updating the ghost's bullet state.
Returns updated ghost data and collision status.

-}
handleBulletUpdate : Data -> BaseData -> Float -> Float -> Maybe (List LobberBullet) -> Vec.Vec -> ( Data, Bool )
handleBulletUpdate data1 bdata1 currentTime lastLaunchTime bulletList pos =
    let
        distance =
            Vec.subtract pos bdata1.position
                |> Vec.length

        isDetected =
            if distance < ghostsConfig.lobber.lobberDeteckDistance then
                True

            else
                False

        movedBullets =
            moveBullet bulletList currentTime bdata1.position

        potentialBulletVelcity =
            Vec.subtract pos bdata1.position
                |> Vec.normalize
                |> Vec.scale ghostsConfig.lobber.lobberBulletVelocity

        ( newTime, appendedBullets ) =
            if isDetected && (currentTime - lastLaunchTime) > ghostsConfig.lobber.shootCooldown then
                ( currentTime, appendBullet movedBullets bdata1.position potentialBulletVelcity currentTime )

            else
                ( lastLaunchTime, movedBullets )

        ( newBullets, isCollied ) =
            handleBulletsCollision appendedBullets pos characterConfig.size

        newGtype =
            case data1.gtype of
                LobberGhost cnt1 _ _ ->
                    LobberGhost cnt1 newTime newBullets

                _ ->
                    data1.gtype
    in
    ( { data1 | gtype = newGtype }, isCollied )
