module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation exposing (Key)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import UI.Colors as Colors
import UI.Fonts as Fonts
import Url exposing (Url)



-- INIT


type alias Flags =
    ()


type alias Model =
    { url : Url
    , key : Key
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model url key
    , Cmd.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ column
            [ spacing 20
            , height fill
            , width fill
            , Background.color Colors.darkGrey
            , Font.color (rgb 1 1 1)
            ]
            [ row
                [ width fill
                , paddingEach { bottom = 10, left = 20, right = 20, top = 20 }
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color Colors.darkestGrey
                ]
                [ column
                    [ alignLeft ]
                    [ link [ Font.family Fonts.cinzel, Font.size 36 ] { url = Route.toString Route.Top, label = text "Moon Forge" } ]
                , row
                    [ alignRight, spacing 20 ]
                    [ link [ Font.family Fonts.quattrocento ] { url = Route.toString Route.Luna, label = text "Luna" } ]
                ]
            , column [ height fill, width fill, paddingXY 20 0 ] page.body
            ]
        ]
    }
