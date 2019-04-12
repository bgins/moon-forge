module Main exposing (Document, Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Fonts
import Html exposing (Html)
import Html.Attributes exposing (title)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }



-- MODEL


type alias Model =
    { osc : Oscillator
    , ampEnvAttack : Float
    , ampEnvDecay : Float
    , ampEnvSustain : Float
    , ampEnvRelease : Float
    , filter : Filter
    , filterFreq : Float
    , filterQ : Float
    , filterEnvAttack : Float
    , filterEnvDecay : Float
    , filterEnvSustain : Float
    , filterEnvRelease : Float
    , gain : Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Sine 0 10 90 10 LPF 100 1 0 10 90 10 50, Cmd.none )


type Oscillator
    = Sine
    | Square
    | Triangle
    | Sawtooth


oscToString : Oscillator -> String
oscToString osc =
    case osc of
        Sine ->
            "sine"

        Square ->
            "square"

        Triangle ->
            "triangle"

        Sawtooth ->
            "sawtooth"


type Filter
    = LPF
    | HPF
    | BPF
    | Notch


filterToString : Filter -> String
filterToString filter =
    case filter of
        LPF ->
            "LPF"

        HPF ->
            "HPF"

        BPF ->
            "BPF"

        Notch ->
            "Notch"



-- UPDATE


type Msg
    = Nop
    | ToggleOscillator Oscillator
    | AdjustAmpEnvAttack Float
    | AdjustAmpEnvDecay Float
    | AdjustAmpEnvSustain Float
    | AdjustAmpEnvRelease Float
    | ToggleFilter Filter
    | AdjustFilterFreq Float
    | AdjustFilterQ Float
    | AdjustFilterEnvAttack Float
    | AdjustFilterEnvDecay Float
    | AdjustFilterEnvSustain Float
    | AdjustFilterEnvRelease Float
    | AdjustGain Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nop ->
            ( model, Cmd.none )

        ToggleOscillator selectedOsc ->
            ( { model | osc = selectedOsc }
            , Cmd.none
            )

        AdjustAmpEnvAttack newVal ->
            ( { model | ampEnvAttack = newVal }
            , Cmd.none
            )

        AdjustAmpEnvDecay newVal ->
            ( { model | ampEnvDecay = newVal }
            , Cmd.none
            )

        AdjustAmpEnvSustain newVal ->
            ( { model | ampEnvSustain = newVal }
            , Cmd.none
            )

        AdjustAmpEnvRelease newVal ->
            ( { model | ampEnvRelease = newVal }
            , Cmd.none
            )

        ToggleFilter selectedFilter ->
            ( { model | filter = selectedFilter }
            , Cmd.none
            )

        AdjustFilterFreq newVal ->
            ( { model | filterFreq = newVal }
            , Cmd.none
            )

        AdjustFilterQ newVal ->
            ( { model | filterQ = newVal }
            , Cmd.none
            )

        AdjustFilterEnvAttack newVal ->
            ( { model | filterEnvAttack = newVal }
            , Cmd.none
            )

        AdjustFilterEnvDecay newVal ->
            ( { model | filterEnvDecay = newVal }
            , Cmd.none
            )

        AdjustFilterEnvSustain newVal ->
            ( { model | filterEnvSustain = newVal }
            , Cmd.none
            )

        AdjustFilterEnvRelease newVal ->
            ( { model | filterEnvRelease = newVal }
            , Cmd.none
            )

        AdjustGain newVal ->
            ( { model | gain = newVal }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Moon Forge"
    , body =
        [ layout
            [ Background.color (rgba 0.16 0.16 0.16 1)
            , Font.color (rgba 1 1 1 1)
            ]
          <|
            column [ width fill, centerX ]
                [ viewNav
                , viewBody model
                ]
        ]
    }


viewNav : Element Msg
viewNav =
    row
        [ width fill
        , paddingXY 0 15
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color (rgba 0.11 0.12 0.14 1)
        ]
        [ column [ centerX, width (px 800) ]
            [ row [ width fill ]
                [ column [ centerX, Font.family Fonts.cinzelFont, Font.size 36 ]
                    [ text "Moon Forge"
                    ]
                ]
            ]
        ]


viewBody : Model -> Element Msg
viewBody model =
    row
        [ width fill
        , paddingXY 0 30
        ]
        [ viewInstrument model
        ]


viewInstrument : Model -> Element Msg
viewInstrument model =
    column [ centerX ]
        [ row
            [ height (px 173)
            , width fill
            , paddingXY 10 5
            , Background.color (rgba 0.95 0.95 0.95 0.9)
            , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
            , Border.color (rgba 0.11 0.12 0.14 1)
            , Border.rounded 7
            , Font.color (rgba 0.11 0.12 0.14 1)
            , Font.family Fonts.quattrocentoFont
            , Font.size 12
            ]
            [ column [ width fill, height fill ]
                [ viewInstrumentName
                , viewPanels model
                ]
            ]
        ]


viewInstrumentName : Element Msg
viewInstrumentName =
    row
        [ height (px 30)
        , width fill
        , Font.family Fonts.cinzelFont
        , Font.size 24
        ]
        [ text "LUNA" ]


viewPanels : Model -> Element Msg
viewPanels model =
    row
        [ height fill
        , width fill
        , paddingXY 5 3
        , spacing 5
        ]
        [ viewOscillator model
        , viewAmplitudeEnvelope model
        , viewFilter model
        , viewFilterEnvelope model
        , viewGain model
        ]


viewOscillator : Model -> Element Msg
viewOscillator model =
    column [ height fill, spacing 5 ]
        [ row panelStyle [ oscButtonGroup model ]
        , row [ centerX ] [ text "Osc" ]
        ]


viewAmplitudeEnvelope : Model -> Element Msg
viewAmplitudeEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup
                [ slider "A" ( 0, 100 ) model.ampEnvAttack AdjustAmpEnvAttack
                , slider "D" ( 0, 100 ) model.ampEnvDecay AdjustAmpEnvDecay
                , slider "S" ( 0, 100 ) model.ampEnvSustain AdjustAmpEnvSustain
                , slider "R" ( 0, 100 ) model.ampEnvRelease AdjustAmpEnvRelease
                ]
            ]
        , row [ centerX ] [ text "Amplitude Envelope" ]
        ]


viewFilter : Model -> Element Msg
viewFilter model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ filterButtonGroup model
            , spacer
            , sliderGroup
                [ slider "Freq" ( 0, 100 ) model.filterFreq AdjustFilterFreq
                , slider "Q" ( 0, 100 ) model.filterQ AdjustFilterQ
                ]
            ]
        , row [ centerX ] [ text "Filter" ]
        ]


viewFilterEnvelope : Model -> Element Msg
viewFilterEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup
                [ slider "A" ( 0, 100 ) model.filterEnvAttack AdjustFilterEnvAttack
                , slider "D" ( 0, 100 ) model.filterEnvDecay AdjustFilterEnvDecay
                , slider "S" ( 0, 100 ) model.filterEnvSustain AdjustFilterEnvSustain
                , slider "R" ( 0, 100 ) model.filterEnvRelease AdjustFilterEnvRelease
                ]
            ]
        , row [ centerX ] [ text "Filter Envelope" ]
        ]


viewGain : Model -> Element Msg
viewGain model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup [ slider "" ( 0, 100 ) model.gain AdjustGain ] ]
        , row [ centerX ] [ text "Gain" ]
        ]



-- BUTTON GROUPS


oscButtonGroup : Model -> Element Msg
oscButtonGroup model =
    Input.radio
        [ width fill, centerX ]
        { onChange = \choice -> ToggleOscillator choice
        , options =
            [ Input.optionWith Sine <| verticalSvgButton <| oscToString Sine
            , Input.optionWith Square <| verticalSvgButton <| oscToString Square
            , Input.optionWith Triangle <| verticalSvgButton <| oscToString Triangle
            , Input.optionWith Sawtooth <| verticalSvgButton <| oscToString Sawtooth
            ]
        , selected = Just model.osc
        , label = Input.labelHidden "Oscillator selection"
        }


filterButtonGroup : Model -> Element Msg
filterButtonGroup model =
    Input.radio
        [ width fill, centerX ]
        { onChange = \choice -> ToggleFilter choice
        , options =
            [ Input.optionWith LPF <| verticalButton <| filterToString LPF
            , Input.optionWith HPF <| verticalButton <| filterToString HPF
            , Input.optionWith BPF <| verticalButton <| filterToString BPF
            , Input.optionWith Notch <| verticalButton <| filterToString Notch
            ]
        , selected = Just model.filter
        , label = Input.labelHidden "Filter selection"
        }


verticalButton : ButtonLabel -> (Input.OptionState -> Element Msg)
verticalButton label =
    \optionState ->
        row
            [ width fill
            , paddingXY 3 7
            , height fill
            , Border.widthEach { bottom = 0, left = 2, right = 0, top = 0 }
            , Border.color (rgba 0.75 0.75 0.75 1)
            , Border.rounded 1
            , case optionState of
                Input.Selected ->
                    -- Border.color (rgba 0.788 0.486 0.31 1)
                    Border.color (rgba 0.5 0.5 0.7 1)

                _ ->
                    Font.regular
            ]
        <|
            [ text label ]


verticalSvgButton : ButtonLabel -> (Input.OptionState -> Element Msg)
verticalSvgButton label =
    \optionState ->
        row
            [ width fill
            , paddingXY 3 3
            , height fill
            , Border.widthEach { bottom = 0, left = 2, right = 0, top = 0 }
            , Border.color (rgba 0.75 0.75 0.75 1)
            , Border.rounded 1
            , case optionState of
                Input.Selected ->
                    Border.color (rgba 0.5 0.5 0.7 1)

                _ ->
                    Font.regular
            ]
        <|
            [ image [] { src = "./assets/" ++ label ++ ".svg", description = label } ]


type alias ButtonLabel =
    String



-- SLIDERS


type alias SliderLabel =
    String


type alias SliderRange =
    ( Float, Float )


type alias SliderValue =
    Float


sliderGroup : List (Element Msg) -> Element Msg
sliderGroup sliders =
    column [ height fill, paddingXY 4 4 ]
        [ row [ height fill ] sliders
        ]


slider : SliderLabel -> SliderRange -> SliderValue -> (Float -> Msg) -> Element Msg
slider label ( min, max ) sliderValue adjustValue =
    Input.slider
        [ height fill
        , width (px 30)
        , behindContent
            (el
                [ width (px 1)
                , height fill
                , centerX
                , Background.color (rgba 0.5 0.5 0.5 1)
                , Border.rounded 2
                ]
                none
            )
        ]
        { onChange = \newVal -> adjustValue newVal
        , label =
            Input.labelBelow
                [ centerX

                -- , Element.htmlAttribute (Html.Attributes.title "some tooltip")
                ]
                (text label)
        , min = min
        , max = max
        , step = Nothing
        , value = sliderValue
        , thumb =
            sliderThumb
        }


sliderThumb : Input.Thumb
sliderThumb =
    Input.thumb
        [ Element.width (Element.px 16)
        , Element.height (Element.px 6)
        , Border.width 1
        , Border.color (rgba 0.9 0.9 0.9 1)
        , Background.color (rgba 0.11 0.12 0.14 1)
        , Border.rounded 2
        ]



-- SPACER


spacer : Element Msg
spacer =
    column [ height fill, paddingXY 3 6 ]
        [ row
            [ height fill
            , Border.widthEach { bottom = 0, left = 1, right = 0, top = 0 }
            , Border.color (rgba 0.8 0.8 0.8 1)
            ]
            [ el [] none ]
        ]



-- STYLES


panelStyle : List (Attribute msg)
panelStyle =
    [ width fill
    , height fill
    , Border.width 1
    , Border.color (rgba 0.8 0.8 0.8 1)
    , Border.rounded 2
    ]
