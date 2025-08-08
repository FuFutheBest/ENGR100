module SceneProtos.GameProto.Components.Umbrella.UmbrellaLogic exposing (Data, Bullet, handleWeapon, handleShootingBullet, renderBullets)

{-|


# UmbrellaLogic module

This module contains the logic for the umbrella component in the game.
It handles weapon exposure, bullet management, and collision detection.
It is part of the GameProto scene and interacts with other components like Character and Ghosts.

@docs Data, Bullet, handleWeapon, handleShootingBullet, renderBullets

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Audio.Base exposing (..)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel as GM exposing (..)
import Messenger.Scene.Scene as Scene
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit exposing (CharacterMsg(..), characterConfig)
import SceneProtos.GameProto.Components.Character.Weapon as Weapon
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit exposing (GhostsMsg(..))
import SceneProtos.GameProto.Components.Umbrella.Init exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Data type for the umbrella component.
-}
type alias Data =
    { lastGenGhostTime : Float
    , attackCount : Int
    , healthPoint : Int
    , lastLaunchTime : Float
    , bullets : Maybe (List Bullet)
    , anim : Anim.Loop
    , isAudioPlaying : Bool
    }


{-| Bullet type for the umbrella component.
-}
type alias Bullet =
    { position : Vec.Vec
    , size : Vec.Vec
    , velocity : Vec.Vec
    , lastUpdateTime : Float
    , anim : Anim.Loop
    }


{-| Handles weapon exposure logic for the umbrella component.
-}
handleWeapon : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleWeapon env msg data basedata =
    let
        handleWeaponExposure weapon =
            case weapon of
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

                        totalDamage =
                            case List.head hitCannons of
                                Just cannon ->
                                    cannon.damage

                                Nothing ->
                                    0

                        newHP =
                            data.healthPoint - totalDamage

                        newData =
                            if totalDamage > 0 then
                                { data | healthPoint = newHP }

                            else
                                data

                        ( newBasedata, msg1 ) =
                            if newData.healthPoint <= 0 then
                                ( { basedata | alive = False }
                                , [ GM.Parent <| GM.SOMMsg (Scene.SOMStopAudio (AudioName 0 "umbrella")), GM.Parent <| GM.SOMMsg (Scene.SOMPlayAudio 0 "home" <| ALoop Nothing Nothing) ]
                                )

                            else
                                ( basedata, [] )
                    in
                    ( ( newData, newBasedata ), msg1, env )

                _ ->
                    ( ( data, basedata ), [], env )
    in
    case msg of
        CharacterMsg (ToBossMsg weapon _) ->
            handleWeaponExposure weapon

        _ ->
            ( ( data, basedata ), [], env )


appendBullet : Maybe (List Bullet) -> Vec.Vec -> Vec.Vec -> Float -> Maybe (List Bullet)
appendBullet maybeBullets position velocity time =
    let
        newBullet =
            { position = position
            , size = uConfig.bulletSize
            , velocity = velocity
            , lastUpdateTime = time
            , anim = Anim.Loop "ub" 3 0.6 0 0
            }

        newBullets =
            List.range 0 5
                |> List.map (\i -> { newBullet | velocity = Vec.rotate (toFloat i * pi / 3) newBullet.velocity })
    in
    case maybeBullets of
        Just bullets ->
            Just (bullets ++ newBullets)

        Nothing ->
            Just newBullets


moveBullet : Maybe (List Bullet) -> Float -> Vec.Vec -> Maybe (List Bullet)
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
                                    > -uConfig.assumeScreenHalfSize
                                    + pos.x
                                    && bullet.position.x
                                    < uConfig.assumeScreenHalfSize
                                    + pos.x
                                    && bullet.position.y
                                    > -uConfig.assumeScreenHalfSize
                                    + pos.y
                                    && bullet.position.y
                                    < uConfig.assumeScreenHalfSize
                                    + pos.y
                            )
            in
            Just updatedBullets

        Nothing ->
            Nothing


handleBulletsCollision : Maybe (List Bullet) -> Vec.Vec -> Vec.Vec -> ( Maybe (List Bullet), Bool )
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


{-| Renders the bullets in the umbrella component.
-}
renderBullets : Maybe (List Bullet) -> List Renderable
renderBullets maybeBullets =
    case maybeBullets of
        Just bullets ->
            List.map
                (\bullet ->
                    -- P.rectCentered (Vec.toTuple bullet.position) (Vec.toTuple bullet.size) 0 Color.red
                    P.centeredTexture (Vec.toTuple bullet.position) (Vec.toTuple (Vec.scale 3 bullet.size)) 0 (Anim.getCurFrameName bullet.anim)
                )
                bullets

        Nothing ->
            []


handleBulletUpdate : Data -> BaseData -> Float -> Float -> Maybe (List Bullet) -> Vec.Vec -> ( Data, Bool )
handleBulletUpdate data1 bdata1 currentTime lastLaunchTime bulletList pos =
    let
        distance =
            Vec.subtract pos bdata1.position
                |> Vec.length

        isDetected =
            if distance < uConfig.detectDistance then
                True

            else
                False

        movedBullets =
            moveBullet bulletList currentTime bdata1.position

        potentialBulletVelcity =
            Vec.subtract pos bdata1.position
                |> Vec.normalize
                |> Vec.scale uConfig.bulletVelocity

        ( newTime, appendedBullets ) =
            if isDetected && (currentTime - lastLaunchTime) > uConfig.shootCooldown then
                ( currentTime, appendBullet movedBullets bdata1.position potentialBulletVelcity currentTime )

            else
                ( lastLaunchTime, movedBullets )

        ( newBullets, isCollied ) =
            handleBulletsCollision appendedBullets pos characterConfig.size

        newData =
            { data1
                | lastLaunchTime = newTime
                , bullets = newBullets
            }
    in
    ( newData, isCollied )


{-| Handles the shooting bullet logic for the umbrella component
-}
handleShootingBullet : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
handleShootingBullet env msg data basedata =
    case msg of
        CharacterMsg (ToBossMsg _ pos) ->
            let
                ( newData, isCollied ) =
                    handleBulletUpdate data basedata (env.globalData.currentTimeStamp / 1000) data.lastLaunchTime data.bullets pos

                appendedMsg =
                    if isCollied then
                        [ Other <| ( "Character", GhostsMsg <| GhostsInit.CharacterSlowDownMsg uConfig.slowDownPercent uConfig.slowDownDuration ) ]

                    else
                        []
            in
            ( ( newData, basedata ), appendedMsg, env )

        _ ->
            ( ( data, basedata ), [], env )
