module SceneProtos.GameProto.MainLayer.Room exposing
    ( roomsLevel1, roomsLevel2, roomsLevel3, roomsFor
    , passagesFor
    , renderRoomsFor
    )

{-| Room generation and management module for the game prototype.

This module defines the layout of rooms for different game levels, including their
positions, sizes, and passage connections. It provides functions to generate room
structures and render them based on the player's position and a culling radius.


# Room Generators

@docs roomsLevel1, roomsLevel2, roomsLevel3, roomsFor


# Passage Generators

@docs passagesFor


# Rendering

@docs renderRoomsFor

-}

import Lib.Utils.Passages as Passages exposing (Room)
import Lib.Utils.RoomRenderer exposing (..)
import Lib.Utils.Rooms exposing (createRoom)
import List exposing (..)
import REGL.Common exposing (..)


{-| Generates rooms for the first level of the game.
-}
roomsLevel1 : ( Float, Float ) -> Float -> List Room
roomsLevel1 playerPos cullRadius =
    -- tile size is 32
    [ createRoom ( 1292, 1292 ) ( -540, 540 ) 1 1 1 1 0 playerPos cullRadius
    , createRoom ( 1292, 1292 ) ( 952, 540 ) 2 1 1 0 0 playerPos cullRadius
    , createRoom ( 1292, 1292 ) ( 2444, 540 ) 3 1 1 0 0 playerPos cullRadius
    , createRoom ( 1292, 1292 ) ( 3936, 540 ) 4 1 0 0 0 playerPos cullRadius
    , createRoom ( 1292, 1292 ) ( 5428, 540 ) 5 1 1 0 1 playerPos cullRadius
    , createRoom ( 1292, 1292 ) ( 3936, 2032 ) 6 0 1 1 1 playerPos cullRadius
    ]


{-| Generates rooms for the second level of the game.
-}
roomsLevel2 : ( Float, Float ) -> Float -> List Room
roomsLevel2 playerPos cullRadius =
    let
        room1 =
            [ createRoom ( 640, 476 ) ( 527, 442 ) 1 1 1 1 0 playerPos cullRadius --gap between r1 and r2 is 544
            , createRoom ( 1904, 204 ) ( 2006, 442 ) 2 1 0 0 1 playerPos cullRadius
            , createRoom ( 1632, 1088 ) ( 2006, 1326 ) 3 0 0 0 0 playerPos cullRadius
            , createRoom ( 476, 1088 ) ( 784, 1326 ) 4 1 1 0 0 playerPos cullRadius
            ]

        room2 =
            [ createRoom ( 340, 612 ) ( 170, 1326 ) 5 1 0 1 0 playerPos cullRadius
            , createRoom ( 340, 340 ) ( 170, 2380 ) 6 0 1 1 0 playerPos cullRadius
            , createRoom ( 2924, 680 ) ( 2006, 2380 ) 7 0 1 0 1 playerPos cullRadius
            , createRoom ( 476, 1292 ) ( 3230, 1326 ) 8 1 1 0 1 playerPos cullRadius
            ]
    in
    room1 ++ room2


{-| Generates rooms for the third level of the game.
-}
roomsLevel3 : ( Float, Float ) -> Float -> List Room
roomsLevel3 playerPos cullRadius =
    let
        room1 =
            [ createRoom ( 612, 612 ) ( 510, 510 ) 1 1 0 1 0 playerPos cullRadius
            , createRoom ( 612, 1020 ) ( 510, 1428 ) 2 0 0 1 0 playerPos cullRadius
            , createRoom ( 1504, 612 ) ( 1760, 510 ) 3 1 0 0 0 playerPos cullRadius
            , createRoom ( 1504, 1020 ) ( 1760, 1428 ) 4 0 1 0 0 playerPos cullRadius
            , createRoom ( 614, 612 ) ( 3300, 510 ) 5 1 1 0 1 playerPos cullRadius
            , createRoom ( 1292, 1020 ) ( 3290, 1428 ) 6 1 0 0 1 playerPos cullRadius
            ]

        room2 =
            [ createRoom ( 612, 680 ) ( 510, 2380 ) 7 0 0 1 0 playerPos cullRadius
            , createRoom ( 680, 680 ) ( 1319, 2380 ) 8 1 1 0 0 playerPos cullRadius
            , createRoom ( 680, 680 ) ( 2135, 2380 ) 9 1 1 0 0 playerPos cullRadius
            , createRoom ( 1360, 680 ) ( 3290, 2380 ) 10 0 0 0 0 playerPos cullRadius
            , createRoom ( 340, 680 ) ( 4460, 2380 ) 11 1 0 0 1 playerPos cullRadius
            , createRoom ( 612, 1360 ) ( 510, 3502 ) 12 0 1 1 0 playerPos cullRadius
            ]

        room3 =
            [ createRoom ( 1360, 1360 ) ( 1598, 3502 ) 13 1 1 0 0 playerPos cullRadius
            , createRoom ( 680, 680 ) ( 2720, 3502 ) 14 1 1 0 0 playerPos cullRadius
            , createRoom ( 340, 340 ) ( 4460, 3502 ) 15 0 1 0 1 playerPos cullRadius
            , createRoom ( 2720, 1700 ) ( 3290, 5692 ) 16 0 1 1 1 playerPos cullRadius
            ]
    in
    room1 ++ room2 ++ room3


{-| Selects and returns the appropriate room list for the specified level.

This function acts as a dispatcher that generates the correct room layout based on
the level name. It handles the three defined levels and provides a default fallback
to Level1 for any unrecognized level names.

Parameters:

  - level - The level identifier string ("Level1", "Level2", "Level3")
  - playerPos - The current position of the player as (x, y) coordinates
  - cullRadius - The radius around the player within which rooms should be rendered

Returns a list of Room objects that define the structure of the selected level.
Each room contains its size, position, ID, door configuration, and rendering data.

-}
roomsFor : String -> ( Float, Float ) -> Float -> List Room
roomsFor level playerPos cullRadius =
    case level of
        "Level1" ->
            roomsLevel1 playerPos cullRadius

        "Level2" ->
            roomsLevel2 playerPos cullRadius

        "Level3" ->
            roomsLevel3 playerPos cullRadius

        _ ->
            roomsLevel1 playerPos cullRadius



{-
   How to create a passage?

   createPassage roomsList
       ( 1, 2 ) -- Connects from Room 1's bottom side (side 2)
       ( 3, 1 ) -- To Room 3's top side (side 1)

   Side mapping convention:
       1 -- Top
       2 -- Bottom
       3 -- Left
       4 -- Right

   The function looks up both rooms by ID, finds the center of the specified doorway side,
   and draws a straight passage if the doorways are aligned either vertically or horizontally.
   If not aligned, no passage is created.
-}


{-| Generates passage connections between rooms for the specified level.

This function creates the hallways and connections between rooms based on the level name.
Each passage connects two rooms at their doorway positions, creating the navigable paths
through the level.

Parameters:

  - level - The level identifier string ("Level1", "Level2", "Level3")
  - roomList - The list of Room objects for the specified level

Side mapping convention:

  - 1 - Top side of room
  - 2 - Bottom side of room
  - 3 - Left side of room
  - 4 - Right side of room

Each passage is defined by two tuples:

  - First tuple: (sourceRoomId, sourceSide)
  - Second tuple: (destinationRoomId, destinationSide)

The passages for each level create the layout's connectivity pattern:

  - Level1: Simple connections between the center room and four surrounding rooms
  - Level2: More complex connections between eight interconnected rooms
  - Level3: Extensive network of passages connecting sixteen rooms in a maze-like structure

Returns a list of lists of Renderable objects representing the visual elements of the passages.

-}
passagesFor : String -> List Room -> List (List Renderable)
passagesFor level roomList =
    case level of
        "Level1" ->
            [ Passages.createPassage roomList ( 1, 4 ) ( 2, 3 )
            , Passages.createPassage roomList ( 2, 4 ) ( 3, 3 )
            , Passages.createPassage roomList ( 3, 4 ) ( 4, 3 )
            , Passages.createPassage roomList ( 4, 4 ) ( 5, 3 )
            , Passages.createPassage roomList ( 5, 4 ) ( 6, 3 )
            , Passages.createPassage roomList ( 4, 2 ) ( 6, 1 )
            ]

        "Level2" ->
            [ Passages.createPassage roomList ( 1, 4 ) ( 2, 3 )
            , Passages.createPassage roomList ( 2, 2 ) ( 3, 1 )
            , Passages.createPassage roomList ( 3, 2 ) ( 7, 1 )
            , Passages.createPassage roomList ( 3, 3 ) ( 4, 4 )
            , Passages.createPassage roomList ( 4, 3 ) ( 5, 4 )
            , Passages.createPassage roomList ( 5, 2 ) ( 6, 1 )
            , Passages.createPassage roomList ( 6, 4 ) ( 7, 3 )
            , Passages.createPassage roomList ( 3, 4 ) ( 8, 3 )
            ]

        "Level3" ->
            -- Level 3: Using same passage configuration as Level2 for now
            let
                passage1 =
                    [ Passages.createPassage roomList ( 1, 4 ) ( 3, 3 )
                    , Passages.createPassage roomList ( 1, 2 ) ( 2, 1 )
                    , Passages.createPassage roomList ( 3, 2 ) ( 4, 1 )
                    , Passages.createPassage roomList ( 2, 4 ) ( 4, 3 )
                    , Passages.createPassage roomList ( 2, 2 ) ( 7, 1 )
                    , Passages.createPassage roomList ( 3, 4 ) ( 5, 3 )
                    , Passages.createPassage roomList ( 4, 4 ) ( 6, 3 )
                    , Passages.createPassage roomList ( 6, 2 ) ( 10, 1 )
                    ]

                passage2 =
                    [ Passages.createPassage roomList ( 10, 4 ) ( 11, 3 )
                    , Passages.createPassage roomList ( 10, 3 ) ( 9, 4 )
                    , Passages.createPassage roomList ( 9, 3 ) ( 8, 4 )
                    , Passages.createPassage roomList ( 8, 3 ) ( 7, 4 )
                    , Passages.createPassage roomList ( 7, 2 ) ( 12, 1 )
                    , Passages.createPassage roomList ( 12, 4 ) ( 13, 3 )
                    , Passages.createPassage roomList ( 13, 4 ) ( 14, 3 )
                    ]

                passage3 =
                    [ Passages.createPassage roomList ( 14, 4 ) ( 15, 3 )
                    , Passages.createPassage roomList ( 10, 2 ) ( 16, 1 )
                    , Passages.createPassage roomList ( 11, 2 ) ( 15, 1 )

                    --, Passages.createPassage roomList ( 4, 4 ) ( 6, 3 )
                    ]
            in
            passage1 ++ passage2 ++ passage3

        _ ->
            []


{-| Renders all rooms and passages for the specified level.

This function orchestrates the complete rendering process for a game level, including
all rooms and their connecting passages. It handles the visual representation of the
entire level structure based on the player's position.

Parameters:

  - level - The level identifier string ("Level1", "Level2", "Level3")
  - playerPos - The current position of the player as (x, y) coordinates
  - cullRadius - The radius around the player within which rooms should be rendered

Rendering process:

1.  Generates the appropriate rooms for the specified level
2.  Creates all passage connections between rooms
3.  Assembles the rendering order with passages appearing behind rooms
4.  Returns a combined list of renderables for the entire level

Returns a List of Renderable objects that can be directly used by the rendering system
to draw the complete level structure.

-}
renderRoomsFor : String -> ( Float, Float ) -> Float -> List Renderable
renderRoomsFor level playerPos cullRadius =
    let
        currentRooms =
            roomsFor level playerPos cullRadius

        passagesRenderables =
            List.concat (passagesFor level currentRooms)

        -- Separate room renderables (floors come before walls in each room)
        roomRenderables =
            List.concatMap .renderables currentRooms
    in
    -- Render passages behind walls and floors
    -- Passages are rendered first (behind), then rooms (in front)
    passagesRenderables ++ roomRenderables
