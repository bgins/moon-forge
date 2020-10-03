module Pages.Luna exposing (Model, Msg, Params, page)

import Components.Instrument.Controls as Controls
import Components.Panels.Settings as SettingsPanel
import Controller exposing (Controller(..), Devices)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Filter exposing (Filter(..))
import Json.Encode as Encode
import Oscillator exposing (Oscillator(..))
import Ports
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Tuning exposing (Tuning(..))
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
    , tuning : Tuning
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
            , divisions = 12
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
        (Tuning.equal
            { baseFrequency = initPatch.baseFrequency
            , baseMidiNote = initPatch.baseMidiNote
            , period = 1200
            , divisions = initPatch.divisions
            }
        )
        Keyboard
    , Ports.initializeInstrument <|
        Encode.object
            [ ( "instrument", Encode.string "luna" )
            , ( "settings"
              , Encode.object
                    [ ( "oscillator", Oscillator.encode initPatch.oscillator )
                    , ( "ampEnvAttack", Encode.float initPatch.ampEnvAttack )
                    , ( "ampEnvDecay", Encode.float initPatch.ampEnvDecay )
                    , ( "ampEnvSustain", Encode.float initPatch.ampEnvSustain )
                    , ( "ampEnvRelease", Encode.float initPatch.ampEnvRelease )
                    , ( "filter", Filter.encode initPatch.filter )
                    , ( "filterFreq", Encode.float initPatch.filterFreq )
                    , ( "filterQ", Encode.float initPatch.filterQ )
                    , ( "filterEnvAttack", Encode.float initPatch.filterEnvAttack )
                    , ( "filterEnvDecay", Encode.float initPatch.filterEnvDecay )
                    , ( "filterEnvSustain", Encode.float initPatch.filterEnvSustain )
                    , ( "filterEnvRelease", Encode.float initPatch.filterEnvRelease )
                    , ( "gain", Encode.float initPatch.gain )
                    , ( "edo", Encode.int initPatch.divisions )
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
    | UpdateTuning Tuning
    | SetTuning Tuning


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOscillator selectedOscillator ->
            ( { model | oscillator = selectedOscillator }
            , Ports.adjustAudioParam "oscillatorType" (Oscillator.encode selectedOscillator)
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
            , Ports.adjustAudioParam "filterType" (Filter.encode selectedFilter)
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

        UpdateTuning tuning ->
            ( { model | tuning = tuning }
            , Cmd.none
            )

        SetTuning tuning ->
            ( { model | tuning = tuning }
            , Cmd.batch
                [ Ports.adjustAudioParam "edo" (Encode.int (Tuning.divisions tuning))
                , Ports.adjustAudioParam "baseFrequency" (Encode.float (Tuning.frequency tuning))
                , Ports.adjustAudioParam "baseMidiNote" (Encode.int (Tuning.midiNote tuning))
                ]
            )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Luna"
    , body =
        [ column [ centerX, width (px 800), paddingXY 0 30, spacing 5 ]
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
            , SettingsPanel.view
                { controller = model.controller
                , onControllerSelection = SelectController
                , onMidiDeviceSelection = SelectMidiDevice
                }
                { tuning = model.tuning
                , onUpdateTuning = UpdateTuning
                , onSetTuning = SetTuning
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
        [ row panelStyle
            [ Controls.verticalButtonGroup
                { label = "Oscillator selection"
                , selected = model.oscillator
                , options = [ Sine, Square, Triangle, Sawtooth ]
                , onSelection = ToggleOscillator
                , toButton = Controls.verticalSvgButton
                , toString = Oscillator.oscillatorToString
                }
            ]
        , row [ centerX ] [ text "Osc" ]
        ]


viewAmplitudeEnvelope : Model -> Element Msg
viewAmplitudeEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ Controls.sliderGroup
                [ Controls.slider
                    { label = "A"
                    , scalingFactor = 2
                    , value = model.ampEnvAttack
                    , toString = Controls.timeToString
                    , onChange = AdjustAmpEnvAttack
                    }
                , Controls.slider
                    { label = "D"
                    , scalingFactor = 2
                    , value = model.ampEnvDecay
                    , toString = Controls.timeToString
                    , onChange = AdjustAmpEnvDecay
                    }
                , Controls.slider
                    { label = "S"
                    , scalingFactor = 1
                    , value = model.ampEnvSustain
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustAmpEnvSustain
                    }
                , Controls.slider
                    { label = "R"
                    , scalingFactor = 3
                    , value = model.ampEnvRelease
                    , toString = Controls.timeToString
                    , onChange = AdjustAmpEnvRelease
                    }
                ]
            ]
        , row [ centerX ] [ text "Amplitude Envelope" ]
        ]


viewFilter : Model -> Element Msg
viewFilter model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ Controls.verticalButtonGroup
                { label = "Filter selection"
                , selected = model.filter
                , options = [ Lowpass, Highpass, Bandpass, Notch ]
                , onSelection = ToggleFilter
                , toButton = Controls.verticalSvgButton
                , toString = Filter.filterToString
                }
            , Controls.spacer
            , Controls.sliderGroup
                [ Controls.slider
                    { label = "Freq"
                    , scalingFactor = 2000
                    , value = model.filterFreq
                    , toString = Controls.frequencyToString
                    , onChange = AdjustFilterFreq
                    }
                , Controls.slider
                    { label = "Q"
                    , scalingFactor = 20
                    , value = model.filterQ
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustFilterQ
                    }
                ]
            ]
        , row [ centerX ] [ text "Filter" ]
        ]


viewFilterEnvelope : Model -> Element Msg
viewFilterEnvelope model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ Controls.sliderGroup
                [ Controls.slider
                    { label = "A"
                    , scalingFactor = 2
                    , value = model.filterEnvAttack
                    , toString = Controls.timeToString
                    , onChange = AdjustFilterEnvAttack
                    }
                , Controls.slider
                    { label = "D"
                    , scalingFactor = 2
                    , value = model.filterEnvDecay
                    , toString = Controls.timeToString
                    , onChange = AdjustFilterEnvDecay
                    }
                , Controls.slider
                    { label = "S"
                    , scalingFactor = 1
                    , value = model.filterEnvSustain
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustFilterEnvSustain
                    }
                , Controls.slider
                    { label = "R"
                    , scalingFactor = 3
                    , value = model.filterEnvRelease
                    , toString = Controls.timeToString
                    , onChange = AdjustFilterEnvRelease
                    }
                ]
            ]
        , row [ centerX ] [ text "Filter Envelope" ]
        ]


viewGain : Model -> Element Msg
viewGain model =
    column [ height fill, spacing 5 ]
        [ row panelStyle
            [ Controls.sliderGroup
                [ Controls.slider
                    { label = ""
                    , scalingFactor = 1
                    , value = model.gain
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustGain
                    }
                ]
            ]
        , row [ centerX ] [ text "Gain" ]
        ]


panelStyle : List (Attribute msg)
panelStyle =
    [ width fill
    , height fill
    , Border.width 1
    , Border.color Colors.lightGrey
    , Border.rounded 2
    ]



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
