defmodule TwitterFeed.Web.SessionController do
  use TwitterFeed.Web, :controller

  require Logger

  alias TwitterFeed.Accounts

  @spec signin(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec create_session(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec twitter_hook(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec delete_session(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec set_current_user(Plug.Conn.t(), Accounts.User.t()) :: Plug.Conn.t()

  def signin(%{assigns: %{current_user: %{id: _}}} = conn, _) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def signin(conn, _) do
    render(conn, "new.html", path: Routes.session_path(conn, :create_session), title: "Sign in")
  end

  def create_session(conn, _) do
    url = Routes.session_url(conn, :twitter_hook)
    Logger.info("Callback url #{url}")
    token = ExTwitter.request_token(url)
    # token =
    #   conn
    #   |> Routes.session_url(:twitter_hook)
    #   |> ExTwitter.request_token

    {:ok, url} = ExTwitter.authenticate_url(token.oauth_token)
    Logger.info("Redirecting to #{url} for authentication")
    redirect(conn, external: url)
  end

  def twitter_hook(conn, %{"oauth_token" => t, "oauth_verifier" => v}) do
    {:ok, %{oauth_token: ot, oauth_token_secret: ots}} = ExTwitter.access_token(v, t)
    config = Application.get_env(:extwitter, :oauth)

    ExTwitter.configure(
      :process,
      consumer_key: config[:consumer_key],
      consumer_secret: config[:consumer_secret],
      access_token: ot,
      access_token_secret: ots
    )

    %{id: user_id} = user_info = ExTwitter.verify_credentials()

    params =
      user_info
      |> params_from_result
      |> Map.put(:access_token, ot)
      |> Map.put(:access_token_secret, ots)

    {:ok, user} = Accounts.create_user(params)

    # Fetch friends
    spawn(fn ->
      TwitterFeed.Accounts.fetch_friends(user_id)
    end)

    conn
    |> set_current_user(user)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def delete_session(conn, _) do
    conn
    |> clear_session
    |> redirect(to: Routes.session_path(conn, :signin))
  end

  defp set_current_user(conn, %Accounts.User{id: id, username: username} = user) do
    Logger.info("Setting current user to @#{username}")

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, id)
    |> configure_session(renew: true)
  end

  defp params_from_result(result) do
    %{
      id: result.id,
      username: result.screen_name,
      name: result.name,
      profile_img: result.profile_image_url_https
    }
  end
end
