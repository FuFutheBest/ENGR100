module SceneProtos.GameProto.Components.Umbrella.Model exposing (component)

{-| Component model

@docs component

-}

import Audio exposing (scaleVolumeAt)
import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Anim as Anim
import Lib.Utils.Collision as Collision
import Lib.Utils.Vec as Vec
import Messenger.Audio.Base exposing (..)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel as GM exposing (..)
import Messenger.Scene.Scene as Scene
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Random
import SceneProtos.GameProto.Components.Character.Init exposing (CharacterMsg(..))
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, emptyBaseData)
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit exposing (GhostsMsg(..))
import SceneProtos.GameProto.Components.Umbrella.Init exposing (..)
import SceneProtos.GameProto.Components.Umbrella.UmbrellaLogic exposing (..)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)
import Time


defaultData : Data
defaultData =
    { lastGenGhostTime = 0.0
    , attackCount = 0
    , healthPoint = uConfig.maxhealthPoint
    , lastLaunchTime = 0.0
    , bullets = Nothing
    , anim = Anim.Loop "u" 6 0.6 0 0
    , isAudioPlaying = False
    }


generateSeed : Float -> Random.Seed
generateSeed seedFloat =
    Random.initialSeed (round seedFloat)


randomProbabilityGenerator : Float -> Int -> Bool
randomProbabilityGenerator seedFloat p =
    let
        seed =
            generateSeed seedFloat

        ( randomVal, _ ) =
            Random.step (Random.int 0 100) seed
    in
    randomVal <= p


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        UmbrellaMsg uMsg ->
            case uMsg of
                UmbrellaInitMsg initData ->
                    ( defaultData, { emptyBaseData | id = initData.id, ty = "Umbrella", position = initData.position, size = uConfig.size, alive = True } )

                _ ->
                    ( defaultData, emptyBaseData )

        _ ->
            ( defaultData, emptyBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                dSec =
                    dt / 1000

                newAnim =
                    Anim.updateLoop data.anim dSec
            in
            ( ( { data | anim = newAnim }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp / 1000
    in
    case msg of
        CharacterMsg (ToBossMsg weapon pos) ->
            let
                distance =
                    Vec.subtract pos basedata.position
                        |> Vec.length

                genGhostMsg =
                    Parent <| OtherMsg <| UmbrellaMsg (GenGhostMsg (GhostInitData basedata.id (modBy 3 (round (env.globalData.currentTimeStamp * 19260817))) basedata.position))

                ( audioprocessedData, audioMsg ) =
                    if distance <= uConfig.detectDistance && not data.isAudioPlaying then
                        let
                            ts =
                                env.globalData.currentTimeStamp

                            nts =
                                Time.millisToPosix <| floor ts + 500

                            lts =
                                Time.millisToPosix <| floor ts + 1000

                            start =
                                Time.millisToPosix (floor ts)

                            end_ =
                                Time.millisToPosix (floor ts + 3000)
                        in
                        ( { data | isAudioPlaying = True }
                        , [ GM.Parent <| GM.SOMMsg (Scene.SOMStopAudio (AudioName 0 "home")), GM.Parent <| GM.SOMMsg (Scene.SOMPlayAudio 0 "umbrella" <| ALoop Nothing Nothing) ]
                          -- , [ GM.Parent <| GM.SOMMsg <| Scene.SOMTransformAudio (AudioName 0 "home") (scaleVolumeAt [ ( Time.millisToPosix <| floor env.globalData.currentTimeStamp, 0 ), ( nts, 2 ), ( lts, 0 ) ])
                          --   , GM.Parent <| GM.SOMMsg (Scene.SOMPlayAudio 0 "umbrella" <| ALoop Nothing Nothing)
                          --   ]
                          -- , [ GM.Parent <|
                          --         GM.SOMMsg <|
                          --             Scene.SOMTransformAudio
                          --                 (AudioName 0 "home")
                          --                 (scaleVolumeAt
                          --                     [ ( start, 2 )
                          --                     , ( end_, 0 )
                          --                     ]
                          --                 )
                          --   , GM.Parent <| GM.SOMMsg (Scene.SOMPlayAudio 1 "umbrella" <| ALoop Nothing Nothing)
                          --   , GM.Parent <|
                          --         GM.SOMMsg <|
                          --             Scene.SOMTransformAudio
                          --                 (AudioName 1 "umbrella")
                          --                 (scaleVolumeAt
                          --                     [ ( start, 0 )
                          --                     , ( end_, 2 )
                          --                     ]
                          --                 )
                          --   ]
                        )

                    else
                        ( data, [] )

                ( newData1, newMsg1 ) =
                    -- handle generate Ghosts
                    if currentTime - data.lastGenGhostTime >= uConfig.genGhostGap && distance <= uConfig.detectDistance then
                        ( { audioprocessedData | lastGenGhostTime = currentTime }, genGhostMsg :: audioMsg )

                    else
                        ( audioprocessedData, [] )

                isCollided =
                    Collision.isPointinRec
                        { centerCoordinate = basedata.position, size = basedata.size }
                        pos

                updatedCnt =
                    if isCollided then
                        data.attackCount + 1

                    else
                        0

                attackMsg =
                    if isCollided && modBy uConfig.attackFrames updatedCnt == 3 then
                        [ Other <| ( "Character", GhostsMsg <| GhostsInit.AttackCharacterMsg uConfig.touchAttack ) ]

                    else
                        []

                ( newData2, newMsg2 ) =
                    -- handle attck character
                    ( newData1, newMsg1 ++ attackMsg )

                ( ( newData3, newbData3 ), appendedMsg1, _ ) =
                    handleWeapon env msg newData2 basedata

                ( ( newData4, newbData4 ), appendedMsg2, _ ) =
                    handleShootingBullet env msg newData3 newbData3
            in
            ( ( newData4, newbData4 ), newMsg2 ++ appendedMsg1 ++ appendedMsg2, env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        uView =
            [ P.centeredTexture (Vec.toTuple basedata.position) ( 400, 400 ) 0 (Anim.getCurFrameName data.anim)
            ]

        bullets =
            renderBullets data.bullets

        bdata =
            basedata

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
            uConfig.maxhealthPoint

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

        allView =
            group [] (uView ++ bullets ++ hpBarView)
    in
    ( allView, -1 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Umbrella"


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
