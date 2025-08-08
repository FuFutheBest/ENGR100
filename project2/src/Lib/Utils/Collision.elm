module Lib.Utils.Collision exposing
    ( Rectangle, Circle, Fan, Rectangle2
    , isRecsCollision, isRecCircleCollision, isPointinRec, isPointinFan, isPointInRectangle2, isWithinBounds, isRecinFan
    )

{-| Collision detection utilities for game objects.


# Types

@docs Rectangle, Circle, Fan, Rectangle2


# Collision Functions

@docs isRecsCollision, isRecCircleCollision, isPointinRec, isPointinFan, isPointInRectangle2, isWithinBounds, isRecinFan

-}

import Lib.Utils.Vec as Vec


{-| Represents an axis-aligned (non-rotated) rectangle.

  - `centerCoordinate` - Position of the rectangle's center (pixels)
  - `size` - Width and height of the rectangle (pixels)

-}
type alias Rectangle =
    { centerCoordinate : Vec.Vec
    , size : Vec.Vec
    }


{-| Represents a circle.

  - `centerCoordinate` - Position of the circle's center (pixels)
  - `radius` - Radius of the circle (pixels)

-}
type alias Circle =
    { centerCoordinate : Vec.Vec
    , radius : Float
    }


{-| Represents a fan-shaped area (like a flashlight beam or radar sweep).

  - `startCoordinate` - Starting position of the fan (origin point)
  - `startRayDir` - Direction vector for the starting ray of the fan
  - `angle` - Angular width of the fan in radians (clockwise from startRayDir)
  - `length` - Maximum reach/distance of the fan from its origin

-}
type alias Fan =
    { startCoordinate : Vec.Vec
    , startRayDir : Vec.Vec
    , angle : Float
    , length : Float
    }


{-| Represents a potentially rotated rectangle defined by its four corner points.

  - `topLeft` - Coordinates of the top-left corner
  - `topRight` - Coordinates of the top-right corner
  - `bottomLeft` - Coordinates of the bottom-left corner
  - `bottomRight` - Coordinates of the bottom-right corner

-}
type alias Rectangle2 =
    { topLeft : Vec.Vec
    , topRight : Vec.Vec
    , bottomLeft : Vec.Vec
    , bottomRight : Vec.Vec
    }


{-| Checks if a position is within screen boundaries.
Takes a position vector and a size vector, returns whether the object
fits within the screen (1920x1080).
-}
isWithinBounds : Vec.Vec -> Vec.Vec -> Bool
isWithinBounds position size =
    let
        halfWidth =
            size.x / 2

        halfHeight =
            size.y / 2

        isWithinScreenBounds =
            position.x
                - halfWidth
                > 0
                && position.x
                + halfWidth
                < 1920
                && position.y
                - halfHeight
                > 0
                && position.y
                + halfHeight
                < 1080
    in
    isWithinScreenBounds


{-| Detects collision between two axis-aligned rectangles.
Uses the separate axis theorem to determine if rectangles overlap.
-}
isRecsCollision : Rectangle -> Rectangle -> Bool
isRecsCollision rec1 rec2 =
    let
        dx =
            abs rec1.centerCoordinate.x - rec2.centerCoordinate.x

        dy =
            abs rec1.centerCoordinate.y - rec2.centerCoordinate.y

        ( mindx, mindy ) =
            Vec.add rec1.size rec2.size
                |> Vec.scale 0.5
                |> Vec.toTuple

        ( isCollideX, isCollideY ) =
            ( dx < mindx, dy < mindy )
    in
    isCollideX && isCollideY


{-| Tests if a point is inside an axis-aligned rectangle.
Compares the point's position with the rectangle boundaries.
-}
isPointinRec : Rectangle -> Vec.Vec -> Bool
isPointinRec rec coordinate =
    let
        halfExtents =
            Vec.scale 0.5 rec.size

        difference =
            Vec.subtract coordinate rec.centerCoordinate

        isWithinX =
            abs difference.x <= halfExtents.x

        isWithinY =
            abs difference.y <= halfExtents.y
    in
    isWithinX && isWithinY


{-| Detects collision between an axis-aligned rectangle and a circle.

    -- Check if player rectangle collides with enemy circle
    isRecCircleCollision playerRect enemyCircle

-}
isRecCircleCollision : Rectangle -> Circle -> Bool
isRecCircleCollision rec circle =
    let
        halfExtents =
            Vec.scale 0.5 rec.size

        difference =
            Vec.subtract circle.centerCoordinate rec.centerCoordinate

        clamped =
            Vec.clamp (Vec.scale -1 halfExtents) halfExtents difference

        closest =
            Vec.add rec.centerCoordinate clamped

        distance =
            Vec.subtract closest circle.centerCoordinate

        isColliding =
            Vec.length distance < circle.radius
    in
    isColliding


{-| Tests if a point is inside a fan-shaped area.
Checks distance from origin and angle within fan boundaries.
-}
isPointinFan : Fan -> Vec.Vec -> Bool
isPointinFan fan coordinate =
    let
        toPoint =
            Vec.subtract coordinate fan.startCoordinate

        distance =
            Vec.length toPoint

        isWithinDistance =
            distance <= fan.length

        isAtOrigin =
            distance == 0

        isWithinAngle =
            if isAtOrigin then
                True

            else
                let
                    angleToPoint =
                        Vec.angleBetween fan.startRayDir toPoint
                in
                angleToPoint >= 0 && angleToPoint <= fan.angle
    in
    isWithinDistance && isWithinAngle


{-| Tests if any corner of a rectangle is inside a fan-shaped area.
Calculates all four corners and checks each against the fan.
-}
isRecinFan : Fan -> Rectangle -> Bool
isRecinFan fan rec =
    let
        halfExtents =
            Vec.scale 0.5 rec.size

        topLeft =
            Vec.subtract rec.centerCoordinate halfExtents

        topRight =
            Vec.add topLeft { x = rec.size.x, y = 0 }

        bottomLeft =
            Vec.add topLeft { x = 0, y = rec.size.y }

        bottomRight =
            Vec.add topLeft rec.size

        corners =
            [ topLeft, topRight, bottomLeft, bottomRight ]
    in
    List.any (isPointinFan fan) corners


{-| Tests if a point is inside a potentially rotated rectangle.
Uses cross products of vectors to determine if point is contained.
-}
isPointInRectangle2 : Vec.Vec -> Rectangle2 -> Bool
isPointInRectangle2 point rect =
    let
        v1 =
            Vec.subtract rect.topLeft point

        v2 =
            Vec.subtract rect.topRight point

        v3 =
            Vec.subtract rect.bottomRight point

        v4 =
            Vec.subtract rect.bottomLeft point

        cross1 =
            Vec.cross v1 v2

        cross2 =
            Vec.cross v2 v3

        cross3 =
            Vec.cross v3 v4

        cross4 =
            Vec.cross v4 v1
    in
    (cross1 >= 0 && cross2 >= 0 && cross3 >= 0 && cross4 >= 0)
        || (cross1 <= 0 && cross2 <= 0 && cross3 <= 0 && cross4 <= 0)
