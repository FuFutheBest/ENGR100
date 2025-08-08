module Scenes.Intro.Storymode.Constants exposing
    ( fadeInDuration, logoFadeOutStart, logoFadeOutDuration
    , particleFadeStart, particleFadeDuration
    , houseFadeStart, houseFadeInTime, houseWaitTime, houseFadeOutTime, houseBlinkInterval
    , phoneFadeStart, phoneFadeInTime, phoneRingingTime, phonePickupTime, phoneFadeOutTime, phoneRingInterval
    , blinkSpeed, blinkPhaseDuration, totalCycleTime
    , dialogueStart, dialogueFadeInTime, dialogueInterval, dialogueCompleteTime
    )

{-| Animation timing constants for the Storymode intro scene

This module contains all the timing constants used for animations in the Storymode intro scene.
All timing values are in milliseconds unless otherwise specified.

The animation sequence follows this general timeline:

1.  Logo fade in and blinking (0-7000ms)
2.  Logo fade out (7000-9000ms)
3.  House appears and blinks (8000-13500ms)
4.  Phone appears and rings (13000-36000ms)
5.  Dialogue sequence (31600-46000ms)
6.  Scene transitions to MainMenu

@docs fadeInDuration, logoFadeOutStart, logoFadeOutDuration
@docs particleFadeStart, particleFadeDuration
@docs houseFadeStart, houseFadeInTime, houseWaitTime, houseFadeOutTime, houseBlinkInterval
@docs phoneFadeStart, phoneFadeInTime, phoneRingingTime, phonePickupTime, phoneFadeOutTime, phoneRingInterval
@docs blinkSpeed, blinkPhaseDuration, totalCycleTime
@docs dialogueStart, dialogueFadeInTime, dialogueInterval, dialogueCompleteTime

-}


{-| Duration for the initial logo fade-in animation in milliseconds

The logo will gradually appear over this duration at the start of the scene.

-}
fadeInDuration : Float
fadeInDuration =
    7000


{-| Time when the logo starts to fade out in milliseconds

After this time, the logo will begin to disappear from the screen.

-}
logoFadeOutStart : Float
logoFadeOutStart =
    7000


{-| Duration for the logo fade-out animation in milliseconds

The logo will gradually disappear over this duration after logoFadeOutStart.

-}
logoFadeOutDuration : Float
logoFadeOutDuration =
    2000


{-| Time when particles start to fade in milliseconds

Particles will begin appearing after this time has elapsed.

-}
particleFadeStart : Float
particleFadeStart =
    fadeInDuration


{-| Duration for particle fade-in animation in milliseconds

Particles will gradually become visible over this duration.

-}
particleFadeDuration : Float
particleFadeDuration =
    3000


{-| Time when the house starts to appear in milliseconds

The house animation begins after this delay from scene start.

-}
houseFadeStart : Float
houseFadeStart =
    fadeInDuration + 1000


{-| Duration for house fade-in animation in milliseconds

The house will become visible over this duration.

-}
houseFadeInTime : Float
houseFadeInTime =
    500


{-| Duration the house remains fully visible in milliseconds

After fading in, the house stays visible and blinks for this duration.

-}
houseWaitTime : Float
houseWaitTime =
    4000


{-| Duration for house fade-out animation in milliseconds

The house will disappear over this duration after the wait time.

-}
houseFadeOutTime : Float
houseFadeOutTime =
    500


{-| Interval between house blink frames in milliseconds

Controls how fast the house alternates between different textures when blinking.

-}
houseBlinkInterval : Float
houseBlinkInterval =
    200


{-| Time when the phone starts to appear in milliseconds

The phone animation begins after this delay from scene start.

-}
phoneFadeStart : Float
phoneFadeStart =
    houseFadeStart + 5000


{-| Duration for phone fade-in animation in milliseconds

The phone will become visible over this duration.

-}
phoneFadeInTime : Float
phoneFadeInTime =
    500


{-| Duration the phone rings before being picked up in milliseconds

After appearing, the phone will ring for this duration with animated frames.

-}
phoneRingingTime : Float
phoneRingingTime =
    5000


{-| Duration showing the phone being picked up in milliseconds

After ringing, the phone shows the pickup animation for this duration.

-}
phonePickupTime : Float
phonePickupTime =
    18000


{-| Duration for phone fade-out animation in milliseconds

The phone will disappear over this duration after the pickup phase.

-}
phoneFadeOutTime : Float
phoneFadeOutTime =
    500


{-| Interval between phone ring animation frames in milliseconds

Controls how fast the phone cycles through its ringing animation frames.

-}
phoneRingInterval : Float
phoneRingInterval =
    250


{-| Speed of individual blink transitions in milliseconds

How fast each blink frame transition occurs.

-}
blinkSpeed : Float
blinkSpeed =
    100


{-| Duration of active blinking phase in milliseconds

How long the blinking effect lasts within each cycle.

-}
blinkPhaseDuration : Float
blinkPhaseDuration =
    7 * blinkSpeed


{-| Total duration of one complete blink cycle in milliseconds

Includes both the blinking phase and the static phase.

-}
totalCycleTime : Float
totalCycleTime =
    10 * blinkSpeed + 500


{-| Time when dialogue text starts appearing in milliseconds

Dialogue begins after the phone has been ringing for a while.

-}
dialogueStart : Float
dialogueStart =
    phoneFadeStart + phoneFadeInTime + phoneRingingTime


{-| Duration for each dialogue line to fade in milliseconds

How long it takes for each dialogue text to become fully visible.

-}
dialogueFadeInTime : Float
dialogueFadeInTime =
    500


{-| Interval between dialogue lines in milliseconds

Time between when each dialogue line starts to appear.

-}
dialogueInterval : Float
dialogueInterval =
    3600


{-| Time when all dialogue is complete in milliseconds

After this time, the scene will transition to the main menu.

-}
dialogueCompleteTime : Float
dialogueCompleteTime =
    dialogueStart + (4 * dialogueInterval) + dialogueFadeInTime + 1000
