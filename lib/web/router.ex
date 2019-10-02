defmodule TwitterFeed.Web.Router do
  use TwitterFeed.Web, :router

  import TwitterFeed.Web.Plug.LoadAuthUser, only: [authenticate_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TwitterFeed.Web.Plug.LoadAuthUser
  end

  scope "/", TwitterFeed.Web do
    pipe_through :browser

    get "/signin", SessionController, :signin
    post "/signin", SessionController, :create_session
    get "/twitter-callback", SessionController, :twitter_hook

    scope "/" do
      pipe_through [:authenticate_user]

      get "/", PageController, :index
      get "/friend/:id", PageController, :friend
      get "/tweets/:id", PageController, :friend_tweets
      post "/last-tweet", PageController, :save_last_tweet

      get "/signout", SessionController, :delete_session
    end

    get "/*path", PageController, :catch_all
  end
end
