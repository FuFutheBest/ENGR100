module Scenes.EndScreen.AfterDeath.Model exposing (layer)

{-| After Death layer configuration module

This module implements the after-death screen layer that appears when the player dies.
It provides a game over interface with options to restart or return to the main menu.

The layer features:

  - Death message display with "You died." text
  - Dead character icon visualization
  - Menu navigation with "new game" and "main menu" options
  - Keyboard controls (arrow keys for navigation, enter for selection)
  - Background particle effects (red blood-like particles falling down)
  - Visual feedback for selected menu items (highlighting and scaling)


# Layer Configuration

@docs layer

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Par exposing (Particle, genParticles, renderParticle, updateParticle)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel as GM exposing (Matcher)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene as Scene
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)
import Scenes.EndScreen.SceneBase exposing (..)


{-| Button selection type for the after-death menu

Represents the available menu options that the player can select.

  - `NewGame` -- Restart the game from the beginning
    When selected, this option will transition to the "ProtoTest" scene to start a new game.
  - `MainMenu` -- Return to the main menu
    When selected, this option will transition back to the "MainMenu" scene.

Example:

    -- Player selects to restart
    selectedButton =
        NewGame

    -- Player selects to go back
    selectedButton =
        MainMenu

-}
type Button
    = NewGame
    | MainMenu


{-| Data model for the AfterDeath layer

This record holds all the state needed for the after-death screen.

  - `selected`: Current menu button selection (NewGame or MainMenu)
    Tracks which option is currently highlighted and will be activated on Enter press.
    Default is NewGame to encourage players to retry.
  - `particles`: List of background particle effects currently active
    Contains red blood-like particles that fall down the screen to create atmosphere.
    Each particle has position, velocity, color, and lifetime properties.

Example:

    { selected = NewGame -- New game option is highlighted
    , particles = [] -- No particles initially
    }

-}
type alias Data =
    { selected : Button
    , particles : List Particle
    }


{-| Initialize the AfterDeath layer data

Sets up the initial state for the after-death screen with default selection
and empty particle list.

Parameters:

  - env: Environment data (unused)
  - initMsg: Initialization message (unused)

Returns:

  - Data: Initial layer state with NewGame selected and no particles

-}
init : LayerInit SceneCommonData UserData LayerMsg Data
init _ _ =
    { selected = NewGame
    , particles = []
    }


{-| Main update function for the AfterDeath layer

Handles user input events and particle system updates.

-}
update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case evt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                updatedParticles =
                    List.map (\p -> updateParticle dSec p) data.particles
                        |> List.filter (\p -> p.t < p.life)

                bgParticles1 =
                    genParticles
                        ( 960, 1400 )
                        env.globalData.currentTimeStamp
                        (rgba 1 0 0 0.4)
                        (rgba 0 0 0 1)
                        ( 1920, 100 )
                        -- boxsize
                        ( 0, -100 )
                        -- initial velocity
                        ( 200, 0 )
                        -- velocity
                        0.2
                        -- rotation speed
                        70
                        -- initial scale
                        15
                        -- final scale
                        2
                        -- life in seconds [^] | particle count [v]
                        1
            in
            ( { data | particles = updatedParticles ++ bgParticles1 }, [], ( env, False ) )

        KeyDown key ->
            case key of
                38 ->
                    -- Up arrow
                    ( { data | selected = NewGame }, [], ( env, False ) )

                40 ->
                    -- Down arrow
                    ( { data | selected = MainMenu }, [], ( env, False ) )

                13 ->
                    -- Enter key - handle navigation based on selection
                    case data.selected of
                        NewGame ->
                            ( data, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "ProtoTest") ], ( env, False ) )

                        MainMenu ->
                            ( data, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "MainMenu") ], ( env, False ) )

                _ ->
                    ( data, [], ( env, False ) )

        _ ->
            ( data, [], ( env, False ) )


{-| Update function for handling layer message updates

Handles recursive layer updates. Currently no special processing is needed.

-}
updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env _ data =
    ( data, [], env )


{-| View rendering function for the AfterDeath layer

Renders the complete after-death screen including:

  - Black background
  - Falling red particle effects
  - "dead" character icon (scaled 8x)
  - "You died." message in red text
  - Navigation menu with "new game" and "main menu" options
      - Visual highlighting for selected menu item (green color, larger scale, selection indicator)

The view uses camera position for particle rendering and provides visual feedback
for the currently selected menu option through color changes and scaling.

-}
view : LayerView SceneCommonData UserData Data
view env data =
    let
        cam =
            env.globalData.camera

        campos =
            ( cam.x, cam.y )

        getButtonScale button =
            if data.selected == button then
                1.2

            else
                1.0

        getButtonColor button =
            if data.selected == button then
                rgb 0 1 0
                -- Green for selected

            else
                white

        renderSelectHighlight button offsetY =
            if data.selected == button then
                P.centeredTextureWithAlpha
                    ( 960 - 20, 700 + 35 + offsetY )
                    ( 146 * 1.5, 23 * 1.5 )
                    0
                    1
                    "select"

            else
                group [] []

        particleRenderable =
            group [] (List.map (\p -> renderParticle p campos) data.particles)
    in
    group []
        [ P.rect ( 0, 0 ) ( 1920, 1080 ) black
        , particleRenderable
        , renderSelectHighlight NewGame 0
        , P.textbox
            ( 860, 700 )
            (48 * getButtonScale NewGame)
            "new game."
            "Garet"
            (getButtonColor NewGame)
        , renderSelectHighlight MainMenu 70
        , P.textbox
            ( 860, 770 )
            (48 * getButtonScale MainMenu)
            "main menu."
            "Garet"
            (getButtonColor MainMenu)
        , P.centeredTextureWithAlpha
            ( 960, 280 )
            ( 32 * 8, 32 * 8 )
            0
            1
            "dead"
        , P.textboxCentered
            ( 960, 480 )
            300
            "You died."
            "Garet"
            Color.red
        ]


{-| Layer matcher function

Determines if this layer should handle messages targeted at "AfterDeath".

-}
matcher : Matcher Data LayerTarget
matcher _ tar =
    tar == "AfterDeath"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
