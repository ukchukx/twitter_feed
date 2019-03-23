defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(%{assigns: %{current_user: user = %{id: _}}} = conn, _) do
    %{friends: friends} = TwitterFeed.Accounts.load_friends(user)

    render conn, "index.html",
      user: user,
      title: "Friends",
      friends: friends
  end

  def index(conn, _), do: redirect(conn, to: Routes.session_path(conn, :signin))

  @spec friend(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def friend(%{assigns: %{current_user: user = %{id: _}}} = conn, %{"id" => id}) do
    friend = TwitterFeed.Accounts.get_user_by_id(id)

    render conn, "show.html",
      user: user,
      title: friend.name,
      friend: friend
  end

  @spec friend_tweets(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def friend_tweets(%{assigns: %{current_user: %{id: id}}} = conn, %{"id" => friend_id}) do
    tweets =
      TwitterFeed.Accounts.get_last_tweet(id, friend_id)
      |> case do
        nil -> [user_id: friend_id]
        tweet_id -> [user_id: friend_id, since_id: tweet_id]
      end
      |> ExTwitter.user_timeline
      |> Enum.map(&Map.from_struct/1)
      # |> Enum.map(fn m -> Map.drop(m, [:user]) end)
      |> Enum.map(&(Map.get(&1, :id_str)))

    # IO.inspect Enum.at tweets, 0

    json(conn, %{data: %{tweets: tweets}})
  end

  @spec save_last_tweet(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def save_last_tweet(%{assigns: %{current_user: %{id: id}}} = conn, %{"tweet" => tweet, "friend" => f_id}) do
    tweet =
      tweet
      |> case  do
        x when is_integer(x) -> x
        x -> x |> Integer.parse |> elem(0) # Convert string to integer
      end

    case TwitterFeed.Accounts.save_last_tweet(id, f_id, tweet) do
      {:ok, _} -> json(conn, %{success: true})
      {:error, _} -> json(conn, %{success: false})
    end
  end

  @spec catch_all(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def catch_all(conn, _), do: redirect(conn, to: Routes.page_path(conn, :index))
end
