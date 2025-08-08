module Lib.Breakout.Vec exposing (..)

{- Simple 2D mathmatical vector module

   Parameters that are represented as a vector are listed below:
       Coordinate: the cordinate of a point on screen
       Size: the size of a rectangle, x and y represent the width and height respectively
       Velocity: the speed and direction of a moving object, x and y represent the horizontal and vertical components respectively
-}


type alias Vec =
    { x : Float
    , y : Float
    }


add : Vec -> Vec -> Vec
add v1 v2 =
    { x = v1.x + v2.x
    , y = v1.y + v2.y
    }


scale : Float -> Vec -> Vec
scale scalar vector =
    { x = scalar * vector.x
    , y = scalar * vector.y
    }


subtract : Vec -> Vec -> Vec
subtract v1 v2 =
    add v1 (scale -1 v2)


dot : Vec -> Vec -> Float
dot v1 v2 =
    v1.x * v2.x + v1.y * v2.y


length : Vec -> Float
length v =
    sqrt (v.x ^ 2 + v.y ^ 2)


clamp : Vec -> Vec -> Vec -> Vec
clamp min max vec =
    { x = Basics.clamp min.x max.x vec.x
    , y = Basics.clamp min.y max.y vec.y
    }


normalize : Vec -> Vec
normalize v =
    let
        l =
            length v
    in
    { x = v.x / l
    , y = v.y / l
    }


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


toTuple : Vec -> ( Float, Float )
toTuple v =
    ( v.x, v.y )
