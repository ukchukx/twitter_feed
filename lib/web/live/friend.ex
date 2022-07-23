defmodule TwitterFeed.Web.FriendLiveView do
  use Phoenix.LiveView

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @topic Application.get_env(:twitter_feed, :topics)[:friend]
  @tweet_marked Application.get_env(:twitter_feed, :events)[:tweet_marked]
  @friend_updated Application.get_env(:twitter_feed, :events)[:friend_updated]

  def mount(%{user_id: uid, friend_id: fid, username: u}, socket) do
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
    id =
      id
      |> case do
        x when is_integer(x) -> x
        x -> x |> Integer.parse |> elem(0) # Convert string to integer
      end

    friend =
      friend
      |> case do
        x when is_integer(x) -> x
        x -> x |> Integer.parse |> elem(0) # Convert string to integer
      end

    case TwitterFeed.Accounts.save_last_tweet(u, friend, id) do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(TwitterFeed.PubSub, @topic, {@topic, @tweet_marked, [friend, id]})
        Phoenix.PubSub.broadcast(TwitterFeed.PubSub, @friends_topic, {@friends_topic, @friend_updated, friend})
      {:error, _} -> :ok
    end

    {:noreply, socket}
  end

  def handle_info(:fetch_tweets, socket = %{assigns: %{friend_id: f, user_id: u}}) do
    tweets =
      TwitterFeed.Accounts.get_last_tweet(u, f)
      |> case do
        nil -> []
        tweet_id -> [since_id: tweet_id]
      end
      |> Kernel.++([count: 80, user_id: f])
      |> ExTwitter.user_timeline
      |> Enum.map(&Map.from_struct/1)
      |> Enum.reverse()

    {:noreply, assign(socket, tweets: tweets, loading: false)}
  end

  def handle_info({@topic, @tweet_marked, [f, id]}, socket = %{assigns: %{tweets: tweets, friend_id: f}}) do
    {:noreply, assign(socket, tweets: Enum.filter(tweets, &(&1.id > id)))}
  end

  def handle_info({@topic, @tweet_marked, _}, socket) do
    {:noreply, socket}
  end

end
