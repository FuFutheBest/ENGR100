module SquareArray2D exposing
    ( SquareArray2D
    , fromRows, fromColumns, fromRowMajor, initialize, repeat
    , sideLength, length, get
    , set, update
    , map, indexedMap
    , toFlatArrayRowMajor
    , generator
    )

{-| Provides an ergonomic and fast way to use square 2 dimensional arrays in Elm.


# Square 2D Arrays

@docs SquareArray2D


# Creation

@docs fromRows, fromColumns, fromRowMajor, initialize, repeat


# Query

@docs sideLength, length, get


# Manipulation

@docs set, update


# Transform

@docs map, indexedMap


# Arrays

@docs toFlatArrayRowMajor


# Randomness

@docs generator

-}

import Array exposing (Array)
import Maybe.Extra as MaybeExtra
import Random exposing (Generator)
import Random.Array as RandomArray
import Utils exposing (firstSubArrayLengthOrZero, indexFromRowAndColumn, isPointOutOfBounds, squareArrayIndexToRowAndColumn)


{-| Type representing a 2 dimensional square array.
-}
type SquareArray2D a
    = InternalSquareArray2D
        { array : Array a
        , sideLength_ : Int
        }


{-| Attempts to create a `SquareArray2D` from an `Array` of `Array`s representing rows.
Returns `Nothing` when the elements don't form a square.
-}
fromRows : Array (Array a) -> Maybe (SquareArray2D a)
fromRows rowsArrays =
    let
        rowLen : Int
        rowLen =
            firstSubArrayLengthOrZero rowsArrays
    in
    if Array.length rowsArrays == rowLen && Utils.arrayAll (\arr -> Array.length arr == rowLen) rowsArrays then
        InternalSquareArray2D
            { array = Utils.arrayConcat rowsArrays
            , sideLength_ = rowLen
            }
            |> Just

    else
        Nothing


{-| Attempts to create a `SquareArray2D` from an `Array` of `Array`s representing columns.
Returns `Nothing` when the elements don't form a square.
-}
fromColumns : Array (Array a) -> Maybe (SquareArray2D a)
fromColumns columnsArrays =
    let
        columnLen : Int
        columnLen =
            firstSubArrayLengthOrZero columnsArrays
    in
    if Array.length columnsArrays == columnLen && Utils.arrayAll (\arr -> Array.length arr == columnLen) columnsArrays then
        let
            sideLength_ : Int
            sideLength_ =
                columnLen

            indicesRowMajor : List ( Int, Int )
            indicesRowMajor =
                let
                    finalIndex : Int
                    finalIndex =
                        sideLength_ - 1
                in
                List.range 0 finalIndex
                    |> List.concatMap
                        (\row ->
                            List.range 0 finalIndex
                                |> List.map (\column -> ( row, column ))
                        )

            listOfMaybes : List (Maybe a)
            listOfMaybes =
                indicesRowMajor
                    |> List.map
                        (\( row, column ) ->
                            columnsArrays
                                |> Array.get column
                                |> Maybe.withDefault Array.empty
                                |> Array.get row
                        )
        in
        listOfMaybes
            |> MaybeExtra.combine
            |> Maybe.map Array.fromList
            |> Maybe.andThen
                (\array ->
                    InternalSquareArray2D
                        { array = array
                        , sideLength_ = sideLength_
                        }
                        |> Just
                )

    else
        Nothing


{-| Attempts to create a `SquareArray2D` from an `Array` of elements and a side length.
Orders the elements in [row major order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
The array has to be the same length as the provided side length squared.
-}
fromRowMajor : Int -> Array a -> Maybe (SquareArray2D a)
fromRowMajor sideLength_ array =
    if (sideLength_ ^ 2) /= Array.length array then
        Nothing

    else
        InternalSquareArray2D
            { array = array
            , sideLength_ = sideLength_
            }
            |> Just


{-| Creates a `SquareArray2D` with the sideLength.
Each element is created using the provided function which gives the index (row and column).
-}
initialize : Int -> (Int -> Int -> a) -> SquareArray2D a
initialize sideLength_ fn =
    InternalSquareArray2D
        { array =
            Array.initialize
                (sideLength_ ^ 2)
                (\index ->
                    let
                        ( row, column ) =
                            squareArrayIndexToRowAndColumn sideLength_ index
                    in
                    fn row column
                )
        , sideLength_ = sideLength_
        }


{-| Creates a `SquareArray2D` with a provided side length and fills it with an element.
-}
repeat : Int -> a -> SquareArray2D a
repeat sideLength_ value =
    initialize
        sideLength_
        (\_ _ -> value)


{-| Gets the total number of elements the `SquareArray2D` holds.
-}
length : SquareArray2D a -> Int
length (InternalSquareArray2D { sideLength_ }) =
    sideLength_ ^ 2


{-| Gets the side length of the `SquareArray2D`.
-}
sideLength : SquareArray2D a -> Int
sideLength (InternalSquareArray2D array) =
    array.sideLength_


{-| Gets an element from the `SquareArray2D` at the provided row and column.
Returns `Nothing` when the index is out of bounds.
-}
get : Int -> Int -> SquareArray2D a -> Maybe a
get row column (InternalSquareArray2D array) =
    if isPointOutOfBounds array.sideLength_ array.sideLength_ row column then
        Nothing

    else
        Array.get
            (indexFromRowAndColumn array.sideLength_ row column)
            array.array


{-| Sets an element in the `SquareArray2D` at the provided row and column.
Returns the `SquareArray2D` unchanged if the index is out of bounds.
-}
set : Int -> Int -> a -> SquareArray2D a -> SquareArray2D a
set row column value (InternalSquareArray2D array) =
    InternalSquareArray2D
        { array
            | array =
                Array.set
                    (indexFromRowAndColumn array.sideLength_ row column)
                    value
                    array.array
        }


{-| Updates an element in the `SquareArray2D` with a function at the provided row and column.
Returns the `SquareArray2D` unchanged if the index is out of bounds.
-}
update : Int -> Int -> (a -> a) -> SquareArray2D a -> SquareArray2D a
update row column updater (InternalSquareArray2D array) =
    let
        maybeElement : Maybe a
        maybeElement =
            get row column (InternalSquareArray2D array)
    in
    case maybeElement of
        Just element ->
            set row column (updater element) (InternalSquareArray2D array)

        Nothing ->
            InternalSquareArray2D array


{-| Applies a function to every element in the `SquareArray2D`.
-}
map : (a -> b) -> SquareArray2D a -> SquareArray2D b
map fn (InternalSquareArray2D array) =
    InternalSquareArray2D
        { array = Array.map fn array.array
        , sideLength_ = array.sideLength_
        }


{-| Applies a function to every element in the `SquareArray2D`.
The index (row and column) are provided to the mapping function.
-}
indexedMap : (Int -> Int -> a -> b) -> SquareArray2D a -> SquareArray2D b
indexedMap fn (InternalSquareArray2D array) =
    let
        indexedMapHelper : Int -> (Int -> Int -> a -> b) -> Int -> a -> b
        indexedMapHelper sideLength_ mapFn index elem =
            let
                ( row, column ) =
                    squareArrayIndexToRowAndColumn sideLength_ index
            in
            mapFn row column elem
    in
    InternalSquareArray2D
        { array =
            Array.indexedMap
                (indexedMapHelper array.sideLength_ fn)
                array.array
        , sideLength_ = array.sideLength_
        }


{-| Flattens the `SquareArray2D` in [row major order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
-}
toFlatArrayRowMajor : SquareArray2D a -> Array a
toFlatArrayRowMajor (InternalSquareArray2D array) =
    array.array


{-| Generates a `SquareArray2D` where each value is randomly generated.
-}
generator : Generator a -> Int -> Generator (SquareArray2D a)
generator valueGenerator sideLength_ =
    Random.map
        (\array ->
            InternalSquareArray2D
                { array = array
                , sideLength_ = sideLength_
                }
        )
        (RandomArray.array (sideLength_ ^ 2) valueGenerator)
