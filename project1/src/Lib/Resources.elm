module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)


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
    let
        listOfLogoTextures =
            [ ( "logo", TextureRes "assets/images/logo.png" Nothing )
            , ( "logo1", TextureRes "assets/images/logo1.png" Nothing )
            , ( "logo3", TextureRes "assets/images/logo3.1.png" Nothing )
            ]

        listOfScriptTextures =
            [ ( "script1", TextureRes "assets/images/1.jpg" Nothing )
            , ( "script2", TextureRes "assets/images/2.jpg" Nothing )
            , ( "script3", TextureRes "assets/images/3.jpg" Nothing )
            , ( "script4", TextureRes "assets/images/4.jpg" Nothing )
            , ( "script5", TextureRes "assets/images/5.jpg" Nothing )
            ]

        listOfMenuTextures =
            [ ( "menu1", TextureRes "assets/images/menu1.jpeg" Nothing )
            , ( "menu2", TextureRes "assets/images/menu2.jpeg" Nothing )
            , ( "menu3", TextureRes "assets/images/menu3.jpeg" Nothing )
            , ( "menu4", TextureRes "assets/images/menu4.jpeg" Nothing )
            , ( "menu5", TextureRes "assets/images/menu5.jpeg" Nothing )
            , ( "menu6", TextureRes "assets/images/menu6.jpeg" Nothing )
            ]

        listOfResultTextures =
            [ ( "result", TextureRes "assets/images/result.jpg" Nothing ) ]
    in
    listOfLogoTextures
        ++ listOfScriptTextures
        ++ listOfMenuTextures
        ++ listOfResultTextures



-- [ ( "logo", TextureRes "assets/images/logo.png" Nothing )
-- , ( "logo1", TextureRes "assets/images/logo1.png" Nothing )
-- , ( "logo3", TextureRes "assets/images/logo3.1.png" Nothing )
-- , ( "script1", TextureRes "assets/images/1.jpg" Nothing )
-- , ( "script2", TextureRes "assets/images/2.jpg" Nothing )
-- , ( "script3", TextureRes "assets/images/3.jpg" Nothing )
-- , ( "script4", TextureRes "assets/images/4.jpg" Nothing )
-- , ( "script5", TextureRes "assets/images/5.jpg" Nothing )
-- , ( "menu1", TextureRes "assets/images/menu1.jpeg" Nothing )
-- , ( "menu2", TextureRes "assets/images/menu2.jpeg" Nothing )
-- , ( "menu3", TextureRes "assets/images/menu3.jpeg" Nothing )
-- , ( "menu4", TextureRes "assets/images/menu4.jpeg" Nothing )
-- , ( "menu5", TextureRes "assets/images/menu5.jpeg" Nothing )
-- , ( "menu6", TextureRes "assets/images/menu6.jpeg" Nothing )
-- , ( "result", TextureRes "assets/images/result.jpg" Nothing )
-- ]


{-| All audio assets.

The format is similar to `allTexture`.

Example:

        [ ( "test", AudioRes "assets/test.ogg" )
        ]

-}
allAudio : ResourceDefs
allAudio =
    [ ( "default", AudioRes "assets/audio/part1.mp3" ) ]


{-| All fonts.

Example:

        [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
        ]

-}
allFont : ResourceDefs
allFont =
    []


{-| All programs.

Example:

        [ ( "test", ProgramRes myprogram )
        ]

-}
allProgram : ResourceDefs
allProgram =
    []
