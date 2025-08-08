module Scenes.AllScenes exposing (allScenes)

{-|


# AllScenes

Record all the scenes here

@docs allScenes

-}

import Dict
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.EndScreen.Model as EndScreen
import Scenes.Intro.Model as Intro
import Scenes.Level1.Model as Level1
import Scenes.Level2.Model as Level2
import Scenes.Level3.Model as Level3
import Scenes.MainMenu.Model as MainMenu
import Scenes.ProtoTest.Model as ProtoTest


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    Dict.fromList
        [ ( "EndScreen", EndScreen.scene )
        , ( "Intro", Intro.scene )
        , ( "Level1", Level1.scene )
        , ( "Level2", Level2.scene )
        , ( "Level3", Level3.scene )
        , ( "ProtoTest", ProtoTest.scene )
        , ( "MainMenu", MainMenu.scene )
        ]
