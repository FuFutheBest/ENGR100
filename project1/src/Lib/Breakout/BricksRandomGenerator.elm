module Lib.Breakout.BricksRandomGenerator exposing (..)

import Lib.Breakout.Vec exposing (Vec)
import Random


type Conditions
    = EqualTo Int -- equal to int Bricks x == int
    | NoCondition


type Behaviors
    = Increment -- increment Bricks "++"
    | Decrement -- decrement Bricks "--"
    | IncrementInt Int -- increment int Bricks "x = x + int"
    | DecrementInt Int -- decrement int Bricks "x = x - int"
    | Multiply Int -- multiply int Bricks "x * int"
    | Divide Int -- divide int Bricks "x / int"
    | LeftShift Int -- left shift "x <<= int"
    | RightShift Int -- right shift "x >>= int"
    | DoNothing


type alias CommonAttributes =
    { centerCoordinate : Vec -- postion is the center coordinates of each brick
    , size : Vec
    }


commonAttributesGenerator : List Vec -> List Vec -> List CommonAttributes
commonAttributesGenerator centerCoordinates sizes =
    List.map2
        (\coordinate size ->
            { centerCoordinate = coordinate
            , size = size
            }
        )
        centerCoordinates
        sizes


randomIntGenerator : Int -> Int -> Int -> Int
randomIntGenerator typeRef seed brickIndex =
    case typeRef of
        3 ->
            Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex))

        4 ->
            Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex + 100))

        5 ->
            Tuple.first <| Random.step (Random.int 0 9) (Random.initialSeed (seed + 2 * brickIndex + 200))

        6 ->
            Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex + 300))

        8 ->
            -- left shift
            Tuple.first <| Random.step (Random.int 1 4) (Random.initialSeed (seed + 2 * brickIndex + 400))

        9 ->
            -- right shift
            Tuple.first <| Random.step (Random.int 1 4) (Random.initialSeed (seed + 2 * brickIndex + 500))

        10 ->
            -- for loop count (2-5 iterations)
            Tuple.first <| Random.step (Random.int 2 5) (Random.initialSeed (seed + 2 * brickIndex + 600))

        _ ->
            0


randomForLoopGenerator : Int -> Int -> ( Int, Behaviors )
randomForLoopGenerator seed brickIndex =
    let
        count =
            Tuple.first <| Random.step (Random.int 2 5) (Random.initialSeed (seed + 2 * brickIndex + 600))

        behavior =
            case Tuple.first <| Random.step (Random.int 0 5) (Random.initialSeed (seed + 2 * brickIndex + 700)) of
                0 ->
                    Increment

                1 ->
                    Decrement

                2 ->
                    IncrementInt (Tuple.first <| Random.step (Random.int 1 5) (Random.initialSeed (seed + 2 * brickIndex + 800)))

                3 ->
                    DecrementInt (Tuple.first <| Random.step (Random.int 1 5) (Random.initialSeed (seed + 2 * brickIndex + 900)))

                4 ->
                    Multiply (Tuple.first <| Random.step (Random.int 2 3) (Random.initialSeed (seed + 2 * brickIndex + 1000)))

                5 ->
                    Divide (Tuple.first <| Random.step (Random.int 2 3) (Random.initialSeed (seed + 2 * brickIndex + 1100)))

                _ ->
                    Increment
    in
    ( count, behavior )


randomConditionBehaviorGenerator : Int -> Int -> ( Conditions, Behaviors )
randomConditionBehaviorGenerator seed brickIndex =
    let
        condition =
            case Tuple.first <| Random.step (Random.int 0 0) (Random.initialSeed (seed + 2 * brickIndex)) of
                0 ->
                    EqualTo (Tuple.first <| Random.step (Random.int -10 10) (Random.initialSeed (seed + 2 * brickIndex + 100)))

                _ ->
                    NoCondition

        behavior =
            case Tuple.first <| Random.step (Random.int 0 7) (Random.initialSeed (seed + 2 * brickIndex + 200)) of
                0 ->
                    Increment

                1 ->
                    Decrement

                2 ->
                    IncrementInt (Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex + 300)))

                3 ->
                    DecrementInt (Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex + 300)))

                4 ->
                    Multiply (Tuple.first <| Random.step (Random.int 0 9) (Random.initialSeed (seed + 2 * brickIndex + 300)))

                5 ->
                    Divide (Tuple.first <| Random.step (Random.int 1 9) (Random.initialSeed (seed + 2 * brickIndex + 300)))

                6 ->
                    LeftShift (Tuple.first <| Random.step (Random.int 1 4) (Random.initialSeed (seed + 2 * brickIndex + 400)))

                7 ->
                    RightShift (Tuple.first <| Random.step (Random.int 1 4) (Random.initialSeed (seed + 2 * brickIndex + 500)))

                _ ->
                    DoNothing
    in
    ( condition, behavior )
