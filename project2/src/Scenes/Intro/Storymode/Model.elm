module Scenes.Intro.Storymode.Model exposing (layer)

{-| Storymode layer configuration module

This module implements the storymode layer for the intro scene, which displays
an animated story sequence with logos, house, phone call, and dialogue.

The storymode layer handles:

  - Logo animation with blinking effects
  - Background particle effects
  - Animated house with blinking lights
  - Phone call sequence with ringing and pickup animations
  - Dialogue text appearing during the phone conversation
  - Automatic transition to MainMenu after completion
  - Manual skip functionality with space key


# Layer Configuration

@docs layer

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.Resources exposing (..)
import Lib.UserData exposing (UserData)
import Lib.Utils.Par exposing (..)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel as GM exposing (Matcher)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene as Scene
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import Scenes.Intro.SceneBase exposing (..)
import Scenes.Intro.Storymode.Constants as C
import Scenes.Intro.Storymode.Utils exposing (..)


{-| Data model for the Storymode layer

This record holds all the state needed for the storymode animation sequence.

  - `startTime`: Timestamp when the layer was initialized (in milliseconds)
    Used as the reference point for all animation timing calculations.
  - `particles`: List of background particle effects currently active
    Each particle has its own position, velocity, and lifetime properties.

-}
type alias Data =
    { startTime : Float
    , particles : List Particle
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env _ =
    { startTime = env.globalData.currentTimeStamp
    , particles = []
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case evt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                elapsedTime =
                    env.globalData.currentTimeStamp - data.startTime

                updatedParticles =
                    List.map (\p -> updateParticle dSec p) data.particles
                        |> List.filter (\p -> p.t < p.life)

                bgParticles1 =
                    genParticles
                        ( 960, 1200 )
                        env.globalData.currentTimeStamp
                        (rgba 0 0.5 0.1 1)
                        (rgba 0 0 0 1)
                        ( 1920, 100 )
                        -- boxsize
                        ( 0, -100 )
                        -- initial velocity
                        ( 100, 0 )
                        -- velocity
                        0.2
                        -- rotation speed
                        70
                        -- initial scale
                        15
                        -- final scale
                        6
                        -- life in seconds [^] | particle count [v]
                        1
            in
            if elapsedTime > C.dialogueCompleteTime then
                ( { data | particles = updatedParticles ++ bgParticles1 }, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "MainMenu") ], ( env, False ) )

            else
                ( { data | particles = updatedParticles ++ bgParticles1 }, [], ( env, False ) )

        KeyDown key ->
            case key of
                32 ->
                    -- Space key - skip to MainMenu
                    ( data, [ GM.Parent <| GM.SOMMsg (Scene.SOMChangeScene Nothing "MainMenu") ], ( env, False ) )

                _ ->
                    ( data, [], ( env, False ) )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env _ data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        cam =
            env.globalData.camera

        campos =
            ( cam.x, cam.y )

        currentTime =
            env.globalData.currentTimeStamp

        animations =
            calculateAnimationValues currentTime data.startTime

        particleRenderable =
            renderParticles animations.elapsedTime animations.particleFadeProgress data.particles campos

        fadedLogo =
            renderLogo animations.fadeProgress animations.logoAlpha animations.yOffset animations.currentTexture

        fadedText =
            renderText animations.combinedTextAlpha animations.yOffset

        houseRenderable =
            renderHouse animations.houseFadeProgress animations.houseTexture

        phoneRenderable =
            renderPhone animations.phoneFadeProgress animations.phoneTexture

        dialogues =
            renderDialogues animations.phoneFadeProgress animations.elapsedTime
    in
    group []
        [ P.rect ( -100, -100 ) ( 1920 * 2, 1080 * 2 ) animations.backgroundColor
        , particleRenderable
        , fadedLogo
        , fadedText
        , houseRenderable
        , phoneRenderable
        , dialogues
        ]


matcher : Matcher Data LayerTarget
matcher _ tar =
    tar == "Storymode"


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
