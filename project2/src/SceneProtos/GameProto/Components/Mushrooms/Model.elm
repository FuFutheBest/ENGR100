module SceneProtos.GameProto.Components.Mushrooms.Model exposing (component)

{-| Mushroom component model module.

This module implements the mushroom component for the game. Mushrooms are interactive objects
that can be consumed by the player to produce special effects, like revealing ghosts or
altering game mechanics. The component handles the mushroom's appearance, animation, and
interaction with the player character.


# Component

@docs component

-}

import Lib.Base exposing (SceneMsg)
import Lib.Resources exposing (..)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Mushrooms.Init as MushroomsInit exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| State of the mushroom component.

  - Normal - Default state when no player is nearby
  - PlayerInRange - State when the player is within interaction range
  - Consuming Float - State when the player is consuming the mushroom, with the Float value representing remaining consumption time in seconds

The mushroom's visual appearance and behavior change based on its current state,
providing visual feedback to the player about possible interactions.

-}
type MushroomState
    = Normal
    | PlayerInRange
    | Consuming Float


{-| Mushroom component's internal state data.

  - scale - The current visual scale of the mushroom (changes based on state)
  - state - The current interaction state of the mushroom
  - anim - Animation loop information for the mushroom's visual representation

This data structure manages both the visual appearance and interactive behavior
of the mushroom. The scale and animation parameters control how the mushroom is
displayed, while the state tracks its interaction status with the player.

-}
type alias Data =
    { scale : Float
    , state : MushroomState
    , anim : Anim.Loop
    }


{-| Initializes the mushroom component.

This function processes initialization messages to set up a new mushroom component instance:

  - When receiving a MushroomInitMsg, it creates a mushroom with the specified id and position
  - Sets initial scale to 150 (will be visually scaled down in rendering)
  - Sets initial state to Normal
  - Sets up animation loop with "M" sequence of 10 frames
  - For any other message, returns default data with smaller scale

The initialization establishes both the internal state (animation, scale, state)
and external properties (position, size) of the mushroom.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ initMsg =
    case initMsg of
        MushroomMsg mushroomMsg ->
            case mushroomMsg of
                MushroomsInit.MushroomInitMsg initData ->
                    ( { scale = 150
                      , state = Normal
                      , anim = { name = "M", size = 10, duration = 0.05, currentFrame = 0, currentDuration = 0 }
                      }
                    , { emptyBaseData | id = initData.id, ty = "Mushroom", position = initData.position, size = mushroomConfig.size, alive = True }
                    )

                _ ->
                    ( { scale = 1.0
                      , state = Normal
                      , anim = { name = "M", size = 10, duration = 0.1, currentFrame = 0, currentDuration = 0 }
                      }
                    , emptyBaseData
                    )

        _ ->
            ( { scale = 1.0
              , state = Normal
              , anim = { name = "M", size = 10, duration = 0.1, currentFrame = 0, currentDuration = 0 }
              }
            , emptyBaseData
            )


{-| Updates the mushroom component based on events.

This function handles the mushroom's behavior on each update cycle:

  - When R key is pressed and player is in range, changes state to Consuming
  - On tick events, updates animation and processes consumption if applicable
  - During consumption, gradually shrinks the mushroom and tracks remaining time
  - When consumption is complete, sends messages to toggle mushroom effects
  - Returns the updated state and any messages to send

The mushroom's consumption mechanic is a key gameplay element that affects
how the player can interact with ghosts and other game elements.

-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        KeyDown 82 ->
            -- R key
            case data.state of
                PlayerInRange ->
                    ( ( { data | state = Consuming 0.5 }, basedata ), [], ( env, False ) )

                _ ->
                    --  R pressed but not in range
                    ( ( data, basedata ), [], ( env, False ) )

        Tick deltaTime ->
            let
                newAnim =
                    Anim.updateLoopWithName data.anim "M" 10 0.1 (deltaTime / 1000.0)
            in
            case data.state of
                Consuming timeLeft ->
                    let
                        newTimeLeft =
                            timeLeft - deltaTime / 1000.0

                        -- Shrink the mushroom as it gets consumed
                        consumptionProgress =
                            1.0 - (newTimeLeft / 0.5)

                        newScale =
                            data.scale * (1.0 - consumptionProgress * 0.8)

                        -- Messages to send when consuming mushroom and toggle mushroom
                        characterToggleMsg =
                            Other <| ( "Character", CharacterMsg <| CharacterInit.ToggleMushroomEffectMsg )

                        ghostToggleMsg =
                            Other <| ( "Ghosts", GhostsMsg <| GhostsInit.ToggleMushroomEffectMsg )
                    in
                    if newTimeLeft <= 0 then
                        ( ( { data | anim = newAnim }, { basedata | alive = False } ), [ characterToggleMsg, ghostToggleMsg ], ( env, False ) )

                    else
                        ( ( { data | scale = newScale, state = Consuming newTimeLeft, anim = newAnim }, basedata ), [], ( env, False ) )

                _ ->
                    ( ( { data | anim = newAnim }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


{-| Processes record-based updates for the mushroom component.

This function handles specific messages sent to the mushroom component:

  - When receiving character position updates via ToGhostsMsg:
      - Calculates distance between character and mushroom
      - If within proximity radius (100 units), changes state to PlayerInRange
      - If outside proximity, returns to Normal state
      - Updates visual scale based on state (pulsating when in range)
  - For other messages, maintains the current state
  - Returns the updated state

This mechanism creates an interactive feedback loop where mushrooms visually
respond to player proximity, indicating they can be interacted with.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CharacterMsg (ToGhostsMsg _ charPos) ->
            let
                distance =
                    Vec.length (Vec.subtract charPos basedata.position)

                proximityRadius =
                    100.0

                ( newState, targetScale ) =
                    case data.state of
                        Consuming _ ->
                            -- Don't change state if already consuming
                            ( data.state, data.scale )

                        _ ->
                            if distance < proximityRadius then
                                ( PlayerInRange, 2.0 + 0.5 * sin (env.globalData.globalStartTime * 0.01) )

                            else
                                ( Normal, 2 )

                newScale =
                    case data.state of
                        Consuming _ ->
                            -- Keep current scale during consumption
                            data.scale

                        _ ->
                            data.scale + (targetScale - data.scale) * 0.2
            in
            ( ( { data | scale = newScale, state = newState }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Renders the mushroom component.

This function creates the visual representation of the mushroom:

  - Calculates scaled size based on the current scale factor
  - Gets the current animation frame based on the mushroom's animation state
  - Creates a centered texture at the mushroom's position with scaled size
  - Returns the rendered mushroom with a z-index of 0 (rendering order)

The mushroom's visual appearance changes based on its scale, which is affected
by player proximity and consumption state, providing clear visual feedback.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view _ data basedata =
    let
        scaledSize =
            Vec.scale data.scale basedata.size

        -- Get the current frame name for the mushroom animation
        currentFrameName =
            Anim.getCurFrameName data.anim

        mushroomView =
            [ P.centeredTexture (Vec.toTuple basedata.position) (Vec.toTuple scaledSize) 0 currentFrameName ]
    in
    ( group [] mushroomView
    , 0
    )


{-| Determines if this component should process a message for the given target.
-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "Mushroom"


{-| Concrete component configuration for the mushroom.
-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Mushroom component generator.
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
