module Lib.Breakout.Ball exposing (..)

import Color
import Lib.Breakout.BallCollideWithBricks exposing (Ball, collideWithBricks, toVCircle)
import Lib.Breakout.BricksInit exposing (..)
import Lib.Breakout.BricksRandomGenerator exposing (..)
import Lib.Breakout.Collision exposing (..)
import Lib.Breakout.Layer exposing (GameMsg(..), gameLayerCommonAttributes)
import Lib.Breakout.Paddle exposing (Paddle, PaddleType(..))
import Lib.Breakout.Vec exposing (Vec, add, toTuple)
import REGL.BuiltinPrograms exposing (circle, textbox)
import REGL.Common exposing (Renderable)


type UpdateBallMsg
    = GameState GameMsg
    | BrickType TypeRelatedAttributes


ballAttributes : { centerCoordinate : Vec, radius : Float, velocity : Vec, color : Color.Color }
ballAttributes =
    { centerCoordinate = { x = 960, y = 540 } -- center of the screen in pixels
    , radius = 10.0 -- radius of the ball
    , velocity = { x = 3, y = -3 } -- initial velocity of the ball
    , color = Color.lightGray -- color of the ball
    }


initBall : Ball
initBall =
    { centerCoordinate = ballAttributes.centerCoordinate
    , radius = ballAttributes.radius
    , velocity = ballAttributes.velocity
    , color = ballAttributes.color
    , variableX = 0
    }


viewBall : Ball -> List Renderable
viewBall b =
    let
        textSize =
            b.radius * 2.5

        textTopLeft =
            ( b.centerCoordinate.x - b.radius / 1.7
            , b.centerCoordinate.y - b.radius * 1.15
            )
    in
    [ circle (toTuple b.centerCoordinate) b.radius b.color
    , textbox textTopLeft textSize "X" "consolas" (Color.rgb 255 0 0)
    ]


updateBall : Ball -> Paddle -> List Brick -> ( Ball, List Brick, UpdateBallMsg )
updateBall ball paddle bricks =
    let
        {- Collide with the Edges -}
        ( collidedEdges, collideWithLayerCoord, collideWithLayerVel ) =
            collideInsideBox (toVCircle ball) (toBox gameLayerCommonAttributes.centerCoordinate gameLayerCommonAttributes.size)

        collideWithEdgesNewBall =
            { ball
                | centerCoordinate = collideWithLayerCoord
                , velocity = collideWithLayerVel
            }

        {- Collide with the Paddle -}
        ( isCollideWithPaddle, collideWithPaddleCoord, collideWithPaddleVel ) =
            collideOutsideBox (toVCircle ball) (toBox paddle.coordinate paddle.size)

        {- Check if all breakable bricks are eliminated -}
        isAllBreakableBricksEliminated =
            List.all
                (\brick ->
                    case brick.typeRef of
                        0 ->
                            -- Comment brick
                            True

                        7 ->
                            -- Conditional brick
                            True

                        10 ->
                            -- For loop brick
                            True

                        _ ->
                            -- All other types (1,2,3,4,5,6,8,9) should be eliminated
                            False
                )
                bricks

        ( collideWithPaddleNewBall, gameStateMsg ) =
            if isCollideWithPaddle && paddle.paddleType == Return && isAllBreakableBricksEliminated then
                ( ball, StopGame )

            else
                ( { ball
                    | centerCoordinate = collideWithPaddleCoord
                    , velocity = collideWithPaddleVel
                  }
                , NoMsg
                )

        maybeBrickCollision =
            collideWithBricks ball bricks

        ( newBall, remainingBricks, updateBallMsg ) =
            case maybeBrickCollision of
                Just result ->
                    ( result.ball
                    , result.remainingBricks
                    , BrickType result.collidedBrickAttributes
                    )

                Nothing ->
                    if collidedEdges == 1 then
                        -- Bottom edge collision (edge = 2)
                        ( collideWithEdgesNewBall, bricks, GameState LoseGame )

                    else if collidedEdges /= 0 then
                        -- Other edge collisions
                        ( collideWithEdgesNewBall, bricks, GameState NoMsg )

                    else if isCollideWithPaddle then
                        ( collideWithPaddleNewBall, bricks, GameState gameStateMsg )

                    else
                        ( { ball | centerCoordinate = add ball.velocity ball.centerCoordinate }
                        , bricks
                        , GameState NoMsg
                        )
    in
    ( newBall, remainingBricks, updateBallMsg )
