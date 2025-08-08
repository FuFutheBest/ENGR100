module Lib.Breakout.BricksView exposing (..)

{- This module only solves the view problems related to bricks.
   More specifically, how to transform a list of Bricks to a list of Renderables.
-}

import Color
import Lib.Breakout.BricksInit exposing (Brick, TypeRelatedAttributes(..))
import Lib.Breakout.BricksRandomGenerator exposing (Behaviors(..), Conditions(..))
import Lib.Breakout.BricksTextBox exposing (..)
import Lib.Breakout.Vec as Vec
import REGL.BuiltinPrograms exposing (rectCentered, textbox)
import REGL.Common exposing (Renderable)


viewBrick : Brick -> List Renderable
viewBrick brick =
    let
        center =
            Vec.toTuple brick.commonAttributes.centerCoordinate

        size1 =
            Vec.toTuple brick.commonAttributes.size

        size2 =
            Vec.toTuple (Vec.scale 0.9 brick.commonAttributes.size)

        angle =
            0.0

        textBox =
            case brick.typeRef of
                0 ->
                    Just (bricks0TextBox brick)

                1 ->
                    Just (bricks12TextBox brick)

                2 ->
                    Just (bricks12TextBox brick)

                3 ->
                    Just (bricks3456TextBox brick)

                4 ->
                    Just (bricks3456TextBox brick)

                5 ->
                    Just (bricks3456TextBox brick)

                6 ->
                    Just (bricks3456TextBox brick)

                7 ->
                    Just (bricks7TextBox brick)

                8 ->
                    Just (bricks89TextBox brick)

                9 ->
                    Just (bricks89TextBox brick)

                10 ->
                    Just (bricks10TextBox brick)

                -- for loop
                _ ->
                    Nothing
    in
    [ rectCentered center size1 angle Color.white
    , rectCentered center size2 angle Color.black
    ]
        ++ (Maybe.map (\textbox -> [ textbox ]) textBox
                |> Maybe.withDefault [ [] ]
                |> List.concat
           )


viewBricks : List Brick -> List Renderable
viewBricks bricks =
    List.concatMap viewBrick bricks
