module SceneProtos.GameProto.Components.Key.Model exposing (component)

{-| Key component model module.

This module implements the key component for the game. Keys are collectible objects
that can be picked up by the character and are used to unlock doors or progress in the game.
The module includes the component's state, behavior, and rendering functionality.


# Component

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import SceneProtos.GameProto.Components.Character.Init as CharacterInit exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Key.Init as KeyInit exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Key component's internal state data.

  - anim - Animation loop information for the key's visual representation

The animation data controls how the key is displayed and animated in the game.
It uses a looping animation system to create visual interest for the key object.

-}
type alias Data =
    { anim : Anim.Loop }


{-| Default initialization values for the key component's data.

Sets up the initial animation state with:

  - "K" animation sequence
  - 12 frames in the animation
  - 0.05 seconds duration per frame
  - Starting at frame 0
  - No elapsed time

-}
defaultData : Data
defaultData =
    { anim = { name = "K", size = 12, duration = 0.05, currentFrame = 0, currentDuration = 0 } }


{-| Initializes the key component.

This function processes initialization messages to set up a new key component instance:

  - When receiving a KeyInitMsg, it creates a key with the specified id and position
  - Sets the key's type to "Key", its size from keyConfig, and marks it as alive
  - For any other message, returns default/empty data

The initialization process establishes both the internal state (animation) and
external properties (position, size) of the key.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        KeyMsg keyMsg ->
            case keyMsg of
                KeyInitMsg initData ->
                    ( defaultData, { emptyBaseData | id = initData.id, ty = "Key", position = initData.position, size = keyConfig.size, alive = True } )

                _ ->
                    ( defaultData, emptyBaseData )

        _ ->
            ( defaultData, emptyBaseData )


{-| Updates the key component based on events.

This function handles the key's behavior on each update cycle:

  - Checks if the key can be collected (env.commonData.canGetKey)
  - If collectable, sends a ToCharacterMsg with the key's position to the Character component
  - Updates the key's animation based on elapsed time (dt)
  - Returns the updated state and any messages to be sent

The key's animation cycles through frames continuously, creating a visual effect
that draws attention to the key in the game world.

-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        keyMsg =
            if env.commonData.canGetKey then
                [ Other <| ( "Character", KeyMsg <| KeyInit.ToCharacterMsg basedata.position ) ]

            else
                []

        newAnim =
            case evnt of
                Tick dt ->
                    Anim.updateLoopWithName data.anim "K" 12 0.1 (dt / 1000.0)

                _ ->
                    data.anim
    in
    ( ( { data | anim = newAnim }, basedata ), keyMsg, ( env, False ) )


{-| Processes record-based updates for the key component.

This function handles specific messages sent to the key component:

  - When receiving a GotKeyMsg from the Character component, marks the key as not alive (collected)
  - For any other message, maintains the current state
  - Returns the potentially updated state and environment

This mechanism allows the character to "collect" the key, making it disappear from the game
world while still maintaining its state for inventory or game progression purposes.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CharacterMsg cmsg ->
            case cmsg of
                CharacterInit.GotKeyMsg ->
                    ( ( data, { basedata | alive = False } ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Renders the key component.

This function creates the visual representation of the key:

  - Gets the current animation frame based on the key's animation state
  - Creates a centered texture at the key's position with its defined size
  - Returns the rendered key with a z-index of 0 (rendering order)

The key is rendered as a sprite that animates through multiple frames,
making it visually distinct and attention-grabbing in the game world.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        currentFrame =
            Anim.getCurFrameName data.anim

        keyView =
            P.centeredTexture (Vec.toTuple basedata.position) ( 32 * 4, 32 * 4 ) 0 currentFrame
    in
    ( keyView
    , 0
    )


{-| Determines if this component should process a message for the given target.

This matcher function checks if a message is intended for the key component:

  - Returns true only if the target is "Key"
  - Ignores the data and basedata parameters as they're not needed for this check

This allows the component system to route messages correctly to key components
throughout the component network.

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Key"


{-| Concrete component configuration for the key.

Assembles all the key component functions into a concrete component structure:

  - init: For initialization
  - update: For event-based updates
  - updaterec: For message-based updates
  - view: For rendering
  - matcher: For message routing

This structure defines the complete behavior of the key component.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Key component generator.

Creates a complete, ready-to-use component for keys in the game.
This component can be added to scenes to create interactive key objects
that the player can collect during gameplay.

-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
