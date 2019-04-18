port module Main exposing (Document, Model, Msg(..), init, main, subscriptions, update, view)

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
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E



-- MAIN


main : Program Decode.Value Model Msg
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
    { oscillator : Oscillator
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
    , keyboardEnabled : Bool
    , midiEnabled : Bool
    , midiDevices : List String
    , selectedMidiDevice : String
    }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        audioParams =
            Decode.decodeValue decodeFlags flags
    in
    ( Model
        Sine
        0.5
        0.5
        0.1
        0.2
        LPF
        1000
        1
        0.1
        0.2
        0.5
        0.5
        0.3
        True
        False
        []
        "a"
    , Cmd.none
    )


type alias Flags =
    { audioParams : List String }


decodeFlags : Decode.Decoder Flags
decodeFlags =
    Decode.succeed Flags
        |> required "audioParams" (Decode.list Decode.string)


type Oscillator
    = Sine
    | Square
    | Triangle
    | Sawtooth


oscillatorToString : Oscillator -> String
oscillatorToString oscillator =
    case oscillator of
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
            "lowpass"

        HPF ->
            "highpass"

        BPF ->
            "bandpass"

        Notch ->
            "notch"



-- UPDATE


type Msg
    = ToggleOscillator Oscillator
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
    | ToggleKeyboard Bool
    | ToggleMidi Bool
    | SelectMidiDevice String
    | ReceiveMidiDevices (List String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOscillator selectedOscillator ->
            ( { model | oscillator = selectedOscillator }
            , adjustAudioParam "oscillatorType" (E.string <| oscillatorToString selectedOscillator)
            )

        AdjustAmpEnvAttack newVal ->
            ( { model | ampEnvAttack = newVal }
            , adjustAudioParam "ampEnvAttack" (E.float newVal)
            )

        AdjustAmpEnvDecay newVal ->
            ( { model | ampEnvDecay = newVal }
            , adjustAudioParam "ampEnvDecay" (E.float newVal)
            )

        AdjustAmpEnvSustain newVal ->
            ( { model | ampEnvSustain = newVal }
            , adjustAudioParam "ampEnvSustain" (E.float newVal)
            )

        AdjustAmpEnvRelease newVal ->
            ( { model | ampEnvRelease = newVal }
            , adjustAudioParam "ampEnvRelease" (E.float newVal)
            )

        ToggleFilter selectedFilter ->
            ( { model | filter = selectedFilter }
            , adjustAudioParam "filterType" (E.string <| filterToString selectedFilter)
            )

        AdjustFilterFreq newVal ->
            ( { model | filterFreq = newVal }
            , adjustAudioParam "filterFreq" (E.float newVal)
            )

        AdjustFilterQ newVal ->
            ( { model | filterQ = newVal }
            , adjustAudioParam "filterQ" (E.float newVal)
            )

        AdjustFilterEnvAttack newVal ->
            ( { model | filterEnvAttack = newVal }
            , adjustAudioParam "filterEnvAttack" (E.float newVal)
            )

        AdjustFilterEnvDecay newVal ->
            ( { model | filterEnvDecay = newVal }
            , adjustAudioParam "filterEnvDecay" (E.float newVal)
            )

        AdjustFilterEnvSustain newVal ->
            ( { model | filterEnvSustain = newVal }
            , adjustAudioParam "filterEnvSustain" (E.float newVal)
            )

        AdjustFilterEnvRelease newVal ->
            ( { model | filterEnvRelease = newVal }
            , adjustAudioParam "filterEnvRelease" (E.float newVal)
            )

        AdjustGain newVal ->
            ( { model | gain = newVal }
            , adjustAudioParam "masterGain" (E.float newVal)
            )

        ToggleKeyboard checked ->
            if checked then
                ( { model | keyboardEnabled = checked }
                , enableKeyboard ()
                )

            else
                ( { model | keyboardEnabled = checked }
                , disableKeyboard ()
                )

        ToggleMidi checked ->
            if checked then
                ( { model | midiEnabled = checked }
                , getMidiDevices ()
                )

            else
                ( { model | midiEnabled = checked, midiDevices = [] }
                , setMidiDevice ""
                )

        SelectMidiDevice newDevice ->
            ( { model | selectedMidiDevice = newDevice }
            , setMidiDevice newDevice
            )

        ReceiveMidiDevices newMidiDevices ->
            if List.isEmpty newMidiDevices then
                ( { model | midiDevices = [ "No Midi devices available" ] }
                , Cmd.none
                )

            else
                ( { model | midiDevices = newMidiDevices }
                , Cmd.none
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateMidiDevices ReceiveMidiDevices



-- PORTS


port updateAudioParam : E.Value -> Cmd msg


adjustAudioParam : String -> E.Value -> Cmd msg
adjustAudioParam name val =
    updateAudioParam <|
        E.object
            [ ( "name", E.string name )
            , ( "val", val )
            ]


port enableKeyboard : () -> Cmd msg


port disableKeyboard : () -> Cmd msg


port getMidiDevices : () -> Cmd msg


port setMidiDevice : String -> Cmd msg


port onMidiDevicesRequest : (E.Value -> msg) -> Sub msg


updateMidiDevices : (List String -> msg) -> Sub msg
updateMidiDevices toMsg =
    onMidiDevicesRequest <|
        \value ->
            toMsg <|
                case Decode.decodeValue decodeMidiDevices value of
                    Ok midiDevicesPortMessage ->
                        midiDevicesPortMessage.midiDevices

                    Err err ->
                        []


type alias MidiDevicesPortMessage =
    { midiDevices : List String }


decodeMidiDevices : Decode.Decoder MidiDevicesPortMessage
decodeMidiDevices =
    Decode.succeed MidiDevicesPortMessage
        |> required "midiDevices" (Decode.list Decode.string)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Moon Forge"
    , body =
        [ layout
            [ Background.color (rgba 0.16 0.16 0.16 1)
            , Font.color (rgba 1 1 1 1)
            , inFront <| viewNav
            ]
          <|
            column [ width fill, centerX ]
                [ viewNav
                , viewBody model
                ]
        ]
    }


viewFrame : Model -> Element Msg
viewFrame model =
    column [ width fill, height fill ]
        [ viewNav
        , viewGlobalControls model
        ]


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


viewGlobalControls : Model -> Element Msg
viewGlobalControls model =
    row [ height fill ]
        [ column
            [ height fill
            , width (px 200)
            , paddingXY 10 10
            , Background.color (rgba 0.16 0.16 0.16 1)
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color (rgba 0.11 0.12 0.14 1)
            , Font.family Fonts.quattrocentoFont
            , Font.size 14
            , spacing 5
            ]
            [ el
                [ paddingXY 0 5
                , Font.size 18
                ]
                (text "Controllers")
            , Input.checkbox [ paddingXY 10 0 ]
                { checked = model.keyboardEnabled
                , onChange = ToggleKeyboard
                , icon = controlsCheckbox
                , label = Input.labelRight [] (text "Keyboard")
                }
            , Input.checkbox [ paddingXY 10 0 ]
                { checked = model.midiEnabled
                , onChange = ToggleMidi
                , icon = controlsCheckbox
                , label = Input.labelRight [] (text "MIDI")
                }
            , controlButtonGroup SelectMidiDevice model.midiDevices model.selectedMidiDevice "Midi device selection"
            ]
        ]


viewBody : Model -> Element Msg
viewBody model =
    row
        [ width fill
        , paddingXY 0 30
        , inFront <| viewGlobalControls model
        ]
        [ column [ centerX, spacing 15 ]
            [ viewInstrument model
            ]
        ]


viewInstrument : Model -> Element Msg
viewInstrument model =
    row
        [ height (px 173)
        , width fill
        , centerX
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
        [ row panelStyle [ oscillatorButtonGroup model ]
        , row [ centerX ] [ text "Osc" ]
        ]


viewAmplitudeEnvelope : Model -> Element Msg
viewAmplitudeEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup
                [ slider "A" ( 0.0001, 1 ) model.ampEnvAttack AdjustAmpEnvAttack
                , slider "D" ( 0.0001, 1 ) model.ampEnvDecay AdjustAmpEnvDecay
                , slider "S" ( 0.0001, 1 ) model.ampEnvSustain AdjustAmpEnvSustain
                , slider "R" ( 0.0001, 2 ) model.ampEnvRelease AdjustAmpEnvRelease
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
                [ slider "Freq" ( 0, 20000 ) model.filterFreq AdjustFilterFreq
                , slider "Q" ( 0.0001, 50 ) model.filterQ AdjustFilterQ
                ]
            ]
        , row [ centerX ] [ text "Filter" ]
        ]


viewFilterEnvelope : Model -> Element Msg
viewFilterEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup
                [ slider "A" ( 0.0001, 1 ) model.filterEnvAttack AdjustFilterEnvAttack
                , slider "D" ( 0.0001, 1 ) model.filterEnvDecay AdjustFilterEnvDecay
                , slider "S" ( 0.0001, 1 ) model.filterEnvSustain AdjustFilterEnvSustain
                , slider "R" ( 0.0001, 2 ) model.filterEnvRelease AdjustFilterEnvRelease
                ]
            ]
        , row [ centerX ] [ text "Filter Envelope" ]
        ]


viewGain : Model -> Element Msg
viewGain model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ sliderGroup [ slider "" ( 0, 1 ) model.gain AdjustGain ] ]
        , row [ centerX ] [ text "Gain" ]
        ]



-- BUTTON GROUPS


controlButtonGroup : (String -> Msg) -> List String -> String -> String -> Element Msg
controlButtonGroup msg options selectedOption label =
    Input.radio
        [ width fill, centerX ]
        { onChange = \choice -> msg choice
        , options =
            List.map controlButton options
        , selected = Just selectedOption
        , label = Input.labelHidden label
        }


controlButton : String -> Input.Option String Msg
controlButton label =
    Input.optionWith label <|
        \optionState ->
            wrappedRow
                [ width fill
                , height fill
                , Font.size 12
                , case optionState of
                    Input.Selected ->
                        paddingXY 23 2

                    _ ->
                        paddingXY 31 2
                ]
            <|
                case optionState of
                    Input.Selected ->
                        [ text <| "• " ++ label ]

                    _ ->
                        [ text label ]


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
            [ Input.optionWith LPF <| verticalSvgButton <| filterToString LPF
            , Input.optionWith HPF <| verticalSvgButton <| filterToString HPF
            , Input.optionWith BPF <| verticalSvgButton <| filterToString BPF
            , Input.optionWith Notch <| verticalSvgButton <| filterToString Notch
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
            , Border.rounded 1
            , case optionState of
                Input.Selected ->
                    -- Border.color (rgba 0.788 0.486 0.31 1)
                    Border.color (rgba 0.5 0.5 0.7 1)

                _ ->
                    Border.color (rgba 0.75 0.75 0.75 1)
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
            , Border.rounded 1
            , case optionState of
                Input.Selected ->
                    Border.color (rgba 0.5 0.5 0.7 1)

                _ ->
                    Border.color (rgba 0.75 0.75 0.75 1)
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



-- CUSTOM ELEMENTS


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


controlsCheckbox : Bool -> Element msg
controlsCheckbox checked =
    el
        ([ width (px 10)
         , height (px 10)
         , centerY
         , Border.rounded 1
         ]
            ++ (if checked then
                    [ Border.width 2
                    , Border.color (rgba 0.9 0.9 0.9 1)

                    -- , Background.color (rgba 0.1 0.1 0.1 1)
                    , Background.color (rgba 0.788 0.486 0.31 1)

                    -- , Background.color (rgba 0.5 0.5 0.7 1)
                    ]

                else
                    [ Border.width 1
                    , Border.color (rgba 0.7 0.7 0.7 1)
                    , Background.color (rgba 0.9 0.9 0.9 1)
                    ]
               )
        )
    <|
        el [] none


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
