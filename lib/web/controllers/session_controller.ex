defmodule TwitterFeed.Web.SessionController do
  use TwitterFeed.Web, :controller

  require Logger

  alias TwitterFeed.Accounts

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @friend_added Application.get_env(:twitter_feed, :events)[:friend_added]

  @spec signin(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec create_session(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec twitter_hook(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec delete_session(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec set_current_user(Plug.Conn.t(), Accounts.User.t()) :: Plug.Conn.t()


  def signin(%{assigns: %{current_user: %{id: _}}} = conn, _) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def signin(conn, _) do
    render conn, "new.html", path: Routes.session_path(conn, :create_session), title: "Sign in"
  end

  def create_session(conn, _) do
    token =
      conn
      |> Routes.session_url(:twitter_hook)
      |> ExTwitter.request_token

    Logger.debug("token: #{inspect(token)}")

    {:ok, authenticate_url} = ExTwitter.authenticate_url(token.oauth_token)
    redirect conn, external: authenticate_url
  end


  def twitter_hook(conn, %{"oauth_token" => t, "oauth_verifier" => v}) do
    {:ok, at = %{oauth_token: ot, oauth_token_secret: ots}} = ExTwitter.access_token(v, t)

    Logger.debug("access_token: #{inspect(at)}")

    ExTwitter.configure(
      :process,
      [
        consumer_key: Application.get_env(:extwitter, :oauth)[:consumer_key],
        consumer_secret: Application.get_env(:extwitter, :oauth)[:consumer_secret],
        access_token: ot,
        access_token_secret: ots
      ]
    )

    %{id: user_id} = user_info = ExTwitter.verify_credentials()

    Logger.debug("user_info: #{inspect(user_info)}")

    params =
      user_info
      |> params_from_result
      |> Map.put(:access_token, ot)
      |> Map.put(:access_token_secret, ots)

    {:ok, user} = Accounts.create_user(params)

    Logger.debug("user: #{inspect(user)}")

    # Fetch friends
    friends =
      user_id
      |> ExTwitter.friend_ids
      |> Map.get(:items, [])

    Logger.info("Spawn a process to fetch and add friends...")

    spawn(fn ->
      friends
      |> Enum.map(&create_friend/1)
      |> Enum.each(fn
        {:ok, friend} ->
          Phoenix.PubSub.broadcast(TwitterFeed.PubSub,
            @friends_topic, {@friends_topic, @friend_added, friend})
        _ -> nil
      end)
      TwitterFeed.Accounts.add_friends(user_id, friends)
      Logger.info("Done adding friends.")
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

