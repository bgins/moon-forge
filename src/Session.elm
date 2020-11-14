module Session exposing (Session, changes, creator, isLoading, loading)

import Creator exposing (Creator)
import Ports


type Session
    = LoggedIn Creator
    | Loading
    | Guest


loading : Session
loading =
    Loading


creator : Session -> Maybe Creator
creator session =
    case session of
        LoggedIn val ->
            Just val

        Loading ->
            Nothing

        Guest ->
            Nothing


isLoading : Session -> Bool
isLoading session =
    case session of
        Loading ->
            True

        _ ->
            False



-- CHANGES


changes : (Session -> msg) -> Sub msg
changes toMsg =
    Ports.creatorChanges
        (\maybeCreator -> toMsg (fromCreator maybeCreator))
        Creator.decoder


fromCreator : Maybe Creator -> Session
fromCreator maybeCreator =
    case maybeCreator of
        Just val ->
            LoggedIn val

        Nothing ->
            Guest
