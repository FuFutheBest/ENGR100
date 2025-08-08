module SceneProtos.GameProto.Components.Character.CharacterExtraLogic exposing (viewAll)

{-| Character extra rendering and UI logic module.

This module handles the visual rendering aspects of the character component, including
character sprites, weapon effects, skill tree UI elements, and other visual feedback.
It separates rendering logic from the main model to maintain code organization.

The module provides comprehensive visual representation for:

  - Character sprite animation and coloring based on weapon type
  - Active weapon visual effects (fan beams, cannon projectiles)
  - Skill tree progression indicators
  - Visual UI elements for character abilities


# Rendering Functions

@docs viewAll

-}

import Color
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Rooms exposing (..)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentView)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.GameProto.Components.Character.Buff exposing (..)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Character.Weapon as Weapon
import SceneProtos.GameProto.Components.Character.WeaponExtraLogic exposing (renderCannon, renderFan)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..))
import SceneProtos.GameProto.MainLayer.Room exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Main view function that renders the character, weapons and skill icons.
This function combines all visual elements of the character component.
-}
viewAll : ComponentView SceneCommonData UserData Data BaseData
viewAll env data basedata =
    let
        currentTime =
            -- Convert milliseconds to seconds
            env.globalData.currentTimeStamp / 1000

        center =
            Vec.toTuple basedata.position

        colorChar =
            case data.weapon of
                Weapon.Fan _ ->
                    "y"

                _ ->
                    "b"

        tSize =
            Vec.toTuple CharacterInit.characterConfig.renderSize

        -- Character view rendering
        characterView =
            [ P.centeredTexture center tSize 0 (colorChar ++ Anim.getCurFrameName data.anim) ]

        -- Weapon view rendering based on weapon type
        weaponView =
            case data.weapon of
                Weapon.Fan (Just fan) ->
                    [ renderFan fan ]

                Weapon.Cannon cannons ->
                    renderCannonWeapon cannons basedata.position currentTime

                _ ->
                    []

        -- Skill icon related constants and positioning
        cameraPos =
            ( env.globalData.camera.x, env.globalData.camera.y )

        -- Render all skill views at specified position
        skillView =
            renderSkillIcons (Vec.genVec 1650 980) data.skillTree cameraPos

        skillViewPos =
            getWorldPosition ( 1650, 1050 ) ( env.globalData.camera.x, env.globalData.camera.y )

        skillPointsText =
            [ P.textboxCentered skillViewPos 50 ("Skill Points: " ++ String.fromInt env.commonData.skillPoints) "Garet" Color.darkGreen ]

        -- Combine all renderables into a single group
        renderable =
            group
                []
                (characterView
                    ++ weaponView
                    ++ skillView
                    ++ skillPointsText
                )
    in
    ( renderable
    , 0
    )


{-| Renders cannon weapon with charging and firing states
-}
renderCannonWeapon : List Weapon.CannonBall -> Vec.Vec -> Float -> List REGL.Common.Renderable
renderCannonWeapon cannons position currentTime =
    let
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

        chargePreview =
            case List.head chargingCannons of
                Just cannon ->
                    case cannon.state of
                        Weapon.Charging chargeState _ ->
                            Weapon.renderCannonChargePreview position cannon.direction chargeState.chargeTime

                        _ ->
                            []

                Nothing ->
                    []

        firingVisuals =
            renderCannon firingCannons currentTime
    in
    chargePreview ++ firingVisuals


{-| Renders all skill icons at the given position
-}
renderSkillIcons : Vec.Vec -> SkillTree -> ( Float, Float ) -> List REGL.Common.Renderable
renderSkillIcons pos skillTree cameraPos =
    let
        skilliconGap =
            0

        skilliconSize =
            Vec.genVec 120 120

        -- Define icon positions relative to base position
        iconPositions =
            [ ( 1, \p -> getWorldPosition cameraPos ( p.x - 3 * (skilliconSize.x + skilliconGap) / 2, p.y ), "resillence" )
            , ( 2, \p -> getWorldPosition cameraPos ( p.x - (skilliconSize.x + skilliconGap) / 2, p.y ), "quick" )
            , ( 3, \p -> getWorldPosition cameraPos ( p.x + (skilliconSize.x + skilliconGap) / 2, p.y ), "invisible" )
            , ( 4, \p -> getWorldPosition cameraPos ( p.x + 3 * (skilliconSize.x + skilliconGap) / 2, p.y ), "emit" )
            ]

        -- Generic icon rendering function
        renderIcon : Int -> (Vec.Vec -> ( Float, Float )) -> String -> List REGL.Common.Renderable
        renderIcon iconId posFunc iconPrefix =
            case toIconNumber iconId skillTree + 1 of
                0 ->
                    [ P.rectCentered (posFunc pos) (Vec.toTuple (Vec.scale 0.5 skilliconSize)) 0 Color.black
                    , P.textboxCentered (posFunc pos) (skilliconSize.x / 1.6) (String.fromInt iconId) "Garet" Color.darkGreen
                    ]

                n ->
                    [ P.centeredTexture (posFunc pos) (Vec.toTuple skilliconSize) 0 (iconPrefix ++ String.fromInt (n - 1)) ]
    in
    -- Map through all icon definitions and render them
    List.concatMap
        (\( id, posFunc, prefix ) -> renderIcon id posFunc prefix)
        iconPositions


{-| Converts skill level to icon number based on skill type.
This function takes a skill type (1-4) and returns the appropriate icon number (0-2)
based on the current level of that skill in the skill tree.
-}
toIconNumber : Int -> SkillTree -> Int
toIconNumber options skill =
    let
        -- Helper function to determine icon number based on skill value
        getIconForValue : Float -> Int
        getIconForValue value =
            if value >= 0.3 then
                2

            else if value >= 0.2 then
                1

            else if value >= 0.1 then
                0

            else
                -1

        -- Helper function for integer-based levels
        getIconForLevel : Int -> Int
        getIconForLevel level =
            if level >= 3 then
                2

            else if level >= 2 then
                1

            else if level >= 1 then
                0

            else
                -1
    in
    case options of
        1 ->
            getIconForValue skill.resilience

        2 ->
            getIconForValue skill.regeneration

        3 ->
            getIconForValue skill.desensitivity

        4 ->
            getIconForLevel skill.emitLevel

        _ ->
            0


{-| Convert screen coordinates to world coordinates
Takes the camera position and a screen-relative position and returns
the absolute world coordinates.
-}
getWorldPosition : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
getWorldPosition ( screenX, screenY ) ( camx, camy ) =
    ( screenX + camx - 960, screenY + camy - 540 )
