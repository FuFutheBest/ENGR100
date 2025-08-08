module SceneProtos.GameProto.Components.ComponentBase exposing
    ( ComponentMsg(..), ComponentTarget, BaseData
    , emptyBaseData
    )

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData
@docs emptyBaseData

-}

import Lib.Utils.Vec as Vec
import SceneProtos.GameProto.Components.Character.Init as CharacterInit
import SceneProtos.GameProto.Components.Chest.Init as ChestInit
import SceneProtos.GameProto.Components.Dialogue.Init as DialogueInit
import SceneProtos.GameProto.Components.Door.Init as DoorInit
import SceneProtos.GameProto.Components.Ghosts.Init as GhostsInit
import SceneProtos.GameProto.Components.Key.Init as KeyInit
import SceneProtos.GameProto.Components.Mushrooms.Init as MushroomsInit
import SceneProtos.GameProto.Components.ParGen.Init as ParGenInit
import SceneProtos.GameProto.Components.Particles.Init as ParticlesInit
import SceneProtos.GameProto.Components.Umbrella.Init as UmbrellaInit


{-| Component message
-}
type ComponentMsg
    = CharacterMsg CharacterInit.CharacterMsg
    | GhostsMsg GhostsInit.GhostsMsg
    | ParGenMsg ParGenInit.ParGenMsg
    | ParticlesMsg ParticlesInit.ParticlesMsg
    | DialogueMsg DialogueInit.DialogueMsg
    | CharacterHP Float
    | CharacterMP Float
    | SwitchWeaponMsg String
    | KeyMsg KeyInit.KeyMsg
    | MushroomMsg MushroomsInit.MushroomMsg
    | DoorMsg DoorInit.DoorMsg
    | ChestMsg ChestInit.ChestMsg
    | UmbrellaMsg UmbrellaInit.UmbrellaMsg
    | NullComponentMsg


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    { id : Int
    , ty : String
    , position : Vec.Vec
    , size : Vec.Vec -- x for width, y for height
    , alive : Bool
    }


{-| Empty base data for components
-}
emptyBaseData : BaseData
emptyBaseData =
    { id = 0
    , ty = ""
    , position = { x = 0, y = 0 }
    , size = { x = 0, y = 0 }
    , alive = False
    }
