module UI.Fonts exposing (cinzel, quattrocento)

import Element.Font as Font


cinzel : List Font.Font
cinzel =
    [ Font.external
        { url = "https://fonts.googleapis.com/css?family=Cinzel"
        , name = "Cinzel"
        }
    , Font.serif
    ]


quattrocento : List Font.Font
quattrocento =
    [ Font.external
        { url = "https://fonts.googleapis.com/css?family=Quattrocento+Sans"
        , name = "Quattrocento Sans"
        }
    , Font.sansSerif
    ]
