module GraphQL exposing
    ( GraphQLResult
    , UserResult(..)
    , getSession
    , mutation
    , query
    , userResultSelection
    , userSelection
    )

import Api.Object exposing (UserResponse)
import Api.Object.FieldError as FieldError
import Api.Object.User as User
import Api.Object.UserResponse as UserResponse
import Api.Query as Query
import Browser.Navigation as Nav
import Graphql.Http exposing (Request)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import User exposing (User)



-- ENDPOINT


endpoint : String
endpoint =
    "http://localhost:4000/graphql"



-- TYPES


type alias GraphQLResult decodesTo =
    Result (Graphql.Http.Error decodesTo) decodesTo



-- MUTATION


mutation :
    SelectionSet decodesTo RootMutation
    -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg)
    -> Cmd msg
mutation selectionSet toMsg =
    selectionSet
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send toMsg



-- QUERY


query :
    SelectionSet decodesTo RootQuery
    -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg)
    -> Cmd msg
query selectionSet toMsg =
    selectionSet
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send toMsg


getSession : Nav.Key -> (GraphQLResult (Maybe User) -> msg) -> Cmd msg
getSession key toMsg =
    query (Query.me userSelection) toMsg



-- SELECTION SETS


type alias UserError =
    { field : String, message : String }


type alias UserResultIntermediary =
    { errors : Maybe (List UserError), user : Maybe User }


type UserResult
    = WithError (List UserError)
    | WithUser User


errorsSelection : SelectionSet UserError Api.Object.FieldError
errorsSelection =
    SelectionSet.map2 UserError FieldError.field FieldError.message


userSelection : SelectionSet User Api.Object.User
userSelection =
    SelectionSet.map2 User User.id User.username


userResultSelection : SelectionSet UserResult Api.Object.UserResponse
userResultSelection =
    SelectionSet.map2 UserResultIntermediary
        (UserResponse.errors errorsSelection)
        (UserResponse.user userSelection)
        |> SelectionSet.map
            (\{ errors, user } ->
                case ( errors, user ) of
                    ( Nothing, Nothing ) ->
                        WithError []

                    ( Just errs, _ ) ->
                        WithError errs

                    ( Nothing, Just u ) ->
                        WithUser u
            )
