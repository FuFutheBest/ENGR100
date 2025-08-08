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
import Scenes.Ending.Model as Ending
import Scenes.Game.Model as Game
import Scenes.Home.Model as Home
import Scenes.Level1.Model as Level1
import Scenes.Level2.Model as Level2
import Scenes.Script.Model as Script
import Scenes.Starting.Model as Starting


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    Dict.fromList
        [ ( "Game", Game.scene )
        , ( "Home", Home.scene )
        , ( "Starting", Starting.scene )
        , ( "Script", Script.scene )
        , ( "Level1", Level1.scene )
        , ( "Level2", Level2.scene )
        , ( "Ending", Ending.scene )
        ]
