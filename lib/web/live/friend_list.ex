defmodule TwitterFeed.Web.FriendListLiveView do
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @friend_added Application.get_env(:twitter_feed, :events)[:friend_added]

  def mount(%{user_id: id}, socket) do
    Phoenix.PubSub.subscribe(TwitterFeed.PubSub, @friends_topic)

    socket =
      socket
      |> assign(user_id: id)
      |> load_friends

    {:ok, socket}
  end

  def render(assigns), do: TwitterFeed.Web.PageView.render("friend-list.html", assigns)


  def handle_info({@friends_topic, @friend_added, friend}, socket = %{assigns: %{friends: friends}}) do
    {:noreply, assign(socket, friends: List.insert_at(friends, -1, friend))}
  end

  defp load_friends(socket = %{assigns: %{user_id: id}}) do
    assign(socket, friends: TwitterFeed.Accounts.get_friends(id))
  end
end
