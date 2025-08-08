module SceneProtos.GameProto.Components.Dialogue.Init exposing
    ( InitData
    , DialogueMsg(..)
    )

{-| This library contains the message type used by the Dialogue component and
initData type used to intialize dialogues.


# Definition

@docs InitData

The data type used in the DialogueInitMsg.

  - `id`: the id of the dialogue component
  - `content`: a list of `Dialogues`, storing the content os a certain dialogue
  - `pos` and `size`: represents the position and size of the box that triggers the dialogue once the player walks in

@docs DialogueMsg

Possible messages used that can be passed to Dialogue component.

  - `DialogueInitMsg`: Msg used to initialize the component
  - `TriggerDialogueMsg`: Contains a `Vec` type storing the current position of the player, used to trigger the dialogue's box
  - `NullDialogueMsg`: Defaulut null msg.

-}

import Lib.Utils.Dialogue exposing (Dialogue, DialogueCharacterType)
import Lib.Utils.Vec as Vec


{-| Possible messages used that can be passed to Dialogue component.
-}
type DialogueMsg
    = DialogueInitMsg InitData
    | TriggerDialogueMsg Vec.Vec
    | NullDialogueMsg


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , content : List Dialogue
    , pos : Vec.Vec
    , size : Vec.Vec
    }
