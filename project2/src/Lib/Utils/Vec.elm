module Lib.Utils.Vec exposing
    ( Vec
    , genVec
    , add, subtract, scale, dot, cross, length, normalize
    , rotate, clamp
    , toTuple, angleBetween
    )

{-| Simple 2D mathematical vector module.

This module provides common vector operations for 2D coordinate systems.


# Types

@docs Vec


# Creation

@docs genVec


# Basic Operations

@docs add, subtract, scale, dot, cross, length, normalize


# Transformations

@docs rotate, clamp


# Utilities

@docs toTuple, angleBetween

-}


{-| Represents a 2D vector with x and y components.

  - `x` - The x-component (horizontal) of the vector
  - `y` - The y-component (vertical) of the vector

Vectors can represent different concepts depending on context:

  - Coordinate: Position of a point on screen (pixels)
  - Size: Dimensions of a rectangle, where x is width and y is height (pixels)
  - Velocity: Speed and direction, where x and y are horizontal and vertical components (pixels/second)

-}
type alias Vec =
    { x : Float
    , y : Float
    }


{-| Creates a new vector with the specified x and y components.

    -- Create a vector at position (10, 20)
    position =
        genVec 10 20

-}
genVec : Float -> Float -> Vec
genVec x y =
    { x = x
    , y = y
    }


{-| Adds two vectors together, returning a new vector.


    newPos =
        add (genVec 10 20) (genVec 5 -3)

    -- results in (15, 17)

-}
add : Vec -> Vec -> Vec
add v1 v2 =
    { x = v1.x + v2.x
    , y = v1.y + v2.y
    }


{-| Multiplies a vector by a scalar value, returning a new vector.


    doubledVelocity =
        scale 2 (genVec 3 4)

    -- results in (6, 8)

-}
scale : Float -> Vec -> Vec
scale scalar vector =
    { x = scalar * vector.x
    , y = scalar * vector.y
    }


{-| Subtracts the second vector from the first, returning a new vector.


    displacement =
        subtract (genVec 10 20) (genVec 5 8)

    -- results in (5, 12)

-}
subtract : Vec -> Vec -> Vec
subtract v1 v2 =
    add v1 (scale -1 v2)


{-| Calculates the dot product of two vectors.


    v1 =
        genVec 3 4

    v2 =
        genVec 1 2

    dotProduct =
        dot v1 v2

    -- results in 3\_1 + 4\_2 = 11

-}
dot : Vec -> Vec -> Float
dot v1 v2 =
    v1.x * v2.x + v1.y * v2.y


{-| Calculates the length (magnitude) of a vector.


    v =
        genVec 3 4

    magnitude =
        length v

    -- results in 5

-}
length : Vec -> Float
length v =
    sqrt (v.x ^ 2 + v.y ^ 2)


{-| Constrains a vector's components to be between the specified minimum and maximum values.


    position =
        genVec 15 30

    minBounds =
        genVec 0 0

    maxBounds =
        genVec 100 50

    clampedPosition =
        clamp minBounds maxBounds position

    -- results in (15, 30)

-}
clamp : Vec -> Vec -> Vec -> Vec
clamp min max vec =
    { x = Basics.clamp min.x max.x vec.x
    , y = Basics.clamp min.y max.y vec.y
    }


{-| Normalizes a vector to have a length of 1 (unit vector), preserving direction.


    unitV =
        normalize (genVec 3 4)

    -- results in (0.6, 0.8)

-}
normalize : Vec -> Vec
normalize v =
    let
        l =
            length v
    in
    { x = v.x / l
    , y = v.y / l
    }


{-| Rotates a vector clockwise by the specified angle (in radians).


    v =
        genVec 1 0

    rotated =
        rotate (pi / 2) v

    -- results in approximately (0, 1)

-}
rotate : Float -> Vec -> Vec
rotate angle v =
    -- rotate the vector clockwise by a given angle in radians
    let
        cosTheta =
            cos angle

        sinTheta =
            sin angle
    in
    { x = v.x * cosTheta - v.y * sinTheta
    , y = v.x * sinTheta + v.y * cosTheta
    }


{-| Converts a vector to a tuple of (x, y).


    v =
        genVec 10 20

    ( x, y ) =
        toTuple v

    -- results in (10, 20)

-}
toTuple : Vec -> ( Float, Float )
toTuple v =
    ( v.x, v.y )


{-| Calculates the cross product of two vectors.

For 2D vectors, the cross product is a scalar representing the area of the
parallelogram formed by the two vectors.


    crossProduct =
        cross (genVec 1 2) (genVec 3 4)

    -- results in 3*2 - 4*1 = 2

-}
cross : Vec -> Vec -> Float
cross v1 v2 =
    v1.x * v2.y - v1.y * v2.x


{-| Calculates the angle between two vectors in radians.

The angle is measured clockwise from vec1 to vec2.
Returns a value between 0 and 2pi.


    horizontal =
        genVec 1 0

    diagonal =
        genVec 1 1

    angle =
        angleBetween horizontal diagonal

    -- results in pi/4 (45 degrees)

-}
angleBetween : Vec -> Vec -> Float
angleBetween vec1 vec2 =
    -- calculate the angle between two vectors in radians, vec1->vec2 should be clockwise
    let
        dotProduct =
            dot vec1 vec2

        crossProduct =
            cross vec1 vec2

        angle =
            atan2 crossProduct dotProduct
    in
    if angle < 0 then
        angle + 2 * pi

    else
        angle
