module Lib.Utils.Anim exposing
    ( Loop
    , updateLoop, updateLoopWithName, getCurFrameName
    )

{-| Animation loop utilities for sprite animations.

This module handles animation frames, timing and sequencing for sprites.


# Types

@docs Loop


# Functions

@docs updateLoop, updateLoopWithName, getCurFrameName

-}

import Debug exposing (toString)


{-| Represents an animation loop for a sprite.

  - `name` - Base name of the animation (e.g. "walk", "idle")
  - `size` - Number of frames in the animation sequence
  - `duration` - Duration of each frame in seconds
  - `currentFrame` - Current frame index (0-based)
  - `currentDuration` - Time accumulated in current frame (seconds)

Example:

    walkAnimation =
        { name = "walk"
        , size = 4
        , duration = 0.1
        , currentFrame = 0
        , currentDuration = 0
        }

-}
type alias Loop =
    { name : String
    , size : Int
    , duration : Float
    , currentFrame : Int
    , currentDuration : Float
    }


{-| Updates an animation loop based on elapsed time.

Updates the current frame and duration based on the time passed.
When the accumulated time exceeds the frame duration, advances to the next frame.

-}
updateLoop : Loop -> Float -> Loop
updateLoop animLoop dSec =
    let
        ( newFrame, newDuration ) =
            if animLoop.currentDuration + dSec >= animLoop.duration then
                ( animLoop.currentFrame + 1 |> modBy animLoop.size, animLoop.currentDuration + dSec - animLoop.duration )

            else
                ( animLoop.currentFrame, animLoop.currentDuration + dSec )
    in
    { animLoop
        | currentFrame = newFrame
        , currentDuration = newDuration
    }


{-| Updates an animation loop with a potential name change.

If the name is different from the current one, resets the animation.
If the name is the same, simply updates the current animation.

-}
updateLoopWithName : Loop -> String -> Int -> Float -> Float -> Loop
updateLoopWithName animLoop newName newSize newDuration dSec =
    if newName == animLoop.name then
        updateLoop animLoop dSec

    else
        { animLoop | name = newName, size = newSize, currentFrame = 0, currentDuration = 0, duration = newDuration }


{-| Gets the current frame name for an animation.

Returns a string combining the animation name and the current frame index.

-}
getCurFrameName : Loop -> String
getCurFrameName animLoop =
    animLoop.name ++ (animLoop.currentFrame |> toString)
