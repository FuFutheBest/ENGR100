module SceneProtos.GameProto.Components.Dialogue.Model exposing (component)

{-| Component model

This library contains the functions that defines the behaviour of dialogues

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Collision as Collision
import Lib.Utils.Dialogue exposing (Dialogue, DialogueCharacterType(..))
import Lib.Utils.Vec as Vec
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Dialogue.Init exposing (DialogueMsg(..), InitData)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)


type alias Data =
    { triggered : Bool, dia : List Dialogue, pos : Vec.Vec, size : Vec.Vec }


defaultData : Data
defaultData =
    { triggered = False
    , dia = [ { character = Charlie, text = "This is a test!" } ]
    , pos = { x = 0, y = 0 }
    , size = { x = 0, y = 0 }
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        DialogueMsg dMsg ->
            case dMsg of
                DialogueInitMsg initData ->
                    ( { defaultData | dia = initData.content, pos = initData.pos, size = initData.size }, { emptyBaseData | id = initData.id, ty = "Dialogue", position = Vec.Vec 960 540, size = Vec.Vec 1 1, alive = True } )

                _ ->
                    ( defaultData, emptyBaseData )

        _ ->
            ( defaultData, emptyBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        KeyDown 90 ->
            -- Z key to try to continue dialogue
            let
                newData =
                    if data.triggered == True then
                        { data | dia = List.drop 1 data.dia }

                    else
                        data
            in
            ( ( newData, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


{-| Checks if `playerPos` is in the 2D box centered at `dialoguePos` with size `dialogueSize`
-}
inDialogue : Vec.Vec -> Vec.Vec -> Vec.Vec -> Bool
inDialogue playerPos dialoguePos dialogueSize =
    let
        ( px, py ) =
            playerPos |> Vec.toTuple

        ( dpx, dpy ) =
            dialoguePos |> Vec.toTuple

        ( dsx, dsy ) =
            dialogueSize |> Vec.toTuple
    in
    if px >= dpx - dsx / 2 && px <= dpx + dsx / 2 && py >= dpy - dsy / 2 && py <= dpy + dsy / 2 then
        True

    else
        False


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        DialogueMsg dMsg ->
            case dMsg of
                TriggerDialogueMsg playerPos ->
                    let
                        newTriggered =
                            inDialogue playerPos data.pos data.size
                    in
                    ( ( { data | triggered = data.triggered || newTriggered }, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        cam =
            env.globalData.camera

        campos =
            ( cam.x, cam.y )

        curDialogue =
            data.dia |> List.head

        rendered =
            if data.triggered then
                case curDialogue of
                    Just dialogue ->
                        let
                            ( characterString, characterName ) =
                                case dialogue.character of
                                    Charlie ->
                                        ( "dia_c", "Charlie" )

                                    Mannie ->
                                        ( "dia_m", "Mannie" )

                                    Aghori ->
                                        ( "dia_a", "Aghori Pret" )

                            text =
                                dialogue.text
                        in
                        group []
                            [ P.centeredTextureWithAlpha ( cam.x, cam.y ) ( 128 * 8, 128 * 8 ) 0 1 "dia_bg"
                            , P.centeredTextureWithAlpha ( cam.x, cam.y - 15 ) ( 128 * 8, 128 * 8 ) 0 1 "dia_box"
                            , P.centeredTextureWithAlpha ( cam.x, cam.y - 15 ) ( 128 * 8, 128 * 8 ) 0 1 characterString
                            , P.textboxCentered ( cam.x - 293, cam.y - 240 ) 30 characterName "Bebas" Color.white
                            , P.textboxCentered ( cam.x + 100, cam.y - 240 ) 30 "PRESS [Z] TO CONTINUE" "Bebas" Color.white
                            , P.textbox ( cam.x - 150, cam.y - 420 ) 40 text "Garet" Color.white
                            ]

                    Nothing ->
                        group [] []
                -- group [] [ P. (data.pos |> Vec.toTuple) (data.size |> Vec.toTuple) 0 0.2 Color.red ]

            else
                group [] []

        -- group [] [ P.rectCentered (data.pos |> Vec.toTuple) (data.size |> Vec.toTuple) 0 Color.red ]
    in
    ( rendered, 1 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Dialogue"


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
