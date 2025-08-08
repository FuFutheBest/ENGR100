module Scenes.Level3.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Dialogue exposing (DialogueCharacterType(..))
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
import SceneProtos.GameProto.Components.Dialogue.Init as DialogueInit
import SceneProtos.GameProto.Components.Dialogue.Model as Dialogue
import SceneProtos.GameProto.Components.Door.Init as DoorInit
import SceneProtos.GameProto.Components.Door.Model as Door
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Ghosts.Model as Ghosts
import SceneProtos.GameProto.Components.Key.Init as KeyInit
import SceneProtos.GameProto.Components.Key.Model as Key
import SceneProtos.GameProto.Components.Mushrooms.Init as MushroomsInit
import SceneProtos.GameProto.Components.Mushrooms.Model as Mushrooms
import SceneProtos.GameProto.Components.ParGen.Init as ParGenInit
import SceneProtos.GameProto.Components.ParGen.Model as ParGen
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit
import SceneProtos.GameProto.Components.Particles.Model as Particles
import SceneProtos.GameProto.Components.Umbrella.Init as UmbrellaInit
import SceneProtos.GameProto.Components.Umbrella.Model as Umbrella
import SceneProtos.GameProto.Init exposing (InitData)
import SceneProtos.GameProto.Model exposing (genScene)
import SceneProtos.GameProto.SceneBase exposing (SceneCommonData)



-- [ createRoom ( 612, 612 ) ( 510, 510 ) 1 1 0 1 0 playerPos cullRadius
-- , createRoom ( 612, 1020 ) ( 510, 1428 ) 2 0 0 1 0 playerPos cullRadius
-- , createRoom ( 1504, 612 ) ( 1760, 510 ) 3 1 0 0 0 playerPos cullRadius
-- , createRoom ( 1504, 1020 ) ( 1760, 1428 ) 4 0 1 0 0 playerPos cullRadius
-- , createRoom ( 614, 612 ) ( 3300, 510 ) 5 1 1 0 1 playerPos cullRadius
-- , createRoom ( 1292, 1020 ) ( 3290, 1428 ) 6 1 0 0 1 playerPos cullRadius
-- , createRoom ( 612, 680 ) ( 510, 2380 ) 7 0 0 1 0 playerPos cullRadius
-- , createRoom ( 680, 680 ) ( 1319, 2380 ) 8 1 1 0 0 playerPos cullRadius
-- , createRoom ( 680, 680 ) ( 2135, 2380 ) 9 1 1 0 0 playerPos cullRadius
-- , createRoom ( 1360, 680 ) ( 3290, 2380 ) 10 0 0 0 0 playerPos cullRadius
-- , createRoom ( 340, 680 ) ( 4460, 2380 ) 11 1 0 0 1 playerPos cullRadius
-- , createRoom ( 612, 1360 ) ( 510, 3502 ) 12 0 1 1 0 playerPos cullRadius
-- , createRoom ( 1360, 1360 ) ( 1598, 3502 ) 13 1 1 0 0 playerPos cullRadius
-- , createRoom ( 680, 680 ) ( 2720, 3502 ) 14 1 1 0 0 playerPos cullRadius
-- , createRoom ( 340, 340 ) ( 4460, 3502 ) 15 0 1 0 1 playerPos cullRadius
-- , createRoom ( 2720, 1700 ) ( 3290, 5692 ) 16 0 1 1 1 playerPos cullRadius
-- ]


room12 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room12 =
    [ -- Room 1: Character init
      Character.component (CharacterMsg <| CharacterInit.CharacterInitMsg { id = 1, position = { x = 510, y = 510 } })

    -- Room 2: Ghosts and Mushrooms
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 360, y = 1128 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 760, y = 1728 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 1, position = { x = 360, y = 1728 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 1, position = { x = 760, y = 1128 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 21, position = { x = 510, y = 1428 } })
    ]


room3 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room3 =
    [ -- Room 3: Ghosts and Mushrooms
      Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 0, position = { x = 1760, y = 360 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 0, position = { x = 1760, y = 660 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 1, position = { x = 1260, y = 360 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 1, position = { x = 1260, y = 660 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 2, position = { x = 2260, y = 360 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 3, gtype = 2, position = { x = 2260, y = 660 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 31, position = { x = 1760, y = 510 } })
    ]


room4Part1 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room4Part1 =
    [ -- Room 4: Ghosts and mushrooms
      Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 2, position = { x = 1760, y = 1428 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 41, position = { x = 1560, y = 1228 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 42, position = { x = 1960, y = 1228 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 43, position = { x = 1560, y = 1628 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 44, position = { x = 1960, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 1, position = { x = 1760, y = 1228 } })
    ]


room4Part2 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room4Part2 =
    [ Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 1, position = { x = 1760, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 1, position = { x = 1560, y = 1428 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 1, position = { x = 1960, y = 1428 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 2, position = { x = 1660, y = 1328 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 2, position = { x = 1660, y = 1528 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 0, position = { x = 1860, y = 1328 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 4, gtype = 0, position = { x = 1860, y = 1528 } })
    ]


room5 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room5 =
    [ -- Room 5: Door and Chests
      Door.component (DoorMsg <| DoorInit.DoorInitMsg { id = 5, position = { x = 3300, y = 610 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 51, position = { x = 3200, y = 410 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 52, position = { x = 3400, y = 410 } })
    ]


room6 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room6 =
    [ -- Room 6: Ghosts and Mushrooms ( 1292, 1020 ) ( 3290, 1428 )
      Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 61, position = { x = 3290, y = 1428 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 0, position = { x = 3090, y = 1228 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 0, position = { x = 3490, y = 1228 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 0, position = { x = 3090, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 0, position = { x = 3490, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 1, position = { x = 3290, y = 1228 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 1, position = { x = 3290, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 1, position = { x = 2190, y = 1228 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 1, position = { x = 2190, y = 1628 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 6, gtype = 2, position = { x = 3290, y = 1428 } })
    ]


room789 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room789 =
    [ -- Room 7 : Chests
      Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 71, position = { x = 410, y = 2380 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 72, position = { x = 610, y = 2380 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 73, position = { x = 510, y = 2280 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 74, position = { x = 510, y = 2480 } })

    -- Room 8 : Ghosts and Chests
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 8, gtype = 0, position = { x = 1319, y = 2226 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 8, gtype = 0, position = { x = 1319, y = 2426 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 81, position = { x = 1319, y = 2380 } })

    -- Room 9 : Ghosts and Chests
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 91, position = { x = 2135, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 9, gtype = 0, position = { x = 2035, y = 2226 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 9, gtype = 0, position = { x = 2035, y = 2426 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 9, gtype = 1, position = { x = 2235, y = 2226 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 9, gtype = 1, position = { x = 2235, y = 2426 } })
    ]


room101112 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room101112 =
    [ -- Room 10 : Ghosts and Mushrooms ( 1360, 680 ) ( 3290, 2380 )
      Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 101, position = { x = 3290, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 10, gtype = 2, position = { x = 3290, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 10, gtype = 1, position = { x = 3090, y = 2380 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 10, gtype = 1, position = { x = 3490, y = 2380 } })

    -- Room 11 chest and ghosts
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 110, gtype = 1, position = { x = 4460, y = 2380 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 111, position = { x = 4460, y = 2280 } })

    -- Room 12 : Mushrooms
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 120, position = { x = 510, y = 3302 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 121, position = { x = 510, y = 3702 } })
    ]


room13 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room13 =
    [ -- Room 13 : Ghosts and Mushrooms ( 1360, 1360 ) ( 1598, 3502 )
      Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 2, position = { x = 1598, y = 3502 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 1, position = { x = 1598, y = 3302 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 2, position = { x = 1598, y = 3702 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 1, position = { x = 1798, y = 3502 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 2, position = { x = 1398, y = 3302 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 130, gtype = 1, position = { x = 1398, y = 3702 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 131, position = { x = 1398, y = 3302 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 132, position = { x = 1798, y = 3702 } })
    ]


room1415 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room1415 =
    [ -- Room 14 Chests and Mushroom
      Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 140, position = { x = 2520, y = 3302 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 141, position = { x = 2920, y = 3302 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 142, position = { x = 2520, y = 3702 } })
    , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 143, position = { x = 2920, y = 3702 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 140, position = { x = 2720, y = 3502 } })

    -- Room 15 : Key
    , Key.component (KeyMsg <| KeyInit.KeyInitMsg { id = 150, position = { x = 4460, y = 3502 } })
    ]


room16Part1 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room16Part1 =
    [ -- Room 16 : Boss and Ghosts and Mushrooms
      Umbrella.component (UmbrellaMsg <| UmbrellaInit.UmbrellaInitMsg { id = 0, position = { x = 3290, y = 5692 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 161, position = { x = 2690, y = 5092 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 162, position = { x = 2690, y = 6292 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 163, position = { x = 3890, y = 5092 } })
    , Mushrooms.component (MushroomMsg <| MushroomsInit.MushroomInitMsg { id = 164, position = { x = 3890, y = 6292 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 3290, y = 5392 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 3290, y = 5992 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 2990, y = 5692 } })
    ]


room16Part2 : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
room16Part2 =
    [ Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 2, position = { x = 3590, y = 5692 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 3290, y = 5392 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 3290, y = 5992 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 2990, y = 5692 } })
    , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 1, position = { x = 3590, y = 5692 } })

    -- Particles effect
    , ParGen.component (ParGenMsg <| ParGenInit.NullParGenMsg)
    , Particles.component (ParticlesMsg <| ParticlesInit.NullParticlesMsg)
    ]


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData _ _ =
    { objects = room12 ++ room3 ++ room4Part1 ++ dialogueCase ++ room4Part2 ++ room5 ++ room6 ++ room789 ++ room101112 ++ room13 ++ room1415 ++ room16Part1 ++ room16Part2
    , level = "Level3"
    }


dialogueCase : List (Env SceneCommonData UserData -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
dialogueCase =
    [ Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia1, pos = { x = 510, y = 510 }, size = { x = 400, y = 400 } })
    ]


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init


tutorialDia1 : List { text : String, character : DialogueCharacterType }
tutorialDia1 =
    let
        t1 =
            [ { text = "Phew... I'm finally here... The last\n level of my intern .", character = Charlie }
            , { text = "WOAH..!! You are alive? I thought I \n killed YOU!", character = Charlie }
            , { text = "Well.. My boy, yes you defeated me \n earlier, but I'm back!", character = Aghori }
            , { text = "But don't worry, I am not here to hurt you,\n rather thank you!", character = Aghori }
            , { text = "Thank me? For what? killing you?", character = Charlie }
            , { text = "Haha..! You are a funny guy... \n I was earlier possesed by those creepy \n ghosts!", character = Aghori }
            , { text = "I am here to Thank you for saving me. \n I can finally medidate back in \n the Everest!", character = Aghori }
            , { text = "Wait so you are a Monk who as possesed \n by these Ghost?", character = Charlie }
            , { text = "Correct....", character = Aghori }
            ]

        t2 =
            [ { text = "Since you helped me to get out  of\n the possesion. I shall bless you with \n something that aids your fight \n against ghost.", character = Aghori }
            , { text = "In this level you shall find some \n mushrooms as a part of my blessing.", character = Aghori }
            , { text = "These mushroom shall cure your wound. \n giving you extra HP... \n Also...", character = Aghori }
            , { text = "These mushroom will enhance your \n ability to see all the ghosts around. \n However...", character = Aghori }
            , { text = "Woah, for real? Thanks old man, \n Imma find one of those mushroom \n real quick", character = Charlie }
            , { text = "You didn't let me finish.... ", character = Aghori }
            , { text = "These mushrooms comes at a price. \n You will also lose something\n precious to you... ", character = Aghori }
            , { text = "What? What do you mean by that?", character = Charlie }
            , { text = "This is the rule of divine powers...\n You gain something, you lose something.", character = Aghori }
            , { text = "Even I can't tell what could equivalently \n be lost.\n Be Careful!!", character = Aghori }
            , { text = "Time has come! I shall take a \n leave now!\n Good luck with your internship!", character = Aghori }
            ]
    in
    t1 ++ t2
