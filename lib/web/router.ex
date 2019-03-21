defmodule TwitterFeed.Web.Router do
  use TwitterFeed.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TwitterFeed.Web.Plug.LoadAuthUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitterFeed.Web do
    pipe_through :browser

    get "/", PageController, :index
    get "/friend/:id", PageController, :friend
    get "/tweets/:id", PageController, :friend_tweets
    post "/last-tweet", PageController, :save_last_tweet

    get "/signin", SessionController, :signin
    post "/signin", SessionController, :create_session
    get "/signout", SessionController, :delete_session
    get "/twitter-callback", SessionController, :twitter_hook

    get "/*path", PageController, :catch_all
  end
end
