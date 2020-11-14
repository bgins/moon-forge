module Instrument exposing (Instrument(..), decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Instrument
    = Luna


encode : Instrument -> Value
encode instrument =
    Encode.string <|
        String.toLower (toString instrument)


toString : Instrument -> String
toString instrument =
    case instrument of
        Luna ->
            "Luna"


decoder : Decoder Instrument
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "luna" ->
                        Decode.succeed Luna

                    _ ->
                        Decode.fail "Not a valid instrument"
            )
