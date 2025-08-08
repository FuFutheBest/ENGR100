module SceneProtos.GameProto.Components.Character.CharacterLogic exposing (seperatedUpdate, updateCharacterMovement)

{-| Character logic and movement module.

This module handles the core logic for character behavior, including input processing,
movement mechanics, weapon switching, skill tree progression, and interaction handling.
It separates the complex update logic from the main model to maintain code organization.

The module provides:

  - Input handling for movement, weapon switching, and skill upgrades
  - Character movement with collision detection and room boundary checking
  - Skill tree progression system with point spending mechanics
  - Weapon switching and interaction state management
  - Environmental interaction logic (keys, chests, doors)


# Update Functions

@docs seperatedUpdate, updateCharacterMovement

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Passages exposing (Room)
import Lib.Utils.Rooms exposing (..)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.Common exposing (group)
import SceneProtos.GameProto.Components.Character.Buff exposing (..)
import SceneProtos.GameProto.Components.Character.CharvterLogicUtils exposing (moveCharacter, updateSkillTree)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Character.Weapon as Weapon
import SceneProtos.GameProto.Components.Character.WeaponLogic as WeaponLogic
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.MainLayer.Room exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)
import Set


{-| Handles separated update logic for character components.

This function manages complex character behaviors that are separated from the main
update loop, including weapon switching, skill tree progression, and interaction
state changes. It processes keyboard input for special actions and updates
character state accordingly.

Parameters:

  - Environment containing global game state and input
  - Event data for this frame
  - Current character data
  - Base component data

Returns updated character and base data along with generated messages.

-}
seperatedUpdate : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
seperatedUpdate env evnt data basedata =
    let
        mouseButtons =
            env.globalData.pressedMouseButtons

        mousePos =
            let
                ( mx, my ) =
                    env.globalData.mousePos

                ( camx, camy ) =
                    data.cameraSpring.pos |> Vec.toTuple
            in
            ( mx + camx - 960, my + camy - 540 )

        currentTime =
            -- Convert milliseconds to seconds
            env.globalData.currentTimeStamp / 1000

        weaponMsg =
            -- share the weapon message with the ghosts
            Other <| ( "Ghosts", CharacterMsg <| CharacterInit.ToGhostsMsg data.weapon basedata.position )

        mushroomMsg =
            -- share position with mushrooms for proximity detection
            Other <| ( "Mushroom", CharacterMsg <| CharacterInit.ToGhostsMsg data.weapon basedata.position )

        toGhostMsg options newEnv =
            if newEnv.commonData.skillPoints < env.commonData.skillPoints then
                [ Other <| ( "Ghosts", CharacterMsg <| CharacterInit.ToGhostSkillTreeMsg options ) ]

            else
                []
    in
    case evnt of
        MouseDown 2 _ ->
            let
                newWeapon =
                    Weapon.switchWeapon data.weapon

                weaponChangeUIMsg =
                    Parent <|
                        OtherMsg <|
                            SwitchWeaponMsg
                                (case data.weapon of
                                    Weapon.Fan _ ->
                                        "b"

                                    Weapon.Cannon _ ->
                                        "y"
                                )
            in
            ( ( { data | weapon = newWeapon }, basedata ), [ weaponMsg, mushroomMsg, weaponChangeUIMsg ], ( env, False ) )

        KeyDown 82 ->
            -- R key to try to interacte with environment
            let
                newData =
                    { data | hasKey = updateKeyState data.hasKey NoneInteraction TryingInteracte }

                chestMsg =
                    Other <| ( "Chest", CharacterMsg <| CharacterInit.TryGetChestMsg basedata.position )
            in
            ( ( newData, basedata ), [ chestMsg ], ( env, False ) )

        KeyUp 82 ->
            let
                newData =
                    { data | hasKey = updateKeyState data.hasKey TryingInteracte NoneInteraction }
            in
            ( ( newData, basedata ), [], ( env, False ) )

        KeyDown 49 ->
            -- 1 key update the resilience in skill tree
            let
                ( newEnv, newSkillTree ) =
                    updateSkillTree env data 1
            in
            ( ( { data | skillTree = newSkillTree }, basedata ), [], ( newEnv, False ) )

        KeyDown 50 ->
            -- 2 key update the regeneration in skill tree
            let
                ( newEnv, newSkillTree ) =
                    updateSkillTree env data 2
            in
            ( ( { data | skillTree = newSkillTree }, basedata ), [], ( newEnv, False ) )

        KeyDown 51 ->
            -- 3 key update the desensitivity in skill tree
            let
                ( newEnv, newSkillTree ) =
                    updateSkillTree env data 3

                tGMsg =
                    toGhostMsg 3 newEnv
            in
            ( ( { data | skillTree = newSkillTree }, basedata ), tGMsg, ( newEnv, False ) )

        KeyDown 52 ->
            -- 4 key update the emitLevel in skill tree
            let
                ( newEnv, newSkillTree ) =
                    updateSkillTree env data 4

                tGMsg =
                    toGhostMsg 4 newEnv
            in
            ( ( { data | skillTree = newSkillTree }, basedata ), tGMsg, ( newEnv, False ) )

        _ ->
            let
                ( newWeapon, remainMana ) =
                    WeaponLogic.updateWeapon basedata.position data.weapon mouseButtons mousePos evnt currentTime 0 data.manaPoint
            in
            ( ( { data | weapon = newWeapon, manaPoint = remainMana }, basedata ), [ weaponMsg, mushroomMsg ], ( env, False ) )


{-| Updates character position based on input and collision detection.

Processes movement input and applies physics-based movement with collision
detection against room boundaries and obstacles. Handles diagonal movement
and ensures the character cannot move through walls.

Parameters:

  - Set of currently pressed keys for movement input
  - Current character position
  - Time delta for frame-rate independent movement
  - Character movement velocity in pixels per second
  - List of room data for collision detection

Returns new character position after movement and collision checks.

-}
updateKeyState : InteractState -> InteractState -> InteractState -> InteractState
updateKeyState currentState fromState toState =
    -- Helper function to update the key state
    if currentState == fromState then
        toState

    else
        currentState


{-| Updates character movement based on input keys and room boundaries.
-}
updateCharacterMovement : Set.Set Int -> Vec.Vec -> Float -> Float -> List Room -> Vec.Vec
updateCharacterMovement keys position dt velocity roomList =
    let
        moveCommand =
            getMoveCommand keys
    in
    if moveCommand /= "" then
        moveCharacter moveCommand position dt velocity roomList

    else
        position


getMoveCommand : Set.Set Int -> String
getMoveCommand keys =
    if Set.member 87 keys && Set.member 65 keys then
        "WA"

    else if Set.member 87 keys && Set.member 68 keys then
        "WD"

    else if Set.member 83 keys && Set.member 65 keys then
        "SA"

    else if Set.member 83 keys && Set.member 68 keys then
        "SD"

    else if Set.member 87 keys then
        "W"

    else if Set.member 83 keys then
        "S"

    else if Set.member 65 keys then
        "A"

    else if Set.member 68 keys then
        "D"

    else
        ""
