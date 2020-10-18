module Oscillator exposing
    ( Oscillator(..)
    , decoder
    , encode
    , oscillatorToString
    )

import Json.Decode as Decode exposing (Decoder)
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


decoder : Decoder Oscillator
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "sine" ->
                        Decode.succeed Sine

                    "square" ->
                        Decode.succeed Square

                    "triangle" ->
                        Decode.succeed Triangle

                    "sawtooth" ->
                        Decode.succeed Sawtooth

                    _ ->
                        Decode.fail "Not an oscillator type"
            )
