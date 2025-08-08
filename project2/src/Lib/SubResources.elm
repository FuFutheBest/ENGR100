module Lib.SubResources exposing (doorTexture, dialogueTexture, chestTexture, skillsTexture1, skillsTexture2)

{-| SubResources module

This module defines sub-resources used in the game, such as textures for doors, dialogue boxes, chests, and skills.
It provides a collection of texture definitions that can be used in various scenes or layers of the game.

@docs doorTexture, dialogueTexture, chestTexture, skillsTexture1, skillsTexture2

-}

import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)
import Pixels exposing (pixel)
import REGL exposing (TextureMagOption(..), TextureMinOption(..), TextureOptions)


pixelResourceDef : Maybe TextureOptions
pixelResourceDef =
    Just { mag = Just MagNearest, min = Just MinNearest, crop = Nothing }


{-| A resource definition for pixel textures.
-}
doorTexture : ResourceDefs
doorTexture =
    [ ( "D0", TextureRes "assets/door/D0.png" pixelResourceDef )
    , ( "D1", TextureRes "assets/door/D1.png" pixelResourceDef )
    , ( "D2", TextureRes "assets/door/D2.png" pixelResourceDef )
    , ( "D3", TextureRes "assets/door/D3.png" pixelResourceDef )
    , ( "D4", TextureRes "assets/door/D4.png" pixelResourceDef )
    , ( "D5", TextureRes "assets/door/D5.png" pixelResourceDef )
    ]


{-| A resource definition for pixel textures.
-}
dialogueTexture : ResourceDefs
dialogueTexture =
    [ ( "dia_bg", TextureRes "assets/ui/dialoguebox/bg.png" pixelResourceDef )
    , ( "dia_box", TextureRes "assets/ui/dialoguebox/box.png" pixelResourceDef )
    , ( "dia_c", TextureRes "assets/ui/dialoguebox/charlie.png" pixelResourceDef )
    , ( "dia_m", TextureRes "assets/ui/dialoguebox/mannie.png" pixelResourceDef )
    , ( "dia_a", TextureRes "assets/ui/dialoguebox/aghori.png" pixelResourceDef )
    ]


{-| A resource definition for pixel textures.
-}
chestTexture : ResourceDefs
chestTexture =
    [ ( "chest_open", TextureRes "assets/chest/chest_op.png" pixelResourceDef )
    , ( "chest_closed", TextureRes "assets/chest/chest_cl.png" pixelResourceDef )
    ]


{-| A resource definition for pixel textures.
-}
skillsTexture1 : ResourceDefs
skillsTexture1 =
    [ ( "invisible0", TextureRes "assets/skills/invisibility_1.png" pixelResourceDef )
    , ( "invisible1", TextureRes "assets/skills/invisibility_2.png" pixelResourceDef )
    , ( "invisible2", TextureRes "assets/skills/invisibility_3.png" pixelResourceDef )
    , ( "quick0", TextureRes "assets/skills/quickshot_1.png" pixelResourceDef )
    , ( "quick1", TextureRes "assets/skills/quickshot_2.png" pixelResourceDef )
    , ( "quick2", TextureRes "assets/skills/quickshot_3.png" pixelResourceDef )
    ]


{-| A resource definition for pixel textures.
-}
skillsTexture2 : ResourceDefs
skillsTexture2 =
    [ ( "resillence0", TextureRes "assets/skills/resillence_1.png" pixelResourceDef )
    , ( "resillence1", TextureRes "assets/skills/resillence_2.png" pixelResourceDef )
    , ( "resillence2", TextureRes "assets/skills/resillence_3.png" pixelResourceDef )
    , ( "emit0", TextureRes "assets/skills/e1.png" pixelResourceDef )
    , ( "emit1", TextureRes "assets/skills/e2.png" pixelResourceDef )
    , ( "emit2", TextureRes "assets/skills/e3.png" pixelResourceDef )
    ]
