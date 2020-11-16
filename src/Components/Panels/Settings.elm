module Components.Panels.Settings exposing (view)

import Controller exposing (Controller(..), Devices)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Tuning exposing (Tuning)
import UI.Colors as Colors
import UI.Fonts as Fonts


view :
    { controller : Controller
    , onControllerSelection : Controller -> msg
    , onMidiDeviceSelection : Controller -> msg
    }
    ->
        { tuning : Tuning
        , onUpdateTuning : Tuning -> msg
        , onSetTuning : Tuning -> msg
        , onInputFocus : msg
        }
    -> Element msg
view controllerOptions tuningOptions =
    row
        [ centerX
        , height (px 175)
        , paddingXY 10 6
        , Background.color Colors.lightestGrey
        , Border.color Colors.darkestGrey
        , Border.rounded 7
        , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
        , Font.color Colors.darkestGrey
        , Font.size 12
        ]
        [ column [ width fill, height fill ]
            [ row
                [ width fill
                , height (px 30)
                , Font.family Fonts.quattrocento
                , Font.size 18
                ]
                [ text "Main Control Panel" ]
            , row
                [ width fill
                , height fill
                , paddingXY 5 2
                , spacing 5
                ]
                [ viewControllerPanel controllerOptions
                , viewTuningPanel tuningOptions
                , viewSpectralDeconfabulatorPanel
                ]
            ]
        ]


viewControllerPanel :
    { controller : Controller
    , onControllerSelection : Controller -> msg
    , onMidiDeviceSelection : Controller -> msg
    }
    -> Element msg
viewControllerPanel options =
    column [ height fill, spacing 5 ]
        [ row
            [ width (px 152)
            , height fill
            , Border.width 1
            , Border.color Colors.lightGrey
            , Border.rounded 2
            ]
            [ column [ alignTop ]
                [ viewControllerTabs options.controller options.onControllerSelection
                , case options.controller of
                    MIDI maybeDevices ->
                        viewDevices maybeDevices options.onMidiDeviceSelection

                    Keyboard ->
                        Element.none
                ]
            ]
        , row [ centerX ] [ text "Controller" ]
        ]


viewControllerTabs : Controller -> (Controller -> msg) -> Element msg
viewControllerTabs controller onControllerSelection =
    Input.radioRow
        [ width fill
        , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
        , Border.color Colors.lightGrey
        ]
        { onChange = \choice -> onControllerSelection choice
        , options =
            [ Input.optionWith Keyboard (controllerOption "Keyboard")
            , case controller of
                MIDI maybeDevices ->
                    Input.optionWith
                        (MIDI maybeDevices)
                        (controllerOption "MIDI")

                Keyboard ->
                    Input.optionWith
                        (MIDI Nothing)
                        (controllerOption "MIDI")
            ]
        , selected = Just controller
        , label = Input.labelHidden "Controller options"
        }


controllerOption : String -> (Input.OptionState -> Element msg)
controllerOption label =
    \optionState ->
        row
            [ width (px 75)
            , paddingXY 0 5
            , case optionState of
                Input.Idle ->
                    Background.color Colors.lightestGrey

                Input.Focused ->
                    Background.color Colors.darkestGrey

                Input.Selected ->
                    Background.color Colors.lightPurple
            ]
            [ row [ centerX ] [ text label ] ]


viewDevices : Maybe Devices -> (Controller -> msg) -> Element msg
viewDevices maybeDevices onMidiDeviceSelection =
    case maybeDevices of
        Just devices ->
            Input.radio
                [ width fill ]
                { onChange =
                    \choice ->
                        onMidiDeviceSelection <|
                            MIDI <|
                                Just
                                    { selected = choice
                                    , available = devices.available
                                    }
                , options =
                    List.map deviceOption devices.available
                , selected = Just devices.selected
                , label = Input.labelHidden "MIDI device options"
                }

        Nothing ->
            column [ centerX, centerY ]
                [ text "No devices available" ]


deviceOption : String -> Input.Option String msg
deviceOption label =
    Input.optionWith label <|
        \optionState ->
            row
                [ width (px 150)
                , paddingXY 3 3
                , case optionState of
                    Input.Idle ->
                        Background.color Colors.lightestGrey

                    Input.Focused ->
                        Background.color Colors.lightestGrey

                    Input.Selected ->
                        Background.color Colors.lightGrey
                , Font.size 10
                , Font.color Colors.darkGrey
                ]
                [ text label ]


viewTuningPanel :
    { tuning : Tuning
    , onUpdateTuning : Tuning -> msg
    , onSetTuning : Tuning -> msg
    , onInputFocus : msg
    }
    -> Element msg
viewTuningPanel options =
    column [ height fill, spacing 5 ]
        [ row
            [ width fill
            , height fill
            , padding 5
            , Border.width 1
            , Border.color Colors.lightGrey
            , Border.rounded 2
            ]
            [ column [ alignTop, centerX, spacing 8 ]
                [ tuningInput
                    { label = "EDO"
                    , current = Tuning.editableDivisions options.tuning
                    , tuning = options.tuning
                    , validateParam = Tuning.validateDivisions
                    , validateEditableParam = Tuning.validateEditableDivisions
                    , mapParam = Tuning.mapDivisions
                    , mapEditableParam = Tuning.mapEditableDivisions
                    , onInputFocus = options.onInputFocus
                    , onUpdateTuning = options.onUpdateTuning
                    , onSetTuning = options.onSetTuning
                    , toNumber = String.toInt
                    }
                , tuningInput
                    { label = "Base Frequency"
                    , current = Tuning.editableFrequency options.tuning
                    , tuning = options.tuning
                    , validateParam = Tuning.validateFrequency
                    , validateEditableParam = Tuning.validateEditableFrequency
                    , mapParam = Tuning.mapFrequency
                    , mapEditableParam = Tuning.mapEditableFrequency
                    , onInputFocus = options.onInputFocus
                    , onUpdateTuning = options.onUpdateTuning
                    , onSetTuning = options.onSetTuning
                    , toNumber = String.toFloat
                    }
                , tuningInput
                    { label = "Base MIDI Note"
                    , current = Tuning.editableMidiNote options.tuning
                    , tuning = options.tuning
                    , validateParam = Tuning.validateMidiNote
                    , validateEditableParam = Tuning.validateEditableMidiNote
                    , mapParam = Tuning.mapMidiNote
                    , mapEditableParam = Tuning.mapEditableMidiNote
                    , onInputFocus = options.onInputFocus
                    , onUpdateTuning = options.onUpdateTuning
                    , onSetTuning = options.onSetTuning
                    , toNumber = String.toInt
                    }
                ]
            ]
        , row [ centerX ] [ text "Tuning" ]
        ]


tuningInput :
    { label : String
    , current : String
    , tuning : Tuning
    , validateParam : Maybe number -> number
    , validateEditableParam : String -> String
    , mapParam : (number -> number) -> Tuning -> Tuning
    , mapEditableParam : (String -> String) -> Tuning -> Tuning
    , onInputFocus : msg
    , onUpdateTuning : Tuning -> msg
    , onSetTuning : Tuning -> msg
    , toNumber : String -> Maybe number
    }
    -> Element msg
tuningInput options =
    Input.text
        [ Events.onLoseFocus <|
            options.onSetTuning <|
                options.mapParam
                    (\_ ->
                        options.validateParam <|
                            options.toNumber options.current
                    )
                <|
                    options.mapEditableParam
                        (\_ ->
                            options.validateEditableParam options.current
                        )
                        options.tuning
        , Events.onFocus options.onInputFocus
        , width (px 80)
        , paddingXY 2 1
        , spacing 4
        , Background.color Colors.lightestGrey
        , Border.color Colors.lightGrey
        , Border.width 1
        , Border.rounded 1
        , focused
            [ Background.color Colors.offWhite
            , Border.shadow
                { offset = ( 0, 0 )
                , blur = 0
                , color = rgb 0 0 0
                , size = 0
                }
            , Border.color (rgb 0.5 0.5 0.5)
            ]
        , Font.size 10
        , Font.center
        ]
        { onChange =
            \newText ->
                options.onUpdateTuning <|
                    options.mapEditableParam
                        (\_ -> newText)
                        options.tuning
        , label =
            Input.labelAbove
                [ centerX
                , Font.size 9
                ]
                (text options.label)
        , placeholder =
            Nothing
        , text = options.current
        }


viewSpectralDeconfabulatorPanel : Element msg
viewSpectralDeconfabulatorPanel =
    row
        [ alignTop
        , width (px 238)
        , height (px 109)
        , padding 5
        , Border.width 1
        , Border.color Colors.lightGrey
        , Border.rounded 2
        ]
        [ column
            [ centerX
            , centerY
            , spacing 5
            , width (px 80)
            , Font.color Colors.mediumGrey
            ]
            [ el [ centerX ] (text "Spectral Deconfabulator")
            , el [ centerX ] (text "Panel")
            ]
        ]
