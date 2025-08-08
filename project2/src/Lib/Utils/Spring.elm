module Lib.Utils.Spring exposing
    ( Spring
    , createSpring
    , updateSpringToTarget, bounceSpring
    )

{-| Physics-based spring simulation module.

This module provides functionality for simulating spring physics, useful for smooth animations
and transitions in UI elements.


# Types

@docs Spring


# Creation

@docs createSpring


# Operations

@docs updateSpringToTarget, bounceSpring

-}

import Lib.Utils.Vec as Vec exposing (Vec)


{-| Represents a spring with physical properties.

  - `k` - Spring constant/stiffness (higher values = stiffer spring)
  - `damping` - Damping factor (higher values = faster energy loss)
  - `pos` - Current position of the spring
  - `vel` - Current velocity of the spring

Example:

    -- Create a moderately stiff spring with medium damping
    spring =
        createSpring 0.1 0.3 (Vec.genVec 0 0) (Vec.genVec 0 0)

-}
type alias Spring =
    { k : Float
    , damping : Float
    , pos : Vec
    , vel : Vec
    }


{-| Creates a new spring with specified properties.

This function initializes a spring with a given spring constant, damping factor,
current position, and velocity.

-}
createSpring : Float -> Float -> Vec -> Vec -> Spring
createSpring springConstant dampingFactor position velocity =
    { k = springConstant
    , damping = dampingFactor
    , pos = position
    , vel = velocity
    }


calculateDisplacementAndForce : Vec -> Vec -> Float -> ( Vec, Vec )
calculateDisplacementAndForce pos1 pos2 k =
    let
        displacement =
            Vec.subtract pos2 pos1

        springForce =
            Vec.scale k displacement
    in
    ( displacement, springForce )


updateSpringState : Float -> Vec -> Spring -> Spring
updateSpringState dSec finalVel spring =
    let
        newPos =
            Vec.add spring.pos (Vec.scale dSec finalVel)
    in
    { spring | pos = newPos, vel = finalVel }


calculateNewVelocity : Spring -> Vec -> Maybe Vec -> Vec
calculateNewVelocity spring springForce maybeDampingForce =
    case maybeDampingForce of
        Just dampingForce ->
            Vec.add springForce (Vec.scale -1 dampingForce)

        Nothing ->
            Vec.add spring.vel (Vec.scale -1 springForce)


updateSpringGeneric : Float -> Vec -> Vec -> Maybe Vec -> Spring -> Spring
updateSpringGeneric dSec pos1 pos2 maybeDampingForce spring =
    let
        ( _, force ) =
            calculateDisplacementAndForce pos1 pos2 spring.k

        newVel =
            calculateNewVelocity spring force maybeDampingForce

        finalVel =
            if maybeDampingForce == Nothing then
                Vec.scale dSec newVel

            else
                newVel
    in
    updateSpringState dSec finalVel spring


{-| Updates a spring to move toward a target position with damping.

This creates a smooth, springy animation that gradually settles at the target.

    -- Move spring smoothly toward position (100, 150) over time
    updatedSpring =
        updateSpringToTarget deltaTime (Vec.genVec 100 150) currentSpring

-}
updateSpringToTarget : Float -> Vec -> Spring -> Spring
updateSpringToTarget dSec targetPos spring =
    let
        dampingForce =
            Vec.scale spring.damping spring.vel
    in
    updateSpringGeneric dSec spring.pos targetPos (Just dampingForce) spring


{-| Makes a spring "bounce" off a target position.

Unlike `updateSpringToTarget`, this function causes the spring to bounce
away from the target rather than settle at it.

    -- Make spring bounce off position (50, 60)
    bouncedSpring =
        bounceSpring deltaTime (Vec.genVec 50 60) currentSpring

-}
bounceSpring : Float -> Vec -> Spring -> Spring
bounceSpring dSec targetPos spring =
    updateSpringGeneric dSec targetPos spring.pos Nothing spring
