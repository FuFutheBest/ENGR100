module SceneProtos.GameProto.Components.Chest.Model exposing (component)

{-| Chest component model and implementation.

This module defines the chest component, which represents interactive chests in the game.
Players can interact with chests to gain skill points. Chests have two states: closed or opened.


# Component

@docs component

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import SceneProtos.GameProto.Components.Character.Init exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.Chest.Init exposing (ChestMsg(..), chestConfig)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit exposing (ParticlesMsg(..))
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| The internal state data for the chest component.

  - `chestState` - Current state of the chest (open or closed)

-}
type alias Data =
    { chestState : ChestState }


{-| Represents the possible states of a chest.

  - `Closed` - The chest is closed and can be opened by the player
  - `Opened` - The chest has been opened and has granted its reward

-}
type ChestState
    = Closed
    | Opened


{-| Default initial state for a chest component.
-}
defaultData : Data
defaultData =
    { chestState = Closed }


{-| Initializes a new chest component.

Creates a chest based on the initialization message, setting up its position,
size, and initial state (always closed at creation).

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ initMsg =
    case initMsg of
        ChestMsg cMsg ->
            case cMsg of
                ChestInitMsg initData ->
                    ( defaultData, { emptyBaseData | id = initData.id, ty = "Chest", position = initData.position, size = chestConfig.size, alive = True } )

                _ ->
                    ( defaultData, emptyBaseData )

        _ ->
            ( defaultData, emptyBaseData )


{-| Regular update function for the chest component (unused but required by the component interface).
-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env _ data basedata =
    ( ( data, basedata ), [], ( env, False ) )


{-| Processes received messages for the chest component.

The key functionality is handling the `TryGetChestMsg` message from the character
component, which is sent when a player attempts to open the chest. If the chest
is closed and the player is within range (collision check), the chest will open
and grant a skill point to the player.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CharacterMsg cMsg ->
            case cMsg of
                TryGetChestMsg pos ->
                    if data.chestState == Closed && Collision.isPointinRec { centerCoordinate = basedata.position, size = Vec.Vec (32 * 4) (32 * 4) } pos then
                        let
                            newData =
                                { data | chestState = Opened }

                            newEnv =
                                let
                                    oldCommonData =
                                        env.commonData
                                in
                                { env | commonData = { oldCommonData | skillPoints = oldCommonData.skillPoints + 1 } }

                            chestPMsg =
                                Other <| ( "Particles", ParticlesMsg <| ParticlesInit.ChestParticleMsg basedata.position )
                        in
                        ( ( newData, basedata ), [ chestPMsg ], newEnv )

                    else
                        ( ( data, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Renders the chest component.

Displays either an open or closed chest texture based on the current state of the chest.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view _ data basedata =
    let
        chestView =
            case data.chestState of
                Opened ->
                    P.centeredTexture (Vec.toTuple basedata.position) ( 32 * 4, 32 * 4 ) 0 "chest_open"

                Closed ->
                    P.centeredTexture (Vec.toTuple basedata.position) ( 32 * 4, 32 * 4 ) 0 "chest_closed"
    in
    ( chestView, 0 )


{-| Determines if a message should be processed by this component.

Returns true if the target of the message is "Chest".

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "Chest"


{-| The concrete implementation of the chest component.

Combines all the component functions (init, update, updaterec, view, matcher)
into a complete component definition.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Generates and returns the chest component storage.

This is the main export of the module, used to register the chest component
with the game's component system.

-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
