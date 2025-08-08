module Scenes.MainMenu.Home.Model exposing (layer)

{-| Home layer configuration module for the MainMenu scene.

This module defines the main menu's home layer, which displays the game's title screen
and provides options for starting the game, selecting levels, and adjusting settings.

The layer includes functionality for:

  - Menu navigation using keyboard controls
  - Audio control for background music
  - Level selection
  - Volume control
  - Scene transitions to gameplay

@docs layer

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.Resources exposing (..)
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (..)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel as GM exposing (..)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene as Scene
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)
import Scenes.MainMenu.Home.RenderPanels exposing (renderLevelSelectionPanel, renderVolumeControlPanel)
import Scenes.MainMenu.Home.RenderRelated exposing (..)
import Scenes.MainMenu.SceneBase exposing (..)


{-| Initializes the Home layer with default values.

Creates the initial state of the Home layer with:

  - StartBust button selected by default
  - Button not pressed
  - Audio not yet started (will start on first tick)
  - Volume control panel hidden
  - Level selection panel hidden
  - Volume set to 50%

-}
init : LayerInit SceneCommonData UserData LayerMsg Data
init _ _ =
    { selected = StartBust, pressed = False, audioStarted = False, showVolumeControl = False, showLevelSelection = False, volume = 0.5 }


{-| Updates the Home layer in response to events.

Handles various events:

  - Tick events: Starts audio if not already started
  - Key events: Handles menu navigation, selection, and scene transitions
  - Mouse events: Not currently implemented

Returns the updated data, any messages to send, and whether the environment was changed.

-}
update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        -- This helps to check if the audio has started or not, and if not it starts wherever called
        autoStartMsgs =
            if not data.audioStarted then
                [ GM.Parent <| GM.SOMMsg (Scene.SOMStopAudio (AudioName 0 "home")), GM.Parent <| GM.SOMMsg (Scene.SOMPlayAudio 0 "home" <| ALoop Nothing Nothing) ]

            else
                []

        updatedData =
            if not data.audioStarted then
                { data | audioStarted = True }

            else
                data
    in
    case evt of
        Tick _ ->
            if not data.audioStarted then
                ( updatedData, autoStartMsgs, ( env, False ) )

            else
                ( data, [], ( env, False ) )

        KeyDown key ->
            case key of
                38 ->
                    -- Up arrow
                    if updatedData.showLevelSelection then
                        case updatedData.selected of
                            Level2 ->
                                ( { updatedData | selected = Level1 }, autoStartMsgs, ( env, True ) )

                            Level3 ->
                                ( { updatedData | selected = Level2 }, autoStartMsgs, ( env, True ) )

                            _ ->
                                ( updatedData, autoStartMsgs, ( env, False ) )

                    else if not updatedData.showVolumeControl then
                        case updatedData.selected of
                            Levels ->
                                ( { updatedData | selected = StartBust }, autoStartMsgs, ( env, True ) )

                            VolumeControl ->
                                ( { updatedData | selected = Levels }, autoStartMsgs, ( env, True ) )

                            _ ->
                                ( { updatedData | selected = StartBust }, autoStartMsgs, ( env, True ) )

                    else
                        ( updatedData, autoStartMsgs, ( env, False ) )

                40 ->
                    -- Down arrow
                    if updatedData.showLevelSelection then
                        case updatedData.selected of
                            Level1 ->
                                ( { updatedData | selected = Level2 }, autoStartMsgs, ( env, True ) )

                            Level2 ->
                                ( { updatedData | selected = Level3 }, autoStartMsgs, ( env, True ) )

                            _ ->
                                ( updatedData, autoStartMsgs, ( env, False ) )

                    else if not updatedData.showVolumeControl then
                        case updatedData.selected of
                            StartBust ->
                                ( { updatedData | selected = Levels }, autoStartMsgs, ( env, True ) )

                            Levels ->
                                ( { updatedData | selected = VolumeControl }, autoStartMsgs, ( env, True ) )

                            _ ->
                                ( { updatedData | selected = VolumeControl }, autoStartMsgs, ( env, True ) )

                    else
                        ( updatedData, autoStartMsgs, ( env, False ) )

                37 ->
                    -- left arrow, volume control
                    if updatedData.selected == VolumeControl && updatedData.showVolumeControl then
                        let
                            newVolume =
                                max 0.0 (updatedData.volume - 0.1)
                        in
                        ( { updatedData | volume = newVolume }, autoStartMsgs ++ [ GM.Parent <| GM.SOMMsg (Scene.SOMSetVolume newVolume) ], ( env, True ) )

                    else
                        ( updatedData, autoStartMsgs, ( env, False ) )

                39 ->
                    -- right arrow, volume control
                    if updatedData.selected == VolumeControl && updatedData.showVolumeControl then
                        let
                            newVolume =
                                min 1.0 (updatedData.volume + 0.1)
                        in
                        ( { updatedData | volume = newVolume }, autoStartMsgs ++ [ GM.Parent <| GM.SOMMsg (Scene.SOMSetVolume newVolume) ], ( env, True ) )

                    else
                        ( updatedData, autoStartMsgs, ( env, False ) )

                13 ->
                    -- Enter
                    case updatedData.selected of
                        StartBust ->
                            ( updatedData, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "ProtoTest") ], ( env, True ) )

                        Levels ->
                            ( { updatedData
                                | showLevelSelection = not updatedData.showLevelSelection
                                , selected =
                                    if updatedData.showLevelSelection then
                                        Levels

                                    else
                                        Level1
                              }
                            , autoStartMsgs
                            , ( env, True )
                            )

                        VolumeControl ->
                            ( { updatedData
                                | showVolumeControl = not updatedData.showVolumeControl
                                , selected =
                                    if updatedData.showVolumeControl then
                                        VolumeControl

                                    else
                                        VolumeControl
                              }
                            , autoStartMsgs
                            , ( env, True )
                            )

                        Level1 ->
                            ( updatedData, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "ProtoTest") ], ( env, True ) )

                        Level2 ->
                            ( updatedData, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "Level2") ], ( env, True ) )

                        Level3 ->
                            ( updatedData, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "Level3") ], ( env, True ) )

                27 ->
                    if updatedData.showVolumeControl then
                        ( { updatedData | showVolumeControl = False, selected = VolumeControl }, autoStartMsgs, ( env, True ) )

                    else if updatedData.showLevelSelection then
                        ( { updatedData | showLevelSelection = False, selected = Levels }, autoStartMsgs, ( env, True ) )

                    else
                        ( updatedData, autoStartMsgs, ( env, False ) )

                _ ->
                    ( updatedData, autoStartMsgs, ( env, False ) )

        _ ->
            ( updatedData, autoStartMsgs, ( env, False ) )


{-| Record-based update function for the Home layer.
-}
updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


{-| Renders the Home layer of the main menu.

Creates the visual elements of the main menu including:

  - Black background for the screen
  - Game logo at the top
  - Menu buttons for "new game", "levels", and "options"
  - Volume control panel (shown conditionally)
  - Level selection panel (shown conditionally)

The layout positions elements vertically in the center of the screen.

-}
view : LayerView SceneCommonData UserData Data
view _ data =
    group []
        [ P.rect ( 0, 0 ) ( 1920, 1080 ) black
        , renderLogo
        , group [] (renderMenuButton -20 StartBust "new game." data)
        , group [] (renderMenuButton 40 Levels "levels." data)
        , group [] (renderMenuButton 100 VolumeControl "options." data)
        , renderVolumeControlPanel data
        , renderLevelSelectionPanel data
        ]


{-| Determines if this layer should process a message targeted at the given layer.

Returns true only if the target layer is "Home", ignoring the data parameter.
This ensures that messages intended for the Home layer are properly routed.

-}
matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "Home"


{-| Concrete layer configuration that combines all Home layer components.
-}
layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator that creates the Home layer for the MainMenu scene.
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
