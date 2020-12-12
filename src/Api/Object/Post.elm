-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Post exposing (..)

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


id : SelectionSet Float Api.Object.Post
id =
    Object.selectionForField "Float" "id" [] Decode.float


title : SelectionSet String Api.Object.Post
title =
    Object.selectionForField "String" "title" [] Decode.string


text : SelectionSet String Api.Object.Post
text =
    Object.selectionForField "String" "text" [] Decode.string


points : SelectionSet Float Api.Object.Post
points =
    Object.selectionForField "Float" "points" [] Decode.float


creatorId : SelectionSet Float Api.Object.Post
creatorId =
    Object.selectionForField "Float" "creatorId" [] Decode.float


createdAt : SelectionSet String Api.Object.Post
createdAt =
    Object.selectionForField "String" "createdAt" [] Decode.string


updatedAt : SelectionSet String Api.Object.Post
updatedAt =
    Object.selectionForField "String" "updatedAt" [] Decode.string


textSnippet : SelectionSet String Api.Object.Post
textSnippet =
    Object.selectionForField "String" "textSnippet" [] Decode.string
