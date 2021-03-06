-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.PaginatedPosts exposing (..)

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


posts :
    SelectionSet decodesTo Api.Object.Post
    -> SelectionSet (List decodesTo) Api.Object.PaginatedPosts
posts object_ =
    Object.selectionForCompositeField "posts" [] object_ (identity >> Decode.list)


hasMore : SelectionSet Bool Api.Object.PaginatedPosts
hasMore =
    Object.selectionForField "Bool" "hasMore" [] Decode.bool
