module SceneProtos.GameProto.Components.ParGen.Init exposing
    ( InitData
    , ParGenMsg(..)
    )

{-| Particle Generator component initialization module.

This module defines the data types and messages needed to initialize and operate the particle generator
component in the game. The particle generator creates and manages visual particles for effects like
backgrounds, explosions, or other visual elements.


# Types

@docs InitData
@docs ParGenMsg

-}

import Color exposing (Color)
import Dict exposing (size)
import Lib.Utils.Par exposing (Particle)
import Lib.Utils.Vec as Vec exposing (Vec)


{-| The data used to initialize a particle generator component.

This is currently an empty record as the particle generator uses default configuration
and does not require specific initialization parameters. The generator's behavior
is configured directly in the component's update function.

Example:

    initData =
        {}

-}
type alias InitData =
    {}


{-| Helper function to update a list of particles based on elapsed time.

  - dSec - The elapsed time in seconds
  - particles - The list of particles to update

This function applies the particle update logic to each particle and filters out
particles that have exceeded their lifetime.

-}
updateParticles : Float -> List Particle -> List Particle
updateParticles dSec particles =
    List.map (Lib.Utils.Par.updateParticle dSec) particles
        |> List.filter (\p -> p.t < p.life)


{-| Message types for particle generator component communication.

  - NullParGenMsg - A placeholder message that does not trigger any action

This type is currently minimalistic as the particle generator primarily operates
based on game ticks rather than explicit messages from other components.

-}
type ParGenMsg
    = NullParGenMsg
