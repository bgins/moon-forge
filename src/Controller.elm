module Controller exposing (Controller(..), Devices, devicesDecoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Controller
    = MIDI (Maybe Devices)
    | Keyboard


type alias Devices =
    { selected : String
    , available : List String
    }


devicesDecoder : Decoder Devices
devicesDecoder =
    Decode.succeed Devices
        |> required "selected" Decode.string
        |> required "available" (Decode.list Decode.string)
