module SceneProtos.GameProto.Components.Particles.Model exposing (component)

{-| Particles component model module.

This module implements the particles component for the game. The particles component
creates and manages visual effects for various game events like character actions,
environmental effects, or special gameplay moments. Different particle effects can be
triggered through messages to create visual feedback for player actions.


# Component

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Par exposing (Particle, findColorAtTime, genParticles, randomPointRect, randomSpeedVect, renderParticle, updateParticle)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import REGL.BuiltinPrograms as P
import REGL.Common
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Particles.Init exposing (ParticlesMsg(..))
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Particles component's internal state data.

  - particles - List of active particles currently being managed by this component

This data structure maintains the state of all particles currently active in the scene.
Each particle contains its own position, velocity, rotation, scale, color, and lifetime information.
As particles are generated, they are added to this list, and as they expire, they are filtered out.

Example:

    -- An empty particle list (initial state)
    initialData = { particles = [] }

    -- Data with some active particles
    activeData = { particles = [particle1, particle2, ...] }

-}
type alias Data =
    { particles : List Particle
    }


{-| Initializes the particles component.

This function creates a new particles component with default settings:

  - Empty initial particle list
  - Component ID set to -1 (special case for singleton components)
  - Type set to "Particles"
  - Position set to the center of a 1920x1080 screen (960, 540)
  - Size set to minimal (1, 1) as it doesn't need physical dimensions
  - Alive flag set to true

The initialization ignores input parameters as the particles component
uses fixed settings and doesn't require custom initialization.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    ( Data []
    , { emptyBaseData
        | id = -1
        , ty = "Particles"
        , position = { x = 960, y = 540 }
        , size = { x = 1, y = 1 }
        , alive = True
      }
    )


{-| Updates the particles component based on events.

This function handles the component's behavior on each update cycle:

  - On each tick, updates all existing particles based on elapsed time (dt)
  - Removes particles that have exceeded their lifetime (p.t < p.life)
  - Returns the updated state with the filtered particle list
  - For events other than ticks, maintains the current state

The particle update process applies physics calculations to each particle,
updating their position, rotation, scale, and lifetime properties.

-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                updatedParticles =
                    List.map (\p -> updateParticle dSec p) data.particles
                        |> List.filter (\p -> p.t < p.life)
            in
            ( ( { data | particles = updatedParticles }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


{-| Processes record-based updates for the particles component.

This function handles specific messages sent to the component:

  - When receiving specific particle effect requests, generates the appropriate particles
  - For other messages, maintains the current state
  - Returns the updated state with any newly generated particles

The function includes a helper method `createParticles` that simplifies particle generation
by providing default values for common parameters and focusing on the key customizable aspects.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        -- Helper function to create particles with common default settings.
        --
        -- Parameters:
        --   - position - The position where particles originate
        --   - startColor - The initial color of particles
        --   - endColor - The color particles fade to over their lifetime
        --   - initialVelocity - The starting velocity vector of particles
        --   - initialScale - The starting size of particles
        --   - endScale - The final size of particles before they disappear
        --   - life - How long (in seconds) particles last before being removed
        --   - particleCount - How many particles to generate
        createParticles position startColor endColor initialVelocity initialScale endScale life particleCount =
            genParticles (Vec.toTuple position)
                env.globalData.currentTimeStamp
                startColor
                endColor
                ( 1, 1 )
                initialVelocity
                ( 280, 0 )
                0.2
                initialScale
                endScale
                life
                particleCount

        -- particle count
    in
    case msg of
        ParticlesMsg (FanParticlesMsg position angle) ->
            let
                newParticle =
                    createParticles position (Color.rgba 1 0.9 0 1) (Color.rgba 1 0.6 0 1) ( 800 * cos angle, 800 * sin angle ) 10 4 0.4 1
            in
            ( ( { data | particles = data.particles ++ newParticle }, basedata ), [], env )

        ParticlesMsg (CannonParticlesMsg position pnum) ->
            let
                newParticle =
                    genParticles (Vec.toTuple position) env.globalData.currentTimeStamp (Color.rgba 1 1 1 0.6) (Color.rgba 0 (163 / 255) 1 0) ( 20, 20 ) ( 0, 0 ) ( 100, 0 ) 0.9 20 5 0.7 (0.4 * pnum)
            in
            ( ( { data | particles = data.particles ++ newParticle }, basedata ), [], env )

        ParticlesMsg (ChestParticleMsg position) ->
            let
                newParticle =
                    genParticles (Vec.toTuple position)
                        env.globalData.currentTimeStamp
                        (Color.rgba 1 0.9 0 1)
                        (Color.rgba 1 0.6 0 1)
                        ( 40, 40 )
                        ( 0, -700 )
                        -- initial velocity
                        ( 500, -2000 )
                        -- velocity
                        0.2
                        -- rotation speed
                        10
                        -- initial scale
                        4
                        -- final scale
                        0.7
                        -- life in seconds [^] | particle count [v]
                        20
            in
            ( ( { data | particles = data.particles ++ newParticle }, basedata ), [], env )

        ParticlesMsg (GhostParticleMsg position) ->
            let
                newParticle =
                    createParticles
                        position
                        (Color.rgba {- 1 0.9 0 -} 0 0.392 0 1)
                        (Color.rgba {- 1 0.6 0 -} 0.188 0.282 0.188 1)
                        ( 0, 0 )
                        10
                        -- initial scale
                        4
                        -- final scale
                        0.4
                        -- life in seconds [^] | particle count [v]
                        40
            in
            ( ( { data | particles = data.particles ++ newParticle }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Renders the particles component.

This function creates the visual representation of all particles:

  - Maps each particle to its rendered form with a fixed camera position (960, 540)
  - Groups all particle renderables into a single group
  - Sets an extremely high z-index (1000000) to ensure particles render on top of most elements

The particles are rendered with a fixed camera reference point, creating a consistent
visual effect regardless of actual camera movement in the game.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( REGL.Common.GroupRenderable [] (List.map (\p -> renderParticle p ( 960, 540 )) data.particles), 1000000 )


{-| Determines if this component should process a message for the given target.

This matcher function checks if a message is intended for the particles component:

  - Returns true only if the target is "Particles"
  - Ignores the data and basedata parameters as they're not needed for this check

This allows the component system to route messages correctly to the particles
component throughout the component network.

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Particles"


{-| Concrete component configuration for the particles generator.

Assembles all the particles component functions into a concrete component structure:

  - init: For initialization
  - update: For event-based updates (primarily tick events)
  - updaterec: For message-based updates (handling specific particle effect requests)
  - view: For rendering all particles
  - matcher: For message routing

This structure defines the complete behavior of the particles component.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Particles component generator.

Creates a complete, ready-to-use component for generating particle effects in the game.
This component can be added to scenes to create visual effects for various game events,
such as character actions, environmental effects, or feedback for player interactions.

-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
