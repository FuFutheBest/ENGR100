module Lib.Utils.Dialogue exposing (Dialogue, DialogueCharacterType(..), DialogueEvent)

{-|


# Dialogue Module

This module defines the structure for dialogue in the game, including the character type and the dialogue text.

@docs Dialogue, DialogueCharacterType, DialogueEvent

-}

import Lib.Utils.Vec as Vec


{-| The Dialogue type represents a piece of dialogue in the game.
-}
type alias Dialogue =
    { text : String
    , character : DialogueCharacterType
    }


{-| The DialogueCharacterType represents the type of character speaking the dialogue.
It can be one of several predefined characters in the game.
-}
type DialogueCharacterType
    = Charlie
    | Mannie
    | Aghori


{-| The DialogueEvent type represents an event that contains a list of dialogues
-}
type alias DialogueEvent =
    { dialogues : List Dialogue
    , positionLeftUp : Vec.Vec
    , positionRightDown : Vec.Vec
    , activated : Bool
    }
