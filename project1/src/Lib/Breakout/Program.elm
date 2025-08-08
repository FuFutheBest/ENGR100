module Lib.Breakout.Program exposing (..)

import Color
import Lib.Breakout.BricksInit exposing (TypeRelatedAttributes(..))
import Lib.Breakout.BricksRandomGenerator exposing (Behaviors(..), Conditions(..))
import REGL.BuiltinPrograms exposing (textbox)
import REGL.Common exposing (Renderable)


programAttributes : { renderedTopLeft : ( Float, Float ), textSize : Float }
programAttributes =
    { renderedTopLeft = ( 30, 30 )
    , textSize = 16
    }


type alias CodeLine =
    { text : String }


type alias ProgramData =
    { codeLines : List CodeLine
    , renderables : List Renderable
    }



-- Programmer humor comments


programmerComments : List String
programmerComments =
    let
        comments1 =
            [ "    // TODO: fix this later"
            , "    // Magic. Do not touch."
            , "    // This is a mess, but works."
            , "    // I'm not sure why this works"
            , "    // Here be dragons"
            , "    // HACK: Don't judge me."
            ]

        comments2 =
            [ "    // Sorry for this code."
            , "    // Should not work but it does."
            , "    // I was drunk when I wrote this"
            , "    // If breaks, blame the intern."
            , "    // Temporary solution (since 2019)"
            , "    // Works on my machine"
            ]

        comments3 =
            [ "    // Don't ask me how this works"
            , "    // Copy from Stack Overflow"
            , "    // No comment, no problem"
            , "    // Not a bug, but a feature"
            ]

        comments =
            comments1 ++ comments2 ++ comments3
    in
    comments


getRandomComment : Int -> String
getRandomComment seed =
    let
        index =
            modBy (List.length programmerComments) seed

        comment =
            List.drop index programmerComments |> List.head
    in
    Maybe.withDefault "    // comment" comment


maxVisibleLines : Int
maxVisibleLines =
    let
        codeAreaHeight =
            1040 - 80

        lineHeight =
            programAttributes.textSize + 5
    in
    floor (codeAreaHeight / lineHeight)


codeLineToRenderable : Int -> CodeLine -> Renderable
codeLineToRenderable lineIndex codeLine =
    let
        yPosition =
            toFloat lineIndex * (programAttributes.textSize + 5) + Tuple.second programAttributes.renderedTopLeft

        position =
            ( Tuple.first programAttributes.renderedTopLeft, yPosition )
    in
    textbox position programAttributes.textSize codeLine.text "consolas" Color.white


updateProgramRenderables : List CodeLine -> List Renderable
updateProgramRenderables codeLines =
    let
        visibleLines =
            if List.length codeLines > maxVisibleLines then
                List.drop (List.length codeLines - maxVisibleLines) codeLines

            else
                codeLines
    in
    List.indexedMap codeLineToRenderable visibleLines


defaultInitProgram : ProgramData
defaultInitProgram =
    let
        initialLines =
            [ { text = "int func () {" }
            , { text = "    int x = 0;" }
            ]
    in
    { codeLines = initialLines
    , renderables = updateProgramRenderables initialLines
    }


getProgramRenderables : ProgramData -> List Renderable
getProgramRenderables programData =
    programData.renderables


appendBrickToProgram : ProgramData -> Int -> TypeRelatedAttributes -> ProgramData
appendBrickToProgram programData seed brickType =
    let
        codeLines =
            case brickType of
                CommentAttributes ->
                    [ getRandomComment seed ]

                IncrementAttributes ->
                    [ "    x++;" ]

                DecrementAttributes ->
                    [ "    x--;" ]

                IncrementIntAttributes value ->
                    [ "    x += " ++ String.fromInt value ++ ";" ]

                DecrementIntAttributes value ->
                    [ "    x -= " ++ String.fromInt value ++ ";" ]

                MultiplyIntAttributes value ->
                    [ "    x *= " ++ String.fromInt value ++ ";" ]

                DivideIntAttributes value ->
                    [ "    x /= " ++ String.fromInt value ++ ";" ]

                LeftShiftAttributes value ->
                    [ "    x <<= " ++ String.fromInt value ++ ";" ]

                RightShiftAttributes value ->
                    [ "    x >>= " ++ String.fromInt value ++ ";" ]

                ForLoopAttributes ( count, behavior ) ->
                    let
                        behaviorStr =
                            case behavior of
                                Increment ->
                                    "        x++;"

                                Decrement ->
                                    "        x--;"

                                IncrementInt value ->
                                    "        x += " ++ String.fromInt value ++ ";"

                                DecrementInt value ->
                                    "        x -= " ++ String.fromInt value ++ ";"

                                Multiply value ->
                                    "        x *= " ++ String.fromInt value ++ ";"

                                Divide value ->
                                    "        x /= " ++ String.fromInt value ++ ";"

                                LeftShift value ->
                                    "        x <<= " ++ String.fromInt value ++ ";"

                                RightShift value ->
                                    "        x >>= " ++ String.fromInt value ++ ";"

                                DoNothing ->
                                    ""
                    in
                    [ "    for (int i = 0; i < " ++ String.fromInt count ++ "; i++) {"
                    , behaviorStr
                    , "    }"
                    ]

                ConditionalAttributes ( condition, behavior ) ->
                    let
                        conditionStr =
                            case condition of
                                EqualTo value ->
                                    "x == " ++ String.fromInt value

                                NoCondition ->
                                    "true"

                        behaviorStr =
                            case behavior of
                                Increment ->
                                    "        x++;"

                                Decrement ->
                                    "        x--;"

                                IncrementInt value ->
                                    "        x += " ++ String.fromInt value ++ ";"

                                DecrementInt value ->
                                    "        x -= " ++ String.fromInt value ++ ";"

                                Multiply value ->
                                    "        x *= " ++ String.fromInt value ++ ";"

                                Divide value ->
                                    "        x /= " ++ String.fromInt value ++ ";"

                                LeftShift value ->
                                    "        x <<= " ++ String.fromInt value ++ ";"

                                RightShift value ->
                                    "        x >>= " ++ String.fromInt value ++ ";"

                                DoNothing ->
                                    ""
                    in
                    [ "    if (" ++ conditionStr ++ ") {"
                    , behaviorStr
                    , "    }"
                    ]

                NullAttributes ->
                    [ "" ]

        newCodeLines =
            List.map (\text -> { text = text }) (List.filter (\line -> line /= "") codeLines)

        updatedCodeLines =
            programData.codeLines ++ newCodeLines

        updatedRenderables =
            updateProgramRenderables updatedCodeLines
    in
    { codeLines = updatedCodeLines
    , renderables = updatedRenderables
    }


defaultEnd : ProgramData -> ProgramData
defaultEnd programData =
    let
        endLines =
            [ { text = "    return x;" }
            , { text = "}" }
            ]

        updatedCodeLines =
            programData.codeLines ++ endLines

        updatedRenderables =
            updateProgramRenderables updatedCodeLines
    in
    { codeLines = updatedCodeLines
    , renderables = updatedRenderables
    }


fromRenderableList : List Renderable -> ProgramData
fromRenderableList renderables =
    { codeLines = []
    , renderables = renderables
    }


toRenderableList : ProgramData -> List Renderable
toRenderableList programData =
    programData.renderables
