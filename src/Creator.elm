module Creator exposing
    ( Creator
    , canEdit
    , decoder
    , encode
    , factory
    , toString
    , user
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Creator
    = Factory
    | User String
    | Community String


factory : Creator
factory =
    Factory


user : String -> Creator
user username =
    User username


canEdit : Creator -> Bool
canEdit creator =
    case creator of
        User username ->
            True

        _ ->
            False


toString : Creator -> String
toString creator =
    case creator of
        Factory ->
            "Factory"

        User name ->
            name

        Community name ->
            name


encode : Creator -> Value
encode creator =
    case creator of
        Factory ->
            Encode.object
                [ ( "type", Encode.string "factory" ) ]

        User name ->
            Encode.object
                [ ( "type", Encode.string "user" )
                , ( "name", Encode.string "name" )
                ]

        Community name ->
            Encode.object
                [ ( "type", Encode.string "community" )
                , ( "name", Encode.string "name" )
                ]


decoder : Decoder Creator
decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "factory" ->
                        Decode.succeed Factory

                    "user" ->
                        Decode.field "name" Decode.string
                            |> Decode.andThen
                                (\name ->
                                    Decode.succeed (User name)
                                )

                    "community" ->
                        Decode.field "name" Decode.string
                            |> Decode.andThen
                                (\name ->
                                    Decode.succeed (Community name)
                                )

                    _ ->
                        Decode.fail "Not a valid creator type"
            )
