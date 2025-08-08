module Lib.Utils.RoomRenderer exposing
    ( calculateTileDimensions, createWallTiles, createHorizontalWallTiles, createVerticalWallTiles
    , generateFloorTiles, generateWallTiles, filterCoordsForDoors, roomTexUpdater
    , tex, wallTile, floorTile
    )

{-| Module for rendering rooms and their contents in the game.

This module provides utilities for calculating room dimensions, rendering room tiles,
and handling room culling for optimization.


# Functions

@docs calculateTileDimensions, createWallTiles, createHorizontalWallTiles, createVerticalWallTiles


# Helper Functions

@docs generateFloorTiles, generateWallTiles, filterCoordsForDoors, roomTexUpdater


# Utility Functions

@docs tex, wallTile, floorTile

-}

import Basics exposing (pi)
import Lib.Utils.RoomTypes exposing (..)
import List exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)


{-| Calculate tile dimensions and coordinate lists for a room
-}
calculateTileDimensions : ( Float, Float ) -> ( Float, Float ) -> TileDimensions
calculateTileDimensions ( w, h ) ( cx, cy ) =
    let
        xTiles =
            max 1 (round (w / tileSize))

        yTiles =
            max 1 (round (h / tileSize))

        tileWidth =
            w / toFloat xTiles

        tileHeight =
            h / toFloat yTiles

        halfTileWidth =
            tileWidth / 2

        halfTileHeight =
            tileHeight / 2

        xLeft =
            cx - (w / 2) + halfTileWidth

        xRight =
            cx + (w / 2) - halfTileWidth

        yTop =
            cy - (h / 2) + halfTileHeight

        yBottom =
            cy + (h / 2) - halfTileHeight

        xs =
            generateCoords xLeft xRight tileWidth

        ys =
            generateCoords yTop yBottom tileHeight
    in
    { tileWidth = tileWidth
    , tileHeight = tileHeight
    , halfTileWidth = halfTileWidth
    , halfTileHeight = halfTileHeight
    , xs = xs
    , ys = ys
    }


{-| Generate floor tiles based on the player's position and culling radius
-}
generateFloorTiles : List Float -> List Float -> Float -> Float -> ( Float, Float ) -> Float -> List Renderable
generateFloorTiles xs ys tileWidth tileHeight playerPos radius =
    concatMap
        (\x ->
            List.filterMap
                (\y ->
                    if isWithinRadius ( x, y ) playerPos radius then
                        Just (tex "gfloor" ( x, y ) ( tileWidth, tileHeight ) 0)

                    else
                        Nothing
                )
                ys
        )
        xs


{-| Filter coordinates to create door openings in walls
-}
filterCoordsForDoors : DoorChecks -> ( Float, Float ) -> List Float -> List Float -> FilteredCoords
filterCoordsForDoors doors ( cx, cy ) xs ys =
    let
        withinDoor gap p origin =
            abs (p - origin) < gap

        doorHalf =
            door / 2

        xsTop =
            if doors.top then
                List.filter (\x -> not (withinDoor doorHalf x cx)) xs

            else
                xs

        xsBottom =
            if doors.bottom then
                List.filter (\x -> not (withinDoor doorHalf x cx)) xs

            else
                xs

        ysLeft =
            if doors.left then
                List.filter (\y -> not (withinDoor doorHalf y cy)) ys

            else
                ys

        ysRight =
            if doors.right then
                List.filter (\y -> not (withinDoor doorHalf y cy)) ys

            else
                ys
    in
    { xsTop = xsTop
    , xsBottom = xsBottom
    , ysLeft = ysLeft
    , ysRight = ysRight
    }


{-| Generic function to create wall tiles with given coordinates and position function
This reduces code duplication between horizontal and vertical wall tile creation
-}
createWallTiles : List Float -> (Float -> ( Float, Float )) -> Float -> TileDimensions -> ( Float, Float ) -> Float -> List Renderable
createWallTiles coords positionFunc rotation tileDim playerPos radius =
    List.filterMap
        (\coord ->
            let
                tilePos =
                    positionFunc coord
            in
            if isWithinRadius tilePos playerPos radius then
                Just (tex "wall" tilePos ( tileDim.tileWidth, tileDim.tileHeight ) rotation)

            else
                Nothing
        )
        coords


{-| Create horizontal wall tiles along the given y position
-}
createHorizontalWallTiles : List Float -> Float -> Float -> TileDimensions -> ( Float, Float ) -> Float -> List Renderable
createHorizontalWallTiles coords yPos rotation tileDim playerPos radius =
    createWallTiles coords (\x -> ( x, yPos )) rotation tileDim playerPos radius


{-| Create vertical wall tiles along the given x position
-}
createVerticalWallTiles : List Float -> Float -> Float -> TileDimensions -> ( Float, Float ) -> Float -> List Renderable
createVerticalWallTiles coords xPos rotation tileDim playerPos radius =
    createWallTiles coords (\y -> ( xPos, y )) rotation tileDim playerPos radius


{-| Generate all wall tiles for a room
-}
generateWallTiles : ( Float, Float ) -> ( Float, Float ) -> TileDimensions -> FilteredCoords -> ( Float, Float ) -> Float -> List Renderable
generateWallTiles ( w, h ) ( cx, cy ) tileDim filteredCoords playerPos radius =
    let
        topWall =
            createHorizontalWallTiles filteredCoords.xsTop (cy - h / 2 - tileDim.halfTileHeight) 0 tileDim playerPos radius

        bottomWall =
            createHorizontalWallTiles filteredCoords.xsBottom (cy + h / 2 - tileDim.halfTileHeight) 0 tileDim playerPos radius

        leftWall =
            createVerticalWallTiles filteredCoords.ysLeft (cx - w / 2 - tileDim.halfTileWidth) (pi / 2) tileDim playerPos radius

        rightWall =
            createVerticalWallTiles filteredCoords.ysRight (cx + w / 2 - tileDim.halfTileWidth) (pi / 2) tileDim playerPos radius
    in
    topWall ++ bottomWall ++ leftWall ++ rightWall


{-| Create all renderables for a room based on room dimensions and player position
-}
roomTexUpdater : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> DoorChecks -> Float -> List Renderable
roomTexUpdater ( w, h ) ( cx, cy ) playerPos doors radius =
    let
        tileDim =
            calculateTileDimensions ( w, h ) ( cx, cy )

        floorTiles =
            generateFloorTiles tileDim.xs tileDim.ys tileDim.tileWidth tileDim.tileHeight playerPos radius

        filteredCoords =
            filterCoordsForDoors doors ( cx, cy ) tileDim.xs tileDim.ys

        wallTiles =
            generateWallTiles ( w, h ) ( cx, cy ) tileDim filteredCoords playerPos radius
    in
    floorTiles ++ wallTiles


{-| Create a texture renderable with the given parameters
-}
tex : String -> ( Float, Float ) -> ( Float, Float ) -> Float -> Renderable
tex name ( x, y ) ( w, h ) rot =
    P.centeredTextureWithAlpha ( x, y ) ( w, h ) rot 1 name


{-| Create a wall tile at the given position
-}
wallTile : ( Float, Float ) -> Bool -> Renderable
wallTile ( x, y ) isVertical =
    let
        rotation =
            if isVertical then
                pi / 2

            else
                0
    in
    P.centeredTextureWithAlpha
        ( x, y )
        ( tileSize, tileSize )
        rotation
        1
        "wall"


{-| Create a floor tile at the given position
-}
floorTile : ( Float, Float ) -> Renderable
floorTile ( x, y ) =
    P.centeredTextureWithAlpha
        ( x, y )
        ( tileSize, tileSize )
        0
        1
        "gfloor"
