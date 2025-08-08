module SceneProtos.GameProto.MainLayer.UI exposing
    ( UIData, initUIData, updateUIData
    , viewUI, viewUIAt, generateHPBar, generateMPBar
    , getWorldPosition, createBarConfig
    )

{-| UI module for GameProto scene
This module handles all UI related rendering and state updates
including health bars, mana bars, and UI animations.

UI elements are positioned relative to the screen and camera.


# UI Data

@docs UIData, initUIData, updateUIData


# Rendering

@docs viewUI, viewUIAt, generateHPBar, generateMPBar


# Helpers

@docs getWorldPosition, createBarConfig

-}

import Color
import Lib.Utils.Spring as Spring exposing (Spring)
import Lib.Utils.Vec exposing (Vec)
import REGL.BuiltinPrograms as P
import REGL.Common
import REGL.Compositors as C


{-| UI data structure containing all state for UI rendering
-}
type alias UIData =
    { heartSpring : Spring -- Spring animation for heart icon
    , heartTimer : Float -- Timer for heart animation
    , heartTimer2 : Float -- Second timer for heart animation
    , playerHP : Float -- Current player health
    , maxplayerHP : Float -- Maximum player health
    , playerMP : Float -- Current player mana
    , maxplayerMP : Float -- Maximum player mana
    , uiColor : String -- Color theme for UI ("y" or "b")
    }


{-| Initialize UI data with default values
-}
initUIData : UIData
initUIData =
    { heartSpring = Spring 1000 0 (Vec 0 0) (Vec 0 0)
    , heartTimer = 0
    , heartTimer2 = 0.25
    , maxplayerHP = 100
    , playerHP = 100
    , playerMP = 50
    , maxplayerMP = 100
    , uiColor = "y"
    }


{-| Update the heart timer and spring animation
This helper function handles the timing and spring physics for heart animations
-}
updateHeartTimer : Float -> Float -> Spring -> Vec -> ( Float, Spring )
updateHeartTimer currentTimer deltaTime currentSpring resetVec =
    if currentTimer + deltaTime > 1.0 then
        ( 0, Spring 1000 0 resetVec (Vec 0 0) )

    else
        ( currentTimer + deltaTime, currentSpring |> Spring.bounceSpring deltaTime (Vec 0 0) )


{-| Update UI data based on delta time
Updates all animated components of the UI including heart animations
-}
updateUIData : UIData -> Float -> UIData
updateUIData uiData deltaTime =
    let
        ( newHeartTimer, newHeartSpring ) =
            updateHeartTimer uiData.heartTimer deltaTime uiData.heartSpring (Vec 7 0)

        ( newHeartTimer2, newHeartSpring2 ) =
            updateHeartTimer uiData.heartTimer2 deltaTime newHeartSpring (Vec 4 0)
    in
    { uiData
        | heartSpring = newHeartSpring2
        , heartTimer = newHeartTimer
        , heartTimer2 = newHeartTimer2
    }


{-| Convert screen coordinates to world coordinates
-}
getWorldPosition : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
getWorldPosition ( screenX, screenY ) ( camx, camy ) =
    ( screenX + camx - 960, screenY + camy - 540 )


{-| Bar dimension configuration record
-}
type alias BarConfig =
    { xOffset : Float
    , yOffset : Float
    , width : Float
    , height : Float
    }


{-| Generate a bar with customizable dimensions based on current and maximum values
This helper reduces code duplication between HP and MP bar generation
-}
generateBar :
    ( Float, Float )
    ->
        -- Screen position
        ( Float, Float )
    ->
        -- Camera position
        ( Float, Float )
    ->
        -- Current and max values
        Bool
    ->
        -- True for horizontal (HP), False for vertical (MP)
        BarConfig
    ->
        -- Positioning offsets and dimensions
        REGL.Common.Renderable
generateBar screenPos ( camx, camy ) ( current, max ) isHorizontal config =
    let
        ( worldX, worldY ) =
            getWorldPosition screenPos ( camx, camy )

        -- Calculate size based on ratio
        ratio =
            current / max

        -- Position and size depend on bar orientation
        barX =
            worldX + config.xOffset

        barY =
            if isHorizontal then
                worldY + config.yOffset

            else
                let
                    yAdjustment =
                        config.height - (config.height * ratio)
                in
                worldY + config.yOffset + yAdjustment

        barWidth =
            if isHorizontal then
                config.width * ratio

            else
                config.width

        barHeight =
            if isHorizontal then
                config.height

            else
                config.height * ratio
    in
    P.rect ( barX, barY ) ( barWidth, barHeight ) Color.white


{-| Create a bar configuration based on type
This helper function creates configuration for either HP or MP bars
-}
createBarConfig : Bool -> BarConfig
createBarConfig isHPBar =
    let
        baseXOffset =
            -38 * 3

        baseYOffset =
            -46 * 3

        standardHeight =
            19 * 3
    in
    if isHPBar then
        -- HP bar configuration (horizontal)
        { xOffset = baseXOffset
        , yOffset = baseYOffset
        , width = 58 * 3
        , height = standardHeight
        }

    else
        -- MP bar configuration (vertical)
        { xOffset = baseXOffset
        , yOffset = baseYOffset + 21 * 3
        , width = 76 * 3
        , height = standardHeight
        }


{-| Generate HP bar based on current and maximum HP
-}
generateHPBar : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> REGL.Common.Renderable
generateHPBar screenPos cameraPos ( curHP, maxHP ) =
    -- HP bar is horizontal
    generateBar screenPos cameraPos ( curHP, maxHP ) True (createBarConfig True)


{-| Generate MP bar based on current and maximum MP
-}
generateMPBar : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> REGL.Common.Renderable
generateMPBar screenPos cameraPos ( curMP, maxMP ) =
    -- MP bar is vertical
    generateBar screenPos cameraPos ( curMP, maxMP ) False (createBarConfig False)


{-| Render UI at the default position
This is a convenience function that renders the UI at a fixed position (200, 900)
-}
viewUI : UIData -> ( Float, Float ) -> List REGL.Common.Renderable
viewUI uiData cameraPos =
    viewUIAt ( 200, 900 ) uiData cameraPos


{-| Render UI at a specified screen position
This function allows rendering the UI at any position on the screen,
which is useful for custom UI layouts or multiple UI instances.
-}
viewUIAt : ( Float, Float ) -> UIData -> ( Float, Float ) -> List REGL.Common.Renderable
viewUIAt screenPos uiData ( camx, camy ) =
    let
        heartIconOffsetX =
            85.5

        heartIconOffsetY =
            -119

        mpBarOffsetY =
            15

        ( worldX, worldY ) =
            getWorldPosition screenPos ( camx, camy )

        ( heartIconX, heartIconY ) =
            getWorldPosition ( screenPos |> Tuple.first |> (+) heartIconOffsetX, screenPos |> Tuple.second |> (+) heartIconOffsetY ) ( camx, camy )
    in
    [ P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 0.7 "ui_bg"
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 "ui_hpempty"
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 "ui_hp"
    , P.centeredTextureCroppedWithAlpha ( heartIconX, heartIconY ) ( (11 + uiData.heartSpring.pos.x) * 3, (11 + uiData.heartSpring.pos.x) * 3 ) 0 ( 87 / 128, 98 / 128 ) ( 11 / 128, 11 / 128 ) 1 "ui_hpicon"
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 "ui_hpfull"
        |> C.maskBySrc (generateHPBar screenPos ( camx, camy ) ( uiData.playerHP, uiData.maxplayerHP ))
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 "ui_mpempty"
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 ("ui_mp" ++ uiData.uiColor)
        |> C.maskBySrc (generateMPBar screenPos ( camx, camy ) ( uiData.playerMP, uiData.maxplayerMP ))
    , P.centeredTextureWithAlpha ( worldX, worldY + mpBarOffsetY ) ( 128 * 3, 128 * 3 ) 0 1 "ui_mp"
    , P.centeredTextureWithAlpha ( worldX, worldY ) ( 128 * 3, 128 * 3 ) 0 1 ("ui_" ++ uiData.uiColor)
    ]
