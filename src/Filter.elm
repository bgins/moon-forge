module Filter exposing
    ( Filter(..)
    , encode
    , filterToString
    )

import Json.Encode as Encode exposing (Value)


type Filter
    = Lowpass
    | Highpass
    | Bandpass
    | Notch



encode : Filter-> Value
encode filter=
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

