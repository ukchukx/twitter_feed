defmodule TwitterFeed.Web.FriendLiveView do
  use Phoenix.LiveView

  @topic Application.get_env(:twitter_feed, :topics)[:friends]
  @tweet_removed Application.get_env(:twitter_feed, :events)[:tweet_removed]

  def mount(%{user: user, friend: friend}, socket) do
    Phoenix.PubSub.subscribe(TwitterFeed.PubSub, @topic)

    socket =
      socket
      |> assign(user: user)
      |> assign(friend: friend)
      |> assign(tweets: [])
      |> assign(loading: true)

    send(self(), :fetch_tweets)

    {:ok, socket}
  end

  def render(assigns), do: TwitterFeed.Web.PageView.render("tweets.html", assigns)

  def handle_event("mark", %{"id" => id}, socket = %{assigns: %{user: %{id: u}, friend: %{id: f}}}) do
    id =
      id
      |> case  do
        x when is_integer(x) -> x
        x -> x |> Integer.parse |> elem(0) # Convert string to integer
      end


    case TwitterFeed.Accounts.save_last_tweet(u, f, id) do
      {:ok, _} -> Phoenix.PubSub.broadcast(TwitterFeed.PubSub, @topic, {@topic, @tweet_removed, id})
      {:error, _} -> :ok
    end

    {:noreply, socket}
  end

  def handle_info(:fetch_tweets, socket = %{assigns: %{friend: f, user: u}}) do
    tweets =
      TwitterFeed.Accounts.get_last_tweet(u.id, f.id)
      |> case do
        nil -> []
        tweet_id -> [since_id: tweet_id]
      end
      |> Kernel.++([count: 200, user_id: f.id])
      |> ExTwitter.user_timeline
      |> Enum.map(&Map.from_struct/1)

    {:noreply, assign(socket, tweets: tweets, loading: false)}
  end

  def handle_info({@topic, @tweet_removed, id}, socket = %{assigns: %{tweets: tweets}}) do
    {:noreply, assign(socket, tweets: Enum.filter(tweets, &(&1.id > id)))}
  end

end
