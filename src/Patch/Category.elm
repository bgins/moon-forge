module Patch.Category exposing (PatchCategory(..), all, toString)


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
