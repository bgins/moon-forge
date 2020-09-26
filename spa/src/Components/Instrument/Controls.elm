module Components.Instrument.Controls exposing
    ( displayFrequency
    , displayMagnitude
    , displayTime
    , panelStyle
    , slider
    , sliderGroup
    , spacer
    , verticalButtonGroup
    , verticalSvgButton
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Colors as Colors
import UI.Fonts as Fonts


type alias Label =
    String



-- BUTTONS


verticalButtonGroup :
    Label
    -> a
    -> (a -> msg)
    -> (Label -> (Input.OptionState -> Element msg))
    -> (a -> String)
    -> List a
    -> Element msg
verticalButtonGroup label selectedOption tomsg toButton toString options =
    Input.radio []
        { onChange = \choice -> tomsg choice
        , options =
            List.map (buttonOption toButton toString) options
        , selected = Just selectedOption
        , label = Input.labelHidden label
        }


buttonOption :
    (Label -> (Input.OptionState -> Element msg))
    -> (a -> String)
    -> a
    -> Input.Option a msg
buttonOption toButton toString option =
    Input.optionWith option <| toButton <| toString option


verticalSvgButton : Label -> (Input.OptionState -> Element msg)
verticalSvgButton label =
    \optionState ->
        row
            [ paddingXY 3 3
            , Border.rounded 1
            , Border.widthEach { bottom = 0, left = 2, right = 0, top = 0 }
            , case optionState of
                Input.Selected ->
                    Border.color Colors.purple

                _ ->
                    Border.color (rgb 0.75 0.75 0.75)
            ]
        <|
            [ image [] { src = "../public/images/" ++ label ++ ".svg", description = label } ]



-- SLIDERS


type alias ScalingFactor =
    Float


type alias ParamValue =
    Float


type alias DisplayFunction =
    Float -> String


sliderGroup : List (Element msg) -> Element msg
sliderGroup sliders =
    column [ height fill, paddingXY 4 4 ]
        [ row [ height fill ] sliders ]


slider :
    Label
    -> ScalingFactor
    -> ParamValue
    -> DisplayFunction
    -> (Float -> msg)
    -> Element msg
slider label scalingFactor paramValue displayFunction adjustValue =
    column
        [ height fill
        , spacing 2
        ]
        [ Input.slider
            [ width (px 30)
            , height fill
            , behindContent <|
                el
                    [ width (px 1)
                    , height fill
                    , centerX
                    , Background.color (rgb 0.5 0.5 0.5)
                    , Border.rounded 2
                    ]
                    none
            ]
            { onChange = \newSliderVal -> adjustValue <| (newSliderVal ^ 2) * scalingFactor
            , label = Input.labelBelow [ centerX ] <| text label
            , min = 0.0001
            , max = 1
            , step = Just 0.001
            , value = sqrt (paramValue / scalingFactor)
            , thumb = sliderThumb
            }
        , el
            [ centerX
            , Font.size 8
            , Font.color (rgb 0.3 0.3 0.3)
            ]
          <|
            text <|
                displayFunction paramValue
        ]


sliderThumb : Input.Thumb
sliderThumb =
    Input.thumb
        [ width (px 16)
        , height (px 6)
        , Border.width 1
        , Border.color Colors.lightestGrey
        , Background.color Colors.darkestGrey
        , Border.rounded 2
        ]



-- SPACER


spacer : Element msg
spacer =
    column [ height fill, paddingXY 3 6 ]
        [ row
            [ height fill
            , Border.color Colors.lightGrey
            , Border.widthEach { bottom = 0, left = 1, right = 0, top = 0 }
            ]
            [ el [] none ]
        ]



-- LABELS


displayMagnitude : Float -> String
displayMagnitude val =
    String.fromFloat
        (toFloat (round (val * 100)) / 100)


displayTime : Float -> String
displayTime time =
    String.fromFloat
        (toFloat (round (time * 1000)) / 1000)
        ++ "s"


displayFrequency : Float -> String
displayFrequency freq =
    if freq >= 1000 then
        String.fromFloat
            (toFloat (round (freq / 100)) / 10)
            ++ "kHz"

    else
        String.fromInt
            (round (freq * 100) // 100)
            ++ "Hz"



-- STYLES


panelStyle : List (Attribute msg)
panelStyle =
    [ width fill
    , height fill
    , Border.width 1
    , Border.color Colors.lightGrey
    , Border.rounded 2
    ]
