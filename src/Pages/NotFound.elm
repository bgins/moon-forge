module Pages.NotFound exposing (Model, Msg, Params, page)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import UI.Colors as Colors
import UI.Fonts as Fonts


type alias Params =
    ()


type alias Model =
    Url Params


type alias Msg =
    Never


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }



-- VIEW


view : Url Params -> Document Msg
view { params } =
    { title = "404"
    , body =
        [ column
            [ width (px 500)
            , centerX
            , spacing 30
            , paddingXY 0 30
            ]
            [ paragraph
                [ spacing 8
                , paddingXY 15 0
                , Font.family Fonts.quattrocento
                , Font.italic
                , Font.size 24
                ]
                [ text
                    """
                    In the frigid cold of space, I sat upon my rock
                    and pondered the harmonies of dusty stars
                    that sang beyond the reckoning of my mind.
                    """
                ]
            , row []
                [ image
                    []
                    { src = "../public/images/404.jpg"
                    , description = "Traveller gazing out to the stars."
                    }
                ]
            , link
                [ centerX
                , Font.size 24
                , Font.color Colors.lightPurple
                , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
                , Border.color Colors.darkGrey
                , mouseOver [ Border.color Colors.lightPurple ]
                ]
                { url = Route.toString Route.Top
                , label = text "Return to the main menu"
                }
            ]
        ]
    }
