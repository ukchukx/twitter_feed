defmodule TwitterFeed.Web.FriendListLiveView do
  alias TwitterFeed.Accounts.{Friend, User}
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @friend_added Application.get_env(:twitter_feed, :events)[:friend_added]
  @friend_updated Application.get_env(:twitter_feed, :events)[:friend_updated]
  @friend_removed Application.get_env(:twitter_feed, :events)[:friend_removed]

  def mount(_params, %{"user_id" => user_id}, socket) do
    Phoenix.PubSub.subscribe(TwitterFeed.PubSub, @friends_topic)

    socket =
      socket
      |> assign(user_id: user_id)
      |> load_friends

    {:ok, socket}
  end

  def render(assigns), do: TwitterFeed.Web.PageView.render("friend-list.html", assigns)

  def handle_event("fetch-friends", _, %{assigns: %{user_id: user_id}} = socket) do
    spawn(fn -> TwitterFeed.Accounts.fetch_friends(user_id) end)
    {:noreply, assign(socket, friend_list: [], friends: %{})}
  end

  def handle_event("mark-all", _, %{assigns: %{friends: friends, user_id: user_id}} = socket) do
    friends =
      friends
      |> Map.values()
      |> Enum.map(& &1.id)

    friends
    |> Enum.chunk_every(TwitterFeed.ideal_chunk_size(friends))
    |> Enum.each(&mark_latest_tweets(&1, user_id))

    {:noreply, socket}
  end

  def handle_event("find_friend", %{"value" => term}, socket = %{assigns: %{friends: friends}}) do
    friend_list =
      term
      |> case do
        "" ->
          Map.values(friends)

        term ->
          friends
          |> Map.values()
          |> Enum.filter(fn %{name: n, username: u} ->
            contains_name? = n |> String.downcase() |> String.contains?(term)
            contains_username? = u |> String.downcase() |> String.contains?(term)
            contains_username? or contains_name?
          end)
      end

    {:noreply, assign(socket, friend_list: friend_list)}
  end

  def handle_info(
        {@friends_topic, @friend_added, %{id: id} = friend},
        socket = %{assigns: %{friends: friends}}
      ) do
    friends = Map.put(friends, id, friend)
    {:noreply, assign(socket, friends: friends, friend_list: Map.values(friends))}
  end

  def handle_info(
        {@friends_topic, @friend_removed, %User{id: id}},
        socket = %{assigns: %{friends: friends}}
      ) do
    friends = Map.delete(friends, id)
    {:noreply, assign(socket, friends: friends, friend_list: Map.values(friends))}
  end

  def handle_info(
        {@friends_topic, @friend_removed, %Friend{friend_id: id}},
        socket = %{assigns: %{friends: friends}}
      ) do
    friends = Map.delete(friends, id)
    {:noreply, assign(socket, friends: friends, friend_list: Map.values(friends))}
  end

  def handle_info({@friends_topic, @friend_updated, _}, socket) do
    {:noreply, load_friends(socket)}
  end

  defp load_friends(socket = %{assigns: %{user_id: id}}) do
    friends = TwitterFeed.Accounts.get_friends(id)

    friend_map =
      friends
      |> Enum.reduce(%{}, fn friend, map -> Map.put(map, friend.id, friend) end)

    assign(socket, friends: friend_map, friend_list: friends)
  end

  defp mark_latest_tweets(friends, user_id) do
    spawn(fn ->
      friends
      |> Enum.each(fn friend_id ->
        [count: 1, user_id: friend_id]
        |> TwitterFeed.user_timeline()
        |> case do
          [%{id: id}] -> TwitterFeed.save_last_tweet(user_id, friend_id, id)
          [] -> :ok
        end
      end)
    end)
  end
end
