module Utils exposing
    ( arrayAll
    , arrayConcat
    , firstSubArrayLengthOrZero
    , indexFromRowAndColumn
    , indexToRowAndColumn
    , isPointOutOfBounds
    , list2dToArray2d
    , squareArrayIndexToRowAndColumn
    )

import Array exposing (Array)


list2dToArray2d : List (List a) -> Array (Array a)
list2dToArray2d =
    List.map Array.fromList >> Array.fromList


arrayAll : (a -> Bool) -> Array a -> Bool
arrayAll predicate =
    Array.foldl
        (\elem acc -> predicate elem && acc)
        True


arrayConcat : Array (Array a) -> Array a
arrayConcat =
    Array.foldr
        Array.append
        Array.empty


indexFromRowAndColumn : Int -> Int -> Int -> Int
indexFromRowAndColumn sideLength row column =
    row * sideLength + column


indexToRowAndColumn : Int -> Int -> ( Int, Int )
indexToRowAndColumn columns index =
    ( index // columns, modBy columns index )


squareArrayIndexToRowAndColumn : Int -> Int -> ( Int, Int )
squareArrayIndexToRowAndColumn sideLength index =
    ( index // sideLength, modBy sideLength index )


isPointOutOfBounds : Int -> Int -> Int -> Int -> Bool
isPointOutOfBounds numRows numCols row column =
    row < 0 || row >= numRows || column < 0 || column >= numCols


firstSubArrayLengthOrZero : Array (Array a) -> Int
firstSubArrayLengthOrZero =
    Array.get 0
        >> Maybe.map Array.length
        >> Maybe.withDefault 0
