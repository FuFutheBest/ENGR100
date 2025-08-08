module Lib.Breakout.BricksInit exposing (Brick, TypeRelatedAttributes(..), initBricks)

{- This module only solves the init problems related to bricks.
   including:
    - assign the init center Coordinates
    - assign the sizes
    - assign the types
    - assign the type related attributes
-}

import Lib.Breakout.BricksRandomGenerator exposing (..)
import Lib.Breakout.Vec exposing (Vec)


type alias Brick =
    { commonAttributes : CommonAttributes
    , typeRef : Int

    {- typeRef as defined as follows:
       0 : comment Bricks
       1: increment Bricks "++"
       2: decrement Bricks "--"
       3: increment int Bricks "x = x + int"
       4: decrement int Bricks "x = x - int"
       5: multiply int Bricks "x = x * int"
       6: divide int Bricks "x = x / int"
       7: Conditional Bricks "if ..."
       8: left shift "x <<= int"
       9: right shift "x >>= int"
       10: for loop "for (i = 0; i < count; i++) { action }"

    -}
    , typeRelatedAttributes : TypeRelatedAttributes
    }


type TypeRelatedAttributes
    = CommentAttributes
    | IncrementAttributes
    | DecrementAttributes
    | IncrementIntAttributes Int -- increment int Bricks "x = x + int"
    | DecrementIntAttributes Int -- decrement int Bricks "x = x - int"
    | MultiplyIntAttributes Int -- multiply int Bricks "x * int"
    | DivideIntAttributes Int -- divide int Bricks "x / int"
    | ConditionalAttributes ( Conditions, Behaviors ) -- Conditional Bricks "if ..."
    | LeftShiftAttributes Int -- left shift "x <<= int"
    | RightShiftAttributes Int -- right shift "x >>= int"
    | ForLoopAttributes ( Int, Behaviors ) -- for loop "for (i = 0; i < count; i++) { behavior }"
    | NullAttributes


centerCoordinatesGenerator : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float } -> List Vec
centerCoordinatesGenerator bricksAttrs =
    let
        totalWidth =
            toFloat bricksAttrs.bricksPerLayer
                * bricksAttrs.width
                + toFloat (bricksAttrs.bricksPerLayer - 1)
                * bricksAttrs.widthGap

        totalHeight =
            toFloat bricksAttrs.layer
                * bricksAttrs.height
                + toFloat (bricksAttrs.layer - 1)
                * bricksAttrs.heightGap

        brickPositions =
            List.concatMap
                (\layerIndex ->
                    let
                        yOffset =
                            -totalHeight
                                / 2
                                + bricksAttrs.height
                                / 2
                                + toFloat layerIndex
                                * (bricksAttrs.height + bricksAttrs.heightGap)
                    in
                    List.map
                        (\brickIndex ->
                            let
                                xOffset =
                                    -totalWidth
                                        / 2
                                        + bricksAttrs.width
                                        / 2
                                        + toFloat brickIndex
                                        * (bricksAttrs.width + bricksAttrs.widthGap)
                            in
                            { x = bricksAttrs.center.x + xOffset
                            , y = bricksAttrs.center.y + yOffset
                            }
                        )
                        (List.range 0 (bricksAttrs.bricksPerLayer - 1))
                )
                (List.range 0 (bricksAttrs.layer - 1))
    in
    brickPositions


typeToTypeRelatedAttributes : Int -> Int -> Int -> TypeRelatedAttributes
typeToTypeRelatedAttributes typeRef seed brickIndex =
    case typeRef of
        0 ->
            CommentAttributes

        1 ->
            IncrementAttributes

        2 ->
            DecrementAttributes

        3 ->
            IncrementIntAttributes (randomIntGenerator 3 seed brickIndex)

        4 ->
            DecrementIntAttributes (randomIntGenerator 4 seed brickIndex)

        5 ->
            MultiplyIntAttributes (randomIntGenerator 5 seed brickIndex)

        6 ->
            DivideIntAttributes (randomIntGenerator 6 seed brickIndex)

        7 ->
            let
                ( condition, behavior ) =
                    randomConditionBehaviorGenerator seed brickIndex
            in
            ConditionalAttributes ( condition, behavior )

        8 ->
            LeftShiftAttributes (randomIntGenerator 8 seed brickIndex)

        9 ->
            RightShiftAttributes (randomIntGenerator 9 seed brickIndex)

        10 ->
            let
                ( count, behavior ) =
                    randomForLoopGenerator seed brickIndex
            in
            ForLoopAttributes ( count, behavior )

        _ ->
            NullAttributes


initBricks : Int -> { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float } -> List Int -> List Brick
initBricks seed bricksAttrs typeRefs =
    let
        centerCoordinates =
            centerCoordinatesGenerator bricksAttrs

        sizes =
            List.repeat (List.length centerCoordinates) { x = bricksAttrs.width, y = bricksAttrs.height }

        commonAttributes =
            commonAttributesGenerator centerCoordinates sizes
    in
    List.map3
        (\index commonAttribute typeRef ->
            { commonAttributes = commonAttribute
            , typeRef = typeRef
            , typeRelatedAttributes = typeToTypeRelatedAttributes typeRef seed index
            }
        )
        (List.range 0 (List.length commonAttributes - 1))
        commonAttributes
        typeRefs
