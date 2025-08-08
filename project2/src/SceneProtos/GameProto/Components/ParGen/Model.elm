module SceneProtos.GameProto.Components.ParGen.Model exposing (component)

{-| Particle Generator component model module.

This module implements the particle generator component for the game. The particle generator
creates and manages visual particles for effects like atmospheric backgrounds, explosions,
or other visual elements that enhance the game's visual appeal.


# Component

@docs component

-}

import Color exposing (Color)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Par exposing (Particle, findColorAtTime, genParticles, randomPointRect, randomSpeedVect, renderParticle, updateParticle)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import REGL.BuiltinPrograms as P
import REGL.Common
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Particle Generator component's internal state data.

  - particles - List of active particles currently being managed by this component

This data structure maintains the state of all particles currently active in the scene.
Each particle contains its own position, velocity, rotation, scale, color, and lifetime information.

Example:

    -- An empty particle list (initial state)
    initialData = { particles = [] }

    -- Data with some active particles
    activeData = { particles = [particle1, particle2, ...] }

-}
type alias Data =
    { particles : List Particle
    }


{-| Initializes the particle generator component.

This function creates a new particle generator component with default settings:

  - Empty initial particle list
  - Component ID set to -1 (special case for singleton components)
  - Type set to "ParGen"
  - Position set to the center of a 1920x1080 screen (960, 540)
  - Size set to minimal (1, 1) as it doesn't need physical dimensions
  - Alive flag set to true

The initialization ignores input parameters as the particle generator
uses fixed settings and doesn't require custom initialization.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    ( Data []
    , { emptyBaseData
        | id = -1
        , ty = "ParGen"
        , position = { x = 960, y = 540 }
        , size = { x = 1, y = 1 }
        , alive = True
      }
    )


{-| Updates the particle generator component based on events.

This function handles the component's behavior on each update cycle:

  - On each tick, updates all existing particles based on elapsed time
  - Removes particles that have exceeded their lifetime
  - Generates new particles from the bottom of the screen moving upward
  - Generates new particles from the top of the screen moving downward
  - Returns the updated state with the combined particle list

The particle generation creates a continuous ambient effect with particles
floating in opposite directions to create a dynamic background atmosphere.
Each particle set has specific parameters for position, color, velocity, rotation,
scaling, and lifetime that create the desired visual effect.

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

                bgParticles1 =
                    genParticles
                        ( 960, 1200 )
                        env.globalData.currentTimeStamp
                        (Color.rgba 0 0.2 0.1 1)
                        (Color.rgba 0 0 0 1)
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
                        20
                        -- final scale
                        4
                        -- life in seconds [^] | particle count [v]
                        0.3

                bgParticles2 =
                    genParticles
                        ( 960, -160 )
                        env.globalData.currentTimeStamp
                        (Color.rgba 0 0.2 0.1 1)
                        (Color.rgba 0 0 0 1)
                        ( 1920, 100 )
                        -- boxsize
                        ( 0, 100 )
                        -- initial velocity
                        ( 100, 0 )
                        -- velocity
                        0.2
                        -- rotation speed
                        50
                        -- initial scale
                        20
                        -- final scale
                        4
                        -- life in seconds [^] | particle count [v]
                        0.3
            in
            ( ( { data | particles = updatedParticles ++ bgParticles1 ++ bgParticles2 }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


{-| Processes record-based updates for the particle generator component.

This function handles specific messages sent to the component. Currently,
the particle generator doesn't respond to any specific messages and simply
returns the current state unchanged.

This is a placeholder for potential future functionality, such as:

  - Responding to explosion events by generating burst particles
  - Creating special effects based on game events
  - Adjusting particle generation based on game state changes

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


{-| Renders the particle generator component.

This function creates the visual representation of all particles:

  - Gets the current camera position from the global data
  - Maps each particle to its rendered form with the camera position as reference
  - Groups all particle renderables into a single group
  - Sets an extremely high z-index (1000000) to ensure particles render on top of most elements

The particles are rendered using the camera position to create proper perspective
and movement effects as the camera moves through the scene.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        cam =
            env.globalData.camera

        campos =
            ( cam.x, cam.y )
    in
    ( REGL.Common.GroupRenderable [] (List.map (\p -> renderParticle p campos) data.particles), 0 )


{-| Determines if this component should process a message for the given target.

This matcher function checks if a message is intended for the particle generator component:

  - Returns true only if the target is "ParGen"
  - Ignores the data and basedata parameters as they're not needed for this check

This allows the component system to route messages correctly to the particle generator
component throughout the component network.

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "ParGen"


{-| Concrete component configuration for the particle generator.

Assembles all the particle generator component functions into a concrete component structure:

  - init: For initialization
  - update: For event-based updates (primarily tick events)
  - updaterec: For message-based updates
  - view: For rendering all particles
  - matcher: For message routing

This structure defines the complete behavior of the particle generator component.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Particle generator component generator.

Creates a complete, ready-to-use component for generating particles in the game.
This component can be added to scenes to create ambient particle effects,
background animations, or other visual effects that enhance the game atmosphere.

-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
