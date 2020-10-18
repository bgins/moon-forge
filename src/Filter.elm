module Filter exposing
    ( Filter(..)
    , decoder
    , encode
    , filterToString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Filter
    = Lowpass
    | Highpass
    | Bandpass
    | Notch


encode : Filter -> Value
encode filter =
    Encode.string (filterToString filter)


filterToString : Filter -> String
filterToString filter =
    case filter of
        Lowpass ->
            "lowpass"

        Highpass ->
            "highpass"

        Bandpass ->
            "bandpass"

        Notch ->
            "notch"


decoder : Decoder Filter
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "lowpass" ->
                        Decode.succeed Lowpass

                    "highpass" ->
                        Decode.succeed Highpass

                    "bandpass" ->
                        Decode.succeed Bandpass

                    "notch" ->
                        Decode.succeed Notch

                    _ ->
                        Decode.fail "Not an filter type"
            )
