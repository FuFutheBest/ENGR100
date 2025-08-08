module Lib.Utils.Par exposing
    ( Particle
    , genParticles, randomPointRect, randomSpeedVect, randomAngle, randomNorm, getSeed
    , updateParticle, renderParticle, findColorAtTime
    )

{-| Particle system utility module that provides functionality for creating, managing and rendering particle effects in games.


# Type Definitions

@docs Particle


# Particle Generation Functions

@docs genParticles, randomPointRect, randomSpeedVect, randomAngle, randomNorm, getSeed


# Particle Management Functions

@docs updateParticle, renderParticle, findColorAtTime

-}

import Color exposing (Color, rgba)
import Lib.Utils.Vec as Vec exposing (Vec)
import List
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import Random


{-| Represents a single particle in the particle system.

Each particle contains attributes like position, velocity, rotation, color, and size,
which change over time to produce dynamic visual effects.

  - `r` - Current position vector of the particle in pixels
  - `v` - Current velocity vector of the particle in pixels/second
  - `rot` - Rotation speed in radians/second
  - `ang` - Current rotation angle in radians
  - `g` - Gravity acceleration, affects vertical movement; higher values cause faster falling
  - `ci` - Initial color of the particle when generated
  - `cf` - Final color of the particle before disappearing
  - `si` - Initial size in pixels
  - `sf` - Final size in pixels
  - `t` - Time since the particle was created, in seconds
  - `life` - Total lifetime in seconds; the particle disappears when t >= life

-}
type alias Particle =
    { r : Vec -- current displacement
    , v : Vec -- current velocity
    , rot : Float -- rotation speed
    , ang : Float -- angle of rotation
    , g : Float -- gravity
    , ci : Color -- initial color
    , cf : Color -- final color
    , si : Float -- initial scale
    , sf : Float -- final scale
    , t : Float -- time since birth
    , life : Float -- life
    }


{-| Update particle state based on a time step.
-}
updateParticle : Float -> Particle -> Particle
updateParticle dSec particle =
    let
        ( x, y ) =
            particle.r |> Vec.toTuple

        ( vx, vy ) =
            particle.v |> Vec.toTuple

        nx =
            x + vx * dSec

        ny =
            y + vy * dSec - particle.g * dSec * dSec

        nvx =
            vx

        nvy =
            vy - particle.g * dSec

        nang =
            particle.ang + particle.rot * dSec
    in
    { particle
        | r = Vec.genVec nx ny
        , v = Vec.genVec nvx nvy
        , t = particle.t + dSec
        , ang = nang
    }


{-| Calculate the current color of a particle based on its lifetime progression.
-}
findColorAtTime : Float -> Particle -> Color
findColorAtTime t particle =
    let
        tNorm =
            t / particle.life

        r =
            1 - tNorm

        g =
            tNorm

        i =
            Color.toRgba particle.ci

        f =
            Color.toRgba particle.cf
    in
    Color.fromRgba
        { red = i.red * r + f.red * g
        , green = i.green * r + f.green * g
        , blue = i.blue * r + f.blue * g
        , alpha = i.alpha * r + f.alpha * g
        }


{-| Generate a random normalized value within a range around the input value.

  - Takes a base value `x` and generates a random number between 0.5x and 1.5x
  - Uses the provided seed to ensure reproducibility
  - Returns a randomized value that maintains a normal distribution around the input

-}
randomNorm : Float -> Int -> Float
randomNorm x seed =
    Tuple.first <| Random.step (Random.float (0.5 * x) (1.5 * x)) (Random.initialSeed seed)


{-| Generate a random angle in radians.
-}
randomAngle : Int -> Float
randomAngle seed =
    Tuple.first <| Random.step (Random.float 0 (2 * pi)) (Random.initialSeed seed)


{-| Generate a random point within a rectangular area.

  - Takes the center coordinates (sx, sy) and dimensions (x, y) of a rectangle
  - Returns a random Vec2 point located anywhere within the rectangle
  - Uses the provided seed for reproducible randomness
  - The returned point is relative to the center of the rectangle

-}
randomPointRect : Float -> Float -> Float -> Float -> Int -> ( Float, Float )
randomPointRect sx sy x y seed =
    let
        ( cx, cy ) =
            Tuple.first <| Random.step (Random.pair (Random.float 0 x) (Random.float 0 y)) (Random.initialSeed seed)
    in
    ( cx + sx - x / 2, cy + sy - y / 2 )


{-| Render a particle as a rectangle with the appropriate position, size, rotation, and color.

  - Takes a particle and the camera position as input
  - Calculates the screen position by applying camera offsets
  - Interpolates the particle size based on its lifetime progression
  - Gets the current color from the findColorAtTime function
  - Returns a Renderable that can be drawn to the screen

-}
renderParticle : Particle -> ( Float, Float ) -> Renderable
renderParticle particle camPos =
    let
        ( rawx, rawy ) =
            particle.r |> Vec.toTuple

        ( x, y ) =
            ( rawx + (camPos |> Tuple.first) - 960
            , rawy + (camPos |> Tuple.second) - 540
            )

        size =
            particle.si + (particle.sf - particle.si) * (particle.t / particle.life)

        color =
            findColorAtTime particle.t particle

        ang =
            particle.ang
    in
    P.rectCentered ( x, y ) ( size, size ) ang color


{-| Generate a random velocity vector with a given magnitude.

  - Takes a base speed value `v` and generates a vector with randomized direction
  - The vector's magnitude will be normalized around the input value (using randomNorm)
  - Uses the provided seed to ensure reproducibility
  - Returns a tuple representing a 2D velocity vector

-}
randomSpeedVect : Float -> Int -> ( Float, Float )
randomSpeedVect v seed =
    let
        norm =
            randomNorm v seed

        theta =
            randomAngle (seed * 7)

        ( nx, ny ) =
            ( cos theta, sin theta )
    in
    ( norm * nx, norm * ny )


{-| Generate a seed value based on the current timestamp.
-}
getSeed : Float -> Int
getSeed currentTimeStamp =
    round (currentTimeStamp * 19260817)


{-| Generate a group of particles with specified properties.
-}
genParticles :
    ( Float, Float )
    -> Float
    -> Color
    -> Color
    -> ( Float, Float )
    -> ( Float, Float )
    -> ( Float, Float )
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> List Particle
genParticles ( x, y ) currentTimeStamp ci cf ( bx, by ) ( ivx, ivy ) ( vel, grav ) rotvel si sf life cnt =
    let
        ncnt =
            if cnt >= 1 then
                cnt

            else if (getSeed currentTimeStamp |> modBy 100) < round (cnt * 100) then
                1

            else
                0
    in
    List.repeat (round ncnt) 0
        |> List.indexedMap
            (\a _ ->
                let
                    seed =
                        getSeed currentTimeStamp * (a + 13) * 19260817 * 10003 |> modBy 100007

                    rTuple =
                        randomPointRect x y bx by seed

                    rx =
                        rTuple |> Tuple.first

                    ry =
                        rTuple |> Tuple.second

                    vTuple =
                        randomSpeedVect vel (seed * 107 |> modBy 100007)

                    vx =
                        ivx + (vTuple |> Tuple.first)

                    vy =
                        ivy + (vTuple |> Tuple.second)

                    rot =
                        (randomAngle seed - pi) * rotvel
                in
                { r = Vec.genVec rx ry
                , v = Vec.genVec vx vy
                , g = grav
                , ci = ci
                , cf = cf
                , si = si
                , sf = sf
                , t = 0
                , life = life
                , rot = rot
                , ang = 0
                }
            )
