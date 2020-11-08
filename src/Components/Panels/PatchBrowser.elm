module Components.Panels.PatchBrowser exposing
    ( PatchBrowser
    , deletePatch
    , init
    , loadPatch
    , savePatch
    , view
    )

import Creator exposing (Creator)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onFocus, onLoseFocus)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes exposing (property)
import Html.Events exposing (onInput)
import Instrument exposing (Instrument)
import Json.Encode as Encode
import Material.Icons.Round as Icons exposing (category)
import Material.Icons.Types exposing (Coloring(..))
import Patch.Category exposing (PatchCategory(..))
import Patch.Metadata exposing (PatchMetadata)
import Svg
import UI.Colors as Colors
import UI.Fonts as Fonts


type PatchBrowser
    = PatchBrowser Internals


type alias Internals =
    { username : String
    , instrument : Instrument
    , currentPatch : PatchMetadata
    , allPatches : List PatchMetadata
    , editMode : EditMode
    , editablePatch : PatchMetadata
    , categoryFilter : PatchCategory
    , creatorFilter : Creator
    }


type EditMode
    = Creating
    | Editing
    | NotEditing



-- API


init :
    { username : String
    , instrument : Instrument
    , currentPatch : PatchMetadata
    , allPatches : List PatchMetadata
    }
    -> PatchBrowser
init options =
    PatchBrowser
        { username = options.username
        , instrument = options.instrument
        , currentPatch = options.currentPatch
        , allPatches = options.allPatches
        , editMode = NotEditing
        , editablePatch = Patch.Metadata.new options.username options.instrument
        , categoryFilter = Basses
        , creatorFilter = Creator.factory
        }


loadPatch : PatchMetadata -> PatchBrowser -> PatchBrowser
loadPatch patch patchBrowser =
    patchBrowser
        |> mapCurrentPatch (\_ -> patch)


savePatch : PatchMetadata -> PatchBrowser -> PatchBrowser
savePatch patch patchBrowser =
    patchBrowser
        |> updatePatches patch
        |> mapEditMode (\_ -> NotEditing)
        |> mapCreatorFilter (\_ -> patch.creator)
        |> mapCategoryFilter (\_ -> patch.category)
        |> mapCurrentPatch (\_ -> patch)


updatePatches : PatchMetadata -> PatchBrowser -> PatchBrowser
updatePatches patch patchBrowser =
    case editMode patchBrowser of
        Creating ->
            patchBrowser
                |> mapPatches
                    (\patches ->
                        patch :: patches
                    )

        Editing ->
            patchBrowser
                |> mapPatches
                    (\patches ->
                        patch
                            :: List.filter
                                (\p -> p /= currentPatch patchBrowser)
                                patches
                    )

        NotEditing ->
            patchBrowser


deletePatch : PatchMetadata -> PatchBrowser -> PatchBrowser
deletePatch patch patchBrowser =
    patchBrowser
        |> mapPatches
            (\patches ->
                List.filter
                    (\p -> p /= patch)
                    patches
            )
        |> (\browser ->
                case
                    List.filter
                        (\p ->
                            (p.creator == patch.creator)
                                && (p.category == patch.category)
                                && (p /= patch)
                        )
                        (allPatches patchBrowser)
                of
                    p :: ps ->
                        mapCurrentPatch (\_ -> p) browser

                    [] ->
                        browser
                            |> mapCreatorFilter (\_ -> Creator.factory)
                            |> mapCategoryFilter (\_ -> Basses)
                            |> mapCurrentPatch (\_ -> Patch.Metadata.init (instrument patchBrowser))
           )



-- ACCESS


username : PatchBrowser -> String
username (PatchBrowser internals) =
    internals.username


instrument : PatchBrowser -> Instrument
instrument (PatchBrowser internals) =
    internals.instrument


currentPatch : PatchBrowser -> PatchMetadata
currentPatch (PatchBrowser internals) =
    internals.currentPatch


editablePatch : PatchBrowser -> PatchMetadata
editablePatch (PatchBrowser internals) =
    internals.editablePatch


allPatches : PatchBrowser -> List PatchMetadata
allPatches (PatchBrowser internals) =
    internals.allPatches


editMode : PatchBrowser -> EditMode
editMode (PatchBrowser internals) =
    internals.editMode


categoryFilter : PatchBrowser -> PatchCategory
categoryFilter (PatchBrowser internals) =
    internals.categoryFilter


creatorFilter : PatchBrowser -> Creator
creatorFilter (PatchBrowser internals) =
    internals.creatorFilter



-- UPDATE


mapCurrentPatch : (PatchMetadata -> PatchMetadata) -> PatchBrowser -> PatchBrowser
mapCurrentPatch transform (PatchBrowser internals) =
    PatchBrowser
        { internals | currentPatch = transform internals.currentPatch }


mapPatches : (List PatchMetadata -> List PatchMetadata) -> PatchBrowser -> PatchBrowser
mapPatches transform (PatchBrowser internals) =
    PatchBrowser
        { internals | allPatches = transform internals.allPatches }


mapEditMode : (EditMode -> EditMode) -> PatchBrowser -> PatchBrowser
mapEditMode transform (PatchBrowser internals) =
    PatchBrowser
        { internals | editMode = transform internals.editMode }


mapEditablePatch : (PatchMetadata -> PatchMetadata) -> PatchBrowser -> PatchBrowser
mapEditablePatch transform (PatchBrowser internals) =
    PatchBrowser
        { internals | editablePatch = transform internals.editablePatch }


mapCategoryFilter : (PatchCategory -> PatchCategory) -> PatchBrowser -> PatchBrowser
mapCategoryFilter transform (PatchBrowser internals) =
    PatchBrowser
        { internals | categoryFilter = transform internals.categoryFilter }


mapCreatorFilter : (Creator -> Creator) -> PatchBrowser -> PatchBrowser
mapCreatorFilter transform (PatchBrowser internals) =
    PatchBrowser
        { internals | creatorFilter = transform internals.creatorFilter }



-- VIEW


view :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    , onLoadPatch : PatchMetadata -> msg
    , onStorePatch : PatchMetadata -> msg
    , onDeletePatch : PatchMetadata -> msg
    , onInputFocus : msg
    , onInputLoseFocus : msg
    }
    -> Element msg
view options =
    column
        [ centerX
        , width (px 500)
        , spacing 5
        ]
        [ row
            [ centerX
            , height (px 300)
            , paddingXY 10 6
            , Background.color Colors.lightestGrey
            , Border.color Colors.darkestGrey
            , Border.rounded 7
            , Border.widthEach { bottom = 2, left = 2, right = 2, top = 2 }
            , Font.color Colors.darkestGrey
            , Font.family Fonts.quattrocento
            , Font.size 12
            ]
            [ column [ width fill, height fill ]
                [ row
                    [ width fill
                    , height (px 30)
                    , Font.family Fonts.quattrocento
                    , Font.size 18
                    ]
                    [ text "Presets"
                    , viewEditorIcons
                        { patchBrowser = options.patchBrowser
                        , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                        , onDeletePatch = options.onDeletePatch
                        }
                    ]
                , row
                    [ width fill
                    , height fill
                    , paddingXY 5 2
                    , spacing 5
                    ]
                    [ viewFilterPanel
                        { patchBrowser = options.patchBrowser
                        , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                        }
                    , viewSelectionPanel
                        { patchBrowser = options.patchBrowser
                        , onLoadPatch = options.onLoadPatch
                        }
                    , case editMode options.patchBrowser of
                        Creating ->
                            viewEditorPanel
                                { patchBrowser = options.patchBrowser
                                , onStorePatch = options.onStorePatch
                                , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                                , onInputFocus = options.onInputFocus
                                , onInputLoseFocus = options.onInputLoseFocus
                                }

                        Editing ->
                            viewEditorPanel
                                { patchBrowser = options.patchBrowser
                                , onStorePatch = options.onStorePatch
                                , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                                , onInputFocus = options.onInputFocus
                                , onInputLoseFocus = options.onInputLoseFocus
                                }

                        NotEditing ->
                            viewDescriptionPanel options.patchBrowser
                    ]
                , row [ paddingXY 5 2 ]
                    [ viewCreatorSelector
                        { patchBrowser = options.patchBrowser
                        , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                        }
                    ]
                ]
            ]
        ]


viewEditorIcons :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    , onDeletePatch : PatchMetadata -> msg
    }
    -> Element msg
viewEditorIcons options =
    let
        patch =
            currentPatch options.patchBrowser
    in
    row
        [ alignRight
        , paddingXY 2 0
        , spacing 3
        , Font.color Colors.darkGrey
        ]
    <|
        addIcon
            { patchBrowser = options.patchBrowser
            , onUpdatePatchBrowser = options.onUpdatePatchBrowser
            }
            :: (if Creator.canEdit patch.creator then
                    [ editIcon
                        { patchBrowser = options.patchBrowser
                        , onUpdatePatchBrowser = options.onUpdatePatchBrowser
                        }
                    , deleteIcon
                        { patchBrowser = options.patchBrowser
                        , onDeletePatch = options.onDeletePatch
                        }
                    ]

                else
                    []
               )


viewFilterPanel :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    }
    -> Element msg
viewFilterPanel { patchBrowser, onUpdatePatchBrowser } =
    column
        [ width (px 95)
        , height fill
        , Border.width 1
        , Border.color Colors.lightGrey
        , Border.rounded 2
        ]
        [ row
            [ width fill
            , Border.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
            , Border.color Colors.lightGrey
            ]
            [ el
                [ centerX
                , paddingXY 0 3
                , Font.size 12
                ]
                (text "Category")
            ]
        , row [ width fill ]
            [ Input.radio
                [ width fill ]
                { onChange =
                    \category ->
                        onUpdatePatchBrowser <|
                            mapCategoryFilter
                                (\_ -> category)
                                patchBrowser
                , options =
                    List.map categoryOption Patch.Category.all
                , selected =
                    Just <|
                        categoryFilter patchBrowser
                , label = Input.labelHidden "Category options"
                }
            ]
        ]


categoryOption : PatchCategory -> Input.Option PatchCategory msg
categoryOption category =
    Input.optionWith category <|
        \optionState ->
            row
                [ width fill
                , paddingXY 3 3
                , case optionState of
                    Input.Idle ->
                        Background.color Colors.lightestGrey

                    Input.Focused ->
                        Background.color Colors.lightestGrey

                    Input.Selected ->
                        Background.color Colors.lightGrey
                , Font.size 11
                , Font.color Colors.darkGrey
                ]
                [ text (Patch.Category.toString category) ]


viewSelectionPanel :
    { patchBrowser : PatchBrowser
    , onLoadPatch : PatchMetadata -> msg
    }
    -> Element msg
viewSelectionPanel { patchBrowser, onLoadPatch } =
    column
        [ width (px 190)
        , height fill
        , Border.width 1
        , Border.color Colors.lightGrey
        , Border.rounded 2
        ]
        [ column
            [ width fill
            , height (px 230)
            , clipY
            , scrollbarY
            ]
            [ Input.radio [ width fill ]
                { onChange =
                    \patchMetadata ->
                        onLoadPatch patchMetadata
                , options =
                    allPatches patchBrowser
                        |> List.filter
                            (\patch ->
                                patch.creator == creatorFilter patchBrowser
                            )
                        |> List.filter
                            (\patch ->
                                patch.category == categoryFilter patchBrowser
                            )
                        |> List.map patchOption
                , selected =
                    Just <|
                        currentPatch patchBrowser
                , label = Input.labelHidden "Patch options"
                }
            ]
        ]


patchOption : PatchMetadata -> Input.Option PatchMetadata msg
patchOption patch =
    Input.optionWith patch <|
        \optionState ->
            row
                [ width fill
                , paddingXY 3 3
                , case optionState of
                    Input.Idle ->
                        Background.color Colors.lightestGrey

                    Input.Focused ->
                        Background.color Colors.lightestGrey

                    Input.Selected ->
                        Background.color Colors.lightGrey
                , Font.size 11
                , Font.color Colors.darkGrey
                ]
                [ text patch.name ]


viewEditorPanel :
    { patchBrowser : PatchBrowser
    , onStorePatch : PatchMetadata -> msg
    , onUpdatePatchBrowser : PatchBrowser -> msg
    , onInputFocus : msg
    , onInputLoseFocus : msg
    }
    -> Element msg
viewEditorPanel { patchBrowser, onStorePatch, onUpdatePatchBrowser, onInputFocus, onInputLoseFocus } =
    let
        patch =
            editablePatch patchBrowser

        nameExists =
            List.any (\p -> patch.name == p.name) (allPatches patchBrowser)
    in
    column
        [ width (px 190)
        , height fill
        , paddingXY 4 5
        , spacing 10
        ]
        [ column [ width fill, spacing 4 ]
            [ Input.text
                [ padding 2
                , Background.color Colors.lightestGrey
                , Border.color Colors.lightGrey
                , Border.width 1
                , Border.rounded 1
                , focused
                    [ Background.color Colors.offWhite
                    , Border.shadow
                        { offset = ( 0, 0 )
                        , blur = 0
                        , color = rgb 0 0 0
                        , size = 0
                        }
                    , Border.color (rgb 0.5 0.5 0.5)
                    ]
                , onFocus onInputFocus
                , onLoseFocus onInputLoseFocus
                ]
                { onChange =
                    \name ->
                        onUpdatePatchBrowser <|
                            mapEditablePatch
                                (\_ -> { patch | name = name })
                                patchBrowser
                , text = patch.name
                , placeholder =
                    Just <|
                        Input.placeholder [] (text "Name your patch")
                , label = Input.labelAbove [] (text "Name")
                }
            , viewNameValidationError patch patchBrowser
            ]
        , Input.multiline
            [ height (px 70)
            , padding 2
            , Background.color Colors.lightestGrey
            , Border.color Colors.lightGrey
            , Border.width 1
            , Border.rounded 1
            , focused
                [ Background.color Colors.offWhite
                , Border.shadow
                    { offset = ( 0, 0 )
                    , blur = 0
                    , color = rgb 0 0 0
                    , size = 0
                    }
                , Border.color (rgb 0.5 0.5 0.5)
                ]
            , onFocus onInputFocus
            , onLoseFocus onInputLoseFocus
            ]
            { onChange =
                \description ->
                    onUpdatePatchBrowser <|
                        mapEditablePatch
                            (\_ -> { patch | description = description })
                            patchBrowser
            , text = patch.description
            , placeholder =
                Just <|
                    Input.placeholder [] (text "Describe your patch")
            , label = Input.labelAbove [] (text "Description")
            , spellcheck = False
            }
        , Input.radioRow
            [ centerX
            , width fill
            , Border.width 1
            , Border.color Colors.lightGrey
            , Font.size 10
            ]
            { onChange =
                \category ->
                    onUpdatePatchBrowser <|
                        mapEditablePatch
                            (\_ -> { patch | category = category })
                            patchBrowser
            , options =
                List.map editorCategoryOption Patch.Category.all
            , selected =
                Just <|
                    patch.category
            , label =
                Input.labelAbove
                    [ paddingEach { bottom = 5, left = 0, top = 0, right = 0 }
                    ]
                    (text "Category")
            }
        , row [ width fill, spacing 5 ]
            [ if
                not (String.isEmpty patch.name)
                    && (String.length patch.name < 30)
              then
                case editMode patchBrowser of
                    Creating ->
                        if
                            not <|
                                List.any (\p -> patch.name == p.name) (allPatches patchBrowser)
                        then
                            Input.button
                                [ width fill
                                , paddingXY 0 3
                                , Border.width 1
                                , Border.color Colors.purple
                                , mouseOver [ Background.color Colors.lightPurple ]
                                ]
                                { onPress =
                                    Just <|
                                        onStorePatch <|
                                            editablePatch patchBrowser
                                , label =
                                    el [ centerX ] (text "Save")
                                }

                        else
                            none

                    Editing ->
                        Input.button
                            [ width fill
                            , paddingXY 0 3
                            , Border.width 1
                            , Border.color Colors.purple
                            , mouseOver [ Background.color Colors.lightPurple ]
                            ]
                            { onPress =
                                Just <|
                                    onStorePatch <|
                                        editablePatch patchBrowser
                            , label =
                                el [ centerX ] (text "Overwrite")
                            }

                    NotEditing ->
                        none

              else
                none
            , Input.button
                [ width fill
                , paddingXY 0 3
                , Border.width 1
                , Border.color Colors.purple
                , mouseOver [ Background.color Colors.lightPurple ]
                ]
                { onPress =
                    Just <|
                        onUpdatePatchBrowser <|
                            mapEditMode
                                (\_ -> NotEditing)
                                patchBrowser
                , label = el [ centerX ] (text "Cancel")
                }
            ]
        ]


viewNameValidationError : PatchMetadata -> PatchBrowser -> Element msg
viewNameValidationError patch patchBrowser =
    if String.length patch.name >= 30 then
        el [ Font.size 10, Font.color Colors.red ]
            (text "Name must be less than 30 characters")

    else
        case editMode patchBrowser of
            Creating ->
                if List.any (\p -> patch.name == p.name) (allPatches patchBrowser) then
                    el [ Font.size 10, Font.color Colors.red ]
                        (text "A patch with this name already exists")

                else
                    none

            _ ->
                none


editorCategoryOption : PatchCategory -> Input.Option PatchCategory msg
editorCategoryOption category =
    Input.optionWith category <|
        \optionState ->
            column
                [ width (px 45)
                , paddingXY 0 3
                , case optionState of
                    Input.Idle ->
                        Background.color Colors.lightestGrey

                    Input.Focused ->
                        Background.color Colors.lightestGrey

                    Input.Selected ->
                        Background.color Colors.lightPurple
                , Font.size 11
                , Font.color Colors.darkGrey
                ]
                [ el [ centerX ] <|
                    text (Patch.Category.toString category)
                ]


viewDescriptionPanel :
    PatchBrowser
    -> Element msg
viewDescriptionPanel (PatchBrowser internals) =
    let
        patch =
            internals.currentPatch
    in
    column
        [ width (px 190)
        , height fill
        , Border.width 1
        , Border.color Colors.lightGrey
        , Border.rounded 2
        ]
        [ column
            [ width fill
            , height (px 230)
            , spacing 5
            , scrollbarY
            ]
            [ row
                [ width fill
                , paddingXY 5 3
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color Colors.lightGrey
                , Font.size 12
                ]
                [ text patch.name ]
            , paragraph [ paddingXY 5 0, Font.size 11 ]
                [ text patch.description ]
            ]
        ]


viewCreatorSelector :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    }
    -> Element msg
viewCreatorSelector { patchBrowser, onUpdatePatchBrowser } =
    row
        [ width (px 95), height (px 20) ]
        [ Input.radioRow
            [ width fill
            , Border.width 1
            , Border.color Colors.lightGrey
            , Font.size 12
            ]
            { onChange =
                \choice ->
                    onUpdatePatchBrowser <|
                        mapCreatorFilter
                            (\_ -> choice)
                            patchBrowser
            , options =
                [ Input.optionWith
                    Creator.factory
                    (creatorOption "Factory")
                , Input.optionWith
                    (Creator.user (username patchBrowser))
                    (creatorOption "User")
                ]
            , selected = Just <| creatorFilter patchBrowser
            , label = Input.labelHidden "Creator options"
            }
        ]


creatorOption : String -> (Input.OptionState -> Element msg)
creatorOption label =
    \optionState ->
        row
            [ width (px 47)
            , paddingXY 0 2
            , case optionState of
                Input.Idle ->
                    Background.color Colors.lightestGrey

                Input.Focused ->
                    Background.color Colors.darkestGrey

                Input.Selected ->
                    Background.color Colors.lightPurple
            ]
            [ row [ centerX ] [ text label ] ]


addIcon :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    }
    -> Element msg
addIcon { patchBrowser, onUpdatePatchBrowser } =
    el
        [ onClick <|
            onUpdatePatchBrowser <|
                mapEditablePatch
                    (\_ ->
                        Patch.Metadata.new
                            (username patchBrowser)
                            (instrument patchBrowser)
                    )
                <|
                    mapEditMode
                        (\_ -> Creating)
                        patchBrowser
        ]
    <|
        html <|
            Icons.add 15 Inherit


editIcon :
    { patchBrowser : PatchBrowser
    , onUpdatePatchBrowser : PatchBrowser -> msg
    }
    -> Element msg
editIcon { patchBrowser, onUpdatePatchBrowser } =
    el
        [ onClick <|
            onUpdatePatchBrowser <|
                mapEditablePatch
                    (\_ ->
                        currentPatch patchBrowser
                    )
                <|
                    mapEditMode
                        (\_ -> Editing)
                        patchBrowser
        ]
    <|
        html <|
            Icons.edit 15 Inherit


deleteIcon :
    { patchBrowser : PatchBrowser
    , onDeletePatch : PatchMetadata -> msg
    }
    -> Element msg
deleteIcon { patchBrowser, onDeletePatch } =
    el
        [ onClick <|
            onDeletePatch (currentPatch patchBrowser)
        ]
    <|
        html <|
            Icons.delete 15 Inherit
