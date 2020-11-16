module Patch.Metadata exposing
    ( PatchMetadata
    , decoder
    , encode
    , init
    , new
    )

import Creator as Creator exposing (Creator)
import Element.Input exposing (username)
import Instrument exposing (Instrument(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
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


new : Creator -> Instrument -> PatchMetadata
new user instrument =
    { name = ""
    , instrument = instrument
    , creator = user
    , category = Basses
    , tags = []
    , description = ""
    , public = False
    }


encode : PatchMetadata -> Value
encode metadata =
    Encode.object
        [ ( "name", Encode.string metadata.name )
        , ( "instrument", Instrument.encode metadata.instrument )
        , ( "creator", Creator.encode metadata.creator )
        , ( "category", Patch.Category.encode metadata.category )
        , ( "tags", Encode.list Encode.string metadata.tags )
        , ( "description", Encode.string metadata.description )
        , ( "public", Encode.bool metadata.public )
        ]


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
