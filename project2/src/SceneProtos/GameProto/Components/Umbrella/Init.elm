module SceneProtos.GameProto.Components.Umbrella.Init exposing
    ( InitData
    , GhostInitData
    , UmbrellaMsg(..)
    , uConfig
    )

{-|


# Init module

@docs InitData
@docs GhostInitData
@docs UmbrellaMsg
@docs uConfig

-}

import Lib.Utils.Vec as Vec


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , position : Vec.Vec
    }


{-| The data used to initialize ghost entities

Ghost Type values:

  - 0: Normal Ghost
  - 1: Dashing Ghost
  - 2: Lobber Ghost

-}
type alias GhostInitData =
    { id : Int
    , gtype : Int
    , position : Vec.Vec
    }


{-| Messages for umbrella component communication
-}
type UmbrellaMsg
    = UmbrellaInitMsg InitData
    | GenGhostMsg GhostInitData
    | NullUmbrellaMsg


{-| Configuration settings for umbrella component behavior

Contains all the gameplay parameters like size, detection distance,
attack properties, bullet properties, and status effect settings.

-}
uConfig :
    { size : Vec.Vec
    , genGhostGap : Float
    , detectDistance : Float
    , attackFrames : Int
    , touchAttack : Int
    , maxhealthPoint : Int
    , assumeScreenHalfSize : Float
    , bulletSize : Vec.Vec
    , bulletVelocity : Float
    , shootCooldown : Float
    , slowDownPercent : Float
    , slowDownDuration : Float
    }
uConfig =
    { size = Vec.genVec 200 400
    , genGhostGap = 5.0
    , detectDistance = 850.0
    , attackFrames = 100
    , touchAttack = 30
    , maxhealthPoint = 9999
    , assumeScreenHalfSize = 2000.0
    , bulletSize = Vec.genVec 20 20
    , bulletVelocity = 300
    , shootCooldown = 2.0
    , slowDownPercent = 0.5
    , slowDownDuration = 5.0
    }
