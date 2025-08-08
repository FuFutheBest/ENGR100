module Lib.Breakout.Layer exposing (GameMsg(..), codeAreaAttributes, gameLayerCommonAttributes, infoAAttributes, infoBAttributes, viewLayer)

import Color
import Lib.Breakout.Vec as Vec exposing (Vec)
import REGL.BuiltinPrograms exposing (rectCentered)
import REGL.Common exposing (Renderable)


type GameMsg
    = NoMsg
    | StopGame
    | LoseGame



{-
      Screen: 1920 x 1080 px
   +------------------------------------------------------------------------------+
   | Outer margin: 20px                                                           |
   |                                                                              |
   |  +-------------+  +----------------------+   +---------------------+        |
   |  |             |  |                      |   |                     |        |
   |  | Code Area   |  |     Game Area        |   |     Info Area A     |        |
   |  |(300x1040)   |  |   (1060 x 1040 px)   |   |    (500 x 100 px)   |        |
   |  |             |  |                      |   +---------------------+        |
   |  |             |  |                      |   |                     |        |
   |  |             |  |                      |   |     Info Area B     |        |
   |  |             |  |                      |   |    (500 x 920 px)   |        |
   |  +-------------+  +----------------------+   +---------------------+        |
   |   width: 300px       width: 1060 px            width: 500 px               |
   |   height: 1040px     height: 1040 px           height: 1040 px             |
   |      ^                    ^                         ^                      |
   |      +-- spacing: 20px ---+-- spacing: 20px -------+                      |
   |                                                                            |
   +----------------------------------------------------------------------------+
-}


codeAreaAttributes : { centerCoordinate : Vec, size : Vec, angle : Float, color : Color.Color }
codeAreaAttributes =
    { centerCoordinate = { x = 20 + 150, y = 540 } -- center of the code area (300/2 = 150)
    , size = { x = 300, y = 1040 } -- size of the code area
    , angle = 0.0 -- angle of the code area
    , color = Color.rgb 30 30 30 -- dark background for code area
    }


gameLayerCommonAttributes : { centerCoordinate : Vec, size : Vec, angle : Float, color : Color.Color }
gameLayerCommonAttributes =
    { centerCoordinate = { x = 300 + 40 + 530, y = 540 } -- center of the game area (300 + 20 + 1060/2)
    , size = { x = 1060, y = 1040 } -- size of the game area
    , angle = 0.0 -- angle of the layer
    , color = Color.darkBlue -- default color of the layer
    }


infoAAttributes : { centerCoordinate : Vec, size : Vec, angle : Float, color : Color.Color }
infoAAttributes =
    { centerCoordinate = { x = 300 + 40 + 1060 + 40 + 250, y = 20 + 50 } -- center of the info area A
    , size = { x = 500, y = 100 } -- size of the info area A
    , angle = 0.0 -- angle of the info area A
    , color = Color.darkBlue -- default color of the info area A
    }


infoBAttributes : { centerCoordinate : Vec, size : Vec, angle : Float, color : Color.Color }
infoBAttributes =
    { centerCoordinate = { x = 300 + 40 + 1060 + 40 + 250, y = 20 + 100 + 20 + 460 } -- center of the info area B
    , size = { x = 500, y = 920 } -- size of the info area B
    , angle = 0.0 -- angle of the info area B
    , color = Color.darkBlue -- default color of the info area B
    }


viewLayer : List Renderable
viewLayer =
    [ rectCentered (Vec.toTuple { x = 960, y = 540 }) (Vec.toTuple { x = 1920, y = 1080 }) 0.0 Color.black --background

    -- Code Area (left side)
    , rectCentered (Vec.toTuple codeAreaAttributes.centerCoordinate)
        (Vec.toTuple codeAreaAttributes.size)
        codeAreaAttributes.angle
        codeAreaAttributes.color
    , rectCentered (Vec.toTuple codeAreaAttributes.centerCoordinate)
        (Vec.toTuple (Vec.subtract codeAreaAttributes.size { x = 5, y = 5 }))
        0.0
        Color.black

    -- code area border
    -- Game Area (center)
    , rectCentered (Vec.toTuple gameLayerCommonAttributes.centerCoordinate)
        (Vec.toTuple gameLayerCommonAttributes.size)
        gameLayerCommonAttributes.angle
        gameLayerCommonAttributes.color
    , rectCentered (Vec.toTuple gameLayerCommonAttributes.centerCoordinate)
        (Vec.toTuple (Vec.subtract gameLayerCommonAttributes.size { x = 5, y = 5 }))
        0.0
        Color.black

    -- game area border
    -- Info Area A (top right)
    , rectCentered (Vec.toTuple infoAAttributes.centerCoordinate)
        (Vec.toTuple infoAAttributes.size)
        infoAAttributes.angle
        infoAAttributes.color
    , rectCentered (Vec.toTuple infoAAttributes.centerCoordinate)
        (Vec.toTuple (Vec.subtract infoAAttributes.size { x = 5, y = 5 }))
        infoAAttributes.angle
        Color.black

    -- info area A border
    -- Info Area B (bottom right)
    , rectCentered (Vec.toTuple infoBAttributes.centerCoordinate)
        (Vec.toTuple infoBAttributes.size)
        infoBAttributes.angle
        infoBAttributes.color
    , rectCentered (Vec.toTuple infoBAttributes.centerCoordinate)
        (Vec.toTuple (Vec.subtract infoBAttributes.size { x = 5, y = 5 }))
        infoBAttributes.angle
        Color.black

    -- info area B border
    ]
