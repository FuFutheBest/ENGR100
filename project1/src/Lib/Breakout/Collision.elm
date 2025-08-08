module Lib.Breakout.Collision exposing
    ( BoundingBox
    , VCircle
    , circleVsAABB
    , collideInsideBox
    , collideOutsideBox
    , toBox
    )

{- Abstract collision module that only depends on the Vec module

   The impactor is abstracted as a circle with velocity i.e A Ball
   The impacted object is abstracted into a rectangle(BoundingBox) i.e A Brick, or the screen edges

   To use the model, implement the corresponding functions that convert objects into the abstracted VCircle and BoundingBox types
   in order to match the model.
-}

import Lib.Breakout.Vec as Vec exposing (Vec)


type alias CollisionInfo =
    { isColliding : Bool
    , penetration : Vec
    }


type alias VCircle =
    { center : Vec
    , radius : Float
    , velocity : Vec
    }


type alias BoundingBox =
    { topLeft : Vec -- The top-left corner coordinate of the rectangle
    , bottomRight : Vec -- The bottom-right corner coordinate of the rectangle
    }


{-| Converts center and size to a bounding box
-}
toBox : Vec -> Vec -> BoundingBox
toBox center size =
    -- help function to convert a rectangle defined by a center and size into a BoundingBox
    let
        halfSize =
            Vec.scale 0.5 size
    in
    { topLeft = Vec.subtract center halfSize
    , bottomRight = Vec.add center halfSize
    }


boxToRec : BoundingBox -> ( Vec, Vec )
boxToRec box =
    -- help function to convert a BoundingBox into a rectangle defined by a center and size
    let
        x1 =
            box.topLeft.x

        x2 =
            box.bottomRight.x

        y1 =
            box.topLeft.y

        y2 =
            box.bottomRight.y

        width =
            abs (x2 - x1)

        height =
            abs (y2 - y1)
    in
    ( { x = x1 + width / 2
      , y = y1 + height / 2
      }
    , { x = width
      , y = height
      }
    )


{-| Detects collision between circle and axis-aligned bounding box
-}
circleVsAABB : VCircle -> BoundingBox -> CollisionInfo
circleVsAABB circle rectangle =
    let
        ( center, extents ) =
            boxToRec rectangle

        halfExtents =
            Vec.scale 0.5 extents

        difference =
            Vec.subtract circle.center center

        clamped =
            Vec.clamp (Vec.scale -1 halfExtents) halfExtents difference

        closest =
            Vec.add center clamped

        distance =
            Vec.subtract closest circle.center

        isColliding =
            Vec.length distance < circle.radius

        penetration =
            if isColliding then
                distance

            else
                { x = 0, y = 0 }
    in
    { isColliding = isColliding
    , penetration = penetration
    }


rebound : Vec -> Vec -> Vec
rebound penetration velocity =
    let
        normal =
            penetration
                |> Vec.scale -1
                |> Vec.normalize

        velocityAlongNormal =
            Vec.dot velocity normal
    in
    if velocityAlongNormal < 0 then
        let
            impulse =
                Vec.scale (2 * velocityAlongNormal) normal
        in
        Vec.subtract velocity impulse

    else
        velocity


type alias Dset =
    { nC : Float
    , v : Float
    , cc : Float
    , r : Float
    , lyAs : Float
    , minBound : Float
    }


axisSetize : (Vec -> Float) -> ( ( Vec, Vec, Vec ), Float, { min : Float, max : Float } ) -> Dset
axisSetize extractAxis ( ( nC, v, cc ), r, bounds ) =
    { nC = extractAxis nC
    , v = extractAxis v
    , cc = extractAxis cc
    , r = r
    , lyAs = bounds.max - bounds.min
    , minBound = bounds.min
    }


xDsetize : ( ( Vec, Vec, Vec ), Float, { min : Float, max : Float } ) -> Dset
xDsetize =
    axisSetize .x


yDsetize : ( ( Vec, Vec, Vec ), Float, { min : Float, max : Float } ) -> Dset
yDsetize =
    axisSetize .y


dsetize : ( ( Vec, Vec, Vec ), Float, BoundingBox ) -> ( Dset, Dset )
dsetize ( ( nC, v, cc ), r, box ) =
    let
        xBounds =
            { min = box.topLeft.x, max = box.bottomRight.x }

        yBounds =
            { min = box.topLeft.y, max = box.bottomRight.y }
    in
    ( xDsetize ( ( nC, v, cc ), r, xBounds )
    , yDsetize ( ( nC, v, cc ), r, yBounds )
    )


type alias NewDvResult =
    { newV : Float
    , newCoord : Float
    , didCollide : Bool
    , edge : Int
    }


newDv : Dset -> NewDvResult
newDv d =
    if d.nC - d.r < d.minBound then
        { newV = -d.v
        , newCoord = d.cc
        , didCollide = True
        , edge = 3
        }

    else if d.nC + d.r > (d.minBound + d.lyAs) then
        { newV = -d.v
        , newCoord = d.cc
        , didCollide = True
        , edge = 4
        }

    else
        { newV = d.v
        , newCoord = d.nC
        , didCollide = False
        , edge = 0
        }


collideInsideBox : VCircle -> BoundingBox -> ( Int, Vec, Vec )
collideInsideBox circle box =
    let
        nextCoord =
            Vec.add circle.center circle.velocity

        ( x, y ) =
            dsetize ( ( nextCoord, circle.velocity, circle.center ), circle.radius, box )

        xRes =
            newDv x

        yRes =
            newDv y

        edgeY =
            case yRes.edge of
                3 ->
                    2

                -- Top
                4 ->
                    1

                -- Bottom
                _ ->
                    0

        collidedEdge =
            case ( xRes.didCollide, yRes.didCollide ) of
                ( False, False ) ->
                    0

                ( True, False ) ->
                    xRes.edge

                ( False, True ) ->
                    edgeY

                ( True, True ) ->
                    xRes.edge
    in
    ( collidedEdge
      {- collidedEdges are defined as follows:
         0: No collision
         1: Collision with top edge
         2: Collision with bottom edge
         3: Collision with left edge
         4: Collision with right edge

      -}
    , { x = xRes.newCoord, y = yRes.newCoord }
    , { x = xRes.newV, y = yRes.newV }
    )


{-| Handles collision with a box object
-}
collideOutsideBox : VCircle -> BoundingBox -> ( Bool, Vec, Vec )
collideOutsideBox circle box =
    let
        collisionInfo =
            circleVsAABB circle box

        newVelocity =
            if collisionInfo.isColliding then
                rebound collisionInfo.penetration circle.velocity

            else
                circle.velocity

        newCoordinate =
            Vec.add circle.center newVelocity
    in
    ( collisionInfo.isColliding, newCoordinate, newVelocity )
