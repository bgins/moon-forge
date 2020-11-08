module Patch.Category exposing (PatchCategory(..), all, decoder, toString)

import Json.Decode as Decode exposing (Decoder)


type PatchCategory
    = Basses
    | Leads
    | Keys
    | Pads


all : List PatchCategory
all =
    [ Basses, Leads, Keys, Pads ]


toString : PatchCategory -> String
toString category =
    case category of
        Basses ->
            "Basses"

        Leads ->
            "Leads"

        Keys ->
            "Keys"

        Pads ->
            "Pads"


decoder : Decoder PatchCategory
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "basses" ->
                        Decode.succeed Basses

                    "leads" ->
                        Decode.succeed Leads

                    "keys" ->
                        Decode.succeed Keys

                    "pads" ->
                        Decode.succeed Pads

                    _ ->
                        Decode.fail "Not a valid category"
            )
