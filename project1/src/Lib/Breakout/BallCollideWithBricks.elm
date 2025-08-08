module Lib.Breakout.BallCollideWithBricks exposing (..)

import Bitwise
import Color
import Lib.Breakout.BricksInit exposing (..)
import Lib.Breakout.BricksRandomGenerator exposing (..)
import Lib.Breakout.Collision exposing (..)
import Lib.Breakout.Layer exposing (GameMsg(..), gameLayerCommonAttributes)
import Lib.Breakout.Paddle exposing (PaddleType(..))
import Lib.Breakout.Vec exposing (Vec)


type alias Ball =
    { centerCoordinate : Vec
    , radius : Float
    , velocity : Vec
    , color : Color.Color
    , variableX : Int
    }


toVCircle : Ball -> VCircle
toVCircle ball =
    { center = ball.centerCoordinate
    , radius = ball.radius
    , velocity = ball.velocity
    }


collideWithBricks : Ball -> List Brick -> Maybe { ball : Ball, remainingBricks : List Brick, collidedBrickAttributes : TypeRelatedAttributes }
collideWithBricks ball bricks =
    case bricks of
        [] ->
            Nothing

        brick :: rest ->
            let
                box =
                    toBox brick.commonAttributes.centerCoordinate brick.commonAttributes.size

                ( isColliding, newCoord, newVel ) =
                    case brick.typeRef of
                        _ ->
                            collideOutsideBox (toVCircle ball) box
            in
            if isColliding then
                Just
                    { ball =
                        { ball
                            | centerCoordinate = newCoord
                            , velocity = newVel
                            , variableX =
                                case brick.typeRef of
                                    1 ->
                                        ball.variableX + 1

                                    2 ->
                                        ball.variableX - 1

                                    3 ->
                                        let
                                            increInt =
                                                case brick.typeRelatedAttributes of
                                                    IncrementIntAttributes int ->
                                                        int

                                                    _ ->
                                                        0
                                        in
                                        ball.variableX + increInt

                                    4 ->
                                        let
                                            decreInt =
                                                case brick.typeRelatedAttributes of
                                                    DecrementIntAttributes int ->
                                                        int

                                                    _ ->
                                                        0
                                        in
                                        ball.variableX - decreInt

                                    5 ->
                                        let
                                            multInt =
                                                case brick.typeRelatedAttributes of
                                                    MultiplyIntAttributes int ->
                                                        int

                                                    _ ->
                                                        1
                                        in
                                        ball.variableX * multInt

                                    6 ->
                                        let
                                            divInt =
                                                case brick.typeRelatedAttributes of
                                                    DivideIntAttributes int ->
                                                        int

                                                    _ ->
                                                        1
                                        in
                                        ball.variableX // divInt

                                    7 ->
                                        let
                                            ( condition, behavior ) =
                                                case brick.typeRelatedAttributes of
                                                    ConditionalAttributes ( cond, behav ) ->
                                                        ( cond, behav )

                                                    _ ->
                                                        ( NoCondition, DoNothing )

                                            newVariableX =
                                                case condition of
                                                    NoCondition ->
                                                        ball.variableX

                                                    EqualTo x ->
                                                        if ball.variableX == x then
                                                            case behavior of
                                                                Increment ->
                                                                    ball.variableX + 1

                                                                Decrement ->
                                                                    ball.variableX - 1

                                                                IncrementInt int ->
                                                                    ball.variableX + int

                                                                DecrementInt int ->
                                                                    ball.variableX - int

                                                                Multiply int ->
                                                                    ball.variableX * int

                                                                Divide int ->
                                                                    ball.variableX // int

                                                                LeftShift int ->
                                                                    Bitwise.shiftLeftBy int ball.variableX

                                                                RightShift int ->
                                                                    Bitwise.shiftRightBy int ball.variableX

                                                                DoNothing ->
                                                                    ball.variableX

                                                        else
                                                            ball.variableX
                                        in
                                        newVariableX

                                    8 ->
                                        let
                                            shiftInt =
                                                case brick.typeRelatedAttributes of
                                                    LeftShiftAttributes int ->
                                                        int

                                                    _ ->
                                                        0
                                        in
                                        Bitwise.shiftLeftBy shiftInt ball.variableX

                                    9 ->
                                        let
                                            shiftInt =
                                                case brick.typeRelatedAttributes of
                                                    RightShiftAttributes int ->
                                                        int

                                                    _ ->
                                                        0
                                        in
                                        Bitwise.shiftRightBy shiftInt ball.variableX

                                    10 ->
                                        let
                                            ( count, behavior ) =
                                                case brick.typeRelatedAttributes of
                                                    ForLoopAttributes ( c, b ) ->
                                                        ( c, b )

                                                    _ ->
                                                        ( 0, DoNothing )

                                            executeLoop currentX remainingCount =
                                                if remainingCount <= 0 then
                                                    currentX

                                                else
                                                    let
                                                        newX =
                                                            case behavior of
                                                                Increment ->
                                                                    currentX + 1

                                                                Decrement ->
                                                                    currentX - 1

                                                                IncrementInt int ->
                                                                    currentX + int

                                                                DecrementInt int ->
                                                                    currentX - int

                                                                Multiply int ->
                                                                    currentX * int

                                                                Divide int ->
                                                                    currentX // int

                                                                DoNothing ->
                                                                    currentX

                                                                _ ->
                                                                    currentX
                                                    in
                                                    executeLoop newX (remainingCount - 1)
                                        in
                                        executeLoop ball.variableX count

                                    _ ->
                                        ball.variableX
                        }
                    , remainingBricks =
                        case brick.typeRef of
                            0 ->
                                brick :: rest

                            7 ->
                                let
                                    ( condition, behavior ) =
                                        case brick.typeRelatedAttributes of
                                            ConditionalAttributes ( cond, behav ) ->
                                                ( cond, behav )

                                            _ ->
                                                ( NoCondition, DoNothing )
                                in
                                case condition of
                                    NoCondition ->
                                        brick :: rest

                                    EqualTo int ->
                                        if ball.variableX == int then
                                            rest

                                        else
                                            brick :: rest

                            _ ->
                                rest
                    , collidedBrickAttributes = brick.typeRelatedAttributes
                    }

            else
                Maybe.map
                    (\result ->
                        { result | remainingBricks = brick :: result.remainingBricks }
                    )
                    (collideWithBricks ball rest)
