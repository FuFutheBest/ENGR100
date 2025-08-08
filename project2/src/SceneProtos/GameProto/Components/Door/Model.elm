module SceneProtos.GameProto.Components.Door.Model exposing (component)

{-| Door component model module.

This module implements the door component for the game. Doors are interactive objects
that allow the character to progress between different levels or scenes when touched.
The module includes the component's state, behavior, and rendering functionality.


# Component

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import SceneProtos.GameProto.Components.Character.Init as CharacterInit exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Door.Init as DoorInit exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Door component's internal state data.

  - anim - Animation loop information for the door's visual representation

The animation data controls how the door is displayed and animated in the game.
It uses a looping animation system to create visual transitions when the door
is activated or interacted with.

-}
type alias Data =
    { anim : Anim.Loop }


{-| Default initialization values for the door component's data.

Sets up the initial animation state with:

  - "D" animation sequence
  - 6 frames in the animation
  - 0.6 seconds duration per frame
  - Starting at frame 0
  - No elapsed time

-}
defaultData : Data
defaultData =
    { anim = Anim.Loop "D" 6 0.6 0 0 }


{-| Initializes the door component.

This function processes initialization messages to set up a new door component instance:

  - When receiving a DoorInitMsg, it creates a door with the specified id and position
  - Sets the door's type to "Door", its size from doorConfig, and marks it as alive
  - For any other message, returns default/empty data

The initialization process establishes both the internal state (animation) and
external properties (position, size) of the door.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        DoorMsg dMsg ->
            case dMsg of
                DoorInitMsg initData ->
                    ( defaultData, { emptyBaseData | id = initData.id, ty = "Door", position = initData.position, size = doorConfig.size, alive = True } )

                _ ->
                    ( defaultData, emptyBaseData )

        _ ->
            ( defaultData, emptyBaseData )


{-| Updates the door component based on events.

This function handles the door's behavior on each update cycle.
Currently, this is a placeholder function that simply returns the current state
without modifications, as door interactions are handled in the updaterec function.

-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    ( ( data, basedata ), [], ( env, False ) )


{-| Determines the next level based on the current scene.

This function implements the level progression logic:

  - From "ProtoTest" -> "Level2"
  - From "Level2" -> "Level3"
  - From "Level3" -> "MainMenu" (temporarily, pending implementation of success ending)
  - From any other scene -> "ProtoTest" (default fallback)

This function is called when a character interacts with the door to determine
which scene should be loaded next.

-}
toNextLevel : String -> String
toNextLevel currentScene =
    case currentScene of
        "ProtoTest" ->
            "Level2"

        "Level2" ->
            "Level3"

        "Level3" ->
            -- TODO: Set success ending here
            "MainMenu"

        _ ->
            "ProtoTest"


{-| Processes record-based updates for the door component.

This function handles specific messages sent to the door component:

  - When receiving a ToDoorMsg from the Character component:
      - Checks if the character position (pos) is within the door's collision area
      - If colliding, generates a scene change message to transition to the next level
      - Updates the door animation regardless of collision
  - For any other message, maintains the current state
  - Returns the potentially updated state and any messages to send

This is the main logic for the door component, enabling scene transitions when
the character touches a door, which is the primary gameplay progression mechanic.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CharacterMsg cmsg ->
            case cmsg of
                -- handle scene transition here
                CharacterInit.ToDoorMsg pos ->
                    let
                        newChangeSceneMsg =
                            if Collision.isPointinRec { centerCoordinate = basedata.position, size = basedata.size } pos then
                                [ Parent <| SOMMsg <| SOMChangeScene Nothing (toNextLevel env.globalData.currentScene) ]

                            else
                                []

                        newAnim =
                            Anim.updateLoop data.anim 0.016
                    in
                    ( ( { data | anim = newAnim }, basedata ), newChangeSceneMsg, env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Renders the door component.

This function creates the visual representation of the door:

  - Gets the current animation frame based on the door's animation state
  - Creates a centered texture at the door's position with its defined size
  - Returns the rendered door with a z-index of 0 (rendering order)

The door is rendered as a sprite that can animate through multiple frames when triggered,
visually representing the door's state in the game world.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( {- P.rectCentered (Vec.toTuple basedata.position) (Vec.toTuple basedata.size) 0 Color.blue -} P.centeredTexture (Vec.toTuple basedata.position) (Vec.toTuple basedata.size) 0 (Anim.getCurFrameName data.anim)
    , 0
    )


{-| Determines if this component should process a message for the given target.

This matcher function checks if a message is intended for the door component:

  - Returns true only if the target is "Door"
  - Ignores the data and basedata parameters as they're not needed for this check

This allows the component system to route messages correctly to door components
throughout the component network.

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Door"


{-| Concrete component configuration for the door.

Assembles all the door component functions into a concrete component structure:

  - init: For initialization
  - update: For event-based updates
  - updaterec: For message-based updates
  - view: For rendering
  - matcher: For message routing

This structure defines the complete behavior of the door component.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Door component generator.

Creates a complete, ready-to-use component for doors in the game.
This component can be added to scenes to create interactive doors that
allow the player to transition between different levels or scenes.

-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
