module Pages.Luna exposing (Model, Msg, Params, page)

import Components.Instrument as Instrument
import Components.Instrument.Settings as InstrumentSettings
import Controller exposing (Controller(..), Devices)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Json.Encode as Encode
import Ports
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import UI.Colors as Colors
import UI.Fonts as Fonts


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
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



-- INIT


type alias Params =
    ()


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
    , temperament : Int
    , baseFrequency : Float
    , baseMidiNote : Float
    , controller : Controller
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    let
        initPatch =
            { oscillator = Square
            , ampEnvAttack = 0.05
            , ampEnvDecay = 0.05
            , ampEnvSustain = 1
            , ampEnvRelease = 0.5
            , filter = Lowpass
            , filterFreq = 2000
            , filterQ = 2
            , filterEnvAttack = 0.05
            , filterEnvDecay = 0.05
            , filterEnvSustain = 1
            , filterEnvRelease = 0.5
            , gain = 0.5
            , temperament = 12
            , baseFrequency = 261.625
            , baseMidiNote = 60
            }
    in
    ( Model
        initPatch.oscillator
        initPatch.ampEnvAttack
        initPatch.ampEnvDecay
        initPatch.ampEnvSustain
        initPatch.ampEnvRelease
        initPatch.filter
        initPatch.filterFreq
        initPatch.filterQ
        initPatch.filterEnvAttack
        initPatch.filterEnvDecay
        initPatch.filterEnvSustain
        initPatch.filterEnvRelease
        initPatch.gain
        initPatch.temperament
        initPatch.baseFrequency
        initPatch.baseMidiNote
        Keyboard
    , Ports.initializeInstrument <|
        Encode.object
            [ ( "instrument", Encode.string "luna" )
            , ( "settings"
              , Encode.object
                    [ ( "oscillator", Encode.string (oscillatorToString initPatch.oscillator) )
                    , ( "ampEnvAttack", Encode.float initPatch.ampEnvAttack )
                    , ( "ampEnvDecay", Encode.float initPatch.ampEnvDecay )
                    , ( "ampEnvSustain", Encode.float initPatch.ampEnvSustain )
                    , ( "ampEnvRelease", Encode.float initPatch.ampEnvRelease )
                    , ( "filter", Encode.string (filterToString initPatch.filter) )
                    , ( "filterFreq", Encode.float initPatch.filterFreq )
                    , ( "filterQ", Encode.float initPatch.filterQ )
                    , ( "filterEnvAttack", Encode.float initPatch.filterEnvAttack )
                    , ( "filterEnvDecay", Encode.float initPatch.filterEnvDecay )
                    , ( "filterEnvSustain", Encode.float initPatch.filterEnvSustain )
                    , ( "filterEnvRelease", Encode.float initPatch.filterEnvRelease )
                    , ( "gain", Encode.float initPatch.gain )
                    , ( "temperament", Encode.int initPatch.temperament )
                    , ( "baseFrequency", Encode.float initPatch.baseFrequency )
                    , ( "baseMidiNote", Encode.float initPatch.baseMidiNote )
                    ]
              )
            ]
    )



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
    | SelectController Controller
    | GotMidiDevices (Maybe Devices)
    | SelectMidiDevice Controller


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOscillator selectedOscillator ->
            ( { model | oscillator = selectedOscillator }
            , Ports.adjustAudioParam "oscillatorType" (Encode.string <| oscillatorToString selectedOscillator)
            )

        AdjustAmpEnvAttack newVal ->
            ( { model | ampEnvAttack = newVal }
            , Ports.adjustAudioParam "ampEnvAttack" (Encode.float newVal)
            )

        AdjustAmpEnvDecay newVal ->
            ( { model | ampEnvDecay = newVal }
            , Ports.adjustAudioParam "ampEnvDecay" (Encode.float newVal)
            )

        AdjustAmpEnvSustain newVal ->
            ( { model | ampEnvSustain = newVal }
            , Ports.adjustAudioParam "ampEnvSustain" (Encode.float newVal)
            )

        AdjustAmpEnvRelease newVal ->
            ( { model | ampEnvRelease = newVal }
            , Ports.adjustAudioParam "ampEnvRelease" (Encode.float newVal)
            )

        ToggleFilter selectedFilter ->
            ( { model | filter = selectedFilter }
            , Ports.adjustAudioParam "filterType" (Encode.string <| filterToString selectedFilter)
            )

        AdjustFilterFreq newVal ->
            ( { model | filterFreq = newVal }
            , Ports.adjustAudioParam "filterFreq" (Encode.float newVal)
            )

        AdjustFilterQ newVal ->
            ( { model | filterQ = newVal }
            , Ports.adjustAudioParam "filterQ" (Encode.float newVal)
            )

        AdjustFilterEnvAttack newVal ->
            ( { model | filterEnvAttack = newVal }
            , Ports.adjustAudioParam "filterEnvAttack" (Encode.float newVal)
            )

        AdjustFilterEnvDecay newVal ->
            ( { model | filterEnvDecay = newVal }
            , Ports.adjustAudioParam "filterEnvDecay" (Encode.float newVal)
            )

        AdjustFilterEnvSustain newVal ->
            ( { model | filterEnvSustain = newVal }
            , Ports.adjustAudioParam "filterEnvSustain" (Encode.float newVal)
            )

        AdjustFilterEnvRelease newVal ->
            ( { model | filterEnvRelease = newVal }
            , Ports.adjustAudioParam "filterEnvRelease" (Encode.float newVal)
            )

        AdjustGain newVal ->
            ( { model | gain = newVal }
            , Ports.adjustAudioParam "masterGain" (Encode.float newVal)
            )

        SelectController controller ->
            case controller of
                MIDI maybeDevices ->
                    ( { model | controller = controller }
                    , Ports.getMidiDevices ()
                    )

                Keyboard ->
                    ( { model | controller = controller }
                    , Ports.enableKeyboard ()
                    )

        GotMidiDevices maybeDevices ->
            case maybeDevices of
                Just devices ->
                    ( { model | controller = MIDI (Just devices) }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | controller = MIDI Nothing }
                    , Cmd.none
                    )

        SelectMidiDevice controller ->
            ( { model | controller = controller }
            , case controller of
                MIDI maybeDevices ->
                    case maybeDevices of
                        Just devices ->
                            Ports.setMidiDevice devices.selected

                        Nothing ->
                            Cmd.none

                Keyboard ->
                    Cmd.none
            )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Luna"
    , body =
        [ column [ centerX, width (px 800), spacing 5 ]
            [ row
                [ centerX
                , height (px 175)
                , paddingXY 10 6
                , Background.color Colors.lightestGrey
                , Border.color Colors.darkestGrey
                , Border.rounded 7
                , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
                , Font.color Colors.darkestGrey
                , Font.family Fonts.quattrocento
                , Font.size 12
                ]
                [ column [ width fill, height fill ]
                    [ row
                        [ width fill
                        , height (px 30)
                        , Font.family Fonts.cinzel
                        , Font.size 24
                        ]
                        [ text "LUNA" ]
                    , viewPanels model
                    ]
                ]
            , InstrumentSettings.view
                { controller = model.controller
                , onControllerSelection = SelectController
                , onMidiDeviceSelection = SelectMidiDevice
                }
            ]
        ]
    }


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
                -- (Instrument.verticalSvgButton model.assetsPath)
                Instrument.verticalSvgButton
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
                [ Instrument.slider "A" 2 model.ampEnvAttack Instrument.displayTime AdjustAmpEnvAttack
                , Instrument.slider "D" 2 model.ampEnvDecay Instrument.displayTime AdjustAmpEnvDecay
                , Instrument.slider "S" 1 model.ampEnvSustain Instrument.displayMagnitude AdjustAmpEnvSustain
                , Instrument.slider "R" 3 model.ampEnvRelease Instrument.displayTime AdjustAmpEnvRelease
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
                -- (Instrument.verticalSvgButton model.assetsPath)
                Instrument.verticalSvgButton
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
                [ Instrument.slider "A" 2 model.filterEnvAttack Instrument.displayTime AdjustFilterEnvAttack
                , Instrument.slider "D" 2 model.filterEnvDecay Instrument.displayTime AdjustFilterEnvDecay
                , Instrument.slider "S" 1 model.filterEnvSustain Instrument.displayMagnitude AdjustFilterEnvSustain
                , Instrument.slider "R" 3 model.filterEnvRelease Instrument.displayTime AdjustFilterEnvRelease
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



--  SHARED


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.midiDevicesChanged GotMidiDevices
