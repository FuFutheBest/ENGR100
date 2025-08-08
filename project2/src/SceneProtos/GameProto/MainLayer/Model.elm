module SceneProtos.GameProto.MainLayer.Model exposing (layer)

{-| Main Layer configuration module for the Game Prototype.

This module implements the main gameplay layer that manages game components,
UI elements, and world rendering. It handles the core gameplay mechanics,
component lifecycle, and visual representation of the game world.

@docs layer

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.RoomTypes exposing (cullRadius)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..), unroll)
import Messenger.Layer.Layer exposing (ConcreteLayer, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Ghosts.Model as Ghosts
import SceneProtos.GameProto.Components.Umbrella.Init as UmbrellaInit
import SceneProtos.GameProto.MainLayer.Room as Room
import SceneProtos.GameProto.MainLayer.UI as UI
import SceneProtos.GameProto.SceneBase exposing (..)


{-| Type alias for game components in the messenger structure.
-}
type alias GameComponent =
    AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg


{-| Main layer state data.

  - components - List of all active game components in the layer
  - uiData - User interface state and configuration

-}
type alias Data =
    { components : List GameComponent
    , uiData : UI.UIData
    }


{-| Filters out components that are no longer alive.

This helper function processes a list of components and removes any that
have their alive flag set to False, keeping only active components in the game.
This is used as part of the component lifecycle management to automatically
remove destroyed or consumed objects.

-}
removeDead : List GameComponent -> List GameComponent
removeDead =
    List.filter (\x -> (unroll x).baseData.alive)


{-| Determines if the player can collect keys in the current state.

This function checks if the boss (with ID 0) is still alive in the component list.
If the boss is present, keys cannot be collected. If the boss has been defeated,
keys become collectable, allowing the player to progress.

-}
judgeCanGetKey : List GameComponent -> Bool
judgeCanGetKey components =
    -- Boss Id must be set to 0
    not (List.any (\x -> (unroll x).baseData.id == 0) components)


{-| Initializes the main layer.
-}
init : LayerInit SceneCommonData UserData (LayerMsg SceneMsg) Data
init env initMsg =
    case initMsg of
        MainInitData data ->
            Data data.components UI.initUIData

        _ ->
            Data [] UI.initUIData


{-| Processes component messages sent to the main layer.

This handler function interprets messages from components and updates the layer state:

  - Scene output messages (SOMMsg) are forwarded to the parent scene
  - Character health (CharacterHP) updates the UI's player health display
  - Character mana (CharacterMP) updates the UI's player mana display
  - Weapon switch messages update the UI's weapon indicator
  - Umbrella ghost generation messages create new ghost components

This function enables components to communicate with the layer and with each other,
allowing for coordinated behavior across the game system.

-}
handleComponentMsg : Handler Data SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg ComponentMsg
handleComponentMsg env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg msg ->
            let
                curUIData =
                    data.uiData
            in
            case msg of
                CharacterHP hp ->
                    ( { data | uiData = { curUIData | playerHP = hp } }, [], env )

                CharacterMP mp ->
                    ( { data | uiData = { curUIData | playerMP = mp } }, [], env )

                SwitchWeaponMsg weaponChar ->
                    ( { data | uiData = { curUIData | uiColor = weaponChar } }, [], env )

                UmbrellaMsg umsg ->
                    case umsg of
                        UmbrellaInit.GenGhostMsg idata ->
                            let
                                objs =
                                    data.components

                                newGhostsInitMsg =
                                    GhostsMsg <| GhostsInit.GhostInitMsg { id = idata.id, gtype = idata.gtype, position = idata.position }

                                newBullet =
                                    Ghosts.component newGhostsInitMsg env

                                newObjs =
                                    newBullet :: objs
                            in
                            ( { data | components = newObjs }, [], env )

                        _ ->
                            ( data, [], env )

                _ ->
                    ( data, [], env )


{-| Updates the main layer based on events.

This function handles the layer's behavior on each update cycle:

  - Updates all components and collects their messages
  - Processes component messages using the handleComponentMsg handler
  - Removes dead components from the component list
  - Updates the canGetKey flag based on boss presence
  - On tick events, updates the UI data with elapsed time
  - Returns the updated state and any messages to be sent

This is the core game loop that drives all gameplay systems within the main layer,
coordinating component updates, message handling, and state management.

-}
update : LayerUpdate SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
update env evt data =
    let
        ( comps1, msgs1, ( env1, block1 ) ) =
            updateComponents env evt data.components

        ( data1, msgs2, env2 ) =
            handleComponentMsgs env1 msgs1 { data | components = comps1 } [] handleComponentMsg

        data2 =
            -- Remove dead components
            { data1 | components = removeDead data1.components }

        env3 =
            let
                oldCommonData =
                    env2.commonData
            in
            { env2 | commonData = { oldCommonData | canGetKey = judgeCanGetKey data2.components } }
    in
    case evt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                -- Update UI data
                updatedUIData =
                    UI.updateUIData data2.uiData dSec
            in
            ( { data2 | uiData = updatedUIData }, msgs2, ( env3, block1 ) )

        _ ->
            ( data2, msgs2, ( env3, block1 ) )


{-| Processes record-based updates for the main layer.
-}
updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
updaterec env msg data =
    ( data, [], env )


{-| Separates components into particle generators and other components.
-}
separateComponents : List GameComponent -> { particles : List GameComponent, others : List GameComponent }
separateComponents components =
    -- Helper function to separate components by type
    List.foldr
        (\comp acc ->
            let
                baseData =
                    (unroll comp).baseData
            in
            if baseData.ty == "ParGen" then
                { acc | particles = comp :: acc.particles }

            else
                { acc | others = comp :: acc.others }
        )
        { particles = [], others = [] }
        components


{-| Renders the main layer.

This function creates the visual representation of the entire game world:

  - Separates particles from other components for rendering order
  - Renders a black background covering the entire visible area
  - Renders the level rooms using the room renderer with culling for performance
  - Renders all game components (particles are rendered separately)
  - Renders the UI elements (health bars, mana, weapon indicators)

The rendering process creates a layered view with background, game world elements,
interactive components, and UI overlays, with each layer having appropriate z-ordering.

-}
view : LayerView SceneCommonData UserData Data
view env data =
    let
        { particles, others } =
            separateComponents data.components

        particleRenderable =
            viewComponents env particles

        otherComponentsRenderable =
            viewComponents env others

        backgroundView =
            [ P.rect ( -2000, -2000 ) ( 9000, 9000 ) black ]

        -- Render the background
        uiView =
            UI.viewUI data.uiData ( env.globalData.camera.x, env.globalData.camera.y )

        playerPos =
            ( env.globalData.camera.x, env.globalData.camera.y )
    in
    group []
        (backgroundView
            ++ particleRenderable
            :: Room.renderRoomsFor env.commonData.level playerPos cullRadius
            ++ [ otherComponentsRenderable ]
            ++ uiView
        )


{-| Determines if this layer should process a message for the given target.
-}
matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "MainLayer"


{-| Concrete layer configuration for the main gameplay layer.
-}
layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator for the main gameplay layer.
-}
layer : LayerStorage SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layer =
    genLayer layercon
