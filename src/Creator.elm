module Creator exposing (Creator, canEdit, factory, toString, user)


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
