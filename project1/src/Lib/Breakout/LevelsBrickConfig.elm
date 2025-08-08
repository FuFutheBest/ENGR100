module Lib.Breakout.LevelsBrickConfig exposing (..)

import Lib.Breakout.LBCHelper exposing (..)
import Lib.Breakout.Vec exposing (Vec)



-- bricksCommonAttributes : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float }
-- bricksCommonAttributes =
--     { center = { x = 870, y = 120 }
--     , width = 90.0
--     , height = 30.0
--     , bricksPerLayer = 10
--     , layer = 3
--     , angle = 0.0 -- the angle
--     , widthGap = 15 -- gap between bricks in the same layer
--     , heightGap = 6 -- gap between bricks in different layers
--     }
--
--
-- typeRefsDefault : List Int
-- typeRefsDefault =
--     [ 8
--     , 5
--     , 5
--     , 8
--     , 6
--     , 6
--     , 0
--     , 9
--     , 5
--     , 8
--     , 9
--     , 9
--     , 9
--     , 0
--     , 1
--     , 1
--     , 2
--     , 2
--     , 1
--     , 7
--     , 7
--     , 2
--     , 2
--     , 0
--     , 10
--     , 10
--     , 8
--     , 0
--     , 10
--     , 1
--     ]


level1BCA : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float }
level1BCA =
    { center = { x = 870, y = 200 }
    , width = 111.0
    , height = 37.0
    , bricksPerLayer = 8
    , layer = 7
    , angle = 0.0 -- the angle
    , widthGap = 20 -- gap between bricks in the same layer
    , heightGap = 8 -- gap between bricks in different layers
    }


level1TR : List Int
level1TR =
    let
        part1 =
            [ 1, 2, 3, 4 ]

        part2 =
            [ 5, 6, 1, 2 ]
    in
    List.concat (List.repeat 7 (part1 ++ part2))



-- [ 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 1
-- , 2
-- ]


level2BCA : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float }
level2BCA =
    { center = { x = 870, y = 200 }
    , width = 111.0
    , height = 37.0
    , bricksPerLayer = 8
    , layer = 7
    , angle = 0.0 -- the angle
    , widthGap = 20 -- gap between bricks in the same layer
    , heightGap = 8 -- gap between bricks in different layers
    }


level2TR : List Int
level2TR =
    l2BricksTypes



-- [ 1
-- , 10
-- , 7
-- , 0
-- , 5
-- , 6
-- , 10
-- , 2
-- , 1
-- , 2
-- , 0
-- , 7
-- , 5
-- , 6
-- , 1
-- , 10
-- , 1
-- , 7
-- , 3
-- , 4
-- , 0
-- , 6
-- , 2
-- , 10
-- , 1
-- , 0
-- , 3
-- , 4
-- , 7
-- , 6
-- , 10
-- , 3
-- , 10
-- , 2
-- , 3
-- , 0
-- , 5
-- , 6
-- , 4
-- , 5
-- , 7
-- , 2
-- , 3
-- , 4
-- , 7
-- , 0
-- , 6
-- , 10
-- , 1
-- , 2
-- , 3
-- , 4
-- , 5
-- , 6
-- , 7
-- , 1
-- ]
--


level3BCA : { center : Vec, width : Float, height : Float, bricksPerLayer : Int, layer : Int, angle : Float, widthGap : Float, heightGap : Float }
level3BCA =
    { center = { x = 870, y = 200 }
    , width = 111.0
    , height = 37.0
    , bricksPerLayer = 8
    , layer = 7
    , angle = 0.0 -- the angle
    , widthGap = 20 -- gap between bricks in the same layer
    , heightGap = 8 -- gap between bricks in different layers
    }


level3TR : List Int
level3TR =
    l3BricksTypes



-- [ 3
-- , 7
-- , 1
-- , 10
-- , 5
-- , 0
-- , 8
-- , 2
-- , 6
-- , 4
-- , 9
-- , 3
-- , 2
-- , 1
-- , 0
-- , 7
-- , 6
-- , 5
-- , 8
-- , 10
-- , 4
-- , 0
-- , 3
-- , 7
-- , 9
-- , 6
-- , 1
-- , 10
-- , 5
-- , 2
-- , 4
-- , 0
-- , 9
-- , 8
-- , 6
-- , 3
-- , 7
-- , 2
-- , 10
-- , 5
-- , 1
-- , 0
-- , 8
-- , 4
-- , 9
-- , 7
-- , 6
-- , 2
-- , 3
-- , 10
-- , 1
-- , 5
-- , 0
-- , 8
-- , 4
-- , 6
-- ]
