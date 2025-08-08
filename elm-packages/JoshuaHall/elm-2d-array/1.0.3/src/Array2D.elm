module Array2D exposing
    ( Array2D
    , fromRows, fromColumns, fromRowMajor, initialize, repeat
    , rows, columns, length, get
    , set, update
    , map, indexedMap
    , toFlatArrayRowMajor
    , generator
    )

{-| Provides an ergonomic and fast way to use 2 dimensional arrays in Elm.


# 2D Arrays

@docs Array2D


# Creation

@docs fromRows, fromColumns, fromRowMajor, initialize, repeat


# Query

@docs rows, columns, length, get


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
import Utils exposing (firstSubArrayLengthOrZero, indexToRowAndColumn, isPointOutOfBounds)


{-| Type representing a 2 dimensional array.
-}
type Array2D a
    = InternalArray2D
        { array : Array a
        , numRows : Int
        , numColumns : Int
        }


{-| Attempts to create a `Array2D` from an `Array` of `Array`s representing rows.
Returns `Nothing` when the rows' lengths don't match.
-}
fromRows : Array (Array a) -> Maybe (Array2D a)
fromRows rowsArrays =
    let
        rowLen : Int
        rowLen =
            firstSubArrayLengthOrZero rowsArrays
    in
    if Utils.arrayAll (\arr -> Array.length arr == rowLen) rowsArrays then
        InternalArray2D
            { array = Utils.arrayConcat rowsArrays
            , numRows = Array.length rowsArrays
            , numColumns = rowLen
            }
            |> Just

    else
        Nothing


{-| Attempts to create a `Array2D` from an `Array` of `Array`s representing columns.
Returns `Nothing` when the columns' lengths don't match.
-}
fromColumns : Array (Array a) -> Maybe (Array2D a)
fromColumns columnsArrays =
    let
        columnLen : Int
        columnLen =
            firstSubArrayLengthOrZero columnsArrays
    in
    if Utils.arrayAll (\arr -> Array.length arr == columnLen) columnsArrays then
        let
            numberOfRows : Int
            numberOfRows =
                columnLen

            numberOfColumns : Int
            numberOfColumns =
                Array.length columnsArrays

            indicesRowMajor : List ( Int, Int )
            indicesRowMajor =
                List.range 0 (numberOfRows - 1)
                    |> List.concatMap
                        (\row ->
                            List.range 0 (numberOfColumns - 1)
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
                    InternalArray2D
                        { array = array
                        , numRows = numberOfRows
                        , numColumns = numberOfColumns
                        }
                        |> Just
                )

    else
        Nothing


{-| Attempts to create a `Array2D` from an `Array` of elements and the rows and columns amounts.
Orders the elements in [row major order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
The array has to be the same length as the product of the provided rows and columns.
-}
fromRowMajor : Int -> Int -> Array a -> Maybe (Array2D a)
fromRowMajor numRows numColumns array =
    if (numRows * numColumns) /= Array.length array then
        Nothing

    else
        InternalArray2D
            { array = array
            , numRows = numRows
            , numColumns = numColumns
            }
            |> Just


{-| Creates an `Array2D` with the provided rows and columns.
Each element is created using the provided function which gives the index (row and column).
-}
initialize : Int -> Int -> (Int -> Int -> a) -> Array2D a
initialize numRows numColumns fn =
    InternalArray2D
        { array =
            Array.initialize
                (numRows * numColumns)
                (\index ->
                    let
                        ( row, column ) =
                            indexToRowAndColumn numColumns index
                    in
                    fn row column
                )
        , numRows = numRows
        , numColumns = numColumns
        }


{-| Creates a `Array2D` with the provided rows and columns and fills it with the provided element.
-}
repeat : Int -> Int -> a -> Array2D a
repeat numRows numColumns value =
    initialize
        numRows
        numColumns
        (\_ _ -> value)


{-| Gets the total number of elements the `Array2D` holds.
-}
length : Array2D a -> Int
length (InternalArray2D { numRows, numColumns }) =
    numRows * numColumns


{-| Gets the number of rows the `Array2D` holds.
-}
rows : Array2D a -> Int
rows (InternalArray2D array) =
    array.numRows


{-| Gets the number of columns the `Array2D` holds.
-}
columns : Array2D a -> Int
columns (InternalArray2D array) =
    array.numColumns


{-| Gets an element from the `Array2D` at the provided row and column.
Returns `Nothing` when the index is out of bounds.
-}
get : Int -> Int -> Array2D a -> Maybe a
get row column (InternalArray2D array) =
    if isPointOutOfBounds array.numRows array.numColumns row column then
        Nothing

    else
        Array.get
            (indexFromRowAndColumn (InternalArray2D array) row column)
            array.array


{-| Sets an element in the `Array2D` at the provided row and column.
Returns the `Array2D` unchanged if the index is out of bounds.
-}
set : Int -> Int -> a -> Array2D a -> Array2D a
set row column value (InternalArray2D array) =
    InternalArray2D
        { array
            | array =
                Array.set
                    (indexFromRowAndColumn (InternalArray2D array) row column)
                    value
                    array.array
        }


{-| Updates an element in the `Array2D` with a function at the provided row and column.
Returns the `Array2D` unchanged if the index is out of bounds.
-}
update : Int -> Int -> (a -> a) -> Array2D a -> Array2D a
update row column updater (InternalArray2D array) =
    let
        maybeElement : Maybe a
        maybeElement =
            get row column (InternalArray2D array)
    in
    case maybeElement of
        Just element ->
            set row column (updater element) (InternalArray2D array)

        Nothing ->
            InternalArray2D array


{-| Applies a function to every element in the `Array2D`.
-}
map : (a -> b) -> Array2D a -> Array2D b
map fn (InternalArray2D array) =
    InternalArray2D
        { array = Array.map fn array.array
        , numRows = array.numRows
        , numColumns = array.numColumns
        }


{-| Applies a function to every element in the `Array2D`.
The index (row and column) are provided to the mapping function.
-}
indexedMap : (Int -> Int -> a -> b) -> Array2D a -> Array2D b
indexedMap fn (InternalArray2D array) =
    let
        indexedMapHelper : (Int -> Int -> a -> b) -> Int -> a -> b
        indexedMapHelper mapFn index elem =
            let
                ( row, column ) =
                    indexToRowAndColumn array.numColumns index
            in
            mapFn row column elem
    in
    InternalArray2D
        { array =
            Array.indexedMap
                (indexedMapHelper fn)
                array.array
        , numRows = array.numRows
        , numColumns = array.numColumns
        }


{-| Flattens the `Array2D` in [row major order](https://en.wikipedia.org/wiki/Row-_and_column-major_order).
-}
toFlatArrayRowMajor : Array2D a -> Array a
toFlatArrayRowMajor (InternalArray2D array) =
    array.array


indexFromRowAndColumn : Array2D a -> Int -> Int -> Int
indexFromRowAndColumn (InternalArray2D array) row column =
    row * array.numColumns + column


{-| Generates a `Array2D` where each value is randomly generated.
-}
generator : Generator a -> Int -> Int -> Generator (Array2D a)
generator valueGenerator numRows numColumns =
    Random.map
        (\array ->
            InternalArray2D
                { array = array
                , numRows = numRows
                , numColumns = numColumns
                }
        )
        (RandomArray.array (numRows * numColumns) valueGenerator)
