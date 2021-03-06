module Page.Home exposing
    ( Model(..)
    , Msg
    , init
    , toSession
    , update
    , updateSession
    , view
    )

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Post as Post
import Api.Query as Query
import Browser
import Components.Button as Button
import Components.LinkButton exposing (linkButton)
import Components.Loader as Loader
import Components.Variant as Variant
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import GraphQL exposing (GraphQLResult, mutation, postSelection, postsWithSnippetSelection, query)
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)
import Post exposing (PaginatedPosts, Post, PostWithUser)
import Post.PostId as PostId
import Route
import Session exposing (Session)
import User exposing (User)



-- MODEL


type Model
    = WithData { session : Session, posts : List PostWithUser }
    | Loading { session : Session, posts : List PostWithUser }
    | NoMoreData { session : Session, posts : List PostWithUser }
    | Voting
        { session : Session
        , posts : List PostWithUser
        , votingOn : PostWithUser
        , hadData : Bool
        }
    | Deleting
        { session : Session
        , posts : List PostWithUser
        , deleting : PostWithUser
        , hadData : Bool
        }


paginationLimit : Int
paginationLimit =
    10


init : Session -> ( Model, Cmd Msg )
init session =
    ( Loading
        { session = session
        , posts = []
        }
    , fetchPosts (Session.apiUrl session) { limit = paginationLimit, cursor = Nothing }
    )



-- MESSAGE


type Msg
    = GotPosts (GraphQLResult PaginatedPosts)
    | RequestedPosts
    | RequestedVote PostWithUser Bool
    | Voted (GraphQLResult Post)
    | RequestedDelete PostWithUser
    | DeletedPost (GraphQLResult Bool)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        posts =
            case model of
                WithData wd ->
                    wd.posts

                Loading l ->
                    l.posts

                NoMoreData n ->
                    n.posts

                Voting v ->
                    v.posts

                Deleting d ->
                    d.posts

        isInitialLoad =
            case model of
                Loading l ->
                    List.isEmpty l.posts

                _ ->
                    False

        showButton =
            case model of
                WithData wd ->
                    True

                Loading l ->
                    True

                NoMoreData nmd ->
                    False

                Voting { hadData } ->
                    hadData

                Deleting { hadData } ->
                    hadData
    in
    { title = "LiReddit"
    , body =
        [ layoutWith { options = [ noStaticStyleSheet ] }
            [ width fill, height fill ]
            (column [ spacing 40, width fill, height fill ]
                [ if isInitialLoad then
                    Loader.dots
                        [ centerX
                        , centerY
                        ]
                        { radius = 30, color = "rgb(31, 107, 142)" }

                  else
                    column
                        [ spacing 60
                        , paddingEach { top = 0, left = 0, right = 0, bottom = 50 }
                        , width <| maximum 1000 fill
                        , centerX
                        ]
                    <|
                        List.map (viewPost model) posts
                            ++ [ el
                                    [ centerX
                                    , paddingEach
                                        { top = 0
                                        , left = 0
                                        , right = 0
                                        , bottom = 100
                                        }
                                    ]
                                 <|
                                    if not showButton then
                                        el [ Font.color <| rgb 0.7 0.7 0.7 ] <|
                                            text "You've reached the end"

                                    else
                                        Button.button
                                            []
                                            { onClick = Just RequestedPosts
                                            , variant = Variant.Teal
                                            , state =
                                                case model of
                                                    Loading _ ->
                                                        Button.Loading

                                                    Voting { hadData } ->
                                                        Button.Enabled "More posts"

                                                    WithData _ ->
                                                        Button.Enabled "More posts"

                                                    NoMoreData _ ->
                                                        Button.Enabled "No more data"

                                                    Deleting _ ->
                                                        Button.Enabled "More posts"
                                            }
                               ]
                ]
            )
        ]
    }


viewPost : Model -> PostWithUser -> Element Msg
viewPost model post =
    let
        loggedIn =
            toSession model
                |> Session.getUser
                |> Maybe.map (\_ -> True)
                |> Maybe.withDefault False

        voting =
            case model of
                Voting { votingOn } ->
                    votingOn == post

                _ ->
                    False

        votedPositive =
            if not loggedIn then
                False

            else
                case post.voteStatus of
                    Just True ->
                        True

                    _ ->
                        False

        votedNegative =
            if not loggedIn then
                False

            else
                case post.voteStatus of
                    Just False ->
                        True

                    _ ->
                        False

        isDeleting =
            case model of
                Deleting { deleting } ->
                    deleting == post

                _ ->
                    False
    in
    row
        [ Border.rounded 4
        , Border.glow (rgba 0.2 0.2 0.2 0.12) 2
        , spacing 30
        , paddingXY 20 50
        , width fill
        ]
        [ column
            [ centerY, spacing 15 ]
            [ Button.button
                []
                { onClick =
                    if votedPositive || not loggedIn then
                        Nothing

                    else
                        Just <| RequestedVote post True
                , variant =
                    if votedPositive then
                        Variant.Green

                    else
                        Variant.Gray
                , state =
                    if voting then
                        Button.Loading

                    else
                        Button.Enabled "/\\"
                }
            , el [ centerX, Font.size 16 ] <| text <| String.fromFloat post.points
            , Button.button
                []
                { onClick =
                    if votedNegative || not loggedIn then
                        Nothing

                    else
                        Just <| RequestedVote post False
                , variant =
                    if votedNegative then
                        Variant.Red

                    else
                        Variant.Gray
                , state =
                    if voting then
                        Button.Loading

                    else
                        Button.Enabled "\\/"
                }
            ]
        , column [ width fill, spacing 20, height fill ]
            [ column [ spacing 10, width fill ]
                [ Route.linkToRoute [ Font.bold ]
                    { route = Route.Post post.id, label = text post.title }
                , paragraph [ Font.color <| rgb 0.7 0.7 0.7, Font.size 18 ]
                    [ text "posted by "
                    , el [ Font.semiBold ] <| text post.creator.username
                    ]
                ]
            , paragraph [] [ text post.text ]
            ]
        , case Session.getUser (toSession model) of
            Nothing ->
                none

            Just user ->
                if user.id == post.creator.id then
                    column [ alignRight, alignTop, spacing 20 ]
                        [ Button.button []
                            { onClick =
                                if isDeleting then
                                    Nothing

                                else
                                    Just <| RequestedDelete post
                            , variant = Variant.Gray
                            , state =
                                if isDeleting then
                                    Button.Loading

                                else
                                    Button.Enabled "Delete"
                            }
                        , linkButton [ width fill ]
                            { route = Route.EditPost post.id
                            , variant = Variant.Gray
                            , label = el [ centerX ] <| text "Edit"
                            }
                        ]

                else
                    none
        ]



-- UPDATE


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case ( msg, model ) of
        ( GotPosts (Ok paginatedPosts), Loading l ) ->
            if paginatedPosts.hasMore then
                ( WithData { l | posts = l.posts ++ paginatedPosts.posts }
                , Cmd.none
                )

            else
                ( NoMoreData { l | posts = l.posts ++ paginatedPosts.posts }, Cmd.none )

        ( GotPosts _, _ ) ->
            ( model, Cmd.none )

        ( RequestedPosts, WithData wd ) ->
            let
                maybeLastPost =
                    List.drop (List.length wd.posts - 1) wd.posts
                        |> List.head
            in
            case maybeLastPost of
                Nothing ->
                    ( model, Cmd.none )

                Just lastPost ->
                    ( Loading wd
                    , fetchPosts (Session.apiUrl wd.session)
                        { limit = paginationLimit, cursor = Just lastPost.createdAt }
                    )

        ( RequestedVote post isPositive, WithData wd ) ->
            ( Voting
                { session = wd.session
                , posts = wd.posts
                , votingOn = post
                , hadData = True
                }
            , vote (Session.apiUrl wd.session)
                { isPositive = isPositive, postId = PostId.getId post.id }
            )

        ( RequestedVote post isPositive, NoMoreData nmd ) ->
            ( Voting
                { session = nmd.session
                , posts = nmd.posts
                , votingOn = post
                , hadData = False
                }
            , vote (Session.apiUrl nmd.session)
                { isPositive = isPositive, postId = PostId.getId post.id }
            )

        ( Voted (Ok post), Voting v ) ->
            let
                modelObj =
                    { session = v.session
                    , posts = renewPostVotes post v.posts
                    }
            in
            if v.hadData then
                ( WithData modelObj, Cmd.none )

            else
                ( NoMoreData modelObj, Cmd.none )

        ( RequestedDelete post, WithData wd ) ->
            ( Deleting
                { session = wd.session
                , posts = wd.posts
                , deleting = post
                , hadData = True
                }
            , deletePost (Session.apiUrl wd.session) post.id
            )

        ( RequestedDelete post, NoMoreData nmd ) ->
            ( Deleting
                { session = nmd.session
                , posts = nmd.posts
                , deleting = post
                , hadData = False
                }
            , deletePost (Session.apiUrl nmd.session) post.id
            )

        ( DeletedPost (Ok True), Deleting d ) ->
            let
                modelObj =
                    { session = d.session
                    , posts = List.filter (\p -> p /= d.deleting) d.posts
                    }
            in
            if d.hadData then
                ( WithData modelObj, Cmd.none )

            else
                ( NoMoreData modelObj, Cmd.none )

        -- Invalid messages
        ( RequestedPosts, _ ) ->
            ( model, Cmd.none )

        ( RequestedVote _ _, _ ) ->
            ( model, Cmd.none )

        ( Voted _, _ ) ->
            ( model, Cmd.none )

        ( RequestedDelete _, _ ) ->
            ( model, Cmd.none )

        ( DeletedPost _, _ ) ->
            ( model, Cmd.none )


renewPostVotes : Post -> List PostWithUser -> List PostWithUser
renewPostVotes newPost oldPosts =
    case List.head oldPosts of
        Just op ->
            if op.id == newPost.id then
                { op | points = newPost.points, voteStatus = newPost.voteStatus }
                    :: List.drop 1 oldPosts

            else
                op :: renewPostVotes newPost (List.drop 1 oldPosts)

        Nothing ->
            oldPosts



-- EXPORT


toSession : Model -> Session
toSession model =
    case model of
        WithData wd ->
            wd.session

        Loading l ->
            l.session

        NoMoreData n ->
            n.session

        Voting v ->
            v.session

        Deleting d ->
            d.session


updateSession : Model -> Maybe User -> ( Model, Cmd Msg )
updateSession model maybeUser =
    case model of
        WithData wd ->
            ( WithData { wd | session = Session.updateSession wd.session maybeUser }
            , Cmd.none
            )

        Loading l ->
            ( Loading { l | session = Session.updateSession l.session maybeUser }
            , Cmd.none
            )

        NoMoreData n ->
            ( NoMoreData { n | session = Session.updateSession n.session maybeUser }
            , Cmd.none
            )

        Voting v ->
            ( Voting { v | session = Session.updateSession v.session maybeUser }
            , Cmd.none
            )

        Deleting d ->
            ( Deleting { d | session = Session.updateSession d.session maybeUser }
            , Cmd.none
            )



-- GRAPHQL


fetchPosts : String -> { limit : Int, cursor : Maybe String } -> Cmd Msg
fetchPosts apiUrl { limit, cursor } =
    query apiUrl
        (Query.posts (\args -> { args | cursor = OptionalArgument.fromMaybe cursor })
            { limit = limit }
            postsWithSnippetSelection
        )
        GotPosts


vote : String -> { isPositive : Bool, postId : Int } -> Cmd Msg
vote apiUrl args =
    mutation apiUrl (Mutation.vote args postSelection) Voted


deletePost : String -> PostId.PostId -> Cmd Msg
deletePost apiUrl postId =
    mutation apiUrl (Mutation.deletePost { id = PostId.getId postId }) DeletedPost
