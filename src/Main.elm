port module Main exposing (Document, Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import View.Colors as Colors
import View.Controls as Controls
import View.Fonts as Fonts
import View.Instrument as Instrument



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
    , tuningPanelVisible : Bool
    , temperamentInput : String
    , baseFrequencyInput : String
    , baseMidiNoteInput : String
    , assetsPath : String
    , errorMessage : String
    , showErrorMessage : Bool
    }


type Oscillator
    = Sine
    | Square
    | Triangle
    | Sawtooth


type Filter
    = Lowpass
    | Highpass
    | Bandpass
    | Notch


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    ( toInitModel flags
    , Cmd.none
    )


toInitModel : Decode.Value -> Model
toInitModel flags =
    case Decode.decodeValue decodeFlags flags of
        Ok decodedFlags ->
            Model
                (case decodedFlags.oscillator of
                    "sine" ->
                        Sine

                    "square" ->
                        Square

                    "triangle" ->
                        Triangle

                    "sawtooth" ->
                        Sawtooth

                    _ ->
                        Sine
                )
                decodedFlags.ampEnvAttack
                decodedFlags.ampEnvDecay
                decodedFlags.ampEnvSustain
                decodedFlags.ampEnvRelease
                (case decodedFlags.filter of
                    "lowpass" ->
                        Lowpass

                    "highpass" ->
                        Highpass

                    "bandpass" ->
                        Bandpass

                    "notch" ->
                        Notch

                    _ ->
                        Lowpass
                )
                decodedFlags.filterFreq
                decodedFlags.filterQ
                decodedFlags.filterEnvAttack
                decodedFlags.filterEnvDecay
                decodedFlags.filterEnvSustain
                decodedFlags.filterEnvRelease
                decodedFlags.gain
                decodedFlags.keyboardEnabled
                decodedFlags.midiEnabled
                decodedFlags.midiDevices
                decodedFlags.selectedMidiDevice
                decodedFlags.tuningPanelVisible
                decodedFlags.temperamentInput
                decodedFlags.baseFrequencyInput
                decodedFlags.baseMidiNoteInput
                decodedFlags.assetsPath
                ""
                False

        Err err ->
            Model
                Triangle
                0.05
                0.05
                0.5
                0.5
                Lowpass
                2000
                2
                0.1
                0.2
                0.5
                0.5
                0.2
                True
                False
                []
                ""
                False
                "12"
                "261.625"
                "60"
                "./assets/"
                "Something went wrong initializing the application. Defaults have been assigned."
                True


type alias Flags =
    { oscillator : String
    , ampEnvAttack : Float
    , ampEnvDecay : Float
    , ampEnvSustain : Float
    , ampEnvRelease : Float
    , filter : String
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
    , tuningPanelVisible : Bool
    , temperamentInput : String
    , baseFrequencyInput : String
    , baseMidiNoteInput : String
    , assetsPath : String
    }


decodeFlags : Decode.Decoder Flags
decodeFlags =
    Decode.succeed Flags
        |> required "oscillator" Decode.string
        |> required "ampEnvAttack" Decode.float
        |> required "ampEnvDecay" Decode.float
        |> required "ampEnvSustain" Decode.float
        |> required "ampEnvRelease" Decode.float
        |> required "filter" Decode.string
        |> required "filterFreq" Decode.float
        |> required "filterQ" Decode.float
        |> required "filterEnvAttack" Decode.float
        |> required "filterEnvDecay" Decode.float
        |> required "filterEnvSustain" Decode.float
        |> required "filterEnvRelease" Decode.float
        |> required "gain" Decode.float
        |> required "keyboardEnabled" Decode.bool
        |> required "midiEnabled" Decode.bool
        |> required "midiDevices" (Decode.list Decode.string)
        |> required "selectedMidiDevice" Decode.string
        |> required "tuningPanelVisible" Decode.bool
        |> required "temperamentInput" Decode.string
        |> required "baseFrequencyInput" Decode.string
        |> required "baseMidiNoteInput" Decode.string
        |> required "assetsPath" Decode.string



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
    | ReceiveMidiDevices MidiDevicesPortMessage
    | ToggleTuningPanel Bool
    | UpdateTemperament String
    | UpdateBaseFrequency String
    | UpdateBaseMidiNote String
    | DismissErrorMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOscillator selectedOscillator ->
            ( { model | oscillator = selectedOscillator }
            , adjustAudioParam "oscillatorType" (Encode.string <| oscillatorToString selectedOscillator)
            )

        AdjustAmpEnvAttack newVal ->
            ( { model | ampEnvAttack = newVal }
            , adjustAudioParam "ampEnvAttack" (Encode.float newVal)
            )

        AdjustAmpEnvDecay newVal ->
            ( { model | ampEnvDecay = newVal }
            , adjustAudioParam "ampEnvDecay" (Encode.float newVal)
            )

        AdjustAmpEnvSustain newVal ->
            ( { model | ampEnvSustain = newVal }
            , adjustAudioParam "ampEnvSustain" (Encode.float newVal)
            )

        AdjustAmpEnvRelease newVal ->
            ( { model | ampEnvRelease = newVal }
            , adjustAudioParam "ampEnvRelease" (Encode.float newVal)
            )

        ToggleFilter selectedFilter ->
            ( { model | filter = selectedFilter }
            , adjustAudioParam "filterType" (Encode.string <| filterToString selectedFilter)
            )

        AdjustFilterFreq newVal ->
            ( { model | filterFreq = newVal }
            , adjustAudioParam "filterFreq" (Encode.float newVal)
            )

        AdjustFilterQ newVal ->
            ( { model | filterQ = newVal }
            , adjustAudioParam "filterQ" (Encode.float newVal)
            )

        AdjustFilterEnvAttack newVal ->
            ( { model | filterEnvAttack = newVal }
            , adjustAudioParam "filterEnvAttack" (Encode.float newVal)
            )

        AdjustFilterEnvDecay newVal ->
            ( { model | filterEnvDecay = newVal }
            , adjustAudioParam "filterEnvDecay" (Encode.float newVal)
            )

        AdjustFilterEnvSustain newVal ->
            ( { model | filterEnvSustain = newVal }
            , adjustAudioParam "filterEnvSustain" (Encode.float newVal)
            )

        AdjustFilterEnvRelease newVal ->
            ( { model | filterEnvRelease = newVal }
            , adjustAudioParam "filterEnvRelease" (Encode.float newVal)
            )

        AdjustGain newVal ->
            ( { model | gain = newVal }
            , adjustAudioParam "masterGain" (Encode.float newVal)
            )

        ToggleKeyboard checked ->
            if checked then
                ( { model | keyboardEnabled = True, midiEnabled = False }
                , enableKeyboard ()
                )

            else
                ( { model | keyboardEnabled = False }
                , disableKeyboard ()
                )

        ToggleMidi checked ->
            if checked then
                ( { model | midiEnabled = True, keyboardEnabled = False }
                , getMidiDevices ()
                )

            else
                ( { model | midiEnabled = False, midiDevices = [] }
                , setMidiDevice ""
                )

        SelectMidiDevice newDevice ->
            ( { model | selectedMidiDevice = newDevice }
            , setMidiDevice newDevice
            )

        ReceiveMidiDevices midiDevicesPortMessage ->
            if List.isEmpty midiDevicesPortMessage.midiDevices then
                ( { model | midiDevices = [ "No Midi devices available" ] }
                , Cmd.none
                )

            else
                ( { model
                    | midiDevices = midiDevicesPortMessage.midiDevices
                    , selectedMidiDevice = midiDevicesPortMessage.selectedMidiDevice
                  }
                , Cmd.none
                )

        ToggleTuningPanel checked ->
            ( { model | tuningPanelVisible = checked }
            , if checked then
                Cmd.batch
                    [ maybeAdjustAudioParam (String.toInt model.temperamentInput) "edo" Encode.int
                    , maybeAdjustAudioParam (String.toFloat model.baseFrequencyInput) "baseFrequency" Encode.float
                    , maybeAdjustAudioParam (String.toInt model.baseMidiNoteInput) "baseMidiNote" Encode.int
                    ]

              else
                Cmd.batch
                    [ adjustAudioParam "edo" (Encode.int 12)
                    , adjustAudioParam "baseFrequency" (Encode.float 261.625)
                    , adjustAudioParam "baseMidiNote" (Encode.int 60)
                    ]
            )

        UpdateTemperament newVal ->
            ( { model | temperamentInput = newVal }
            , maybeAdjustAudioParam (String.toInt newVal) "edo" Encode.int
            )

        UpdateBaseFrequency newVal ->
            ( { model | baseFrequencyInput = newVal }
            , maybeAdjustAudioParam (String.toFloat newVal) "baseFrequency" Encode.float
            )

        UpdateBaseMidiNote newVal ->
            ( { model | baseMidiNoteInput = newVal }
            , maybeAdjustAudioParam (String.toInt newVal) "baseMidiNote" Encode.int
            )

        DismissErrorMessage ->
            if model.showErrorMessage then
                ( { model | showErrorMessage = False }, Cmd.none )

            else
                ( model, Cmd.none )


maybeAdjustAudioParam : Maybe a -> String -> (a -> Encode.Value) -> Cmd Msg
maybeAdjustAudioParam maybeVal paramName encoder =
    case maybeVal of
        Just val ->
            adjustAudioParam paramName (encoder val)

        Nothing ->
            Cmd.none



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.midiEnabled then
        updateMidiDevices ReceiveMidiDevices

    else
        Sub.none



-- PORTS


{-| Update instrument parameters in web audio

At the moment, the parameters are tightly coupled and need to be changed on both
sides.

-}
port updateAudioParam : Encode.Value -> Cmd msg


adjustAudioParam : String -> Encode.Value -> Cmd msg
adjustAudioParam name val =
    updateAudioParam <|
        Encode.object
            [ ( "name", Encode.string name )
            , ( "val", val )
            ]


{-| Enable or disable computer keyboard

This is the default controller. When the keyboard is enabled, Midi controllers
are disabled. When Midi controllers are enabled, the keyboard is disabled. It is
possible to disable all devices.

-}
port enableKeyboard : () -> Cmd msg


port disableKeyboard : () -> Cmd msg


{-| Enable, disable, or select Midi devices

getMidiDevices enables Midi control and requests a list of available devices.

setMidiDevice sets the active Midi device in WebMidi.

onMidiDevicesRequest receives a list of available Midi devices.

WebMidi control has not been implemented in all browsers. If WebMidi is not
available, getMidiDevices will return an empty list.

-}
port getMidiDevices : () -> Cmd msg


port setMidiDevice : String -> Cmd msg


port onMidiDevicesRequest : (Encode.Value -> msg) -> Sub msg


updateMidiDevices : (MidiDevicesPortMessage -> msg) -> Sub msg
updateMidiDevices toMsg =
    onMidiDevicesRequest <|
        \value ->
            toMsg <|
                case Decode.decodeValue decodeMidiDevices value of
                    Ok midiDevicesPortMessage ->
                        midiDevicesPortMessage

                    Err err ->
                        MidiDevicesPortMessage [] ""


type alias MidiDevicesPortMessage =
    { midiDevices : List String
    , selectedMidiDevice : String
    }


decodeMidiDevices : Decode.Decoder MidiDevicesPortMessage
decodeMidiDevices =
    Decode.succeed MidiDevicesPortMessage
        |> required "midiDevices" (Decode.list Decode.string)
        |> required "selectedMidiDevice" Decode.string



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Moon Forge"
    , body =
        [ layout
            [ Background.color Colors.darkGrey
            , Font.color (rgb 1 1 1)
            , inFront <| viewNav
            ]
          <|
            column [ width fill, height fill ]
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
        , Border.color Colors.nearBlack
        ]
        [ column [ width (px 800), centerX ]
            [ row [ width fill ]
                [ column
                    [ centerX
                    , Font.family Fonts.cinzelFont
                    , Font.size 36
                    ]
                    [ text "Moon Forge"
                    ]
                ]
            ]
        ]


viewBody : Model -> Element Msg
viewBody model =
    row
        [ width fill
        , height fill
        , paddingXY 0 30
        , inFront <| viewGlobalControls model
        ]
        [ column [ alignTop, centerX, spacing 10 ] <|
            [ viewInstrument model
            , viewError model
            ]
        ]



-- VIEW: GLOBAL CONTROLS


viewGlobalControls : Model -> Element Msg
viewGlobalControls model =
    column
        [ width (px 200)
        , height fill
        , paddingXY 10 10
        , Background.color Colors.darkGrey
        , Border.color Colors.nearBlack
        , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
        , Font.family Fonts.quattrocentoFont
        , spacing 5
        ]
        [ viewControllersControls model
        , viewInstrumentControls model
        ]


viewControllersControls : Model -> Element Msg
viewControllersControls model =
    row []
        [ column [ paddingXY 0 5, spacing 5 ]
            [ el [ Font.size 18 ] (text "Controllers")
            , Input.checkbox [ paddingXY 10 0 ]
                { checked = model.keyboardEnabled
                , onChange = ToggleKeyboard
                , icon = Controls.checkbox
                , label = Input.labelRight [ Font.size 14 ] (text "Keyboard")
                }
            , Input.checkbox [ paddingXY 10 0 ]
                { checked = model.midiEnabled
                , onChange = ToggleMidi
                , icon = Controls.checkbox
                , label = Input.labelRight [ Font.size 14 ] (text "MIDI")
                }
            , viewMidiOptions model
            ]
        ]


viewMidiOptions : Model -> Element Msg
viewMidiOptions model =
    row []
        [ column [ paddingXY 20 0 ]
            [ Controls.radioGroup
                SelectMidiDevice
                Controls.smallRadioOption
                model.midiDevices
                model.selectedMidiDevice
                "Midi device selection"
            ]
        ]


viewInstrumentControls : Model -> Element Msg
viewInstrumentControls model =
    row []
        [ column [ paddingXY 0 5, spacing 5 ] <|
            [ el [ Font.size 18 ] (text "Instrument")
            , Input.checkbox [ paddingXY 10 0 ]
                { checked = model.tuningPanelVisible
                , onChange = ToggleTuningPanel
                , icon = Controls.checkbox
                , label = Input.labelRight [ Font.size 14 ] (text "Custom Tuning")
                }
            , viewTuningPanel model
            ]
        ]


viewTuningPanel : Model -> Element Msg
viewTuningPanel model =
    if model.tuningPanelVisible then
        row []
            [ column
                [ paddingXY 20 2
                , spacing 8
                ]
                [ el [ Font.size 12 ] <| text "• Temperament"
                , row
                    [ paddingXY 8 0
                    , spacing 5
                    ]
                    [ Controls.textInput UpdateTemperament "EDO" model.temperamentInput
                    , Controls.textInput UpdateBaseFrequency "Base Freq" model.baseFrequencyInput
                    , Controls.textInput UpdateBaseMidiNote "At MIDI" model.baseMidiNoteInput
                    ]
                ]
            ]

    else
        el [] none



-- VIEW: INSTRUMENT


viewInstrument : Model -> Element Msg
viewInstrument model =
    row
        [ width fill
        , height (px 175)
        , paddingXY 10 6
        , Background.color Colors.lightGrey
        , Border.color Colors.nearBlack
        , Border.rounded 7
        , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
        , Font.color Colors.nearBlack
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
        [ width fill
        , height (px 30)
        , Font.family Fonts.cinzelFont
        , Font.size 24
        ]
        [ text "LUNA" ]


viewPanels : Model -> Element Msg
viewPanels model =
    row
        [ width fill
        , height fill
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
        [ row Instrument.panelStyle
            [ Instrument.verticalButtonGroup "Oscillator selection"
                model.oscillator
                ToggleOscillator
                (Instrument.verticalSvgButton model.assetsPath)
                oscillatorToString
                [ Sine, Square, Triangle, Sawtooth ]
            ]
        , row [ centerX ] [ text "Osc" ]
        ]


viewAmplitudeEnvelope : Model -> Element Msg
viewAmplitudeEnvelope model =
    column [ height fill, spacing 5 ]
        [ row Instrument.panelStyle
            [ Instrument.sliderGroup
                [ Instrument.slider "A" 1 model.ampEnvAttack Instrument.displayTime AdjustAmpEnvAttack
                , Instrument.slider "D" 1 model.ampEnvDecay Instrument.displayTime AdjustAmpEnvDecay
                , Instrument.slider "S" 1 model.ampEnvSustain Instrument.displayMagnitude AdjustAmpEnvSustain
                , Instrument.slider "R" 1 model.ampEnvRelease Instrument.displayTime AdjustAmpEnvRelease
                ]
            ]
        , row [ centerX ] [ text "Amplitude Envelope" ]
        ]


viewFilter : Model -> Element Msg
viewFilter model =
    column [ height fill, spacing 5 ]
        [ row Instrument.panelStyle
            [ Instrument.verticalButtonGroup "Filter selection"
                model.filter
                ToggleFilter
                (Instrument.verticalSvgButton model.assetsPath)
                filterToString
                [ Lowpass, Highpass, Bandpass, Notch ]
            , Instrument.spacer
            , Instrument.sliderGroup
                [ Instrument.slider "Freq" 20000 model.filterFreq Instrument.displayFrequency AdjustFilterFreq
                , Instrument.slider "Q" 20 model.filterQ Instrument.displayMagnitude AdjustFilterQ
                ]
            ]
        , row [ centerX ] [ text "Filter" ]
        ]


viewFilterEnvelope : Model -> Element Msg
viewFilterEnvelope model =
    column [ height fill, spacing 5 ]
        [ row Instrument.panelStyle
            [ Instrument.sliderGroup
                [ Instrument.slider "A" 1 model.filterEnvAttack Instrument.displayTime AdjustFilterEnvAttack
                , Instrument.slider "D" 1 model.filterEnvDecay Instrument.displayTime AdjustFilterEnvDecay
                , Instrument.slider "S" 1 model.filterEnvSustain Instrument.displayMagnitude AdjustFilterEnvSustain
                , Instrument.slider "R" 1 model.filterEnvRelease Instrument.displayTime AdjustFilterEnvRelease
                ]
            ]
        , row [ centerX ] [ text "Filter Envelope" ]
        ]


viewGain : Model -> Element Msg
viewGain model =
    column [ height fill, spacing 5 ]
        [ row Instrument.panelStyle
            [ Instrument.sliderGroup
                [ Instrument.slider "" 1 model.gain Instrument.displayMagnitude AdjustGain ]
            ]
        , row [ centerX ] [ text "Gain" ]
        ]



-- VIEW: ERROR MESSAGE


viewError : Model -> Element Msg
viewError model =
    if model.showErrorMessage then
        row
            [ height (px 26)
            , centerX
            , paddingXY 4 4
            , spacing 2
            , Background.color Colors.lightGrey
            , Border.color Colors.nearBlack
            , Border.rounded 4
            , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
            , Font.color Colors.nearBlack
            , Font.family Fonts.quattrocentoFont
            , Font.size 12
            ]
            [ column [ alignTop ]
                [ Input.button
                    [ paddingXY 2 0
                    , focused
                        [ Border.shadow
                            { offset = ( 0, 0 )
                            , blur = 0
                            , color = rgb 0 0 0
                            , size = 0
                            }
                        ]
                    ]
                    { onPress = Just DismissErrorMessage
                    , label = el [ Font.color (rgb 0 0 0) ] <| text "x"
                    }
                ]
            , column [] [ text model.errorMessage ]
            ]

    else
        el [] none



-- SHOW


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


filterToString : Filter -> String
filterToString filter =
    case filter of
        Lowpass ->
            "lowpass"

        Highpass ->
            "highpass"

        Bandpass ->
            "bandpass"

        Notch ->
            "notch"
