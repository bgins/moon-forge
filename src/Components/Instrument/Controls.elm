module Components.Instrument.Controls exposing
    ( frequencyToString
    , magnitudeToString
    , slider
    , sliderGroup
    , spacer
    , timeToString
    , verticalButtonGroup
    , verticalSvgButton
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Colors as Colors



-- BUTTONS


verticalButtonGroup :
    { label : String
    , selected : option
    , options : List option
    , onSelection : option -> msg
    , toButton : String -> (Input.OptionState -> Element msg)
    , toString : option -> String
    }
    -> Element msg
verticalButtonGroup params =
    Input.radio []
        { onChange = \choice -> params.onSelection choice
        , options =
            List.map
                (\option ->
                    Input.optionWith option <|
                        params.toButton <|
                            params.toString option
                )
                params.options
        , selected = Just params.selected
        , label = Input.labelHidden params.label
        }


verticalSvgButton : String -> (Input.OptionState -> Element msg)
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
            [ image []
                { src = "./images/" ++ label ++ ".svg"
                , description = label
                }
            ]



-- SLIDERS


sliderGroup : List (Element msg) -> Element msg
sliderGroup sliders =
    column [ height fill, paddingXY 4 4 ]
        [ row [ height fill ] sliders ]


slider :
    { label : String
    , scalingFactor : Float
    , value : Float
    , toString : Float -> String
    , onChange : Float -> msg
    }
    -> Element msg
slider params =
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
            { onChange =
                \newSliderVal ->
                    params.onChange <|
                        (newSliderVal ^ 2)
                            * params.scalingFactor
            , label =
                Input.labelBelow [ centerX ] <|
                    text params.label
            , min = 0.0001
            , max = 1
            , step = Just 0.001
            , value = sqrt (params.value / params.scalingFactor)
            , thumb = sliderThumb
            }
        , el
            [ centerX
            , Font.size 8
            , Font.color (rgb 0.3 0.3 0.3)
            ]
          <|
            text <|
                params.toString params.value
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
            , Border.widthEach
                { bottom = 0, left = 1, right = 0, top = 0 }
            ]
            [ el [] none ]
        ]



-- LABELS


magnitudeToString : Float -> String
magnitudeToString val =
    String.fromFloat
        (toFloat (round (val * 100)) / 100)


timeToString : Float -> String
timeToString time =
    String.fromFloat
        (toFloat (round (time * 1000)) / 1000)
        ++ "s"


frequencyToString : Float -> String
frequencyToString freq =
    if freq >= 1000 then
        String.fromFloat
            (toFloat (round (freq / 100)) / 10)
            ++ "kHz"

    else
        String.fromInt
            (round (freq * 100) // 100)
            ++ "Hz"
