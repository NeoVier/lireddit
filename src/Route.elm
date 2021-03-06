module Route exposing (Route(..), fromUrl, linkToRoute, previousPage, replaceUrl)

import Browser.Navigation as Nav
import Element exposing (..)
import Post.PostId as PostId exposing (PostId)
import Token as Token exposing (Token)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)



-- ROUTING


type Route
    = Home
    | Register
    | Login
    | ForgotPassword
    | ChangePassword Token
    | CreatePost
    | Post PostId
    | EditPost PostId


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Register (s "register")
        , Parser.map Login (s "login")
        , Parser.map ChangePassword (s "change-password" </> Token.urlParser)
        , Parser.map ForgotPassword (s "change-password")
        , Parser.map CreatePost (s "create-post")
        , Parser.map Post (s "post" </> PostId.urlParser)
        , Parser.map EditPost (s "edit-post" </> PostId.urlParser)
        ]



-- PUBLIC HELPERS


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toString route)


previousPage : Nav.Key -> Cmd msg
previousPage key =
    Nav.back key 1


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser


linkToRoute :
    List (Attribute msg)
    -> { route : Route, label : Element msg }
    -> Element msg
linkToRoute attrs { route, label } =
    link attrs { url = toString route, label = label }



-- INTERNAL


toString : Route -> String
toString page =
    "/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Register ->
            [ "register" ]

        Login ->
            [ "login" ]

        ChangePassword token ->
            [ "change-password", token ]

        ForgotPassword ->
            [ "change-password" ]

        CreatePost ->
            [ "create-post" ]

        Post postId ->
            [ "post", PostId.toString postId ]

        EditPost postId ->
            [ "edit-post", PostId.toString postId ]
