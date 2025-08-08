module Scenes.Home.A.Background exposing (..)

import Color exposing (Color(..))
import REGL.BuiltinPrograms exposing (TextBoxOption, rect, textboxPro)
import REGL.Common exposing (Renderable(..), group)


type alias TextA =
    { key1 : ( Int, Int )
    , key2 : String
    }


textBoxOption : TextBoxOption
textBoxOption =
    { fonts = [ "consolas" ]
    , text = ""
    , size = 80
    , color = Color.white
    , wordBreak = False
    , thickness = Nothing
    , italic = Nothing
    , width = Nothing
    , lineHeight = Nothing
    , wordSpacing = Nothing
    , align = Just "left"
    , tabSize = Nothing
    , valign = Nothing
    , letterSpacing = Nothing
    }


titleOption : TextBoxOption
titleOption =
    { textBoxOption | text = "Variable X", size = 160, align = Just "center" }


background : Renderable
background =
    rect ( 0, 0 ) ( 1920, 1080 ) Color.black


title : Renderable
title =
    textboxPro ( 960, 160 ) titleOption


wordList : List ( ( number, number ), String )
wordList =
    [ ( ( 480, 400 ), "Level 1" ), ( ( 480, 520 ), "Level 2" ), ( ( 480, 640 ), "Level 3" ), ( ( 480, 760 ), "return \"quit\";" ) ]


optionList : List Renderable
optionList =
    List.map (\( x, y ) -> textboxPro x { textBoxOption | text = y }) wordList


viewBackground : Renderable
viewBackground =
    group []
        (title :: optionList)
