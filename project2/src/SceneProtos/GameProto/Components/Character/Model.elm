module SceneProtos.GameProto.Components.Character.Model exposing (component)

{-| Character component model module.

This module implements the main character component for the game, including the player-controlled
character entity with movement, combat, interaction, and progression systems. The character
component manages health, mana, weapons, buffs, skill tree progression, and camera following.

The character serves as the central player entity that can:

  - Move around the game world with collision detection
  - Interact with other game entities (ghosts, keys, doors, mushrooms)
  - Use various weapons and abilities
  - Manage health and mana resources
  - Apply and receive buffs/debuffs
  - Progress through a skill tree system


# Component

@docs component

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Collision as Collision
import Lib.Utils.Par exposing (randomSpeedVect)
import Lib.Utils.RoomTypes exposing (cullRadius)
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
import SceneProtos.GameProto.Components.Character.ModelUtils exposing (calculateMousePosition, createWeaponMessages, createWeaponParticleMessage, processTickUpdate)
import SceneProtos.GameProto.Components.Character.Weapon as Weapon exposing (CannonState(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Dialogue.Init exposing (DialogueMsg(..))
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Key.Init as KeyInit
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)
import Set


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ initMsg =
    case initMsg of
        CharacterMsg cmsg ->
            case cmsg of
                CharacterInit.CharacterInitMsg initData ->
                    ( { emptyData
                        | speed = CharacterInit.characterConfig.defaultSpeed
                        , healthPoint = CharacterInit.characterConfig.maxHealth
                        , manaPoint = CharacterInit.characterConfig.maxMana / 2
                        , mushroomConsumed = CharacterInit.characterConfig.mushroomConsumed
                        , buffs =
                            ( []
                            , { speed = CharacterInit.characterConfig.defaultSpeed }
                            )
                      }
                    , { emptyBaseData
                        | id = initData.id
                        , ty = "Character"
                        , position = initData.position
                        , size = CharacterInit.characterConfig.size
                        , alive = True
                      }
                    )

                _ ->
                    ( emptyData, emptyBaseData )

        _ ->
            ( emptyData, emptyBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        ( keys, curAnim, mouseButtons ) =
            ( env.globalData.pressedKeys, data.anim, env.globalData.pressedMouseButtons )

        mousePos =
            calculateMousePosition data.cameraSpring.pos env.globalData.mousePos

        currentTime =
            -- Convert milliseconds to seconds
            env.globalData.currentTimeStamp / 1000

        weaponMessages =
            createWeaponMessages data.weapon basedata.position

        weaponPMsg =
            createWeaponParticleMessage data.weapon

        dialogueMsg =
            Other <| ( "Dialogue", DialogueMsg <| TriggerDialogueMsg basedata.position )
    in
    case evnt of
        Tick dt ->
            processTickUpdate env dt data basedata keys curAnim mouseButtons mousePos currentTime weaponMessages weaponPMsg dialogueMsg

        _ ->
            seperatedUpdate env evnt data basedata


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        GhostsMsg gmsg ->
            case gmsg of
                GhostsInit.AttackCharacterMsg damage ->
                    let
                        newHealth =
                            data.healthPoint - round (toFloat damage * (1 - data.skillTree.resilience))

                        changeHPMsg =
                            Parent <| OtherMsg <| CharacterHP (toFloat newHealth)

                        ( sceneChangeMsg, newEnv ) =
                            if newHealth <= 0 then
                                let
                                    resetCameraEnv =
                                        { env | globalData = setCameraPos ( 960, 540 ) env.globalData }
                                in
                                ( [ Parent <| SOMMsg (Scene.SOMChangeScene Nothing "EndScreen")
                                  , Parent <| SOMMsg (Scene.SOMStopAudio <| AudioName 0 "scream")
                                  , Parent <| SOMMsg (Scene.SOMPlayAudio 0 "scream" <| AOnce Nothing)
                                  ]
                                , resetCameraEnv
                                )

                            else
                                ( [], env )
                    in
                    ( ( { data | healthPoint = newHealth }, basedata ), changeHPMsg :: sceneChangeMsg, newEnv )

                GhostsInit.CharacterSlowDownMsg percent duration ->
                    let
                        newBuff =
                            { tar = "speed", per = percent, duration = duration }

                        ( buffs, originalData ) =
                            data.buffs

                        newBuffs =
                            newBuff :: buffs

                        newData =
                            { data | buffs = ( newBuffs, originalData ) }
                    in
                    ( ( newData, basedata ), [], env )

                GhostsInit.HitByCannonMsg cannonId _ ->
                    let
                        updatedWeapon =
                            case data.weapon of
                                Weapon.Cannon cannons ->
                                    Weapon.Cannon
                                        (List.indexedMap
                                            (\idx cannon ->
                                                if idx == cannonId then
                                                    { cannon | wearLevel = cannon.wearLevel - 1 }

                                                else
                                                    cannon
                                            )
                                            cannons
                                        )

                                _ ->
                                    data.weapon
                    in
                    ( ( { data | weapon = updatedWeapon }, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        KeyMsg kmsg ->
            case kmsg of
                KeyInit.ToCharacterMsg position ->
                    let
                        newData =
                            { data
                                | hasKey =
                                    if data.hasKey == TryingInteracte && Collision.isPointinRec { centerCoordinate = basedata.position, size = basedata.size } position then
                                        Result HasKey

                                    else
                                        data.hasKey
                            }

                        newMsg =
                            case newData.hasKey of
                                Result HasKey ->
                                    [ Other <| ( "Key", CharacterMsg <| CharacterInit.GotKeyMsg ) ]

                                _ ->
                                    []
                    in
                    ( ( newData, basedata ), newMsg, env )

                _ ->
                    ( ( data, basedata ), [], env )

        CharacterMsg cmsg ->
            case cmsg of
                CharacterInit.ToggleMushroomEffectMsg ->
                    let
                        newData =
                            { data | mushroomConsumed = not data.mushroomConsumed }

                        -- Add HP increase when mushroom is consumed
                        ( finalData, hpMsg ) =
                            if not data.mushroomConsumed && newData.mushroomConsumed then
                                let
                                    hpIncrease =
                                        30

                                    newHealth =
                                        min CharacterInit.characterConfig.maxHealth (data.healthPoint + hpIncrease)

                                    updatedData =
                                        { newData | healthPoint = newHealth }

                                    changeHPMsg =
                                        Parent <| OtherMsg <| CharacterHP (toFloat newHealth)
                                in
                                ( updatedData, [ changeHPMsg ] )

                            else
                                ( newData, [] )
                    in
                    ( ( finalData, basedata ), hpMsg, env )

                CharacterInit.ShakeMsg intensity ->
                    let
                        ( vx, vy ) =
                            randomSpeedVect intensity (Lib.Utils.Par.getSeed env.globalData.currentTimeStamp)

                        randomVector =
                            Vec.genVec vx vy

                        curVel =
                            data.cameraSpring.vel

                        newVel =
                            Vec.add curVel randomVector

                        oldSpring =
                            data.cameraSpring

                        newSpring =
                            { oldSpring | vel = newVel }
                    in
                    ( ( { data | cameraSpring = newSpring }, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    viewAll env data basedata


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "Character"


componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
