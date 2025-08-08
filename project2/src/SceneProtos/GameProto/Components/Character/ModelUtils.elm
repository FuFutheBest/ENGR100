module SceneProtos.GameProto.Components.Character.ModelUtils exposing (calculateMousePosition, createWeaponMessages, createWeaponParticleMessage, processTickUpdate)

{-| This module provides utility functions for character model updates in the game prototype.
It includes functions for calculating mouse positions, creating weapon-related messages,
and processing tick updates for character state and animations.

@docs calculateMousePosition, createWeaponMessages, createWeaponParticleMessage, processTickUpdate

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Par exposing (randomSpeedVect)
import Lib.Utils.RoomTypes exposing (cullRadius)
import Lib.Utils.Spring as Spring
import Lib.Utils.Vec as Vec exposing (Vec)
import Messenger.Audio.Audio exposing (audioDuration)
import Messenger.Audio.Base exposing (AudioCommonOption, AudioOption(..), AudioTarget(..))
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Camera exposing (setCameraPos)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene as Scene exposing (MMsg)
import SceneProtos.GameProto.Components.Character.Buff exposing (..)
import SceneProtos.GameProto.Components.Character.CharacterExtraLogic exposing (viewAll)
import SceneProtos.GameProto.Components.Character.CharacterLogic as CharacterLogic exposing (seperatedUpdate)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Character.Weapon as Weapon exposing (CannonState(..))
import SceneProtos.GameProto.Components.Character.WeaponLogic as WeaponLogic
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Dialogue.Init exposing (DialogueMsg(..))
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit
import SceneProtos.GameProto.MainLayer.Room as Room
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)
import Set


{-| Calculates the mouse position relative to the camera position.
-}
calculateMousePosition : Vec.Vec -> ( Float, Float ) -> ( Float, Float )
calculateMousePosition cameraPos mousePos =
    let
        ( mx, my ) =
            mousePos

        ( camx, camy ) =
            cameraPos |> Vec.toTuple
    in
    ( mx + camx - 960, my + camy - 540 )


{-| Creates messages for weapon-related actions based on the weapon type and position.
-}
createWeaponMessages : Weapon.Weapon -> Vec.Vec -> ( Msg String ComponentMsg sommsg, Msg String ComponentMsg sommsg, Msg String ComponentMsg sommsg )
createWeaponMessages weapon position =
    ( Other <| ( "Ghosts", CharacterMsg <| CharacterInit.ToGhostsMsg weapon position )
    , Other <| ( "Umbrella", CharacterMsg <| CharacterInit.ToBossMsg weapon position )
    , Other <| ( "Mushroom", CharacterMsg <| CharacterInit.ToGhostsMsg weapon position )
    )


{-| Creates particle messages based on the weapon type.
-}
createWeaponParticleMessage : Weapon.Weapon -> List (Msg String ComponentMsg sommsg)
createWeaponParticleMessage weapon =
    case weapon of
        Weapon.Fan (Just fan) ->
            let
                ( fanXDir, fanYDir ) =
                    fan.startRayDir |> Vec.toTuple

                fanAngle =
                    atan2 fanYDir fanXDir
            in
            [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.FanParticlesMsg fan.startCoordinate fanAngle )
            , Other <| ( "Character", CharacterMsg <| CharacterInit.ShakeMsg 100 )
            ]

        Weapon.Cannon cannonballs ->
            let
                cannonballToParticle cannonball =
                    case cannonball.state of
                        Firing _ ->
                            [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.CannonParticlesMsg cannonball.startCoordinate 1 ) ]

                        Charging _ _ ->
                            let
                                chargePos =
                                    Vec.add cannonball.startCoordinate (Vec.scale 30 cannonball.direction)
                            in
                            [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.CannonParticlesMsg chargePos 0.4 )
                            , Other <| ( "Character", CharacterMsg <| CharacterInit.ShakeMsg 200 )
                            ]

                        _ ->
                            [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.NullParticlesMsg ) ]
            in
            List.concat (List.map cannonballToParticle cannonballs)

        _ ->
            [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.NullParticlesMsg ) ]


{-| Processes the tick update for character state, animations, and interactions.
-}
processTickUpdate :
    Env SceneCommonData UserData
    -> Float
    -> Data
    -> BaseData
    -> Set.Set Int
    -> Anim.Loop
    -> Set.Set Int
    -> ( Float, Float )
    -> Float
    -> ( Msg String ComponentMsg sommsg, Msg String ComponentMsg sommsg, Msg String ComponentMsg sommsg )
    -> List (Msg String ComponentMsg sommsg)
    -> Msg String ComponentMsg sommsg
    ->
        ( ( Data, BaseData )
        , List (Msg String ComponentMsg sommsg)
        , ( Env SceneCommonData UserData, Bool )
        )
processTickUpdate env dt data basedata keys curAnim mouseButtons mousePos currentTime weaponMessages weaponPMsg dialogueMsg =
    let
        dSec =
            dt / 10 ^ 3

        newPosition =
            calculateNewPosition data env.commonData.level keys basedata.position dSec

        newAnim =
            updateAnimation curAnim keys dSec

        ( newWeapon, remainMana ) =
            WeaponLogic.updateWeapon basedata.position data.weapon mouseButtons mousePos (Tick dt) currentTime dSec data.manaPoint

        cameraUpdatedData =
            processBuffsAndCamera data newAnim newWeapon newPosition dSec

        newMana =
            clamp 0.0 CharacterInit.characterConfig.maxMana (remainMana + CharacterInit.characterConfig.manaRegenRate * (1 + data.skillTree.regeneration) * dSec)

        cameraPos =
            cameraUpdatedData.cameraSpring.pos

        newEnv =
            updateCamera env cameraPos

        ( chestMsg, manaMsg ) =
            ( [ Other <| ( "Chest", CharacterMsg <| CharacterInit.TryGetChestMsg basedata.position ) ], Parent <| OtherMsg <| CharacterMP newMana )

        doorMsg =
            if cameraUpdatedData.hasKey == Result HasKey then
                [ Other <| ( "Door", CharacterMsg <| CharacterInit.ToDoorMsg basedata.position ) ]

            else
                []

        ( weaponMsg, bossWeaponMsg, mushroomMsg ) =
            weaponMessages

        allMessages =
            [ weaponMsg, mushroomMsg, manaMsg, bossWeaponMsg, dialogueMsg ] ++ doorMsg ++ chestMsg ++ weaponPMsg
    in
    ( ( { cameraUpdatedData | manaPoint = newMana }, { basedata | position = newPosition } ), allMessages, ( newEnv, False ) )


calculateNewPosition : Data -> String -> Set.Set Int -> Vec.Vec -> Float -> Vec.Vec
calculateNewPosition data level keys position dSec =
    let
        effectiveSpeed =
            if data.mushroomConsumed then
                -data.speed

            else
                data.speed

        newPosition =
            CharacterLogic.updateCharacterMovement keys position dSec effectiveSpeed (Room.roomsFor level ( position.x, position.y ) cullRadius)
    in
    newPosition


updateAnimation : Anim.Loop -> Set.Set Int -> Float -> Anim.Loop
updateAnimation curAnim keys dSec =
    if Set.isEmpty keys then
        Anim.updateLoopWithName curAnim "idle" 4 0.25 dSec

    else
        Anim.updateLoopWithName curAnim "walk" 4 0.1 dSec


processBuffsAndCamera : Data -> Anim.Loop -> Weapon.Weapon -> Vec.Vec -> Float -> Data
processBuffsAndCamera data newAnim newWeapon newPosition dSec =
    let
        initialUpdatedData =
            { data | anim = newAnim, weapon = newWeapon }

        newBuffs =
            updateBuffs (Tuple.first data.buffs) dSec

        buffedData =
            applyBuffs initialUpdatedData newBuffs

        cameraUpdatedData =
            updateCameraSpring dSec newPosition buffedData
    in
    cameraUpdatedData


updateCameraSpring : Float -> Vec.Vec -> Data -> Data
updateCameraSpring dSec characterPos data =
    let
        newSpring =
            Spring.updateSpringToTarget dSec characterPos data.cameraSpring
    in
    { data | cameraSpring = newSpring }


updateCamera : Env SceneCommonData UserData -> Vec.Vec -> Env SceneCommonData UserData
updateCamera env cameraPos =
    { env
        | globalData =
            let
                ( oldGlobalData, oldCamera ) =
                    ( env.globalData, env.globalData.camera )
            in
            { oldGlobalData
                | camera = { oldCamera | x = cameraPos.x, y = cameraPos.y }
            }
    }
