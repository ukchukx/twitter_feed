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

    Logger.debug("access_token: #{inspect(access_token)}")

    ExTwitter.configure(
      :process,
      [
        consumer_key: Application.get_env(:extwitter, :oauth)[:consumer_key],
        consumer_secret: Application.get_env(:extwitter, :oauth)[:consumer_secret],
        access_token: access_token.oauth_token,
        access_token_secret: access_token.oauth_token_secret
      ]
    )

    %{id: user_id} = user_info = ExTwitter.verify_credentials()

    Logger.debug("user_info: #{inspect(user_info)}")

    params =
      user_info
      |> params_from_result
      |> Map.put(:access_token, access_token.oauth_token)
      |> Map.put(:access_token_secret, access_token.oauth_token_secret)

    {:ok, user} = Accounts.create_user(params)

    Logger.debug("user: #{inspect(user)}")

    # Fetch friends
    friends =
      user_id
      |> ExTwitter.friend_ids
      |> Map.get(:items, [])

    Logger.warn("Spawn a process to fetch and add friends...")

    spawn(fn ->
      Enum.each(friends, &(create_friend(&1)))
      TwitterFeed.Accounts.add_friends(user_id, friends)
      Logger.warn("Done adding friends.")
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
    Logger.warn("Setting current user to @#{username}")

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, id)
    |> configure_session(renew: true)
  end

  defp create_friend(id) do
    id
    |> ExTwitter.user
    |> Map.from_struct
    |> params_from_result
    |> Accounts.create_user
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

