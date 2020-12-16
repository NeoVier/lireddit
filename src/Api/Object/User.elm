-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.User exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Int Api.Object.User
id =
    Object.selectionForField "Int" "id" [] Decode.int


username : SelectionSet String Api.Object.User
username =
    Object.selectionForField "String" "username" [] Decode.string


email : SelectionSet String Api.Object.User
email =
    Object.selectionForField "String" "email" [] Decode.string


createdAt : SelectionSet String Api.Object.User
createdAt =
    Object.selectionForField "String" "createdAt" [] Decode.string


updatedAt : SelectionSet String Api.Object.User
updatedAt =
    Object.selectionForField "String" "updatedAt" [] Decode.string
