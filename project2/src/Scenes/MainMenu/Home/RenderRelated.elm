module Scenes.MainMenu.Home.RenderRelated exposing
    ( Data, Button(..)
    , renderMenuButton, renderLogo, renderSelectHighlight
    , getButtonScale, getButtonColor
    )

{-| Rendering utilities for the MainMenu's Home layer.

This module contains types and core functions related to rendering the main menu interface.
It defines the menu button types, rendering functions for basic elements like buttons and logo,
and utility functions for calculating button appearance based on selection state.

Panel rendering functions have been moved to RenderPanels.elm.


# Types

@docs Data, Button


# Core Rendering Functions

@docs renderMenuButton, renderLogo, renderSelectHighlight


# Utility Functions

@docs getButtonScale, getButtonColor

-}

import Color exposing (..)
import Lib.Resources exposing (..)
import Messenger.Audio.Base exposing (..)
import Messenger.Base exposing (UserEvent(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)
import Scenes.MainMenu.SceneBase exposing (..)


{-| Data structure for the Home layer's state.

  - selected - Currently selected menu button
  - pressed - Whether a button is currently being pressed
  - audioStarted - Whether the background music has started playing
  - showVolumeControl - Whether the volume control panel is visible
  - showLevelSelection - Whether the level selection panel is visible
  - volume - Current audio volume (0.0 to 1.0)

-}
type alias Data =
    { selected : Button
    , pressed : Bool
    , audioStarted : Bool
    , showVolumeControl : Bool
    , showLevelSelection : Bool
    , volume : Float
    }


{-| Types of buttons in the main menu.

  - StartBust - Button to start a new game
  - Levels - Button to open the level selection panel
  - VolumeControl - Button to open the volume control panel
  - Level1 - Button to start level 1
  - Level2 - Button to start level 2
  - Level3 - Button to start level 3

-}
type Button
    = StartBust
    | Levels
    | VolumeControl
    | Level1
    | Level2
    | Level3


{-| Calculates the scale factor for a button based on its selection state.

  - Returns 1.2 (20% larger) if the button is currently selected
  - Returns 1.0 (normal size) if the button is not selected
  - Used to visually highlight the currently selected menu option

-}
getButtonScale : Button -> Data -> Float
getButtonScale sel data =
    if data.selected == sel then
        1.2

    else
        1.0


{-| Determines the color for a button based on its selection state.

  - Returns green (RGB 0,1,0) if the button is currently selected
  - Returns white (RGB 1,1,1) if the button is not selected
  - Used to visually highlight the currently selected menu option

-}
getButtonColor : Button -> Data -> Color
getButtonColor sel data =
    if data.selected == sel then
        rgb 0 1 0

    else
        rgb 1 1 1


{-| Renders a menu button with text and selection highlight.

Creates a renderable list containing:

  - A selection highlight (if the button is selected)
  - Text with the button label

Parameters:

  - offsetY - Vertical offset from the center of the screen
  - sel - The button type to render
  - label - The text to display on the button
  - data - Current state data to determine selection status

-}
renderMenuButton : Float -> Button -> String -> Data -> List Renderable
renderMenuButton offsetY sel label data =
    [ renderSelectHighlight sel offsetY data
    , P.textbox
        ( 960 - 100, 540 + offsetY )
        (48 * getButtonScale sel data)
        label
        "Garet"
        (getButtonColor sel data)
    ]


{-| Renders the game logo in the upper portion of the main menu.

Creates a texture-based renderable displaying the game logo:

  - Positioned at coordinates (1150, 280)
  - With dimensions 1275x461 pixels
  - No rotation (0 degrees)
  - Full opacity (1.0)
  - Using the "gamelogo" texture resource

-}
renderLogo : Renderable
renderLogo =
    P.centeredTextureWithAlpha
        ( 1150, 280 )
        ( 1275, 461 )
        0
        1
        "gamelogo"


{-| Renders a highlight texture behind the currently selected menu button.

Creates a visual indicator for the currently selected menu item:

  - Uses the "select" texture resource
  - Positions the highlight relative to the button's position with the given vertical offset
  - Scales the highlight to 146x23 pixels multiplied by a factor of 1.5
  - Returns an empty group if the button is not currently selected

Parameters:

  - sel - The button to potentially highlight
  - offsetY - Vertical offset from the center of the screen
  - data - Current state data to determine if this button is selected

-}
renderSelectHighlight : Button -> Float -> Data -> Renderable
renderSelectHighlight sel offsetY data =
    if data.selected == sel then
        P.centeredTextureWithAlpha
            ( 960 - 20, 540 + 35 + offsetY )
            ( 146 * 1.5, 23 * 1.5 )
            0
            1
            "select"

    else
        group [] []
