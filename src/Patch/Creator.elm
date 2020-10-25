module Patch.Creator exposing (Creator, user)


type Creator
    = Factory
    | User String
    | Community String


user : String -> Creator
user username =
    User username
