module Components.Instrument.Settings exposing (view)

import Controller exposing (Controller(..), Devices)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Colors as Colors
import UI.Fonts as Fonts


view :
    { controller : Controller
    , onControllerSelection : Controller -> msg
    , onMidiDeviceSelection : Controller -> msg
    }
    -> Element msg
view controllerOptions =
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
                [ text "Settings" ]
            , row
                [ width fill
                , height fill
                , paddingXY 5 3
                , spacing 5
                ]
                [ viewControllerPanel controllerOptions
                , viewTuningPanel
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
                    Background.color Colors.purple
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


viewTuningPanel : Element msg
viewTuningPanel =
    Element.none
