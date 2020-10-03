module Oscillator exposing
    ( Oscillator(..)
    , encode
    , oscillatorToString
    )

import Json.Encode as Encode exposing (Value)


type Oscillator
    = Sine
    | Square
    | Triangle
    | Sawtooth


encode : Oscillator -> Value
encode oscillator =
    Encode.string (oscillatorToString oscillator)


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
