module UI.Controls exposing (checkbox, radioGroup, smallRadioOption, textInput)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Fonts



-- TEXT INPUTS


type alias Label =
    String


textInput : (String -> msg) -> Label -> String -> Element msg
textInput tomsg label currentText =
    Input.text
        [ width fill
        , paddingXY 2 0
        , Font.size 10
        , Font.center
        , Background.color (rgba 0.16 0.16 0.16 1)
        , Border.color (rgba 0.3 0.3 0.3 1)
        , Border.width 1
        , Border.rounded 1
        , focused
            [ Border.shadow
                { offset = ( 0, 0 )
                , blur = 0
                , color = rgba 235 235 235 0
                , size = 0
                }
            , Border.color (rgba 0.5 0.5 0.5 1)
            ]
        ]
        { onChange = \newText -> tomsg newText
        , label = Input.labelAbove [] (text label)
        , placeholder = Just (Input.placeholder [] (text ""))
        , text = currentText
        }



-- BUTTON AND RADIO GROUPS


radioGroup :
    (String -> msg)
    -> (String -> Input.Option String msg)
    -> List String
    -> String
    -> String
    -> Element msg
radioGroup msg toRadioOption options selectedOption label =
    Input.radio
        [ width fill, centerX ]
        { onChange = \choice -> msg choice
        , options =
            List.map toRadioOption options
        , selected = Just selectedOption
        , label = Input.labelHidden label
        }


smallRadioOption : String -> Input.Option String msg
smallRadioOption label =
    Input.optionWith label <|
        \optionState ->
            row
                [ width fill
                , height fill
                , Font.size 12
                , case optionState of
                    Input.Selected ->
                        paddingXY 20 2

                    _ ->
                        paddingXY 28 2
                ]
            <|
                case optionState of
                    Input.Selected ->
                        [ text <| "• " ++ label ]

                    _ ->
                        [ text label ]


checkbox : Bool -> Element msg
checkbox checked =
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
