module SceneProtos.GameProto.Components.Ghosts.GhostUtils exposing
    ( gTypeTrans
    , init, update, updaterec
    )

{-| Ghost utility functions and component implementations.

This module contains the core implementation functions for ghost components,
including initialization, updates, rendering, and type conversion utilities.


# Type Conversion

@docs gTypeTrans


# Component Functions

@docs init, update, updaterec

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.RoomTypes exposing (cullRadius)
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentUpdate, ComponentUpdateRec, ComponentView)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.GhostModel exposing (moveGhost, updateSingleGhost)
import SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing (DashingState(..), Data, GType(..), emptyData)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit
import SceneProtos.GameProto.MainLayer.Room as Room
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Converts integer ghost type to GType enum value.

Maps numeric ghost type identifiers to their corresponding GType variants:

  - 1: DashingGhost with default state
  - 2: LobberGhost with empty state
  - Other: NormalGhost

-}
gTypeTrans : Int -> GType
gTypeTrans gtype =
    case gtype of
        1 ->
            DashingGhost (None 0 0)

        2 ->
            LobberGhost 0 0 Nothing

        3 ->
            -- monk
            LobberGhost 0 0 Nothing

        _ ->
            NormalGhost 0


{-| Initializes a ghost component with provided initialization data.

Creates ghost data and base data structures based on the ghost type,
setting up appropriate animations, health, position, and initial state.
Returns default empty data for invalid initialization messages.

-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        GhostsMsg gmsg ->
            case gmsg of
                GhostsInit.GhostInitMsg initData ->
                    let
                        defaultHp =
                            GhostsInit.ghostsConfig.common.defaultHealthPoint

                        ( gAnim, hp ) =
                            case initData.gtype of
                                1 ->
                                    ( Anim.Loop "dash" 3 0.3 0 0, defaultHp )

                                2 ->
                                    ( Anim.Loop "lobber" 3 0.3 0 0, defaultHp )

                                3 ->
                                    ( Anim.Loop "mf" 2 0.3 0 0, GhostsInit.ghostsConfig.monk.maxHp )

                                _ ->
                                    ( Anim.Loop "normal" 3 0.3 0 0, defaultHp )
                    in
                    ( { emptyData
                        | gtype = gTypeTrans initData.gtype
                        , velocity = Vec.genVec 0 GhostsInit.ghostsConfig.common.speed
                        , state = GhostsInit.Invisible
                        , healthPoint = hp
                        , mushroomConsumed = GhostsInit.ghostsConfig.common.mushroomConsumed
                        , anim = gAnim
                      }
                    , { emptyBaseData
                        | id = initData.id
                        , ty = "Ghost"
                        , position = initData.position
                        , size =
                            case initData.gtype of
                                3 ->
                                    Vec.scale 2.4 (Vec.genVec 60 98)

                                _ ->
                                    GhostsInit.ghostsConfig.common.defaultSize
                        , alive = True
                      }
                    )

                _ ->
                    ( emptyData, emptyBaseData )

        _ ->
            ( emptyData, emptyBaseData )


{-| Updates ghost component on each tick.

Handles ghost movement, skill tree particle emission based on emit level,
and timing controls for particle generation. Updates ghost position and
manages skill tree state including emission timing.

-}
update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                currentTime =
                    env.globalData.currentTimeStamp / 1000

                ( movedData, movedBaseData ) =
                    moveGhost data basedata (toFloat basedata.id + currentTime) dSec (Room.roomsFor env.commonData.level ( basedata.position.x, basedata.position.y ) cullRadius)

                lastEmitTime =
                    data.skillTree.lastEmitTime

                timeGap =
                    case data.skillTree.emitLevel of
                        1 ->
                            Just 10

                        2 ->
                            Just 8

                        3 ->
                            Just 6

                        _ ->
                            Nothing

                ( particleMsg, newTime ) =
                    if data.skillTree.emitLevel > 0 then
                        case timeGap of
                            Just gap ->
                                if (currentTime - lastEmitTime) >= gap then
                                    ( [ Other <| ( "Particles", ParticlesMsg <| ParticlesInit.GhostParticleMsg basedata.position ) ], currentTime )

                                else
                                    ( [], lastEmitTime )

                            Nothing ->
                                ( [], lastEmitTime )

                    else
                        ( [], lastEmitTime )

                oldskillTree =
                    data.skillTree
            in
            ( ( { movedData | skillTree = { oldskillTree | lastEmitTime = newTime } }, movedBaseData ), particleMsg, ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


{-| Updates ghost component based on received messages.

Delegates to updateSingleGhost for handling character interactions,
weapon messages, and other game events that affect ghost behavior.

-}
updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    updateSingleGhost env msg data basedata
