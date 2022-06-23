defmodule TwitterFeed.Web.FriendListLiveView do
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @friend_added Application.get_env(:twitter_feed, :events)[:friend_added]
  @friend_updated Application.get_env(:twitter_feed, :events)[:friend_updated]
  @friend_removed Application.get_env(:twitter_feed, :events)[:friend_removed]

  def mount(%{user_id: id}, socket) do
    Phoenix.PubSub.subscribe(TwitterFeed.PubSub, @friends_topic)

    socket =
      socket
      |> assign(user_id: id)
      |> load_friends

    {:ok, socket}
  end

  def render(assigns), do: TwitterFeed.Web.PageView.render("friend-list.html", assigns)


  def handle_event("fetch-friends", _, %{assigns: %{user_id: user_id}} = socket) do
    spawn(fn -> TwitterFeed.Accounts.fetch_friends(user_id) end)
    {:noreply, assign(socket, friend_list: [], friends: %{})}
  end

  def handle_event("find_friend", %{"value" => term}, socket = %{assigns: %{friends: friends}}) do
    friend_list =
      term
      |> case do
        "" -> Map.values(friends)
        term ->
          friends
          |> Map.values()
          |> Enum.filter(fn %{name: n, username: u} ->
            contains_name? = n |> String.downcase() |> String.contains?(term)
            contains_username? = String.contains?(u, term)
            contains_username? or contains_name?
          end)
      end

    {:noreply, assign(socket, friend_list: friend_list)}
  end


  def handle_info({@friends_topic, @friend_added, %{id: id} = friend}, socket = %{assigns: %{friends: friends}}) do
    friends = Map.put(friends, id, friend)
    {:noreply, assign(socket, friends: friends, friend_list: Map.values(friends))}
  end

  def handle_info({@friends_topic, @friend_removed, %{id: id}}, socket = %{assigns: %{friends: friends}}) do
    friends = Map.delete(friends, id)
    {:noreply, assign(socket, friends: friends, friend_list: Map.values(friends))}
  end

  def handle_info({@friends_topic, @friend_updated, _}, socket) do
    {:noreply, load_friends(socket)}
  end

  defp load_friends(socket = %{assigns: %{user_id: id}}) do
    friends =
      id
      |> TwitterFeed.Accounts.get_friends()
      |> Enum.reduce(%{}, fn friend, map -> Map.put(map, friend.id, friend) end)

    assign(socket, friends: friends, friend_list: Map.values(friends))
  end
end
