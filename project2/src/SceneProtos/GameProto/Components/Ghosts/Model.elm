module SceneProtos.GameProto.Components.Ghosts.Model exposing (component)

{-| Ghost component model.

This module provides the main component interface for ghost entities in the game.
It connects all the ghost-related modules into a cohesive component that can be
used by the game engine.


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
import REGL.Common exposing (Renderable, group)
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.GhostUtils exposing (init, update, updaterec)
import SceneProtos.GameProto.Components.Ghosts.GhostsExtraLogic exposing (renderLobberBullets)
import SceneProtos.GameProto.Components.Ghosts.GhostsTypes exposing (DashingState(..), Data, GType(..), emptyData)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


{-| Renders the ghost component visually.

Creates a grouped renderable containing the ghost graphics and
delegates to renderGhost for the actual rendering logic.

-}
view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        ghostView =
            group [] (renderGhost data basedata)
    in
    ( ghostView, 0 )


{-| Renders ghost graphics including sprite, health bar, and bullets.

Handles transparency based on visibility state, draws health bars for visible ghosts,
and includes special rendering for lobber ghost bullets. Adjusts alpha based on
whether the ghost is invisible or visible.

-}
renderGhost : Data -> BaseData -> List Renderable
renderGhost data bdata =
    let
        alpha =
            case data.state of
                GhostsInit.Invisible ->
                    0.2

                GhostsInit.Visible _ _ ->
                    1.0

        normalView =
            case String.length (Anim.getCurFrameName data.anim) of
                3 ->
                    -- monk
                    [ P.centeredTextureWithAlpha (Vec.toTuple bdata.position) ( 60 * 2.5, 89 * 2.5 ) 0.0 alpha (Anim.getCurFrameName data.anim) ]

                _ ->
                    [ P.centeredTextureWithAlpha (Vec.toTuple bdata.position) (Vec.toTuple bdata.size) 0.0 alpha (Anim.getCurFrameName data.anim) ]

        hpBarPos =
            Vec.genVec 0 (-bdata.size.y / 2)
                |> Vec.add bdata.position

        hpBarThick =
            3

        hpBarWidth =
            20

        hpBarOutSize =
            Vec.genVec bdata.size.x hpBarWidth

        innerBlanckSize =
            Vec.genVec (bdata.size.x - 2 * hpBarThick) (hpBarWidth - 2 * hpBarThick)

        wholeLength =
            bdata.size.x - 2 * hpBarThick

        maxHP =
            case String.length (Anim.getCurFrameName data.anim) of
                3 ->
                    -- monk
                    GhostsInit.ghostsConfig.monk.maxHp

                _ ->
                    GhostsInit.ghostsConfig.common.defaultHealthPoint

        currentHP =
            data.healthPoint

        hpBarlength =
            if currentHP > 0 then
                (toFloat currentHP / toFloat maxHP) * wholeLength

            else
                0

        hpBarSize =
            Vec.genVec hpBarlength (hpBarWidth - 2 * hpBarThick)

        hpBarPosInner =
            Vec.genVec (hpBarPos.x - innerBlanckSize.x / 2 + hpBarlength / 2) hpBarPos.y

        hpBarView =
            [ P.rectCentered (Vec.toTuple hpBarPos) (Vec.toTuple hpBarOutSize) 0.0 (Color.rgba 0.7 0.0 0.0 0.5)
            , P.rectCentered (Vec.toTuple hpBarPos) (Vec.toTuple innerBlanckSize) 0.0 Color.black
            , P.rectCentered (Vec.toTuple hpBarPosInner) (Vec.toTuple hpBarSize) 0.0 Color.red
            ]

        ghostView =
            case data.gtype of
                LobberGhost _ _ bullets ->
                    let
                        bulletsView =
                            renderLobberBullets bullets
                    in
                    normalView ++ bulletsView

                _ ->
                    normalView

        allView =
            case data.state of
                GhostsInit.Invisible ->
                    ghostView

                GhostsInit.Visible _ _ ->
                    ghostView ++ hpBarView
    in
    allView


{-| Determines if a component message targets this ghost component.

Returns True if the target matches "Ghosts", used by the component
system to route messages to the appropriate components.

-}
matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Ghosts"


{-| Concrete component configuration structure.

Defines the complete component behavior by combining init, update, view,
and matcher functions into a cohesive component configuration.

-}
componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
