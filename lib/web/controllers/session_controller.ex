defmodule TwitterFeed.Web.SessionController do
  use TwitterFeed.Web, :controller

  require Logger

  alias TwitterFeed.Accounts

  def signin(%{assigns: %{current_user: %{id: _}}} = conn, _) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def signin(conn, _) do
    render conn, "new.html", path: Routes.session_path(conn, :create_session), title: "Sign in"
  end

  def create_session(conn, _params) do
    token =
      conn
      |> Routes.session_url(:twitter_hook)
      |> ExTwitter.request_token

    Logger.debug("token: #{inspect(token)}")

    {:ok, authenticate_url} = ExTwitter.authenticate_url(token.oauth_token)
    redirect conn, external: authenticate_url
  end


  def twitter_hook(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    {:ok, access_token} = ExTwitter.access_token(verifier, token)

    ExTwitter.configure(
      :process,
      Enum.concat(
        ExTwitter.Config.get_tuples,
        [access_token: access_token.oauth_token, access_token_secret: access_token.oauth_token_secret]
      )
    )

    user_info = ExTwitter.verify_credentials()

    Logger.debug("User info: #{inspect(user_info)}")

    params = %{
      id: user_info.id,
      access_token: access_token.oauth_token,
      access_token_secret: access_token.oauth_token_secret
    }

    {:ok, user} = Accounts.create_user(params)

    IO.inspect user, label: "user"

    # Fetch friends
    conn
    |> set_current_user(user)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def delete_session(conn, _) do
    conn
    |> clear_session
    |> redirect(to: Routes.session_path(conn, :signin))
  end

  defp set_current_user(conn, %Accounts.User{id: id} = user) do
    Logger.debug("Setting current user to #{inspect(user)}")

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, id)
    |> configure_session(renew: true)
  end
end

