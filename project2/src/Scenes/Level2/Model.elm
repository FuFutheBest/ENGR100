module Scenes.Level2.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.Component exposing (AbstractComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Character.Model as Character
import SceneProtos.GameProto.Components.Chest.Init as ChestInit
import SceneProtos.GameProto.Components.Chest.Model as Chest
import SceneProtos.GameProto.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.GameProto.Components.Door.Init as DoorInit
import SceneProtos.GameProto.Components.Door.Model as Door
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Ghosts.Model as Ghosts
import SceneProtos.GameProto.Components.Key.Init as KeyInit
import SceneProtos.GameProto.Components.Key.Model as Key
import SceneProtos.GameProto.Components.ParGen.Init as ParGenInit
import SceneProtos.GameProto.Components.ParGen.Model as ParGen
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit
import SceneProtos.GameProto.Components.Particles.Model as Particles
import SceneProtos.GameProto.Init exposing (InitData)
import SceneProtos.GameProto.Model exposing (genScene)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)



-- [ createRoom ( 640, 476 ) ( 527, 442 ) 1 1 1 1 0 playerPos cullRadius -- 1
-- , createRoom ( 1904, 204 ) ( 2006, 442 ) 2 1 0 0 1 playerPos cullRadius -- 2
-- , createRoom ( 1632, 1088 ) ( 2006, 1326 ) 3 0 0 0 0 playerPos cullRadius --3
-- , createRoom ( 476, 1088 ) ( 784, 1326 ) 4 1 1 0 0 playerPos cullRadius -- 4
-- , createRoom ( 340, 612 ) ( 170, 1326 ) 5 1 0 1 0 playerPos cullRadius -- 5
-- , createRoom ( 340, 340 ) ( 170, 2380 ) 6 0 1 1 0 playerPos cullRadius -- 6
-- , createRoom ( 2924, 680 ) ( 2006, 2380 ) 7 0 1 0 1 playerPos cullRadius -- 7
-- , createRoom ( 476, 1292 ) ( 3230, 1326 ) 8 1 1 0 1 playerPos cullRadius -- 8
-- ]


room12 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room12 =
    [ -- Room 1: Character init
      Character.component (CharacterMsg <| CharacterInit.CharacterInitMsg { id = 1, position = { x = 527, y = 442 } })

    -- Room 2: Ghosts
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 2006, y = 442 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 1700, y = 442 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 1400, y = 442 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 2306, y = 442 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 2606, y = 442 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 21, position = { x = 2806, y = 390 } })
    ]


room34 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room34 =
    [ -- Room 3: Ghosts
      Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 1, position = { x = 2006, y = 1326 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 1, position = { x = 1506, y = 1326 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 1, position = { x = 2506, y = 1326 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 0, position = { x = 2006, y = 1126 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 0, position = { x = 2006, y = 1526 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 0, position = { x = 1706, y = 1526 } })

    -- Room 4: Ghosts and Chest
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 1, position = { x = 784, y = 1126 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 2, position = { x = 784, y = 1526 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 41, position = { x = 784, y = 900 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 42, position = { x = 784, y = 1700 } })
    ]


room568 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room568 =
    [ -- Room 5 : Key room
      Key.component (KeyMsg <| KeyInit.KeyInitMsg { id = 5, position = { x = 170, y = 1326 } })

    -- Room 6: Chest and Door
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 6, position = { x = 170, y = 2280 } })
    , Door.component (DoorMsg <| DoorInit.DoorInitMsg { id = 61, position = { x = 170, y = 2380 } })

    -- Room 8 : Ghosts and Chest
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 8, gtype = 0, position = { x = 3230, y = 1326 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 8, gtype = 0, position = { x = 3230, y = 1126 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 8, gtype = 0, position = { x = 3230, y = 1526 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 81, position = { x = 3230, y = 900 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 82, position = { x = 3230, y = 1700 } })

    -- Particles effect
    , ParGen.component (ParGenMsg <| ParGenInit.NullParGenMsg)
    , Particles.component (ParticlesMsg <| ParticlesInit.NullParticlesMsg)
    ]


room7 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room7 =
    [ -- Room 7: Boos fight
      Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 1606, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 2206, y = 2580 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 3, position = { x = 2006, y = 2180 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 1806, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 1006, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 3006, y = 2580 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 2406, y = 2180 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 1406, y = 2580 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 2606, y = 2580 } })
    ]


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData _ _ =
    { objects =
        room12 ++ room34 ++ room568 ++ room7
    , level = "Level2"
    }


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init
