module Tuning exposing
    ( Tuning
    , decoder
    , divisions
    , editableDivisions
    , editableFrequency
    , editableMidiNote
    , editablePeriod
    , encode
    , equal
    , frequency
    , mapDivisions
    , mapEditableDivisions
    , mapEditableFrequency
    , mapEditableMidiNote
    , mapEditablePeriod
    , mapFrequency
    , mapMidiNote
    , mapPeriod
    , midiNote
    , period
    , validateDivisions
    , validateEditableDivisions
    , validateEditableFrequency
    , validateEditableMidiNote
    , validateEditablePeriod
    , validateFrequency
    , validateMidiNote
    , validatePeriod
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)


type Tuning
    = Equal Basis EqualInfo


type alias Basis =
    { frequency : ( Float, String )
    , midiNote : ( Int, String )
    }


type alias EqualInfo =
    { period : ( Float, String )
    , divisions : ( Int, String )
    }


equal :
    { baseFrequency : Float
    , baseMidiNote : Int
    , period : Float
    , divisions : Int
    }
    -> Tuning
equal options =
    Equal
        { frequency =
            ( options.baseFrequency
            , String.fromFloat options.baseFrequency
            )
        , midiNote =
            ( options.baseMidiNote
            , String.fromInt options.baseMidiNote
            )
        }
        { period =
            ( options.period
            , String.fromFloat options.period
            )
        , divisions =
            ( options.divisions
            , String.fromInt options.divisions
            )
        }



-- BASIS


frequency : Tuning -> Float
frequency (Equal basis _) =
    Tuple.first basis.frequency


editableFrequency : Tuning -> String
editableFrequency (Equal basis _) =
    Tuple.second basis.frequency


midiNote : Tuning -> Int
midiNote (Equal basis _) =
    Tuple.first basis.midiNote


editableMidiNote : Tuning -> String
editableMidiNote (Equal basis _) =
    Tuple.second basis.midiNote


mapFrequency : (Float -> Float) -> Tuning -> Tuning
mapFrequency transform tuning =
    case tuning of
        Equal basis equalInfo ->
            Equal
                { basis
                    | frequency =
                        Tuple.pair
                            (transform <| Tuple.first basis.frequency)
                            (Tuple.second basis.frequency)
                }
                equalInfo


mapEditableFrequency : (String -> String) -> Tuning -> Tuning
mapEditableFrequency transform tuning =
    case tuning of
        Equal basis equalInfo ->
            Equal
                { basis
                    | frequency =
                        Tuple.pair
                            (Tuple.first basis.frequency)
                            (transform <| Tuple.second basis.frequency)
                }
                equalInfo


mapMidiNote : (Int -> Int) -> Tuning -> Tuning
mapMidiNote transform tuning =
    case tuning of
        Equal basis equalInfo ->
            Equal
                { basis
                    | midiNote =
                        Tuple.pair
                            (transform <| Tuple.first basis.midiNote)
                            (Tuple.second basis.midiNote)
                }
                equalInfo


mapEditableMidiNote : (String -> String) -> Tuning -> Tuning
mapEditableMidiNote transform tuning =
    case tuning of
        Equal basis equalInfo ->
            Equal
                { basis
                    | midiNote =
                        Tuple.pair
                            (Tuple.first basis.midiNote)
                            (transform <| Tuple.second basis.midiNote)
                }
                equalInfo


validateFrequency : Maybe Float -> Float
validateFrequency maybeFreq =
    case maybeFreq of
        Just freq ->
            if freq > 30 && freq < 18000 then
                freq

            else
                261.625

        Nothing ->
            261.625


validateEditableFrequency : String -> String
validateEditableFrequency val =
    case String.toFloat val of
        Just freq ->
            if freq > 30 && freq < 18000 then
                val

            else
                "261.625"

        Nothing ->
            "261.625"


validateMidiNote : Maybe Int -> Int
validateMidiNote maybeMidiNote =
    case maybeMidiNote of
        Just note ->
            if note >= 0 && note <= 127 then
                note

            else
                60

        Nothing ->
            60


validateEditableMidiNote : String -> String
validateEditableMidiNote val =
    case String.toInt val of
        Just note ->
            if note >= 0 && note <= 127 then
                val

            else
                "60"

        Nothing ->
            "60"



-- EQUALINFO


period : Tuning -> Float
period (Equal _ equalInfo) =
    Tuple.first equalInfo.period


editablePeriod : Tuning -> String
editablePeriod (Equal _ equalInfo) =
    Tuple.second equalInfo.period


divisions : Tuning -> Int
divisions (Equal _ equalInfo) =
    Tuple.first equalInfo.divisions


editableDivisions : Tuning -> String
editableDivisions (Equal _ equalInfo) =
    Tuple.second equalInfo.divisions


mapPeriod : (Float -> Float) -> Tuning -> Tuning
mapPeriod transform (Equal basis equalInfo) =
    Equal
        basis
        { equalInfo
            | period =
                Tuple.pair
                    (transform <| Tuple.first equalInfo.period)
                    (Tuple.second equalInfo.period)
        }


mapEditablePeriod : (String -> String) -> Tuning -> Tuning
mapEditablePeriod transform (Equal basis equalInfo) =
    Equal
        basis
        { equalInfo
            | period =
                Tuple.pair
                    (Tuple.first equalInfo.period)
                    (transform <| Tuple.second equalInfo.period)
        }


mapDivisions : (Int -> Int) -> Tuning -> Tuning
mapDivisions transform (Equal basis equalInfo) =
    Equal
        basis
        { equalInfo
            | divisions =
                Tuple.pair
                    (transform <| Tuple.first equalInfo.divisions)
                    (Tuple.second equalInfo.divisions)
        }


mapEditableDivisions : (String -> String) -> Tuning -> Tuning
mapEditableDivisions transform (Equal basis equalInfo) =
    Equal
        basis
        { equalInfo
            | divisions =
                Tuple.pair
                    (Tuple.first equalInfo.divisions)
                    (transform <| Tuple.second equalInfo.divisions)
        }


validatePeriod : Maybe Int -> Int
validatePeriod maybePeriod =
    case maybePeriod of
        Just prd ->
            if prd > 0 && prd <= 15600 then
                prd

            else
                1200

        Nothing ->
            1200


validateEditablePeriod : String -> String
validateEditablePeriod val =
    case String.toFloat val of
        Just prd ->
            if prd > 0 && prd <= 15600 then
                val

            else
                "1200"

        Nothing ->
            "1200"


validateDivisions : Maybe Int -> Int
validateDivisions maybeDivisions =
    case maybeDivisions of
        Just divs ->
            if divs > 0 && divs <= 196608 then
                divs

            else
                12

        Nothing ->
            12


validateEditableDivisions : String -> String
validateEditableDivisions val =
    case String.toInt val of
        Just divs ->
            if divs > 0 && divs <= 196608 then
                val

            else
                "12"

        Nothing ->
            "12"



-- ENCODE


encode : Tuning -> Value
encode tuning =
    case tuning of
        Equal basis equalInfo ->
            Encode.object
                [ ( "variant", Encode.string "equal" )
                , ( "baseFrequency", Encode.float <| frequency tuning )
                , ( "baseMidiNote", Encode.int <| midiNote tuning )
                , ( "period", Encode.float <| period tuning )
                , ( "divisions", Encode.int <| divisions tuning )
                ]



-- DECODE


decoder : Decoder Tuning
decoder =
    Decode.field "variant" Decode.string
        |> Decode.andThen
            (\variant ->
                case variant of
                    "equal" ->
                        Decode.succeed Equal
                            |> custom basisDecoder
                            |> custom equalInfoDecoder

                    _ ->
                        Decode.fail "Invalid tuning variant"
            )


basisDecoder : Decoder Basis
basisDecoder =
    Decode.succeed Basis
        |> required "baseFrequency"
            (Decode.map
                (\freq ->
                    ( freq, String.fromFloat freq )
                )
                Decode.float
            )
        |> required "baseMidiNote"
            (Decode.map
                (\note ->
                    ( note, String.fromInt note )
                )
                Decode.int
            )


equalInfoDecoder : Decoder EqualInfo
equalInfoDecoder =
    Decode.succeed EqualInfo
        |> required "period"
            (Decode.map
                (\prd ->
                    ( prd, String.fromFloat prd )
                )
                Decode.float
            )
        |> required "divisions"
            (Decode.map
                (\divs ->
                    ( divs, String.fromInt divs )
                )
                Decode.int
            )
