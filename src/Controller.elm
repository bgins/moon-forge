module Controller exposing (Controller(..), Devices, devicesDecoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type Controller
    = MIDI (Maybe Devices)
    | Keyboard


type alias Devices =
    { selected : String
    , available : List String
    }


encode : Controller -> Value
encode controller =
    Encode.string (controllerToString controller)


controllerToString : Controller -> String
controllerToString controller =
    case controller of
        MIDI _ ->
            "midi"

        Keyboard ->
            "keyboard"


devicesDecoder : Decoder Devices
devicesDecoder =
    Decode.succeed Devices
        |> required "selected" Decode.string
        |> required "available" (Decode.list Decode.string)
