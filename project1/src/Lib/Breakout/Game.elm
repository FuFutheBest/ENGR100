module Lib.Breakout.Game exposing (..)

import Color
import Lib.Breakout.Ball exposing (..)
import Lib.Breakout.BallCollideWithBricks exposing (Ball)
import Lib.Breakout.Layer exposing (infoAAttributes)
import Lib.Breakout.Vec as Vec
import REGL.BuiltinPrograms exposing (rect, textbox, textboxCentered)
import REGL.Common exposing (Renderable, group)


getHelpTexts : Int -> List String
getHelpTexts levelnum =
    case levelnum of
        1 ->
            let
                part1 =
                    [ "Remember: \n  Each Brick corresponds to\n  a programming operation\n"
                    , "Break all the breakable bricks\n"
                    , "The Bricks in this level \nis like mathematical operations\n"
                    , "\"++\"  means: increase x by 1"
                    , "\"--\"  means: decrease x by 1"
                    ]

                part2 =
                    [ "\"+= 3\" means: add 3 to x"
                    , "\"-= 2\" means: subtract 2 from x"
                    , "\"*= 2\" means: multiply x by 2"
                    , "\"/= 2\" means: divide x by 2\n"
                    , "Feel free to pause and\ncheck the info windows"
                    ]
            in
            -- [ "Remember: \n  Each Brick corresponds to\n  a programming operation\n"
            -- , "Break all the breakable bricks\n"
            -- , "The Bricks in this level \nis like mathematical operations\n"
            -- , "\"++\"  means: increase x by 1"
            -- , "\"--\"  means: decrease x by 1"
            -- , "\"+= 3\" means: add 3 to x"
            -- , "\"-= 2\" means: subtract 2 from x"
            -- , "\"*= 2\" means: multiply x by 2"
            -- , "\"/= 2\" means: divide x by 2\n"
            -- , "Feel free to pause and\ncheck the info windows"
            -- ]
            part1 ++ part2

        2 ->
            [ "Remember: \n  Each Brick corresponds to\n  a programming operation\n"
            , "Break all the breakable bricks\n"
            , "\"if\"  means: the brick breaks\n   only if x has the right value\n"
            , "\"for\" means: the operation will\n   repeat for several times\n"
            , "Some bricks are unbreakable...\nYou can't break the grey ones"
            , "Tip: These special bricks\nrepresent comments in programming\n"
            , "Use what you've learned and\nwatch for clues in the code!"
            ]

        3 ->
            [ "Remember: \n  Each Brick corresponds to\n  a programming operation\n"
            , "Break all the breakable bricks\n"
            , "You are a master of programming!\n"
            , "Try to figure out what \"<<\" \nand \">>\" mean by observing \nthe changes to info windows\n"
            , "Use what you've learned!"
            ]

        _ ->
            [ "" ]


viewX : Ball -> State -> Int -> Renderable
viewX ball state levelnum =
    let
        valueCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 0.4 * 480, y = infoAAttributes.centerCoordinate.y - 20 }

        textCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 0.5 * 480, y = infoAAttributes.centerCoordinate.y + 110 }

        continueCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 0.4 * 480, y = infoAAttributes.centerCoordinate.y + 900 }

        returnCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 900, y = infoAAttributes.centerCoordinate.y + 500 }

        endCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 1150, y = infoAAttributes.centerCoordinate.y + 300 }

        winCoordinateTuple =
            Vec.toTuple { x = infoAAttributes.centerCoordinate.x - 880, y = infoAAttributes.centerCoordinate.y + 300 }

        helpTexts =
            getHelpTexts levelnum
                |> String.join "\n"

        blackBackground =
            rect ( 0, 0 ) ( 1920, 1080 ) Color.black

        xTextBox =
            [ textbox valueCoordinateTuple 50 ("Value of X is " ++ String.fromInt ball.variableX) "consolas" Color.red ]

        esctextBox =
            [ textbox continueCoordinateTuple 40 "Esc to Menu" "consolas" Color.white ]

        spaceHelpTextBox =
            [ textbox textCoordinateTuple 40 "Space to Get Help" "consolas" Color.white ]

        helpTextBox =
            [ textbox textCoordinateTuple 30 helpTexts "consolas" Color.white ]
    in
    case state of
        Ended ->
            group []
                [ blackBackground

                {- , textbox endCoordinateTuple 60 "Segmentation fault: x is out of bounds" "consolas" Color.white -}
                , textboxCentered ( 960, infoAAttributes.centerCoordinate.y + 300 ) 60 "Segmentation fault" "consolas" Color.white
                , textboxCentered ( 960, infoAAttributes.centerCoordinate.y + 400 ) 40 "(Hint: x is out of bounds)" "consolas" Color.white
                , textbox returnCoordinateTuple 40 ("Return x (x = " ++ String.fromInt ball.variableX ++ ")") "consolas" Color.white
                , textbox continueCoordinateTuple 40 "Space to try again" "consolas" Color.white
                ]

        Playing ->
            -- group []
            --     [ textbox valueCoordinateTuple 50 ("Value of X is " ++ String.fromInt ball.variableX) "consolas" Color.red
            --     , textbox textCoordinateTuple 40 "Space to Get Help" "consolas" Color.white
            --     , textbox continueCoordinateTuple 40 "Esc to Menu" "consolas" Color.white
            --     ]
            group []
                (xTextBox
                    ++ spaceHelpTextBox
                    ++ esctextBox
                )

        Paused ->
            -- group []
            --     [ textbox valueCoordinateTuple 50 ("Value of X is " ++ String.fromInt ball.variableX) "consolas" Color.green
            --     , textbox textCoordinateTuple 30 helpTexts "consolas" Color.white
            --     , textbox continueCoordinateTuple 40 "Space to Continue" "consolas" Color.white
            --     ]
            group []
                (xTextBox
                    ++ helpTextBox
                    ++ [ textbox continueCoordinateTuple 40 "Space to Continue" "consolas" Color.white ]
                )

        Won ->
            let
                normalRendered =
                    [ blackBackground
                    , textbox winCoordinateTuple 70 "You won!" "consolas" Color.white
                    , textbox returnCoordinateTuple 40 ("Return x (x = " ++ String.fromInt ball.variableX ++ ")") "consolas" Color.white
                    ]

                rendered =
                    case levelnum of
                        3 ->
                            normalRendered ++ [ textboxCentered ( 960, infoAAttributes.centerCoordinate.y + 700 ) 40 "Press Enter to Continue" "consolas" Color.lightRed ]

                        _ ->
                            normalRendered
            in
            group [] rendered


type State
    = Playing
    | Paused
    | Ended
    | Won


stateToggle : State -> State
stateToggle state =
    case state of
        Playing ->
            Paused

        _ ->
            Playing
