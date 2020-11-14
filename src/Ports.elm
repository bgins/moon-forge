port module Ports exposing
    ( adjustAudioParam
    , creatorChanges
    , deletePatch
    , disableKeyboard
    , enableKeyboard
    , getMidiDevices
    , gotPatch
    , gotPatches
    , loadPatch
    , login
    , midiDevicesChanged
    , patchInstrument
    , setMidiDevice
    , storePatch
    )

import Controller exposing (Devices, devicesDecoder)
import Creator exposing (Creator)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Patch.Metadata exposing (PatchMetadata)



-- CONTROLS


{-| Update instrument parameters in web audio

At the moment, the parameters are tightly coupled and need to be changed on both
sides.

-}
port updateAudioParam : Encode.Value -> Cmd msg


adjustAudioParam : String -> Encode.Value -> Cmd msg
adjustAudioParam name val =
    updateAudioParam <|
        Encode.object
            [ ( "name", Encode.string name )
            , ( "val", val )
            ]



-- AUTH


port login : () -> Cmd msg


port onAuthChange : (Value -> msg) -> Sub msg


creatorChanges : (Maybe creator -> msg) -> Decoder creator -> Sub msg
creatorChanges toMsg decoder =
    onAuthChange
        (\val ->
            Decode.decodeValue decoder val
                |> Result.toMaybe
                |> toMsg
        )



-- PATCH


port patchInstrument : Value -> Cmd msg


port onPatches : (Encode.Value -> msg) -> Sub msg


gotPatches : (List PatchMetadata -> msg) -> Sub msg
gotPatches toMsg =
    onPatches <|
        \value ->
            toMsg <|
                case Decode.decodeValue (Decode.list Patch.Metadata.decoder) value of
                    Ok patches ->
                        patches

                    Err err ->
                        []


port loadPatch : Value -> Cmd msg


port onPatch : (Encode.Value -> msg) -> Sub msg


gotPatch :
    Decoder a
    -> (Maybe { metadata : PatchMetadata, patch : a } -> msg)
    -> Sub msg
gotPatch patchDecoder toMsg =
    onPatch <|
        \value ->
            toMsg <|
                case Decode.decodeValue Patch.Metadata.decoder value of
                    Ok metadata ->
                        case
                            Decode.decodeValue
                                (Decode.field "patch" patchDecoder)
                                value
                        of
                            Ok patch ->
                                Just
                                    { metadata = metadata
                                    , patch = patch
                                    }

                            Err err ->
                                Nothing

                    Err err ->
                        Nothing


port storePatch : Value -> Cmd msg


port deletePatch : Value -> Cmd msg



-- CONTROLLER


{-| Enable or disable computer keyboard

This is the default controller. When the keyboard is enabled, Midi controllers
are disabled. When Midi controllers are enabled, the keyboard is disabled.

-}
port enableKeyboard : () -> Cmd msg


port disableKeyboard : () -> Cmd msg


{-| Enable, disable, or select Midi devices

getMidiDevices enables Midi control and requests a list of available devices.

setMidiDevice sets the active Midi device in WebMidi.

onMidiDevices receives a list of available Midi devices.

WebMidi control has not been implemented in all browsers. If WebMidi is not
available, getMidiDevices will return an empty list.

-}
port getMidiDevices : () -> Cmd msg


port setMidiDevice : String -> Cmd msg


port onMidiDevices : (Encode.Value -> msg) -> Sub msg


midiDevicesChanged : (Maybe Devices -> msg) -> Sub msg
midiDevicesChanged toMsg =
    onMidiDevices <|
        \value ->
            toMsg <|
                case Decode.decodeValue devicesDecoder value of
                    Ok devices ->
                        Just devices

                    Err err ->
                        Nothing
