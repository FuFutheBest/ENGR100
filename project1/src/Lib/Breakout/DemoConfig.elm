module Lib.Breakout.DemoConfig exposing (..)

import Lib.Breakout.Vec exposing (Vec)


demoBCA : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float }
demoBCA =
    { center = { x = 870, y = 200 }
    , width = 111.0
    , height = 37.0
    , bricksPerLayer = 8
    , layer = 1
    , angle = 0.0 -- the angle
    , widthGap = 20 -- gap between bricks in the same layer
    , heightGap = 8 -- gap between bricks in different layers
    }


demoTR : List Int
demoTR =
    [ 1
    , 2
    , 3
    , 0
    , 4
    , 5
    , 6
    , 10
    ]
