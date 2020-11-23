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
import Creator exposing (Creator)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Events exposing (onMouseEnter)
import Json.Encode as Encode exposing (Value)
import Patch.Metadata exposing (PatchMetadata)
import Ports
import Session exposing (Session)
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
    , session : Session
    , patches : List PatchMetadata
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model url key Session.loading []
    , Cmd.none
    )



-- UPDATE


type Msg
    = GotSession Session
    | GotPatches (List PatchMetadata)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }
            , Cmd.none
            )

        GotPatches patches ->
            ( { model | patches = patches }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession
        , Ports.gotPatches GotPatches
        ]



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
                    [ centerX
                    , mouseOver
                        [ Font.shadow
                            { offset = ( 0, 0 )
                            , blur = 6
                            , color = rgb255 150 150 180
                            }
                        ]
                    ]
                    [ link [ Font.family Fonts.cinzel, Font.size 36 ] { url = Route.toString Route.Top, label = text "Moon Forge" } ]
                ]
            , column [ height fill, width fill, paddingXY 20 0 ] page.body
            ]
        ]
    }
