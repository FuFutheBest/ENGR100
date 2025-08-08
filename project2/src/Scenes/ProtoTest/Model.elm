module Scenes.ProtoTest.Model exposing (scene)

{-|


# Level configuration module

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Lib.Utils.Dialogue exposing (DialogueCharacterType(..))
import Messenger.Base exposing (Env)
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.RawScene exposing (RawSceneProtoLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Character.Model as Character
import SceneProtos.GameProto.Components.Chest.Init as ChestInit
import SceneProtos.GameProto.Components.Chest.Model as Chest
import SceneProtos.GameProto.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.GameProto.Components.Dialogue.Init as DialogueInit
import SceneProtos.GameProto.Components.Dialogue.Model as Dialogue
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
import SceneProtos.GameProto.Components.Umbrella.Init as UmbrellaInit
import SceneProtos.GameProto.Components.Umbrella.Model as Umbrella
import SceneProtos.GameProto.Init exposing (InitData)
import SceneProtos.GameProto.Model exposing (genScene)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData _ _ =
    { objects =
        let
            c1 =
                [ -- Ghosts in the upper room
                  -- , Umbrella.component (UmbrellaMsg <| UmbrellaInit.UmbrellaInitMsg { id = 2, position = { x = 960, y = -996 } })
                  Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 2400, y = 540 } })
                , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 2450, y = 700 } })

                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 660, y = -1240 } })
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 2, gtype = 0, position = { x = 1260, y = -690 } })
                -- -- Ghosts in the bottom room
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 960, y = 2076 } })
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 560, y = 1676 } })
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 560, y = 2476 } })
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 1360, y = 1676 } })
                -- , Ghosts.component (GhostsMsg <| GhostsInit.GhostInitMsg { id = 0, gtype = 0, position = { x = 1360, y = 2476 } })
                ]

            -- Door and Chest in the left room
            c2 =
                [ Door.component (DoorMsg <| DoorInit.DoorInitMsg { id = 4, position = { x = 5428, y = 540 } })
                , Chest.component (ChestMsg <| ChestInit.ChestInitMsg { id = 5, position = { x = 3936, y = 240 } })

                -- -- Key and chest in the right room
                , Key.component (KeyMsg <| KeyInit.KeyInitMsg { id = 3, position = { x = 3936, y = 2032 } })
                , Character.component (CharacterMsg <| CharacterInit.CharacterInitMsg { id = 1, position = { x = -540, y = 540 } })

                -- ParGen and Particles for effects
                , ParGen.component (ParGenMsg <| ParGenInit.NullParGenMsg)
                , Particles.component (ParticlesMsg <| ParticlesInit.NullParticlesMsg)
                , Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia1, pos = { x = -540, y = 540 }, size = { x = 400, y = 400 } })
                , Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia2, pos = { x = 340, y = 540 }, size = { x = 400, y = 400 } })
                , Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia3, pos = { x = 3936, y = 540 }, size = { x = 600, y = 400 } })
                , Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia4, pos = { x = 3936, y = 2000 }, size = { x = 400, y = 400 } })
                , Dialogue.component (DialogueMsg <| DialogueInit.DialogueInitMsg { id = 100, content = tutorialDia5, pos = { x = 4800, y = 540 }, size = { x = 400, y = 400 } })
                ]
        in
        c1 ++ c2
    , level = "Level1"
    }


tutorialDia1 : List { text : String, character : DialogueCharacterType }
tutorialDia1 =
    [ { text = "Phew... I'm finally here... The last\nmission of my intern.", character = Charlie }
    , { text = "This company sucks. They weren't even\nallowing me to touched this awesome suit\nbefore this STUPID mission...", character = Charlie }
    , { text = "... Ahem. Comms check.", character = Mannie }
    , { text = "I mean this company is the best!\nComms - check!", character = Charlie }
    , { text = "Okay, comms are ready...\nGood morning intern, I'm Mannie, the\ncoordinator of this ghostbust operation.", character = Mannie }
    , { text = "Hi Mannie! Pleasure to hear your voice!", character = Charlie }
    , { text = "Let's get to business. Try moving\naround with your suit.", character = Mannie }
    , { text = "Once you engage in contact with the\nghosts, we wouldn't be able to help\nyou fix your suit.", character = Mannie }
    , { text = "Yeah well... I got sleepy during your\nlectures back in HQ... Now how do I move\naround in this thing again?", character = Charlie }
    , { text = "**sigh**\nThere should be four keys labelled\nW, A, S and D by your left hand. Press\nthem to move.", character = Mannie }
    , { text = "Keep in touch. I'll guide you once you reach\nthe room on your right.", character = Mannie }
    ]


tutorialDia2 : List { text : String, character : DialogueCharacterType }
tutorialDia2 =
    let
        t21 =
            [ { text = "From the technical reports, this\ndungeon seems to be haunted by\ninvisible ghosts.", character = Mannie }
            , { text = "Wait what? Invisible? Then how the\nheck am I supposed to find them?", character = Charlie }
            , { text = "Dear God... You really haven't\npaid attention to anything I've\nsaid back in HQ...", character = Mannie }
            , { text = "Sorry!", character = Charlie }
            , { text = "You are equipped with our company's\nghostmarker spray. It consumes some\nof your suit's mana and can reveal\nghosts.", character = Mannie }
            , { text = "This room is ghost-free. Try it\nout here. Press the left button\nof your mouse to spray.", character = Mannie }
            ]

        t22 =
            [ { text = "Now how do I kill the ghosts?", character = Charlie }
            , { text = "Press right button to switch to the\nghostbuster cannon. Remember using\nweapons consumes MP.", character = Mannie }
            , { text = "Then hold your left button to charge,\nand release to shoot.\nYou can switch between the two\nweapons with the right button.", character = Mannie }
            , { text = "That sounds simple!", character = Charlie }
            , { text = "Because it IS simple...\nAnyways, there will be two ghosts in\nthe next room.", character = Mannie }
            , { text = "You cannot proceed to the next level\nif you miss any ghost in the current\none.", character = Mannie }
            , { text = "Remember, reveal it with the yellow\nspray, and buzz it with the blue cannon.\nGood luck.", character = Mannie }
            ]
    in
    t21 ++ t22


tutorialDia3 : List { text : String, character : DialogueCharacterType }
tutorialDia3 =
    [ { text = "Woah! What's this precious?", character = Charlie }
    , { text = "This is a treasure chest. Directly\nwalk past it to open it.", character = Mannie }
    , { text = "Okay... So what's in it?", character = Charlie }
    , { text = "A bit of HP and MP, and one\nSKILL POINT. Notice the four buttons\non the bottom right corner of your\nscreen?", character = Mannie }
    , { text = "Uh-huh.", character = Charlie }
    , { text = "Press the corresponding button\non the keyboard to upgrade those\nskills with your SKILL POINTS.", character = Mannie }
    , { text = "One of them reveals ghosts, and one\nof the other makes you stronger...", character = Mannie }
    , { text = "I forgot about the details, you're\ngonna have to test them out\nby yourself.", character = Mannie }
    ]


tutorialDia4 : List { text : String, character : DialogueCharacterType }
tutorialDia4 =
    [ { text = "Oh great! That's the key ahead of\nyou.", character = Mannie }
    , { text = "I assume that's my way to the\nnext level?", character = Charlie }
    , { text = "Bingo! Press [R] to pick it up.\nBe careful though, keys are also\nsupernatural entities. \n", character = Mannie }
    , { text = "They can't be picked up if \nthere's still ghosts nearby.", character = Mannie }
    , { text = "So be sure to clear every one of\nthem ghosts.", character = Mannie }
    , { text = "Roger roger.", character = Charlie }
    ]


tutorialDia5 : List { text : String, character : DialogueCharacterType }
tutorialDia5 =
    [ { text = "See the door over there?\nThat's your way outta here.", character = Mannie }
    , { text = "However you're gonna need a\nkey to open it.", character = Mannie }
    , { text = "So there will be more ghosts\nin the next level?", character = Charlie }
    , { text = "Usually, yes.", character = Mannie }
    , { text = "Could this dungeon be an \nexception?", character = Charlie }
    , { text = "Not likely.", character = Mannie }
    , { text = "Aw f-", character = Charlie }
    , { text = "Watch your language! Deductions\nwill follow if you use\nimproper language during work\ntime!", character = Mannie }
    , { text = "... fine.", character = Charlie }
    ]


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init
