module Creator exposing (Creator, factory, user)


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
