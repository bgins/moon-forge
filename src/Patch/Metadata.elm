module Patch.Metadata exposing (PatchMetadata, decoder, init, new)

import Creator as Creator exposing (Creator)
import Element.Input exposing (username)
import Instrument exposing (Instrument(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Patch.Category exposing (PatchCategory(..))


type alias PatchMetadata =
    { name : String
    , instrument : Instrument
    , creator : Creator
    , category : PatchCategory
    , tags : List String
    , description : String
    , public : Bool
    }


init : Instrument -> PatchMetadata
init instrument =
    { name = "Init"
    , instrument = instrument
    , creator = Creator.factory
    , category = Basses
    , tags = []
    , description = "Init Square"
    , public = False
    }


new : String -> Instrument -> PatchMetadata
new username instrument =
    { name = ""
    , instrument = instrument
    , creator = Creator.user username
    , category = Basses
    , tags = []
    , description = ""
    , public = False
    }


decoder : Decoder PatchMetadata
decoder =
    Decode.succeed PatchMetadata
        |> required "name" Decode.string
        |> required "instrument" Instrument.decoder
        |> required "creator" Creator.decoder
        |> required "category" Patch.Category.decoder
        |> required "tags" (Decode.list Decode.string)
        |> required "description" Decode.string
        |> required "public" Decode.bool
