defmodule TwitterFeed.Web.FriendLiveView do
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @topic Application.get_env(:twitter_feed, :topics)[:friend]
  @tweet_marked Application.get_env(:twitter_feed, :events)[:tweet_marked]

  def mount(_params, %{"user_id" => uid, "friend_id" => fid, "username" => u}, socket) do
    Phoenix.PubSub.subscribe(TwitterFeed.PubSub, @topic)

    socket =
      socket
      |> assign(user_id: uid)
      |> assign(friend_id: fid)
      |> assign(username: u)
      |> assign(tweets: [])
      |> assign(loading: true)

    send(self(), :fetch_tweets)

    {:ok, socket}
  end

  def render(assigns), do: TwitterFeed.Web.PageView.render("tweets.html", assigns)

  def handle_event("mark", %{"id" => id, "friend" => friend}, socket = %{assigns: %{user_id: u}}) do
    TwitterFeed.save_last_tweet(u, friend, id)

    {:noreply, socket}
  end

  def handle_event(
        "mark-all",
        %{"friend" => f},
        socket = %{assigns: %{user_id: u, tweets: tweets}}
      ) do
    %{id: id} = List.last(tweets)
    TwitterFeed.save_last_tweet(u, f, id)

    {:noreply, socket}
  end

  def handle_info(:fetch_tweets, socket = %{assigns: %{friend_id: f, user_id: u}}) do
    {:noreply, assign(socket, tweets: TwitterFeed.fetch_tweets(u, f), loading: false)}
  end

  def handle_info(
        {@topic, @tweet_marked, [f, id]},
        socket = %{assigns: %{tweets: tweets, friend_id: f}}
      ) do
    {:noreply, assign(socket, tweets: TwitterFeed.remove_older_tweets(tweets, id))}
  end

  def handle_info({@topic, @tweet_marked, _}, socket) do
    {:noreply, socket}
  end
end
