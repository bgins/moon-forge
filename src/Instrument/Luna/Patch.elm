module Instrument.Luna.Patch exposing (Patch, decoder, encode, init)

import Filter exposing (Filter(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Oscillator exposing (Oscillator(..))
import Tuning exposing (Tuning)


type alias Patch =
    { oscillator : Oscillator
    , ampEnvAttack : Float
    , ampEnvDecay : Float
    , ampEnvSustain : Float
    , ampEnvRelease : Float
    , filter : Filter
    , filterFreq : Float
    , filterQ : Float
    , filterEnvAttack : Float
    , filterEnvDecay : Float
    , filterEnvSustain : Float
    , filterEnvRelease : Float
    , gain : Float
    , tuning : Tuning
    }


init : Patch
init =
    { oscillator = Square
    , ampEnvAttack = 0.05
    , ampEnvDecay = 0.05
    , ampEnvSustain = 1
    , ampEnvRelease = 0.5
    , filter = Lowpass
    , filterFreq = 20000
    , filterQ = 0
    , filterEnvAttack = 0.05
    , filterEnvDecay = 0.05
    , filterEnvSustain = 1
    , filterEnvRelease = 0.5
    , gain = 0.5
    , tuning =
        Tuning.equal
            { baseFrequency = 261.625
            , baseMidiNote = 60
            , period = 1200
            , divisions = 12
            }
    }


encode : Patch -> Value
encode patch =
    Encode.object
        [ ( "oscillator", Oscillator.encode patch.oscillator )
        , ( "ampEnvAttack", Encode.float patch.ampEnvAttack )
        , ( "ampEnvDecay", Encode.float patch.ampEnvDecay )
        , ( "ampEnvSustain", Encode.float patch.ampEnvSustain )
        , ( "ampEnvRelease", Encode.float patch.ampEnvRelease )
        , ( "filter", Filter.encode patch.filter )
        , ( "filterFreq", Encode.float patch.filterFreq )
        , ( "filterQ", Encode.float patch.filterQ )
        , ( "filterEnvAttack", Encode.float patch.filterEnvAttack )
        , ( "filterEnvDecay", Encode.float patch.filterEnvDecay )
        , ( "filterEnvSustain", Encode.float patch.filterEnvSustain )
        , ( "filterEnvRelease", Encode.float patch.filterEnvRelease )
        , ( "gain", Encode.float patch.gain )
        , ( "tuning", Tuning.encode patch.tuning )
        ]


decoder : Decoder Patch
decoder =
    Decode.succeed Patch
        |> required "oscillator" Oscillator.decoder
        |> required "ampEnvAttack" Decode.float
        |> required "ampEnvDecay" Decode.float
        |> required "ampEnvSustain" Decode.float
        |> required "ampEnvRelease" Decode.float
        |> required "filter" Filter.decoder
        |> required "filterFreq" Decode.float
        |> required "filterQ" Decode.float
        |> required "filterEnvAttack" Decode.float
        |> required "filterEnvDecay" Decode.float
        |> required "filterEnvSustain" Decode.float
        |> required "filterEnvRelease" Decode.float
        |> required "gain" Decode.float
        |> required "tuning" Tuning.decoder
