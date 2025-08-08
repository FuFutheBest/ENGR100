module SceneProtos.GameProto.Components.Character.CharvterLogicUtils exposing (moveCharacter, updateSkillTree)

{-| The module provides utility functions for character movement and skill tree updates in a game scene.
It includes logic for moving the character based on input direction and velocity, as well as updating the skill tree based on player choices.

@docs moveCharacter, updateSkillTree

-}

import Lib.UserData exposing (UserData)
import Lib.Utils.Passages exposing (Room)
import Lib.Utils.Rooms exposing (..)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import SceneProtos.GameProto.Components.Character.Buff exposing (..)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.MainLayer.Room exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| This function handles the skill tree updates based on player choices.
It checks if the player has enough skill points and if the skill can be upgraded.
If so, it updates the skill tree and reduces the skill points accordingly.
-}
updateSkillTree : Env SceneCommonData UserData -> Data -> Int -> ( Env SceneCommonData UserData, SkillTree )
updateSkillTree env data options =
    let
        oldskillTree =
            data.skillTree

        ( newEnv, newSkillTree ) =
            case options of
                1 ->
                    if env.commonData.skillPoints > 0 && oldskillTree.resilience < 0.3 then
                        let
                            oldCommonData =
                                env.commonData
                        in
                        ( { env | commonData = { oldCommonData | skillPoints = oldCommonData.skillPoints - 1 } }, { oldskillTree | resilience = oldskillTree.resilience + 0.1 } )

                    else
                        ( env, oldskillTree )

                2 ->
                    if env.commonData.skillPoints > 0 && oldskillTree.regeneration < 0.3 then
                        let
                            oldCommonData =
                                env.commonData
                        in
                        ( { env | commonData = { oldCommonData | skillPoints = oldCommonData.skillPoints - 1 } }, { oldskillTree | regeneration = oldskillTree.regeneration + 0.1 } )

                    else
                        ( env, oldskillTree )

                3 ->
                    if env.commonData.skillPoints > 0 && oldskillTree.desensitivity < 0.3 then
                        let
                            oldCommonData =
                                env.commonData
                        in
                        ( { env | commonData = { oldCommonData | skillPoints = oldCommonData.skillPoints - 1 } }, { oldskillTree | desensitivity = oldskillTree.desensitivity + 0.1 } )

                    else
                        ( env, oldskillTree )

                4 ->
                    if env.commonData.skillPoints > 0 && oldskillTree.emitLevel < 3 then
                        let
                            oldCommonData =
                                env.commonData
                        in
                        ( { env | commonData = { oldCommonData | skillPoints = oldCommonData.skillPoints - 1 } }, { oldskillTree | emitLevel = oldskillTree.emitLevel + 1 } )

                    else
                        ( env, oldskillTree )

                _ ->
                    ( env, oldskillTree )
    in
    ( newEnv, newSkillTree )


{-| Moves the character based on the input direction and velocity.
-}
moveCharacter : String -> Vec.Vec -> Float -> Float -> List Room -> Vec.Vec
moveCharacter dir position dt velocity roomList =
    let
        diagonalVelocity =
            velocity / sqrt 2

        potentialCoordinate =
            case dir of
                "W" ->
                    Vec.subtract position (Vec.scale dt (Vec.genVec 0 velocity))

                "S" ->
                    Vec.add position (Vec.scale dt (Vec.genVec 0 velocity))

                "A" ->
                    Vec.subtract position (Vec.scale dt (Vec.genVec velocity 0))

                "D" ->
                    Vec.add position (Vec.scale dt (Vec.genVec velocity 0))

                "WA" ->
                    Vec.add position (Vec.scale dt (Vec.genVec -diagonalVelocity -diagonalVelocity))

                "WD" ->
                    Vec.add position (Vec.scale dt (Vec.genVec diagonalVelocity -diagonalVelocity))

                "SA" ->
                    Vec.add position (Vec.scale dt (Vec.genVec -diagonalVelocity diagonalVelocity))

                "SD" ->
                    Vec.add position (Vec.scale dt (Vec.genVec diagonalVelocity diagonalVelocity))

                _ ->
                    position

        -- TODO: Check legal move base on room design
        legalMove =
            isLegalMove roomList position potentialCoordinate

        newCoordinate =
            if legalMove then
                potentialCoordinate

            else
                position
    in
    newCoordinate
