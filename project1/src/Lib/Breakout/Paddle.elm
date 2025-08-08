module Lib.Breakout.Paddle exposing (Paddle, PaddleType(..), initPaddle, movePaddle, viewPaddle)

import Color
import Lib.Breakout.Layer exposing (gameLayerCommonAttributes)
import Lib.Breakout.Vec as Vec exposing (Vec, add, scale, toTuple)
import REGL.BuiltinPrograms exposing (rectCentered, textbox)
import REGL.Common exposing (Renderable)


type alias Paddle =
    { paddleType : PaddleType -- type of the paddle, Normal or Return
    , coordinate : Vec -- center coordinates of each brick
    , size : Vec
    }


type PaddleType
    = Normal
    | Return


paddleCommonAttributes : { width : Float, height : Float, angle : Float, velocity : Vec }
paddleCommonAttributes =
    { width = 200
    , height = 30
    , angle = 0.0
    , velocity = { x = 10, y = 0 } -- initial velocity of the paddle
    }


initPaddle : Paddle
initPaddle =
    { paddleType = Normal
    , coordinate = { x = gameLayerCommonAttributes.centerCoordinate.x, y = gameLayerCommonAttributes.centerCoordinate.y + 400 } -- initial position of the paddle
    , size = { x = paddleCommonAttributes.width, y = paddleCommonAttributes.height }
    }


viewPaddle : Paddle -> List Renderable
viewPaddle b =
    case b.paddleType of
        Normal ->
            [ rectCentered (toTuple b.coordinate) (toTuple b.size) paddleCommonAttributes.angle Color.white ]

        Return ->
            let
                textSize =
                    Vec.scale 0.2 b.size

                topLeft =
                    { x = b.coordinate.x - textSize.x * 1.5
                    , y = b.coordinate.y - textSize.y * 2.5
                    }
            in
            [ rectCentered (toTuple b.coordinate) (toTuple b.size) paddleCommonAttributes.angle Color.lightGreen
            , textbox (Vec.toTuple topLeft) textSize.x "Return" "consolas" Color.darkGreen
            ]



-- Move the paddle left or right based on the direction( 1 for right, -1 for left)


canMove : Paddle -> Int -> Bool
canMove paddle direction =
    let
        xmax =
            gameLayerCommonAttributes.centerCoordinate.x + (gameLayerCommonAttributes.size.x / 2) - (paddle.size.x / 2)

        xmin =
            gameLayerCommonAttributes.centerCoordinate.x - (gameLayerCommonAttributes.size.x / 2) + (paddle.size.x / 2)
    in
    if direction == 1 then
        paddle.coordinate.x < xmax

    else if direction == -1 then
        paddle.coordinate.x > xmin

    else
        False


movePaddle : Paddle -> Int -> Paddle
movePaddle paddle direction =
    let
        cordinateBefore =
            paddle.coordinate

        velocity =
            paddleCommonAttributes.velocity

        trueVelocity =
            if canMove paddle direction then
                if (direction * round velocity.x) < 0 then
                    scale -1 velocity

                else
                    velocity

            else
                { x = 0, y = 0 }
    in
    case direction + 1 of
        2 ->
            { paddle | coordinate = add cordinateBefore trueVelocity }

        0 ->
            { paddle | coordinate = add cordinateBefore trueVelocity }

        _ ->
            paddle
