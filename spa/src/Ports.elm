port module Ports exposing (adjustAudioParam, initializeInstrument)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)



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



-- CONTROLLER


{-| Enable or disable computer keyboard

This is the default controller. When the keyboard is enabled, Midi controllers
are disabled. When Midi controllers are enabled, the keyboard is disabled. It is
possible to disable all devices.

-}
port enableKeyboard : () -> Cmd msg


port disableKeyboard : () -> Cmd msg


{-| Enable, disable, or select Midi devices

getMidiDevices enables Midi control and requests a list of available devices.

setMidiDevice sets the active Midi device in WebMidi.

onMidiDevicesRequest receives a list of available Midi devices.

WebMidi control has not been implemented in all browsers. If WebMidi is not
available, getMidiDevices will return an empty list.

-}
port getMidiDevices : () -> Cmd msg


port setMidiDevice : String -> Cmd msg


port onMidiDevicesRequest : (Encode.Value -> msg) -> Sub msg


updateMidiDevices : (MidiDevicesPortMessage -> msg) -> Sub msg
updateMidiDevices toMsg =
    onMidiDevicesRequest <|
        \value ->
            toMsg <|
                case Decode.decodeValue decodeMidiDevices value of
                    Ok midiDevicesPortMessage ->
                        midiDevicesPortMessage

                    Err err ->
                        MidiDevicesPortMessage [] ""


type alias MidiDevicesPortMessage =
    { midiDevices : List String
    , selectedMidiDevice : String
    }


decodeMidiDevices : Decode.Decoder MidiDevicesPortMessage
decodeMidiDevices =
    Decode.succeed MidiDevicesPortMessage
        |> required "midiDevices" (Decode.list Decode.string)
        |> required "selectedMidiDevice" Decode.string
