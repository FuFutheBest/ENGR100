module Scenes.MainMenu.Home.RenderPanels exposing
    ( renderVolumeControlPanel, renderLevelSelectionPanel
    , renderLevelButton, renderLevelHighlight, renderVolumeSlider, renderVolumeControlHighlight
    )

{-| Panel rendering utilities for the MainMenu's Home layer.

This module contains functions related to rendering the modal panels in the main menu interface,
such as the volume control panel and level selection panel.


# Panel Rendering Functions

@docs renderVolumeControlPanel, renderLevelSelectionPanel


# Panel Component Rendering Functions

@docs renderLevelButton, renderLevelHighlight, renderVolumeSlider, renderVolumeControlHighlight

-}

import Color exposing (..)
import Lib.Resources exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)
import Scenes.MainMenu.Home.RenderRelated exposing (Button(..), Data, getButtonColor, getButtonScale)


{-| Renders the volume control panel when it should be visible.

Creates a modal panel for adjusting the game's audio volume:

  - Semi-transparent background overlay to dim the main menu
  - Panel with border and background
  - Volume slider with color-coded indicator (green for low volume, yellow for medium, red for high)
  - Text showing the current volume percentage
  - Instructions for using the controls
  - Returns an empty group if the panel should not be visible

Parameters:

  - data - Current state data determining visibility and volume level

-}
renderVolumeControlPanel : Data -> Renderable
renderVolumeControlPanel data =
    if data.showVolumeControl then
        let
            color =
                if data.volume < 0.7 then
                    Color.green

                else if data.volume < 0.9 then
                    Color.yellow

                else
                    Color.red

            sliderColor =
                color

            handleColor =
                color

            volumePercentage =
                String.fromInt (round (data.volume * 100)) ++ "%"
        in
        group []
            [ -- Semi-transparent background
              P.rect ( 0, 0 ) ( 1920, 1080 ) (rgba 0 0 0 0.82)

            -- Volume control panel background
            , P.rect ( 660, 600 ) ( 600, 200 ) (rgb 0.2 0.2 0.3)

            -- Panel border
            , P.rect ( 658, 598 ) ( 604, 204 ) (rgb 0.4 0.4 0.5)
            , P.rect ( 660, 600 ) ( 600, 200 ) (rgb 0.2 0.2 0.3)

            -- Volume label
            , P.textboxCentered ( 960, 625 ) 36 "Volume Control" "Bebas" (rgb 1 1 1)

            -- , P.textbox ( 960 - 80, 615 ) 36 "Volume Controls" "Bebas" (rgb 1 1 1)
            -- Volume slider components
            , renderVolumeSlider data sliderColor handleColor
            , P.textboxCentered ( 960, 715 ) 42 volumePercentage "Bebas" (rgb 0.8 0.8 0.8)
            , P.textboxCentered ( 960, 770 ) 24 "Use Left/Right to adjust volume " "Garet" (rgb 0.6 0.6 0.6)
            , P.textbox ( 50, 50 ) 36 " Press ESC or ENTER to close" "Bebas" (rgb 0.9 0.8 0.7)
            , renderVolumeControlHighlight data
            ]

    else
        group [] []


{-| Renders the level selection panel when it should be visible.

Creates a modal panel for selecting game levels:

  - Semi-transparent background overlay to dim the main menu
  - Panel with border and background
  - Title text "Select Level"
  - Three level buttons (Level 1, Level 2, Level 3)
  - Navigation instructions
  - ESC key instruction to close the panel
  - Returns an empty group if the panel should not be visible

Parameters:

  - data - Current state data determining visibility and selected level

-}
renderLevelSelectionPanel : Data -> Renderable
renderLevelSelectionPanel data =
    if data.showLevelSelection then
        group []
            [ -- Semi-transparent background
              P.rect ( 0, 0 ) ( 1920, 1080 ) (rgba 0 0 0 0.82)

            -- Level selection panel background
            , P.rect ( 660, 500 ) ( 600, 300 ) (rgb 0.2 0.2 0.3)

            -- Panel border
            , P.rect ( 658, 498 ) ( 604, 304 ) (rgb 0.4 0.4 0.5)
            , P.rect ( 660, 500 ) ( 600, 300 ) (rgb 0.2 0.2 0.3)

            -- Level selection label
            , P.textboxCentered ( 960, 530 ) 36 "Select Level" "Bebas" (rgb 1 1 1)

            -- Level buttons
            , group [] (renderLevelButton 580 Level1 "Level 1" data)
            , group [] (renderLevelButton 630 Level2 "Level 2" data)
            , group [] (renderLevelButton 680 Level3 "Level 3" data)

            -- Instructions
            , P.textboxCentered ( 960, 750 ) 24 "Use Up/Down to navigate, Enter to select" "Garet" (rgb 0.6 0.6 0.6)
            , P.textbox ( 50, 50 ) 36 " Press ESC to close" "Bebas" (rgb 0.9 0.8 0.7)
            ]

    else
        group [] []


{-| Renders a level selection button within the level selection panel.

Creates a renderable list containing:

  - A highlight background if the level is currently selected
  - Text with the level name (e.g., "Level 1")

The button's appearance changes based on whether it's currently selected:

  - Selected buttons appear larger and green
  - Non-selected buttons appear at normal size and white

Parameters:

  - yPos - Vertical position for the button
  - levelButton - The button type (Level1, Level2, or Level3)
  - label - The text to display on the button
  - data - Current state data to determine selection status

-}
renderLevelButton : Float -> Button -> String -> Data -> List Renderable
renderLevelButton yPos levelButton label data =
    [ renderLevelHighlight levelButton yPos data
    , P.textboxCentered ( 960, yPos ) (36 * getButtonScale levelButton data) label "Garet" (getButtonColor levelButton data)
    ]


{-| Renders a highlight background for a selected level button.

Creates a semi-transparent green rectangle behind the currently selected level button:

  - Rectangle positioned horizontally at 700 and vertically relative to the button position
  - Rectangle dimensions 520x40 pixels
  - Semi-transparent green color (rgba 0 1 0 0.2)
  - Returns an empty group if the level button is not currently selected

Parameters:

  - levelButton - The button to potentially highlight
  - yPos - Vertical position of the button
  - data - Current state data to determine if this button is selected

-}
renderLevelHighlight : Button -> Float -> Data -> Renderable
renderLevelHighlight levelButton yPos data =
    if data.selected == levelButton then
        P.rect ( 700, yPos - 15 ) ( 520, 40 ) (rgba 0 1 0 0.2)

    else
        group [] []


{-| Renders a volume slider control with background, fill, and handle.

Creates a visual representation of the current volume level with three components:

  - Background: A light pink/beige bar (rgb 1 0.8 0.86) showing the full slider range
  - Fill: A colored bar that fills from left to right based on the current volume value
  - Handle: A small rectangle that moves along the slider to indicate the current position

The colors of the fill and handle change based on the volume level:

  - Green for lower volumes (< 70%)
  - Yellow for medium volumes (70-90%)
  - Red for high volumes (> 90%)

Parameters:

  - data - Current state data containing the volume value (0.0 to 1.0)
  - sliderColor - Color for the slider fill bar (changes based on volume)
  - handleColor - Color for the slider handle (changes based on volume)

-}
renderVolumeSlider : Data -> Color -> Color -> Renderable
renderVolumeSlider data sliderColor handleColor =
    group []
        [ -- Volume slider background
          P.rect ( 760, 665 ) ( 400, 10 ) (rgb 1 0.8 0.86)

        -- Volume slider fill
        , P.rect ( 760, 665 ) ( 400 * data.volume, 10 ) sliderColor

        -- Volume slider handle
        , P.rect ( 760 + (400 * data.volume) - 5, 660 ) ( 10, 20 ) handleColor
        ]


{-| Renders a highlight around the volume control when it's selected in the menu.

Creates a semi-transparent green rectangle around the volume slider:

  - Rectangle positioned at coordinates (750, 655)
  - Rectangle dimensions 420x30 pixels
  - Semi-transparent green color (rgba 0 1 0 0.2)
  - Only shown when the VolumeControl button is selected in the main menu
  - Returns an empty group if VolumeControl is not selected

Parameters:

  - data - Current state data to determine if VolumeControl is selected

-}
renderVolumeControlHighlight : Data -> Renderable
renderVolumeControlHighlight data =
    if data.selected == VolumeControl then
        P.rect ( 750, 655 ) ( 420, 30 ) (rgba 0 1 0 0.2)

    else
        group [] []
