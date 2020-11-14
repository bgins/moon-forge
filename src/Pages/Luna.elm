module Pages.Luna exposing (Model, Msg, Params, page)

import Components.Instrument.Controls as Controls
import Components.Panels.PatchBrowser as PatchBrowser exposing (PatchBrowser)
import Components.Panels.Settings as SettingsPanel
import Controller exposing (Controller(..), Devices)
import Creator exposing (Creator)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Filter exposing (Filter(..))
import Instrument exposing (Instrument(..))
import Instrument.Luna.Patch as Patch exposing (Patch)
import Json.Encode as Encode
import Oscillator exposing (Oscillator(..))
import Patch.Category exposing (PatchCategory(..))
import Patch.Metadata exposing (PatchMetadata)
import Ports
import Session exposing (Session)
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
    { session : Session
    , patch : Patch
    , controller : Controller
    , patchBrowser : PatchBrowser
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( Model
        shared.session
        Patch.init
        Keyboard
        (PatchBrowser.init
            { session = shared.session
            , instrument = Luna
            , currentPatch = Patch.Metadata.init Luna
            , allPatches =
                List.filter (\patch -> patch.instrument == Luna) shared.patches
            }
        )
    , Cmd.batch
        [ Ports.patchInstrument <|
            Encode.object
                [ ( "instrument", Instrument.encode Luna )
                , ( "patch", Patch.encode Patch.init )
                ]
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
    | UpdateTuning Tuning
    | SetTuning Tuning
    | SelectController Controller
    | GotMidiDevices (Maybe Devices)
    | SelectMidiDevice Controller
    | DisableKeyboardController
    | EnableKeyboardController
    | UpdatePatchBrowser PatchBrowser
    | LoadPatch PatchMetadata
    | GotPatch (Maybe { metadata : PatchMetadata, patch : Patch })
    | StorePatch PatchMetadata
    | DeletePatch PatchMetadata
    | Login


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleOscillator selectedOscillator ->
            ( model
                |> updatePatch (\patch -> { patch | oscillator = selectedOscillator })
            , Ports.adjustAudioParam "oscillatorType" (Oscillator.encode selectedOscillator)
            )

        AdjustAmpEnvAttack newVal ->
            ( model
                |> updatePatch (\patch -> { patch | ampEnvAttack = newVal })
            , Ports.adjustAudioParam "ampEnvAttack" (Encode.float newVal)
            )

        AdjustAmpEnvDecay newVal ->
            ( model
                |> updatePatch (\patch -> { patch | ampEnvDecay = newVal })
            , Ports.adjustAudioParam "ampEnvDecay" (Encode.float newVal)
            )

        AdjustAmpEnvSustain newVal ->
            ( model
                |> updatePatch (\patch -> { patch | ampEnvSustain = newVal })
            , Ports.adjustAudioParam "ampEnvSustain" (Encode.float newVal)
            )

        AdjustAmpEnvRelease newVal ->
            ( model
                |> updatePatch (\patch -> { patch | ampEnvRelease = newVal })
            , Ports.adjustAudioParam "ampEnvRelease" (Encode.float newVal)
            )

        ToggleFilter selectedFilter ->
            ( model
                |> updatePatch (\patch -> { patch | filter = selectedFilter })
            , Ports.adjustAudioParam "filterType" (Filter.encode selectedFilter)
            )

        AdjustFilterFreq newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterFreq = newVal })
            , Ports.adjustAudioParam "filterFreq" (Encode.float newVal)
            )

        AdjustFilterQ newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterQ = newVal })
            , Ports.adjustAudioParam "filterQ" (Encode.float newVal)
            )

        AdjustFilterEnvAttack newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterEnvAttack = newVal })
            , Ports.adjustAudioParam "filterEnvAttack" (Encode.float newVal)
            )

        AdjustFilterEnvDecay newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterEnvDecay = newVal })
            , Ports.adjustAudioParam "filterEnvDecay" (Encode.float newVal)
            )

        AdjustFilterEnvSustain newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterEnvSustain = newVal })
            , Ports.adjustAudioParam "filterEnvSustain" (Encode.float newVal)
            )

        AdjustFilterEnvRelease newVal ->
            ( model
                |> updatePatch (\patch -> { patch | filterEnvRelease = newVal })
            , Ports.adjustAudioParam "filterEnvRelease" (Encode.float newVal)
            )

        AdjustGain newVal ->
            ( model
                |> updatePatch (\patch -> { patch | gain = newVal })
            , Ports.adjustAudioParam "masterGain" (Encode.float newVal)
            )

        UpdateTuning tuning ->
            ( model
                |> updatePatch (\patch -> { patch | tuning = tuning })
            , Cmd.none
            )

        SetTuning tuning ->
            ( model
                |> updatePatch (\patch -> { patch | tuning = tuning })
            , Cmd.batch
                [ Ports.adjustAudioParam "divisions" (Encode.int (Tuning.divisions tuning))
                , Ports.adjustAudioParam "baseFrequency" (Encode.float (Tuning.frequency tuning))
                , Ports.adjustAudioParam "baseMidiNote" (Encode.int (Tuning.midiNote tuning))
                , case model.controller of
                    MIDI _ ->
                        Cmd.none

                    Keyboard ->
                        Ports.enableKeyboard ()
                ]
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

        DisableKeyboardController ->
            ( model
            , case model.controller of
                MIDI _ ->
                    Cmd.none

                Keyboard ->
                    Ports.disableKeyboard ()
            )

        EnableKeyboardController ->
            ( model
            , case model.controller of
                MIDI _ ->
                    Cmd.none

                Keyboard ->
                    Ports.enableKeyboard ()
            )

        UpdatePatchBrowser patchBrowser ->
            ( { model | patchBrowser = patchBrowser }
            , Cmd.none
            )

        LoadPatch metadata ->
            ( model
            , Ports.loadPatch <|
                Patch.Metadata.encode metadata
            )

        GotPatch maybePatch ->
            case maybePatch of
                Just { metadata, patch } ->
                    ( { model
                        | patchBrowser =
                            PatchBrowser.loadPatch metadata model.patchBrowser
                        , patch = patch
                      }
                    , Ports.patchInstrument <|
                        Encode.object
                            [ ( "instrument", Instrument.encode metadata.instrument )
                            , ( "patch", Patch.encode patch )
                            ]
                    )

                Nothing ->
                    -- show a patch could not load error
                    ( model, Cmd.none )

        StorePatch metadata ->
            ( { model
                | patchBrowser =
                    PatchBrowser.savePatch metadata model.patchBrowser
              }
            , Cmd.batch
                [ Ports.storePatch <|
                    Encode.object
                        [ ( "metadata", Patch.Metadata.encode metadata )
                        , ( "patch", Patch.encode model.patch )
                        ]
                , case model.controller of
                    MIDI _ ->
                        Cmd.none

                    Keyboard ->
                        Ports.enableKeyboard ()
                ]
            )

        DeletePatch metadata ->
            ( { model
                | patchBrowser =
                    PatchBrowser.deletePatch metadata model.patchBrowser
              }
            , Ports.deletePatch <|
                Patch.Metadata.encode metadata
            )

        Login ->
            ( model, Ports.login () )


updatePatch : (Patch -> Patch) -> Model -> Model
updatePatch transform model =
    { model | patch = transform model.patch }



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
                { tuning = model.patch.tuning
                , onUpdateTuning = UpdateTuning
                , onSetTuning = SetTuning
                , onInputFocus = DisableKeyboardController
                }
            , PatchBrowser.view
                { patchBrowser = model.patchBrowser
                , onUpdatePatchBrowser = UpdatePatchBrowser
                , onLoadPatch = LoadPatch
                , onStorePatch = StorePatch
                , onDeletePatch = DeletePatch
                , onInputFocus = DisableKeyboardController
                , onInputLoseFocus = EnableKeyboardController
                , session = model.session
                , onLogin = Login
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
                , selected = model.patch.oscillator
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
                    , value = model.patch.ampEnvAttack
                    , toString = Controls.timeToString
                    , onChange = AdjustAmpEnvAttack
                    }
                , Controls.slider
                    { label = "D"
                    , scalingFactor = 2
                    , value = model.patch.ampEnvDecay
                    , toString = Controls.timeToString
                    , onChange = AdjustAmpEnvDecay
                    }
                , Controls.slider
                    { label = "S"
                    , scalingFactor = 1
                    , value = model.patch.ampEnvSustain
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustAmpEnvSustain
                    }
                , Controls.slider
                    { label = "R"
                    , scalingFactor = 3
                    , value = model.patch.ampEnvRelease
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
                , selected = model.patch.filter
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
                    , value = model.patch.filterFreq
                    , toString = Controls.frequencyToString
                    , onChange = AdjustFilterFreq
                    }
                , Controls.slider
                    { label = "Q"
                    , scalingFactor = 20
                    , value = model.patch.filterQ
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
                    , value = model.patch.filterEnvAttack
                    , toString = Controls.timeToString
                    , onChange = AdjustFilterEnvAttack
                    }
                , Controls.slider
                    { label = "D"
                    , scalingFactor = 2
                    , value = model.patch.filterEnvDecay
                    , toString = Controls.timeToString
                    , onChange = AdjustFilterEnvDecay
                    }
                , Controls.slider
                    { label = "S"
                    , scalingFactor = 1
                    , value = model.patch.filterEnvSustain
                    , toString = Controls.magnitudeToString
                    , onChange = AdjustFilterEnvSustain
                    }
                , Controls.slider
                    { label = "R"
                    , scalingFactor = 3
                    , value = model.patch.filterEnvRelease
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
                    , value = model.patch.gain
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
    ( { model
        | session = shared.session
        , patchBrowser =
            PatchBrowser.loadPatches
                (List.filter (\patch -> patch.instrument == Luna) shared.patches)
                model.patchBrowser
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.midiDevicesChanged GotMidiDevices
        , Ports.gotPatch Patch.decoder GotPatch
        ]
