module Lib.Breakout.BricksTextBox exposing (..)

import Color
import Lib.Breakout.BricksInit exposing (Brick, TypeRelatedAttributes(..))
import Lib.Breakout.BricksRandomGenerator exposing (Behaviors(..), Conditions(..))
import Lib.Breakout.Vec as Vec
import REGL.BuiltinPrograms exposing (rectCentered, textbox)
import REGL.Common exposing (Renderable)


bricks89TextBox : Brick -> List Renderable
bricks89TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize =
            Vec.scale 0.2 brick.commonAttributes.size

        textTopLeft =
            ( Tuple.first center - textSize.x * 2
            , Tuple.second center - textSize.y
            )

        ( text, textColor ) =
            case brick.typeRelatedAttributes of
                LeftShiftAttributes int ->
                    ( "x <<= " ++ String.fromInt int, Color.rgb 0 255 255 )

                RightShiftAttributes int ->
                    ( "x >>= " ++ String.fromInt int, Color.rgb 255 0 255 )

                _ ->
                    ( "", Color.black )
    in
    [ textbox textTopLeft textSize.x text "consolas" textColor ]


bricks12TextBox : Brick -> List Renderable
bricks12TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize =
            Vec.scale 0.2 brick.commonAttributes.size

        textTopLeft =
            ( Tuple.first center - textSize.x / 2
            , Tuple.second center - textSize.y
            )

        ( text, textColor ) =
            case brick.typeRef of
                1 ->
                    ( "x++", Color.blue )

                2 ->
                    ( "x--", Color.red )

                _ ->
                    ( "", Color.black )
    in
    [ textbox textTopLeft textSize.x text "consolas" textColor ]


bricks3456TextBox : Brick -> List Renderable
bricks3456TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize =
            Vec.scale 0.2 brick.commonAttributes.size

        textTopLeft =
            ( Tuple.first center - textSize.x * 2
            , Tuple.second center - textSize.y
            )

        ( text, textColor ) =
            case brick.typeRelatedAttributes of
                IncrementIntAttributes int ->
                    ( "x = x + " ++ String.fromInt int, Color.green )

                DecrementIntAttributes int ->
                    ( "x = x - " ++ String.fromInt int, Color.orange )

                MultiplyIntAttributes int ->
                    ( "x = x * " ++ String.fromInt int, Color.purple )

                DivideIntAttributes int ->
                    ( "x = x / " ++ String.fromInt int, Color.brown )

                _ ->
                    ( "", Color.black )
    in
    [ textbox textTopLeft textSize.x text "consolas" textColor ]


bricks0TextBox : Brick -> List Renderable
bricks0TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize =
            Vec.scale 0.15 brick.commonAttributes.size

        textTopLeft =
            ( Tuple.first center - textSize.x * 2.5
            , Tuple.second center - textSize.y
            )
    in
    [ textbox textTopLeft textSize.x "// Comment" "consolas" Color.gray ]


bricks7TextBox : Brick -> List Renderable
bricks7TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize =
            Vec.scale 0.12 brick.commonAttributes.size

        textTopLeft1 =
            ( Tuple.first center - textSize.x * 3
            , Tuple.second center - textSize.y * 2.5
            )

        textTopLeft2 =
            ( Tuple.first center - textSize.x * 1.5
            , Tuple.second center
            )

        ( condition, behavior ) =
            case brick.typeRelatedAttributes of
                ConditionalAttributes ( cond, behav ) ->
                    ( cond, behav )

                _ ->
                    ( NoCondition, DoNothing )

        textbox1 =
            case condition of
                EqualTo int ->
                    textbox textTopLeft1 textSize.x ("if (x == " ++ String.fromInt int ++ ")") "consolas" Color.yellow

                _ ->
                    textbox textTopLeft1 textSize.x "" "consolas" Color.charcoal

        textbox2 =
            case behavior of
                Increment ->
                    textbox textTopLeft2 textSize.x "x++;" "consolas" Color.blue

                Decrement ->
                    textbox textTopLeft2 textSize.x "x--;" "consolas" Color.red

                IncrementInt int ->
                    textbox textTopLeft2 textSize.x ("x += " ++ String.fromInt int ++ ";") "consolas" Color.green

                DecrementInt int ->
                    textbox textTopLeft2 textSize.x ("x -= " ++ String.fromInt int ++ ";") "consolas" Color.orange

                Multiply int ->
                    textbox textTopLeft2 textSize.x ("x *= " ++ String.fromInt int ++ ";") "consolas" Color.purple

                Divide int ->
                    textbox textTopLeft2 textSize.x ("x /= " ++ String.fromInt int ++ ";") "consolas" Color.brown

                LeftShift int ->
                    textbox textTopLeft2 textSize.x ("x <<= " ++ String.fromInt int ++ ";") "consolas" (Color.rgb 0 255 255)

                RightShift int ->
                    textbox textTopLeft2 textSize.x ("x >>= " ++ String.fromInt int ++ ";") "consolas" (Color.rgb 255 0 255)

                DoNothing ->
                    textbox textTopLeft2 0 "" "consolas" Color.black
    in
    [ textbox1, textbox2 ]


bricks10TextBox : Brick -> List Renderable
bricks10TextBox brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        textSize1 =
            Vec.scale 0.09 brick.commonAttributes.size

        textSize2 =
            Vec.scale 0.12 brick.commonAttributes.size

        textTopLeft1 =
            ( Tuple.first center - textSize2.x * 3
            , Tuple.second center - textSize2.y * 2.5
            )

        textTopLeft2 =
            ( Tuple.first center - textSize2.x * 1.5
            , Tuple.second center
            )

        ( count, behavior ) =
            case brick.typeRelatedAttributes of
                ForLoopAttributes ( c, b ) ->
                    ( c, b )

                _ ->
                    ( 0, DoNothing )

        textbox1 =
            textbox textTopLeft1 textSize1.x ("for (i=0; i<" ++ String.fromInt count ++ "; i++)") "consolas" Color.lightYellow

        textbox2 =
            case behavior of
                Increment ->
                    textbox textTopLeft2 textSize2.x "x++;" "consolas" Color.blue

                Decrement ->
                    textbox textTopLeft2 textSize2.x "x--;" "consolas" Color.red

                IncrementInt int ->
                    textbox textTopLeft2 textSize2.x ("x += " ++ String.fromInt int ++ ";") "consolas" Color.green

                DecrementInt int ->
                    textbox textTopLeft2 textSize2.x ("x -= " ++ String.fromInt int ++ ";") "consolas" Color.orange

                Multiply int ->
                    textbox textTopLeft2 textSize2.x ("x *= " ++ String.fromInt int ++ ";") "consolas" Color.purple

                Divide int ->
                    textbox textTopLeft2 textSize2.x ("x /= " ++ String.fromInt int ++ ";") "consolas" Color.brown

                DoNothing ->
                    textbox textTopLeft2 0 "" "consolas" Color.black

                _ ->
                    textbox textTopLeft2 textSize2.x "x++;" "consolas" Color.blue
    in
    [ textbox1, textbox2 ]
