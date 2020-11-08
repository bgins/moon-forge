module Instrument exposing (Instrument(..), decoder)

import Json.Decode as Decode exposing (Decoder)


type Instrument
    = Luna


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
