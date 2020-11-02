module Patch.Metadata exposing (PatchMetadata, init, new)

import Creator as Creator exposing (Creator)
import Element.Input exposing (username)
import Instrument exposing (Instrument(..))
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
