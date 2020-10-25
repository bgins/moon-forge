module Patch.Metadata exposing (Metadata)

import Element.Input exposing (username)
import Patch.Category exposing (Category(..))
import Patch.Creator as Creator exposing (Creator)


type alias Metadata =
    { name : String
    , instrument : String
    , creator : Creator
    , category : Category
    , tags : List String
    , description : String
    , public : Bool
    }


init : String -> Metadata
init username =
    { name = ""
    , instrument = ""
    , creator = Creator.user username
    , category = Basses
    , tags = []
    , description = ""
    , public = False
    }
