defmodule TwitterFeed.Web.FriendListLiveView do
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @friend_added Application.get_env(:twitter_feed, :events)[:friend_added]
  @friend_updated Application.get_env(:twitter_feed, :events)[:friend_updated]

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
    spawn(fn ->
      TwitterFeed.Accounts.fetch_friends(user_id)
    end)

    {:noreply, assign(socket, friends: [])}
  end


  def handle_info({@friends_topic, @friend_added, friend}, socket = %{assigns: %{friends: friends}}) do
    {:noreply, assign(socket, friends: List.insert_at(friends, -1, friend))}
  end

  def handle_info({@friends_topic, @friend_updated, _}, socket) do
    {:noreply, load_friends(socket)}
  end

  defp load_friends(socket = %{assigns: %{user_id: id}}) do
    assign(socket, friends: TwitterFeed.Accounts.get_friends(id))
  end
end
