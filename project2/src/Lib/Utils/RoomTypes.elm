module Lib.Utils.RoomTypes exposing
    ( TileDimensions, FilteredCoords, DoorChecks
    , tileSize, door, cullRadius
    , manhattanDistance, isWithinRadius, generateCoords
    )

{-| Types and constants for room rendering.


# Types

@docs TileDimensions, FilteredCoords, DoorChecks


# Constants

@docs tileSize, door, cullRadius


# Utility Functions

@docs manhattanDistance, isWithinRadius, generateCoords

-}

import List exposing (..)


{-| Represents dimensions and coordinate lists for room tiles.

  - `tileWidth` - Width of each tile
  - `tileHeight` - Height of each tile
  - `halfTileWidth` - Half the width of a tile
  - `halfTileHeight` - Half the height of a tile
  - `xs` - List of x-coordinates for tiles
  - `ys` - List of y-coordinates for tiles

-}
type alias TileDimensions =
    { tileWidth : Float
    , tileHeight : Float
    , halfTileWidth : Float
    , halfTileHeight : Float
    , xs : List Float
    , ys : List Float
    }


{-| Represents filtered coordinates for each wall of a room.

  - `xsTop` - List of x-coordinates for the top wall
  - `xsBottom` - List of x-coordinates for the bottom wall
  - `ysLeft` - List of y-coordinates for the left wall
  - `ysRight` - List of y-coordinates for the right wall

-}
type alias FilteredCoords =
    { xsTop : List Float
    , xsBottom : List Float
    , ysLeft : List Float
    , ysRight : List Float
    }


{-| Represents door configuration for each side of a room.

  - `top` - Whether there's a door on the top wall
  - `bottom` - Whether there's a door on the bottom wall
  - `left` - Whether there's a door on the left wall
  - `right` - Whether there's a door on the right wall

-}
type alias DoorChecks =
    { top : Bool
    , bottom : Bool
    , left : Bool
    , right : Bool
    }


{-| Size of each tile in pixels
-}
tileSize : Float
tileSize =
    68


{-| Size of door openings in pixels
-}
door : Float
door =
    96


{-| Radius for culling tiles that are too far from the player
-}
cullRadius : Float
cullRadius =
    1500


{-| Calculate Manhattan distance between two points
-}
manhattanDistance : ( Float, Float ) -> ( Float, Float ) -> Float
manhattanDistance ( x1, y1 ) ( x2, y2 ) =
    abs (x2 - x1) + abs (y2 - y1)


{-| Check if a tile position is within the culling radius of the player
-}
isWithinRadius : ( Float, Float ) -> ( Float, Float ) -> Float -> Bool
isWithinRadius tilePos playerPos radius =
    manhattanDistance tilePos playerPos <= radius


{-| Generate a list of coordinates from start to end with given step size
-}
generateCoords : Float -> Float -> Float -> List Float
generateCoords start end step =
    if start > end then
        []

    else
        start :: generateCoords (start + step) end step
