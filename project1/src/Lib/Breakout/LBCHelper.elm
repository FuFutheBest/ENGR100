module Lib.Breakout.LBCHelper exposing (l2BricksTypes, l3BricksTypes)

-- [ 1, 10, 7, 0, 5, 6, 10, 2, 1, 2, 0, 7, 5, 6, 1, 10, 1, 7, 3, 4, 0, 6, 2, 10,
--          1, 0, 3, 4, 7, 6, 10, 3, 10, 2, 3, 0, 5, 6, 4, 5, 7, 2, 3, 4, 7, 0, 6, 10,
--          1, 2, 3, 4, 5, 6, 7, 1 ]


l21 : List Int
l21 =
    [ 1, 10, 7, 0 ]


l22 : List Int
l22 =
    [ 5, 6, 10, 2 ]


l23 : List Int
l23 =
    [ 1, 2, 0, 7 ]


l24 : List Int
l24 =
    [ 5, 6, 1, 10 ]


l25 : List Int
l25 =
    [ 1, 7, 3, 4 ]


l26 : List Int
l26 =
    [ 0, 6, 2, 10 ]


l27 : List Int
l27 =
    [ 1, 0, 3, 4 ]


l28 : List Int
l28 =
    [ 7, 6, 10, 3 ]


l29 : List Int
l29 =
    [ 10, 2, 3, 0 ]


l210 : List Int
l210 =
    [ 5, 6, 4, 5 ]


l211 : List Int
l211 =
    [ 7, 2, 3, 4 ]


l212 : List Int
l212 =
    [ 7, 0, 6, 10 ]


l213 : List Int
l213 =
    [ 1, 2, 3, 4 ]


l214 : List Int
l214 =
    [ 5, 6, 7, 1 ]


l2BricksTypes : List Int
l2BricksTypes =
    l21
        ++ l22
        ++ l23
        ++ l24
        ++ l25
        ++ l26
        ++ l27
        ++ l28
        ++ l29
        ++ l210
        ++ l211
        ++ l212
        ++ l213
        ++ l214



-- [ 3, 7, 1, 10, 5, 0, 8, 2, 6, 4, 9, 3, 2, 1, 0, 7,
--          6, 5, 8, 10, 4, 0, 3, 7, 9, 6, 1, 10, 5, 2, 4, 0,
--          9, 8, 6, 3, 7, 2, 10, 5, 1, 0, 8, 4, 9, 7, 6, 2,
--          3, 10, 1, 5, 0, 8, 4, 6 ]


l31 : List Int
l31 =
    [ 3, 7, 1, 10 ]


l32 : List Int
l32 =
    [ 5, 0, 8, 2 ]


l33 : List Int
l33 =
    [ 6, 4, 9, 3 ]


l34 : List Int
l34 =
    [ 2, 1, 0, 7 ]


l35 : List Int
l35 =
    [ 6, 5, 8, 10 ]


l36 : List Int
l36 =
    [ 4, 0, 3, 7 ]


l37 : List Int
l37 =
    [ 9, 6, 1, 10 ]


l38 : List Int
l38 =
    [ 5, 2, 4, 0 ]


l39 : List Int
l39 =
    [ 9, 8, 6, 3 ]


l310 : List Int
l310 =
    [ 7, 2, 10, 5 ]


l311 : List Int
l311 =
    [ 1, 0, 8, 4 ]


l312 : List Int
l312 =
    [ 9, 7, 6, 2 ]


l313 : List Int
l313 =
    [ 3, 10, 1, 5 ]


l314 : List Int
l314 =
    [ 0, 8, 4, 6 ]


l3BricksTypes : List Int
l3BricksTypes =
    l31
        ++ l32
        ++ l33
        ++ l34
        ++ l35
        ++ l36
        ++ l37
        ++ l38
        ++ l39
        ++ l310
        ++ l311
        ++ l312
        ++ l313
        ++ l314
