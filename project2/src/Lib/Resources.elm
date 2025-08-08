module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

import Lib.SubResources exposing (chestTexture, dialogueTexture, doorTexture, skillsTexture1, skillsTexture2)
import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)
import Pixels exposing (pixel)
import REGL exposing (TextureMagOption(..), TextureMinOption(..), TextureOptions)


pixelResourceDef : Maybe TextureOptions
pixelResourceDef =
    Just { mag = Just MagNearest, min = Just MinNearest, crop = Nothing }


{-| Resources
-}
resources : ResourceDefs
resources =
    allTexture ++ allAudio ++ allFont ++ allProgram


{-| allTexture

A list of all the textures.

Add your textures here. Don't worry if your list is too long.

Example:

        [ ( "ball", TextureRes "assets/img/ball.png" Nothing )
        , ( "car", TextureRes "assets/img/car.jpg" Nothing )
        ]

-}
allTexture : ResourceDefs
allTexture =
    allCharacterTexture
        ++ allGhostTexture
        ++ chargeTexture
        ++ uiTexture
        ++ mushroomTexture
        ++ keyTexture1
        ++ keyTexture2
        ++ doorTexture
        ++ chestTexture
        ++ skillsTexture1
        ++ skillsTexture2
        ++ dialogueTexture
        ++ phoneTexture
        ++ houseTexture
        ++ lolipopstudios
        ++ doorTexture


allCharacterTexture : ResourceDefs
allCharacterTexture =
    let
        t1 =
            [ ( "yidle0", TextureRes "assets/char/charlie/yidle0.png" pixelResourceDef )
            , ( "yidle1", TextureRes "assets/char/charlie/yidle1.png" pixelResourceDef )
            , ( "yidle2", TextureRes "assets/char/charlie/yidle2.png" pixelResourceDef )
            , ( "yidle3", TextureRes "assets/char/charlie/yidle3.png" pixelResourceDef )
            , ( "ywalk0", TextureRes "assets/char/charlie/ywalk0.png" pixelResourceDef )
            , ( "ywalk1", TextureRes "assets/char/charlie/ywalk1.png" pixelResourceDef )
            ]

        t2 =
            [ ( "ywalk2", TextureRes "assets/char/charlie/ywalk2.png" pixelResourceDef )
            , ( "ywalk3", TextureRes "assets/char/charlie/ywalk3.png" pixelResourceDef )
            , ( "bidle0", TextureRes "assets/char/charlie/bidle0.png" pixelResourceDef )
            , ( "bidle1", TextureRes "assets/char/charlie/bidle1.png" pixelResourceDef )
            , ( "bidle2", TextureRes "assets/char/charlie/bidle2.png" pixelResourceDef )
            , ( "bidle3", TextureRes "assets/char/charlie/bidle3.png" pixelResourceDef )
            ]

        t3 =
            [ ( "bwalk0", TextureRes "assets/char/charlie/bwalk0.png" pixelResourceDef )
            , ( "bwalk1", TextureRes "assets/char/charlie/bwalk1.png" pixelResourceDef )
            , ( "bwalk2", TextureRes "assets/char/charlie/bwalk2.png" pixelResourceDef )
            , ( "bwalk3", TextureRes "assets/char/charlie/bwalk3.png" pixelResourceDef )
            , ( "dead", TextureRes "assets/char/charlie/dead.png" pixelResourceDef )
            ]

        homepage =
            [ ( "gamelogo", TextureRes "assets/lolipop/ghostbust_hotline.png" Nothing )
            , ( "select", TextureRes "assets/lolipop/option_highlight.png" Nothing )
            ]
    in
    t1 ++ t2 ++ t3 ++ homepage


lolipopstudios : ResourceDefs
lolipopstudios =
    [ ( "ls", TextureRes "assets/lolipop/lolipopstudios.png" Nothing )
    , ( "ls2", TextureRes "assets/lolipop/lolipop@3x.png" Nothing )
    ]


houseTexture : ResourceDefs
houseTexture =
    [ ( "house0", TextureRes "assets/Intro/anim_house.png" pixelResourceDef )
    , ( "house1", TextureRes "assets/Intro/bland_house.png" pixelResourceDef )
    ]


phoneTexture : ResourceDefs
phoneTexture =
    let
        ringing =
            [ ( "ph1", TextureRes "assets/Intro/ph1.png" pixelResourceDef )
            , ( "ph2", TextureRes "assets/Intro/ph2.png" pixelResourceDef )
            , ( "ph3", TextureRes "assets/Intro/ph3.png" pixelResourceDef )
            , ( "ph4", TextureRes "assets/Intro/ph4.png" pixelResourceDef )
            ]

        idle =
            [ ( "pickup", TextureRes "assets/Intro/pickup.png" pixelResourceDef )
            , ( "dialogue_right", TextureRes "assets/Intro/dialogue_right.png" pixelResourceDef )
            , ( "dialogue_left", TextureRes "assets/Intro/dialogue_left.png" pixelResourceDef )
            ]
    in
    ringing ++ idle


allGhostTexture : ResourceDefs
allGhostTexture =
    let
        normalGhostTexture =
            [ ( "normal0", TextureRes "assets/char/ghosts/normal0.png" pixelResourceDef )
            , ( "normal1", TextureRes "assets/char/ghosts/normal1.png" pixelResourceDef )
            , ( "normal2", TextureRes "assets/char/ghosts/normal2.png" pixelResourceDef )
            ]

        lobberGhostTexture =
            [ ( "lobber0", TextureRes "assets/char/ghosts/lobber0.png" pixelResourceDef )
            , ( "lobber1", TextureRes "assets/char/ghosts/lobber1.png" pixelResourceDef )
            , ( "lobber2", TextureRes "assets/char/ghosts/lobber2.png" pixelResourceDef )
            ]

        dasherGhostTexture =
            [ ( "dash0", TextureRes "assets/char/ghosts/dash0.png" pixelResourceDef )
            , ( "dash1", TextureRes "assets/char/ghosts/dash1.png" pixelResourceDef )
            , ( "dash2", TextureRes "assets/char/ghosts/dash2.png" pixelResourceDef )
            , ( "dash_charge0", TextureRes "assets/char/ghosts/dash_charge0.png" pixelResourceDef )
            , ( "dash_charge1", TextureRes "assets/char/ghosts/dash_charge1.png" pixelResourceDef )
            , ( "dash_charge2", TextureRes "assets/char/ghosts/dash_charge2.png" pixelResourceDef )
            , ( "dash_charge3", TextureRes "assets/char/ghosts/dash_charge3.png" pixelResourceDef )
            , ( "dash_charge4", TextureRes "assets/char/ghosts/dash_charge4.png" pixelResourceDef )
            , ( "dash_charge5", TextureRes "assets/char/ghosts/dash_charge5.png" pixelResourceDef )
            , ( "dash_charge6", TextureRes "assets/char/ghosts/dash_charge6.png" pixelResourceDef )
            , ( "dash_charge7", TextureRes "assets/char/ghosts/dash_charge7.png" pixelResourceDef )
            ]

        lobberBulletsTexture =
            [ ( "lb0", TextureRes "assets/proj/lobber0.png" pixelResourceDef )
            , ( "lb1", TextureRes "assets/proj/lobber1.png" pixelResourceDef )
            , ( "lb2", TextureRes "assets/proj/lobber2.png" pixelResourceDef )
            ]

        umbrellaTexture =
            [ ( "u0", TextureRes "assets/char/boss/umbrella/F0.png" pixelResourceDef )
            , ( "u1", TextureRes "assets/char/boss/umbrella/F1.png" pixelResourceDef )
            , ( "u2", TextureRes "assets/char/boss/umbrella/F2.png" pixelResourceDef )
            , ( "u3", TextureRes "assets/char/boss/umbrella/F3.png" pixelResourceDef )
            , ( "u4", TextureRes "assets/char/boss/umbrella/F4.png" pixelResourceDef )
            , ( "u5", TextureRes "assets/char/boss/umbrella/F5.png" pixelResourceDef )
            , ( "ub0", TextureRes "assets/proj/F9.png" pixelResourceDef )
            , ( "ub1", TextureRes "assets/proj/F10.png" pixelResourceDef )
            , ( "ub2", TextureRes "assets/proj/F11.png" pixelResourceDef )
            ]

        monkTexture =
            [ ( "mf0", TextureRes "assets/char/boss/aghori_baba/float0.png" pixelResourceDef )
            , ( "mf1", TextureRes "assets/char/boss/aghori_baba/float1.png" pixelResourceDef )
            ]
    in
    normalGhostTexture ++ dasherGhostTexture ++ lobberGhostTexture ++ lobberBulletsTexture ++ umbrellaTexture ++ monkTexture


chargeTexture : ResourceDefs
chargeTexture =
    [ ( "charge0", TextureRes "assets/proj/charge0.png" pixelResourceDef )
    , ( "charge1", TextureRes "assets/proj/charge1.png" pixelResourceDef )
    , ( "charge2", TextureRes "assets/proj/charge2.png" pixelResourceDef )
    , ( "fired0", TextureRes "assets/proj/fired0.png" pixelResourceDef )
    , ( "fired1", TextureRes "assets/proj/fired1.png" pixelResourceDef )
    , ( "fired2", TextureRes "assets/proj/fired2.png" pixelResourceDef )
    , ( "gfloor", TextureRes "assets/tile/gfloor.png" pixelResourceDef )
    , ( "wall", TextureRes "assets/tile/gfloor_edge.png" pixelResourceDef )
    , ( "ptiles", TextureRes "assets/tile/gfloor_lolipop.png" pixelResourceDef )
    ]


uiTexture : ResourceDefs
uiTexture =
    [ ( "ui_b", TextureRes "assets/ui/ui_b.png" pixelResourceDef )
    , ( "ui_bg", TextureRes "assets/ui/ui_bg.png" pixelResourceDef )
    , ( "ui_hp", TextureRes "assets/ui/ui_hp.png" pixelResourceDef )
    , ( "ui_hpempty", TextureRes "assets/ui/ui_hpempty.png" pixelResourceDef )
    , ( "ui_hpfull", TextureRes "assets/ui/ui_hpfull.png" pixelResourceDef )
    , ( "ui_hpicon", TextureRes "assets/ui/ui_hpicon.png" pixelResourceDef )
    , ( "ui_mp", TextureRes "assets/ui/ui_mp.png" pixelResourceDef )
    , ( "ui_mpb", TextureRes "assets/ui/ui_mpb.png" pixelResourceDef )
    , ( "ui_mpempty", TextureRes "assets/ui/ui_mpempty.png" pixelResourceDef )
    , ( "ui_mpy", TextureRes "assets/ui/ui_mpy.png" pixelResourceDef )
    , ( "ui_y", TextureRes "assets/ui/ui_y.png" pixelResourceDef )
    ]


mushroomTexture : ResourceDefs
mushroomTexture =
    [ ( "M0", TextureRes "assets/mushrooms/F0.png" pixelResourceDef )
    , ( "M1", TextureRes "assets/mushrooms/F1.png" pixelResourceDef )
    , ( "M2", TextureRes "assets/mushrooms/F2.png" pixelResourceDef )
    , ( "M3", TextureRes "assets/mushrooms/F3.png" pixelResourceDef )
    , ( "M4", TextureRes "assets/mushrooms/F4.png" pixelResourceDef )
    , ( "M5", TextureRes "assets/mushrooms/F5.png" pixelResourceDef )
    , ( "M6", TextureRes "assets/mushrooms/F6.png" pixelResourceDef )
    , ( "M7", TextureRes "assets/mushrooms/F7.png" pixelResourceDef )
    , ( "M8", TextureRes "assets/mushrooms/F8.png" pixelResourceDef )
    , ( "M9", TextureRes "assets/mushrooms/F9.png" pixelResourceDef )
    ]


keyTexture1 : ResourceDefs
keyTexture1 =
    [ ( "K0", TextureRes "assets/key/F0.png" pixelResourceDef )
    , ( "K1", TextureRes "assets/key/F1.png" pixelResourceDef )
    , ( "K2", TextureRes "assets/key/F2.png" pixelResourceDef )
    , ( "K3", TextureRes "assets/key/F3.png" pixelResourceDef )
    , ( "K4", TextureRes "assets/key/F4.png" pixelResourceDef )
    , ( "K5", TextureRes "assets/key/F5.png" pixelResourceDef )
    ]


keyTexture2 : ResourceDefs
keyTexture2 =
    [ ( "K6", TextureRes "assets/key/F6.png" pixelResourceDef )
    , ( "K7", TextureRes "assets/key/F7.png" pixelResourceDef )
    , ( "K8", TextureRes "assets/key/F8.png" pixelResourceDef )
    , ( "K9", TextureRes "assets/key/F9.png" pixelResourceDef )
    , ( "K10", TextureRes "assets/key/F10.png" pixelResourceDef )
    , ( "K11", TextureRes "assets/key/F11.png" pixelResourceDef )
    ]


{-| All audio assets.

The format is similar to `allTexture`.

Example:

        [ ( "test", AudioRes "assets/test.ogg" )
        ]

-}
allAudio : ResourceDefs
allAudio =
    [ ( "home", AudioRes "assets/music/title.ogg" )
    , ( "scream", AudioRes "assets/music/pathetic.ogg" )
    , ( "umbrella", AudioRes "assets/music/umbrella.ogg" )
    ]


{-| All fonts.

Example:

        [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
        ]

-}
allFont : ResourceDefs
allFont =
    [ ( "Bebas", FontRes "assets/fonts/font_0.png" "assets/fonts/BebasNeue.json" )
    , ( "Garet", FontRes "assets/fonts/font_1.png" "assets/fonts/Garet-Book.json" )
    ]


{-| All programs.

Example:

        [ ( "test", ProgramRes myprogram )
        ]

-}
allProgram : ResourceDefs
allProgram =
    []
