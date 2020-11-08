port module Ports exposing
    ( adjustAudioParam
    , disableKeyboard
    , enableKeyboard
    , getMidiDevices
    , gotPatches
    , initializeInstrument
    , loadPatches
    , midiDevicesChanged
    , setMidiDevice
    )

import Controller exposing (Devices, devicesDecoder)
import Html.Attributes exposing (disabled)
import Json.Decode as Decode
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



-- PATCH


port initializeInstrument : Value -> Cmd msg


port loadPatches : Value -> Cmd msg


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
