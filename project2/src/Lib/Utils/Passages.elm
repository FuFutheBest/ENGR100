module Lib.Utils.Passages exposing
    ( Room, DoorChecks
    , door, tileSize, halfTile
    , generateCoords, tex, doorCenter, createPassage, generatePassages
    )

{-| Module for handling room passages and doors in the game.

This module provides utilities for creating, rendering, and managing passages between rooms.


# Types

@docs Room, DoorChecks


# Constants

@docs door, tileSize, halfTile


# Functions

@docs generateCoords, tex, doorCenter, createPassage, generatePassages

-}

import Basics exposing (pi)
import Lib.Utils.Vec as Vec
import List exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)


{-| Width of a door passage in pixels
-}
door : Float
door =
    96


{-| Size of a single tile in pixels
-}
tileSize : Float
tileSize =
    32


{-| Half of a tile size in pixels, used for centering calculations
-}
halfTile : Float
halfTile =
    tileSize / 2


{-| Represents which doors are present in a room.

  - `top` - Whether there is a door on the top wall of the room
  - `bottom` - Whether there is a door on the bottom wall of the room
  - `left` - Whether there is a door on the left wall of the room
  - `right` - Whether there is a door on the right wall of the room

-}
type alias DoorChecks =
    { top : Bool
    , bottom : Bool
    , left : Bool
    , right : Bool
    }


{-| Represents a room in the game.

  - `id` - Unique identifier for the room
  - `size` - Width and height of the room in pixels
  - `center` - Position vector of the room's center
  - `doors` - Which doors are present in the room
  - `renderables` - Visual elements that make up the room

-}
type alias Room =
    { id : Int
    , size : ( Float, Float )
    , center : Vec.Vec
    , doors : DoorChecks
    , renderables : List Renderable
    }


{-| Generates a list of coordinates between start and end with the specified step.

  - Takes start position, end position, and step size
  - Returns a list of equally spaced coordinates

-}
generateCoords : Float -> Float -> Float -> List Float
generateCoords start end step =
    if start > end then
        []

    else
        start :: generateCoords (start + step) end step


{-| Creates a texture renderable with the given parameters.

  - Takes texture name, position (x, y), dimensions (w, h), and rotation angle
  - Returns a renderable object with the specified properties

-}
tex : String -> ( Float, Float ) -> ( Float, Float ) -> Float -> Renderable
tex name ( x, y ) ( w, h ) rot =
    P.centeredTextureWithAlpha ( x, y ) ( w, h ) rot 1 name


{-| Calculates the center position of a door on the specified side of a room.

  - Takes a room and a side identifier (1=top, 2=bottom, 3=left, 4=right)
  - Returns the coordinates of the door's center

-}
doorCenter : Room -> Int -> ( Float, Float )
doorCenter room side =
    let
        ( w, h ) =
            room.size
    in
    case side of
        1 ->
            ( room.center.x, room.center.y - h / 2 )

        2 ->
            ( room.center.x, room.center.y + h / 2 )

        3 ->
            ( room.center.x - w / 2, room.center.y )

        4 ->
            ( room.center.x + w / 2, room.center.y )

        _ ->
            ( room.center.x, room.center.y )


{-| Creates floor tiles for a passage between two sets of coordinates.
-}
createPassageFloors : List Float -> List Float -> List Renderable
createPassageFloors primaryCoords secondaryCoords =
    concatMap
        (\primary -> List.map (\secondary -> tex "ptiles" ( primary, secondary ) ( tileSize, tileSize ) 0) secondaryCoords)
        primaryCoords


{-| Creates wall tiles for a single wall line based on coordinates and position.
-}
createSingleWall : List Float -> Float -> Float -> Bool -> List Renderable
createSingleWall coords wallPos rotation isVertical =
    -- Generate wall tiles for a single wall line
    List.map
        (\coord ->
            if isVertical then
                tex "wall" ( wallPos, coord ) ( tileSize, tileSize ) rotation

            else
                tex "wall" ( coord, wallPos ) ( tileSize, tileSize ) rotation
        )
        coords


{-| Creates walls for both sides of a passage based on coordinates and positions.
-}
createPassageWalls : List Float -> Float -> Float -> Float -> Bool -> List Renderable
createPassageWalls coords wallPos1 wallPos2 rotation isVertical =
    -- Generate wall tiles along the passage sides
    let
        wall1 =
            createSingleWall coords wallPos1 rotation isVertical

        wall2 =
            createSingleWall coords wallPos2 rotation isVertical
    in
    wall1 ++ wall2


{-| Creates a generic passage between two coordinates, either vertical or horizontal.
-}
createPassageGeneric : Float -> Float -> Float -> Bool -> List Renderable
createPassageGeneric primaryCoord secondaryA secondaryB isVertical =
    let
        secondaryStart =
            Basics.min secondaryA secondaryB + halfTile - tileSize

        secondaryEnd =
            Basics.max secondaryA secondaryB - halfTile + tileSize

        secondaryCoords =
            generateCoords secondaryStart secondaryEnd tileSize

        primaryStart =
            primaryCoord - door / 2 + halfTile

        primaryEnd =
            primaryCoord + door / 2 - halfTile

        primaryCoords =
            generateCoords primaryStart primaryEnd tileSize

        floors =
            if isVertical then
                createPassageFloors primaryCoords secondaryCoords

            else
                createPassageFloors secondaryCoords primaryCoords

        wall1Pos =
            primaryCoord - door / 2 - halfTile

        wall2Pos =
            primaryCoord + door / 2 + halfTile - tileSize

        rotation =
            if isVertical then
                pi / 2

            else
                0

        walls =
            if isVertical then
                createPassageWalls secondaryCoords wall1Pos wall2Pos rotation True

            else
                createPassageWalls secondaryCoords wall1Pos wall2Pos rotation False
    in
    floors ++ walls


{-| Creates a vertical passage between two y-coordinates at a fixed x-coordinate.
-}
createVerticalPassage : Float -> Float -> Float -> List Renderable
createVerticalPassage x yA yB =
    createPassageGeneric x yA yB True


{-| Creates a horizontal passage between two x-coordinates at a fixed y-coordinate.
-}
createHorizontalPassage : Float -> Float -> Float -> List Renderable
createHorizontalPassage y xA xB =
    createPassageGeneric y xA xB False


{-| Creates a passage between two rooms at specified door sides.
-}
createPassage : List Room -> ( Int, Int ) -> ( Int, Int ) -> List Renderable
createPassage roomsList ( id1, side1 ) ( id2, side2 ) =
    -- Create a passage between two rooms at specified door sides
    let
        room1 =
            List.head <| List.filter (\r -> r.id == id1) roomsList

        room2 =
            List.head <| List.filter (\r -> r.id == id2) roomsList
    in
    case ( room1, room2 ) of
        ( Just r1, Just r2 ) ->
            let
                ( x1, y1 ) =
                    doorCenter r1 side1

                ( x2, y2 ) =
                    doorCenter r2 side2
            in
            if x1 == x2 then
                createVerticalPassage x1 y1 y2

            else if y1 == y2 then
                createHorizontalPassage y1 x1 x2

            else
                []

        _ ->
            []


{-| Generates a list of passages between predefined rooms.
-}
generatePassages : List Room -> List (List Renderable)
generatePassages roomsList =
    -- Generate all passages between rooms based on predefined connections
    [ createPassage roomsList ( 1, 2 ) ( 3, 1 )
    , createPassage roomsList ( 1, 4 ) ( 4, 3 )
    , createPassage roomsList ( 1, 3 ) ( 5, 4 )
    , createPassage roomsList ( 2, 2 ) ( 1, 1 )
    ]
