defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller

  def index(%{assigns: %{current_user: user = %{id: _}}} = conn, _) do
    %{friends: friends} = TwitterFeed.Accounts.load_friends(user)

    render conn, "index.html",
      user: user,
      title: "Friends",
      friends: friends
  end

  def index(conn, _), do: redirect(conn, to: Routes.session_path(conn, :signin))

  def friend(%{assigns: %{current_user: user = %{id: _}}} = conn, %{"id" => id}) do
    friend = TwitterFeed.Accounts.get_user_by_id(id)

    render conn, "show.html",
      user: user,
      title: friend.name,
      friend: friend
  end

  def friend_tweets(%{assigns: %{current_user: %{id: _}}} = conn, %{"id" => id}) do
    %{username: username} = TwitterFeed.Accounts.get_user_by_id(id)
    tweets =
      ExTwitter.user_timeline(screen_name: username)
      |> Enum.map(&Map.from_struct/1)
      # |> Enum.map(fn m -> Map.drop(m, [:user]) end)
      |> Enum.map(&(Map.get(&1, :id_str)))

    # IO.inspect Enum.at tweets, 0

    json(conn, %{data: %{tweets: tweets}})
  end

  def catch_all(conn, _), do: redirect(conn, to: Routes.page_path(conn, :index))
end
