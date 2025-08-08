module Scenes.Intro.Storymode.Animation exposing
    ( calculateLogoFadeOut, calculateLogoAlpha, calculateParticleFade, calculateFadeWithStart, calculateMultiPhaseFade, calculateHouseFade, calculatePhoneFade
    , getHouseTexture, getPhoneTexture, getCurrentTexture, isBlinkingPhase, calculateAnimationProgress, applyEasing, calculateYOffset, getBlinkCycleIndex, getBackgroundColor
    , calculateTextAlpha, calculateDialogueAlpha
    )

{-| Animation calculation functions for the Storymode intro scene

This module contains all animation progress and texture selection logic
extracted from the main Model to improve code organization.

All functions work with elapsed time in milliseconds and return progress values
typically between 0.0 and 1.0, or specific texture names for animated elements.

@docs calculateLogoFadeOut, calculateLogoAlpha, calculateParticleFade, calculateFadeWithStart, calculateMultiPhaseFade, calculateHouseFade, calculatePhoneFade
@docs getHouseTexture, getPhoneTexture, getCurrentTexture, isBlinkingPhase, calculateAnimationProgress, applyEasing, calculateYOffset, getBlinkCycleIndex, getBackgroundColor
@docs calculateTextAlpha, calculateDialogueAlpha

-}

import Color exposing (..)
import Scenes.Intro.Storymode.Constants as C


{-| Calculate logo fade out progress

Returns a value from 0.0 to 1.0 representing how much the logo has faded out.

-}
calculateLogoFadeOut : Float -> Float
calculateLogoFadeOut elapsedTime =
    calculateFadeWithStart elapsedTime C.logoFadeOutStart <|
        \elapsed -> min 1.0 (elapsed / C.logoFadeOutDuration)


{-| Calculate logo alpha value (inverse of fade out)

Returns a value from 0.0 to 1.0 representing the logo's opacity.

-}
calculateLogoAlpha : Float -> Float
calculateLogoAlpha elapsedTime =
    1.0 - calculateLogoFadeOut elapsedTime


{-| Calculate particle fade progress

Returns a value from 0.0 to 1.0 representing how visible the particles should be.

  - 0.0: Particles are completely transparent
  - 1.0: Particles are fully visible

Parameters:

  - elapsedTime: Time elapsed since scene start in milliseconds

-}
calculateParticleFade : Float -> Float
calculateParticleFade elapsedTime =
    calculateFadeWithStart elapsedTime C.particleFadeStart <|
        \elapsed -> min 1.0 (elapsed / C.particleFadeDuration)


{-| Helper function for fade calculations with start time check

Generic helper that applies fade logic only after a specific start time.
Returns 0.0 if before start time, otherwise applies the provided fade logic.

-}
calculateFadeWithStart : Float -> Float -> (Float -> Float) -> Float
calculateFadeWithStart elapsedTime startTime fadeLogic =
    if elapsedTime > startTime then
        fadeLogic (elapsedTime - startTime)

    else
        0.0


{-| Generic helper for multi-phase fade animations (fade in -> wait -> fade out)

Calculates fade progress for animations with three phases:

1.  Fade in: 0.0 to 1.0 over fadeInTime
2.  Wait: stays at 1.0 for waitTime
3.  Fade out: 1.0 to 0.0 over fadeOutTime

-}
calculateMultiPhaseFade : Float -> Float -> Float -> Float -> Float
calculateMultiPhaseFade elapsed fadeInTime waitTime fadeOutTime =
    if elapsed < fadeInTime then
        -- Fade in phase
        elapsed / fadeInTime

    else if elapsed < (fadeInTime + waitTime) then
        -- Wait phase (fully visible)
        1.0

    else if elapsed < (fadeInTime + waitTime + fadeOutTime) then
        -- Fade out phase
        1.0 - ((elapsed - fadeInTime - waitTime) / fadeOutTime)

    else
        -- Completely faded out
        0.0


{-| Calculate house fade progress

Returns a value from 0.0 to 1.0 representing the house's visibility.
Uses multi-phase animation: fade in -> stay visible while blinking -> fade out

-}
calculateHouseFade : Float -> Float
calculateHouseFade elapsedTime =
    calculateFadeWithStart elapsedTime C.houseFadeStart <|
        \houseElapsed ->
            calculateMultiPhaseFade houseElapsed C.houseFadeInTime C.houseWaitTime C.houseFadeOutTime


{-| Calculate phone fade progress

Returns a value from 0.0 to 1.0 representing the phone's visibility.
Uses multi-phase animation: fade in -> stay visible during ringing and pickup -> fade out

-}
calculatePhoneFade : Float -> Float
calculatePhoneFade elapsedTime =
    calculateFadeWithStart elapsedTime C.phoneFadeStart <|
        \phoneElapsed ->
            calculateMultiPhaseFade phoneElapsed C.phoneFadeInTime (C.phoneRingingTime + C.phonePickupTime) C.phoneFadeOutTime


{-| Get house texture based on blink cycle

Returns the appropriate house texture name based on the current blink state.
The house alternates between "house0" and "house1" textures when visible.

-}
getHouseTexture : Float -> Float -> String
getHouseTexture elapsedTime houseFadeProgress =
    if houseFadeProgress > 0 then
        let
            blinkCycle =
                floor (elapsedTime / C.houseBlinkInterval)
        in
        if modBy 2 blinkCycle == 0 then
            "house0"

        else
            "house1"

    else
        "house0"


{-| Get phone texture based on animation phase

Returns the appropriate phone texture name based on the current animation phase.
During ringing, cycles through animation frames. During pickup, shows pickup texture.

-}
getPhoneTexture : Float -> Float -> String
getPhoneTexture elapsedTime phoneFadeProgress =
    if phoneFadeProgress > 0 then
        let
            phoneElapsed =
                elapsedTime - C.phoneFadeStart
        in
        if phoneElapsed < (C.phoneFadeInTime + C.phoneRingingTime) then
            let
                ringCycle =
                    floor (elapsedTime / C.phoneRingInterval)

                frameIndex =
                    modBy 4 ringCycle
            in
            case frameIndex of
                0 ->
                    "ph1"

                1 ->
                    "ph2"

                2 ->
                    "ph3"

                _ ->
                    "ph4"

        else
            "pickup"

    else
        "ph1"


{-| Check if currently in blinking phase
-}
isBlinkingPhase : Float -> Bool
isBlinkingPhase elapsedTime =
    elapsedTime < C.fadeInDuration


{-| Calculate animation progress for Y offset
-}
calculateAnimationProgress : Float -> Float
calculateAnimationProgress elapsedTime =
    calculateFadeWithStart elapsedTime (C.fadeInDuration + 2000) <|
        \elapsed -> min 1.0 (elapsed / 2000)


{-| Apply easing to animation progress
-}
applyEasing : Float -> Float
applyEasing progress =
    progress * (2.0 - progress)


{-| Calculate Y offset based on eased progress
-}
calculateYOffset : Float -> Float
calculateYOffset elapsedTime =
    let
        progress =
            calculateAnimationProgress elapsedTime

        easedProgress =
            applyEasing progress
    in
    easedProgress * -1080


{-| Helper function to calculate blink cycle index
-}
getBlinkCycleIndex : Float -> Int
getBlinkCycleIndex elapsedTime =
    let
        fullPeriods =
            floor (elapsedTime / C.totalCycleTime)

        timeInCurrentPeriod =
            elapsedTime - (toFloat fullPeriods * C.totalCycleTime)
    in
    if isBlinkingPhase elapsedTime && timeInCurrentPeriod < C.blinkPhaseDuration then
        let
            blinkCycle =
                floor (timeInCurrentPeriod / C.blinkSpeed)
        in
        modBy 2 blinkCycle

    else
        0


{-| Get current logo texture based on blinking phase
-}
getCurrentTexture : Float -> String
getCurrentTexture elapsedTime =
    case getBlinkCycleIndex elapsedTime of
        0 ->
            "ls"

        _ ->
            "ls2"


{-| Get background color based on blinking phase
-}
getBackgroundColor : Float -> Color
getBackgroundColor elapsedTime =
    case getBlinkCycleIndex elapsedTime of
        0 ->
            black

        _ ->
            white


{-| Calculate combined text alpha (fade in, then fade out with logo)
-}
calculateTextAlpha : Float -> Float -> Float
calculateTextAlpha elapsedTime fadeProgress =
    let
        logoFadeOutProgress =
            calculateLogoFadeOut elapsedTime
    in
    if elapsedTime <= C.fadeInDuration then
        fadeProgress

    else
        1.0 - logoFadeOutProgress


{-| Calculate dialogue alpha for a specific dialogue index (0-4)
-}
calculateDialogueAlpha : Float -> Int -> Float
calculateDialogueAlpha elapsedTime dialogueIndex =
    calculateFadeWithStart elapsedTime (C.dialogueStart + (toFloat dialogueIndex * C.dialogueInterval)) <|
        \elapsed -> min 1.0 (elapsed / C.dialogueFadeInTime)
