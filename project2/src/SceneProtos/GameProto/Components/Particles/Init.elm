module SceneProtos.GameProto.Components.Particles.Init exposing
    ( InitData
    , ParticlesMsg(..)
    )

{-| Particles component initialization module.

This module defines the data types and messages needed to initialize and operate the particles
component in the game. The particles component creates visual effects for various game events
like character actions or environmental effects.


# Types

@docs InitData
@docs ParticlesMsg

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize a particles component.

This is currently an empty record as the particles component doesn't require
specific initialization parameters. The particles are created dynamically
in response to events during gameplay.

Example:

    initData =
        {}

-}
type alias InitData =
    {}


{-| Message types for particles component communication.

  - FanParticlesMsg - Creates a fan-shaped particle effect at the specified position and angle
      - First parameter: Position vector where the effect should originate
      - Second parameter: Angle in radians determining the direction of the particle spread

  - GhostParticleMsg - Creates a ghost-themed particle effect at the specified position
      - Parameter: Position vector where the ghost particles should appear

  - ChestParticleMsg - Creates a particle effect for chest interactions at the specified position
      - Parameter: Position vector where the chest particles should appear

  - NullParticlesMsg - A placeholder message that does not trigger any action

These messages allow other components to request specific particle effects
at particular locations and with specific orientations in the game world.

-}
type ParticlesMsg
    = FanParticlesMsg Vec.Vec Float -- position and angle
    | CannonParticlesMsg Vec.Vec Float -- position and particle number
    | GhostParticleMsg Vec.Vec --  position
    | ChestParticleMsg Vec.Vec -- position
    | NullParticlesMsg
