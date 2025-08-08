module Lib.Utils.Rooms exposing
    ( createRoom, updateRoomRenderables
    , isWithinRoomArea, isWithinRoomBound, isWithinBoundForGhost
    , isLegalMove, isLegalMoveForGhost, getCurrentRoom
    )

{-| Room utilities for game level construction and navigation.


# Room Creation

@docs createRoom, updateRoomRenderables


# Room Boundaries

@docs isWithinRoomArea, isWithinRoomBound, isWithinBoundForGhost


# Movement

@docs isLegalMove, isLegalMoveForGhost, getCurrentRoom

-}

import Lib.Utils.RoomConstants exposing (..)
import Lib.Utils.RoomRenderer as RoomRenderer
import Lib.Utils.RoomTypes exposing (DoorChecks)
import Lib.Utils.Vec as Vec
import List exposing (..)


{-| Creates a new room.
Parameters: size, position, room ID, door flags (0=door, 1=wall)

Example:

    mainRoom =
        -- Create a room with doors on bottom, left and right
        createRoom
            -- size
            ( 384, 384 )
            -- center position
            ( 960, 540 )
            -- room ID
            1
            -- top wall (no door)
            1
            -- bottom door
            0
            -- left door
            0
            -- right door
            0

-}
createRoom : ( Float, Float ) -> ( Float, Float ) -> Int -> Int -> Int -> Int -> Int -> ( Float, Float ) -> Float -> Room
createRoom ( w, h ) ( cx, cy ) roomId top_d bottom_d left_d right_d playerPos cullRadius =
    let
        doors : DoorChecks
        doors =
            { top = top_d == 0
            , bottom = bottom_d == 0
            , left = left_d == 0
            , right = right_d == 0
            }

        renderable_room =
            RoomRenderer.roomTexUpdater ( w, h ) ( cx, cy ) playerPos doors cullRadius
    in
    { id = roomId
    , size = ( w, h )
    , center = Vec.genVec cx cy
    , doors = doors
    , renderables = renderable_room
    }


{-| Updates room renderables based on player position for culling optimization.
-}
updateRoomRenderables : Room -> ( Float, Float ) -> Float -> Room
updateRoomRenderables room playerPos cullRadius =
    let
        ( w, h ) =
            room.size

        ( cx, cy ) =
            ( room.center.x, room.center.y )

        newRenderables =
            RoomRenderer.roomTexUpdater ( w, h ) ( cx, cy ) playerPos room.doors cullRadius
    in
    { room | renderables = newRenderables }


{-| Checks if position is within room's outer boundaries.
-}
isWithinRoomArea : Room -> Vec.Vec -> Bool
isWithinRoomArea room pos =
    let
        ( w, h ) =
            room.size

        ( left, right ) =
            ( room.center.x - w / 2, room.center.x + w / 2 )

        ( top, bottom ) =
            ( room.center.y - h / 2, room.center.y + h / 2 )
    in
    pos.x >= left && pos.x <= right && pos.y >= top && pos.y <= bottom


{-| Finds which room contains a position.
-}
getCurrentRoom : List Room -> Vec.Vec -> Maybe Room
getCurrentRoom rooms pos =
    List.head (List.filter (\room -> isWithinRoomArea room pos) rooms)


{-| Checks if position is within room boundaries, considering walls and doors.
-}
isWithinRoomBound : Room -> Vec.Vec -> Bool
isWithinRoomBound room pos =
    let
        ( w, h ) =
            room.size

        innerLeft =
            room.center.x - w / 2 + wallThickness

        innerRight =
            room.center.x + w / 2 - wallThickness

        innerTop =
            room.center.y - h / 2 + wallThickness

        innerBottom =
            room.center.y + h / 2 - wallThickness

        doorHalf =
            door / 2

        inDoorX =
            abs (pos.x - room.center.x) <= doorHalf

        inDoorY =
            abs (pos.y - room.center.y) <= doorHalf

        withinLeft =
            if room.doors.left && inDoorY && pos.x < innerLeft then
                True

            else
                pos.x >= innerLeft

        withinRight =
            if room.doors.right && inDoorY && pos.x > innerRight then
                True

            else
                pos.x <= innerRight

        withinTop =
            if room.doors.top && inDoorX && pos.y < innerTop then
                True

            else
                pos.y >= innerTop

        withinBottom =
            if room.doors.bottom && inDoorX && pos.y > innerBottom then
                True

            else
                pos.y <= innerBottom
    in
    withinLeft && withinRight && withinTop && withinBottom


{-| Checks room boundaries for ghost movement.
-}
isWithinBoundForGhost : Room -> Vec.Vec -> Bool
isWithinBoundForGhost room pos =
    let
        bounds =
            getRoomBoundaries room wallThickness
    in
    pos.x >= bounds.left && pos.x <= bounds.right && pos.y >= bounds.top && pos.y <= bounds.bottom


{-| Determines if movement between positions is legal.
-}
isLegalMove : List Room -> Vec.Vec -> Vec.Vec -> Bool
isLegalMove rooms currentPos newPos =
    case getCurrentRoom rooms currentPos of
        Just currentRoom ->
            isWithinRoomBound currentRoom newPos

        Nothing ->
            List.any (\room -> isWithinRoomBound room newPos) rooms


{-| Determines if ghost movement between positions is legal.
-}
isLegalMoveForGhost : List Room -> Vec.Vec -> Vec.Vec -> Bool
isLegalMoveForGhost rooms currentPos newPos =
    case getCurrentRoom rooms currentPos of
        Just currentRoom ->
            isWithinBoundForGhost currentRoom newPos

        Nothing ->
            List.any (\room -> isWithinBoundForGhost room newPos) rooms
