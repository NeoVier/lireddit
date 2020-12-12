-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Query exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias PostsOptionalArguments =
    { cursor : OptionalArgument String }


type alias PostsRequiredArguments =
    { limit : Int }


posts :
    (PostsOptionalArguments -> PostsOptionalArguments)
    -> PostsRequiredArguments
    -> SelectionSet decodesTo Api.Object.Post
    -> SelectionSet (List decodesTo) RootQuery
posts fillInOptionals requiredArgs object_ =
    let
        filledInOptionals =
            fillInOptionals { cursor = Absent }

        optionalArgs =
            [ Argument.optional "cursor" filledInOptionals.cursor Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "posts" (optionalArgs ++ [ Argument.required "limit" requiredArgs.limit Encode.int ]) object_ (identity >> Decode.list)


type alias PostRequiredArguments =
    { id : Float }


post :
    PostRequiredArguments
    -> SelectionSet decodesTo Api.Object.Post
    -> SelectionSet (Maybe decodesTo) RootQuery
post requiredArgs object_ =
    Object.selectionForCompositeField "post" [ Argument.required "id" requiredArgs.id Encode.float ] object_ (identity >> Decode.nullable)


me :
    SelectionSet decodesTo Api.Object.User
    -> SelectionSet (Maybe decodesTo) RootQuery
me object_ =
    Object.selectionForCompositeField "me" [] object_ (identity >> Decode.nullable)
