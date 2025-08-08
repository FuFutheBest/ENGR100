module Lib.Utils.RoomConstants exposing
    ( Room
    , wallThickness, roomW, roomH, door, center
    , getRoomBoundaries
    )

{-| Room constants and basic types for game level construction.


# Types

@docs Room


# Constants

@docs wallThickness, roomW, roomH, door, center


# Utilities

@docs getRoomBoundaries

-}

import Lib.Utils.RoomTypes exposing (DoorChecks)
import Lib.Utils.Vec as Vec
import REGL.Common exposing (..)


{-| Thickness of room walls in pixels.
-}
wallThickness : Float
wallThickness =
    4


{-| Standard room width in pixels.
-}
roomW : Float
roomW =
    384


{-| Standard room height in pixels.
-}
roomH : Float
roomH =
    384


{-| Standard door width in pixels.
-}
door : Float
door =
    64


{-| Center position for default room placement.
-}
center : Vec.Vec
center =
    Vec.genVec 960 540


{-| Game room representation.

  - `id` - Unique identifier
  - `size` - Width and height in pixels
  - `center` - Center position coordinates
  - `doors` - Door configuration
  - `renderables` - Visual elements

-}
type alias Room =
    { id : Int
    , size : ( Float, Float )
    , center : Vec.Vec
    , doors : DoorChecks
    , renderables : List Renderable
    }


{-| Calculates room boundaries with inset.
-}
getRoomBoundaries : Room -> Float -> { left : Float, right : Float, top : Float, bottom : Float }
getRoomBoundaries room inset =
    let
        ( w, h ) =
            room.size
    in
    { left = room.center.x - w / 2 + inset
    , right = room.center.x + w / 2 - inset
    , top = room.center.y - h / 2 + inset
    , bottom = room.center.y + h / 2 - inset
    }
