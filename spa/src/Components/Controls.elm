module Components.Controls exposing (checkbox, radioGroup, smallRadioOption, textInput)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import View.Colors as Colors
import View.Fonts as Fonts



-- TEXT INPUTS


type alias Label =
    String


textInput : (String -> msg) -> Label -> String -> Element msg
textInput tomsg label currentText =
    Input.text
        [ width fill
        , paddingXY 2 0
        , Background.color Colors.darkGrey
        , Border.color (rgb 0.3 0.3 0.3)
        , Border.width 1
        , Border.rounded 1
        , focused
            [ Border.shadow
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
                , case optionState of
                    Input.Selected ->
                        paddingXY 0 2

                    _ ->
                        paddingXY 8 2
                , Font.size 12
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
                    , Border.color Colors.lightGrey
                    , Background.color Colors.orange
                    ]

                else
                    [ Border.width 1
                    , Border.color (rgb 0.7 0.7 0.7)
                    , Background.color Colors.lightGrey
                    ]
               )
        )
    <|
        el [] none
