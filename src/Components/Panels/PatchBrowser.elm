module Components.Panels.PatchBrowser exposing (EditMode(..), view)

import Element exposing (..)
import Patch.Category exposing (Category)
import Patch.Creator exposing (Creator)
import Patch.Metadata exposing (Metadata)


view :
    { currentPatch : Metadata -- GotPatch in parent updates current patch, highlight it here
    , patches : List Metadata -- LoadPatches in parent updates the list of all patches
    , editMode : EditMode
    , onLoadPatch : Metadata -> msg
    , onToggleEditMode : EditMode -> Metadata -> msg
    , onStorePatch : Metadata -> msg
    , onDeletePatch : Metadata -> msg
    , onFilterPatches : Creator -> Category -> msg
    , onInputFocus : msg
    }
    -> Element msg
view options =
    row [] []


type EditMode
    = Editing
    | NotEditing
