module Components.Panels.PatchBrowser exposing (EditMode, PatchBrowser, init, view)

import Creator exposing (Creator)
import Element exposing (..)
import Patch.Category exposing (PatchCategory)
import Patch.Metadata exposing (PatchMetadata)


type PatchBrowser
    = PatchBrowser Internals


type alias Internals =
    { currentPatch : PatchMetadata
    , patches : List PatchMetadata
    , editMode : EditMode
    }


type EditMode
    = Editing
    | NotEditing


init : PatchMetadata -> List PatchMetadata -> PatchBrowser
init currentPatch allPatches =
    PatchBrowser
        { currentPatch = currentPatch
        , patches = allPatches
        , editMode = NotEditing
        }



-- UPDATE


mapCurrentPatch : (PatchMetadata -> PatchMetadata) -> PatchBrowser -> PatchBrowser
mapCurrentPatch transform (PatchBrowser internals) =
    PatchBrowser
        { currentPatch = transform internals.currentPatch
        , patches = internals.patches
        , editMode = internals.editMode
        }


mapPatches : (List PatchMetadata -> List PatchMetadata) -> PatchBrowser -> PatchBrowser
mapPatches transform (PatchBrowser internals) =
    PatchBrowser
        { currentPatch = internals.currentPatch
        , patches = transform internals.patches
        , editMode = internals.editMode
        }


mapEditMode : (EditMode -> EditMode) -> PatchBrowser -> PatchBrowser
mapEditMode transform (PatchBrowser internals) =
    PatchBrowser
        { currentPatch = internals.currentPatch
        , patches = internals.patches
        , editMode = transform internals.editMode
        }



-- VIEW


view :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    , onLoadPatch : PatchMetadata -> msg
    , onStorePatch : PatchMetadata -> msg
    , onDeletePatch : PatchMetadata -> msg
    , onInputFocus : msg
    }
    -> Element msg
view options =
    row [] [ text "test" ]
