module Fonts exposing (cinzelFont, quattrocentoFont)

import Element.Font as Font


cinzelFont : List Font.Font
cinzelFont =
    [ Font.external
        { url = "https://fonts.googleapis.com/css?family=Cinzel"
        , name = "Cinzel"
        }
    , Font.serif
    ]


quattrocentoFont : List Font.Font
quattrocentoFont =
    [ Font.external
        { url = "https://fonts.googleapis.com/css?family=Quattrocento+Sans"
        , name = "Quattrocento Sans"
        }
    , Font.sansSerif
    ]
