defmodule TwitterFeed.Web.Router do
  alias TwitterFeed.Web
  use Web, :router

  import Web.Plug.LoadAuthUser, only: [authenticate_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {Web.LayoutView, :app}
    plug Web.Plug.LoadAuthUser
  end

  scope "/", Web do
    pipe_through :browser

    get "/signin", SessionController, :signin
    post "/signin", SessionController, :create_session
    get "/twitter-callback", SessionController, :twitter_hook

    scope "/" do
      pipe_through [:authenticate_user]

      get "/", PageController, :index
      get "/friend/:id", PageController, :friend

      get "/signout", SessionController, :delete_session
    end

    get "/*path", PageController, :catch_all
  end
end
