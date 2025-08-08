module Scenes.Intro.Storymode.Utils exposing (calculateAnimationValues, renderDialogues, renderHouse, renderLogo, renderParticles, renderPhone, renderText)

{-|

    # Storymode Utils
    This module contains utility functions for the Storymode scene in the Intro.

    It includes functions to calculate animation values and render various elements like particles, logo, text, house, and phone.

    @docs calculateAnimationValues, renderParticles, renderLogo, renderText, renderHouse, renderPhone, renderDialogues

-}

import Color exposing (..)
import Lib.Resources exposing (..)
import Lib.Utils.Par exposing (..)
import Messenger.Base exposing (UserEvent(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import REGL.Compositors as Comp
import Scenes.Intro.SceneBase exposing (..)
import Scenes.Intro.Storymode.Animation as Anim
import Scenes.Intro.Storymode.Constants as C


{-| Calculate all animation values based on the current time and start time.

    This function computes various animation progress values, alpha levels, and textures
    based on the elapsed time since the start of the scene.

    @param currentTime - The current timestamp in milliseconds.
    @param startTime - The timestamp when the scene started in milliseconds.
    @return A record containing all calculated animation values.

-}
calculateAnimationValues : Float -> Float -> { elapsedTime : Float, fadeProgress : Float, logoAlpha : Float, particleFadeProgress : Float, houseFadeProgress : Float, phoneFadeProgress : Float, yOffset : Float, combinedTextAlpha : Float, currentTexture : String, houseTexture : String, phoneTexture : String, backgroundColor : Color }
calculateAnimationValues currentTime startTime =
    let
        elapsedTime =
            currentTime - startTime

        fadeProgress =
            min 1.0 (elapsedTime / C.fadeInDuration)

        logoAlpha =
            Anim.calculateLogoAlpha elapsedTime

        particleFadeProgress =
            Anim.calculateParticleFade elapsedTime

        houseFadeProgress =
            Anim.calculateHouseFade elapsedTime

        phoneFadeProgress =
            Anim.calculatePhoneFade elapsedTime

        yOffset =
            Anim.calculateYOffset elapsedTime

        currentTexture =
            Anim.getCurrentTexture elapsedTime

        houseTexture =
            Anim.getHouseTexture elapsedTime houseFadeProgress

        phoneTexture =
            Anim.getPhoneTexture elapsedTime phoneFadeProgress

        backgroundColor =
            Anim.getBackgroundColor elapsedTime

        combinedTextAlpha =
            Anim.calculateTextAlpha elapsedTime fadeProgress
    in
    { elapsedTime = elapsedTime
    , fadeProgress = fadeProgress
    , logoAlpha = logoAlpha
    , particleFadeProgress = particleFadeProgress
    , houseFadeProgress = houseFadeProgress
    , phoneFadeProgress = phoneFadeProgress
    , yOffset = yOffset
    , combinedTextAlpha = combinedTextAlpha
    , currentTexture = currentTexture
    , houseTexture = houseTexture
    , phoneTexture = phoneTexture
    , backgroundColor = backgroundColor
    }


{-|

    Render particles based on elapsed time and fade progress.

    This function creates a renderable group of particles that fade in and out
    based on the elapsed time since the scene started.

    @param elapsedTime - The time elapsed since the scene started in milliseconds.
    @param particleFadeProgress - The fade progress for particles from 0.0 to 1.0.
    @param particles - The list of particles to render.
    @param campos - The camera position as a tuple (x, y).
    @return A Renderable object containing the rendered particles.

-}
renderParticles : Float -> Float -> List Particle -> ( Float, Float ) -> Renderable
renderParticles elapsedTime particleFadeProgress particles campos =
    if elapsedTime > C.particleFadeStart then
        let
            baseParticles =
                group [] (List.map (\p -> renderParticle p campos) particles)
        in
        Comp.linearFade particleFadeProgress (P.clear (rgba 0 0 0 0)) baseParticles

    else
        group [] []


{-| Render a single particle with fade effect.

    This function creates a renderable object for a single particle,
    applying a fade effect based on the elapsed time and camera position.

    @param particle - The Particle object to render.
    @param campos - The camera position as a tuple (x, y).
    @return A Renderable object for the particle.

-}
renderLogo : Float -> Float -> Float -> String -> Renderable
renderLogo fadeProgress logoAlpha yOffset currentTexture =
    let
        logoRenderable =
            P.centeredTextureWithAlpha ( 960, 540 + yOffset ) ( 206, 276 ) 0 logoAlpha currentTexture
    in
    Comp.linearFade fadeProgress (P.clear black) logoRenderable


{-|

    Render the introductory text with fade effect.

    This function creates a renderable object for the introductory text,
    applying a fade effect based on the combined text alpha and yOffset.

    @param combinedTextAlpha - The alpha value for the text fade effect.
    @param yOffset - The vertical offset for positioning the text.
    @return A Renderable object containing the rendered text.

-}
renderText : Float -> Float -> Renderable
renderText combinedTextAlpha yOffset =
    let
        textRenderable =
            group []
                [ P.textbox ( 880, 700 + yOffset ) 48 "Presents" "Bebas" black
                , P.textbox ( 1700, 40 ) 28 "Press space to skip!" "Garet" black
                ]
    in
    Comp.linearFade combinedTextAlpha (P.clear (rgba 0 0 0 0)) textRenderable


{-|

    Render the house with a fade effect.

    This function creates a renderable object for the house,
    applying a fade effect based on the houseFadeProgress.

    @param houseFadeProgress - The fade progress for the house from 0.0 to 1.0.
    @param houseTexture - The texture to use for the house.
    @return A Renderable object containing the rendered house.

-}
renderHouse : Float -> String -> Renderable
renderHouse houseFadeProgress houseTexture =
    if houseFadeProgress > 0 then
        let
            baseHouse =
                P.centeredTextureWithAlpha ( 960, 540 ) ( 1920, 1080 ) 0 1.0 houseTexture
        in
        Comp.linearFade houseFadeProgress (P.clear (rgba 0 0 0 0)) baseHouse

    else
        group [] []


{-|

    Render the phone with a fade effect.

    This function creates a renderable object for the phone,
    applying a fade effect based on the phoneFadeProgress.

    @param phoneFadeProgress - The fade progress for the phone from 0.0 to 1.0.
    @param phoneTexture - The texture to use for the phone.
    @return A Renderable object containing the rendered phone.

-}
renderPhone : Float -> String -> Renderable
renderPhone phoneFadeProgress phoneTexture =
    if phoneFadeProgress > 0 then
        let
            ( phonePosition, phoneSize ) =
                if phoneTexture == "pickup" then
                    ( ( 1000, 500 ), ( 680, 580 ) )

                else
                    ( ( 960, 600 ), ( 400, 300 ) )

            basePhone =
                P.centeredTextureWithAlpha phonePosition phoneSize 0 1.0 phoneTexture
        in
        Comp.linearFade phoneFadeProgress (P.clear (rgba 0 0 0 0)) basePhone

    else
        group [] []


{-|

    Render dialogues based on phone fade progress and elapsed time.

    This function creates a renderable group of dialogues that appear
    when the phone is ringing or being picked up, with each dialogue
    having its own fade effect based on the elapsed time.

    @param phoneFadeProgress - The fade progress for the phone from 0.0 to 1.0.
    @param elapsedTime - The time elapsed since the scene started in milliseconds.
    @return A Renderable object containing the rendered dialogues.

-}
renderDialogues : Float -> Float -> Renderable
renderDialogues phoneFadeProgress elapsedTime =
    if phoneFadeProgress > 0 then
        let
            dialogue1Alpha =
                Anim.calculateDialogueAlpha elapsedTime 0

            dialogue2Alpha =
                Anim.calculateDialogueAlpha elapsedTime 1

            dialogue3Alpha =
                Anim.calculateDialogueAlpha elapsedTime 2

            dialogue4Alpha =
                Anim.calculateDialogueAlpha elapsedTime 3

            dialogue5Alpha =
                Anim.calculateDialogueAlpha elapsedTime 4

            dialogue1 =
                Comp.linearFade dialogue1Alpha (P.clear (rgba 0 0 0 0)) (P.textbox ( 1260, 200 ) 64 "..." "Garet" white)

            dialogue2 =
                Comp.linearFade dialogue2Alpha (P.clear (rgba 0 0 0 0)) (P.textbox ( 160, 300 ) 64 "GhostBust Hotline Speaki..." "Garet" white)

            dialogue3 =
                Comp.linearFade dialogue3Alpha (P.clear (rgba 0 0 0 0)) (P.textbox ( 1260, 400 ) 64 "HELPP..." "Garet" white)

            dialogue4 =
                Comp.linearFade dialogue4Alpha (P.clear (rgba 0 0 0 0)) (P.textbox ( 160, 500 ) 64 "What's your emergency?" "Garet" white)

            dialogue5 =
                Comp.linearFade dialogue5Alpha (P.clear (rgba 0 0 0 0)) (P.textbox ( 1260, 600 ) 64 "Aaghh...GGhh-GHOSTT..." "Garet" white)
        in
        group []
            [ dialogue1
            , dialogue2
            , dialogue3
            , dialogue4
            , dialogue5
            ]

    else
        group [] []
