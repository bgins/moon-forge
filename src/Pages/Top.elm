module Pages.Top exposing (Model, Msg, Params, page)

import Browser.Navigation exposing (Key)
import Element exposing (..)
import Element.Background as Background
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
    { title = "Moon Forge"
    , body =
        [ column [ centerX, width (px 600), paddingXY 0 30, spacing 60 ]
            [ column
                [ width fill, spacing 15 ]
                [ paragraph
                    [ Font.center
                    , Font.family Fonts.cinzel
                    , Font.size 36
                    ]
                    [ text "A Song of Moons" ]
                , paragraph
                    [ Font.family Fonts.quattrocento
                    , Font.size 20
                    ]
                    [ text
                        """Moon Forge is a playground for lunar instruments.
                        We currently have one moon and are building more.
                        """
                    ]
                , paragraph
                    [ Font.family Fonts.quattrocento
                    , Font.size 20
                    ]
                    [ text
                        """
                        You play them on your keyboard using the letter keys,
                        number keys, and sometimes symbol keys. You can also
                        play using a MIDI controller.
                        """
                    ]
                ]
            , column [ width fill, spacing 15 ]
                [ paragraph
                    [ Font.center
                    , Font.family Fonts.cinzel
                    , Font.size 36
                    ]
                    [ text "Select an Instrument" ]
                , link
                    [ centerX
                    , width fill
                    , height (px 50)
                    , Background.color Colors.lightestGrey
                    , Border.color Colors.darkestGrey
                    , Border.rounded 7
                    , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
                    , Font.color Colors.darkestGrey
                    , Font.family Fonts.cinzel
                    , Font.size 24
                    , mouseOver
                        [ Border.color (rgb255 80 80 80)
                        , Border.shadow
                            { offset = ( 0, 0 )
                            , size = 1
                            , blur = 4
                            , color = rgb255 120 120 150
                            }
                        ]
                    ]
                    { url = Route.toString Route.Luna
                    , label =
                        row
                            [ width fill
                            , centerX
                            ]
                            [ el
                                [ centerX
                                , paddingXY 35 2
                                , inFront <|
                                    el
                                        [ paddingXY 6 3
                                        , alignRight
                                        , Background.color Colors.lightBlue
                                        , Border.rounded 15
                                        , Font.family Fonts.quattrocento
                                        , Font.size 10
                                        ]
                                        (text "Beta")
                                ]
                                (text "LUNA")
                            ]
                    }
                ]
            , column
                [ width fill, spacing 15 ]
                [ paragraph
                    [ Font.center
                    , Font.family Fonts.cinzel
                    , Font.size 36
                    ]
                    [ text "Proudly 0data"
                    ]
                , paragraph
                    [ Font.family Fonts.quattrocento
                    , Font.size 20
                    ]
                    [ text "Moon Forge is proud to be part of the "
                    , newTabLink
                        [ Font.color Colors.lightPurple
                        , Font.bold
                        , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
                        , Border.color Colors.darkGrey
                        , mouseOver
                            [ Border.color Colors.lightPurple
                            ]
                        ]
                        { url = "https://ring.0data.app/", label = text "0data Doorless Appring" }
                    , text ". 0data apps keep your data under your control. Visit a "
                    , newTabLink
                        [ Font.color Colors.lightPurple
                        , Font.bold
                        , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
                        , Border.color Colors.darkGrey
                        , mouseOver
                            [ Border.color Colors.lightPurple
                            ]
                        ]
                        { url = "https://ring.0data.app/#random", label = text "random site " }
                    , text "in the ring!"
                    ]
                ]
            ]
        ]
    }
