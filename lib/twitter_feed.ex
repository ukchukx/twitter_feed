defmodule TwitterFeed do
  @moduledoc """
  TwitterFeed keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]
  @topic Application.get_env(:twitter_feed, :topics)[:friend]
  @tweet_marked Application.get_env(:twitter_feed, :events)[:tweet_marked]
  @friend_updated Application.get_env(:twitter_feed, :events)[:friend_updated]

  alias TwitterFeed.{Accounts, PubSub}

  def save_last_tweet(user_id, friend_id, tweet_id) do
    tweet_id = integer_id(tweet_id)
    friend_id = integer_id(friend_id)

    case Accounts.save_last_tweet(user_id, friend_id, tweet_id) do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(PubSub, @topic, {@topic, @tweet_marked, [friend_id, tweet_id]})

        Phoenix.PubSub.broadcast(
          PubSub,
          @friends_topic,
          {@friends_topic, @friend_updated, friend_id}
        )

      {:error, _} ->
        :ok
    end
  end

  def user_timeline(opts \\ []) do
    try do
      opts
      |> Keyword.put_new(:count, 50)
      |> ExTwitter.user_timeline()
    rescue
      Extwitter.RateLimitExceededError -> []
    end
    |> Enum.map(&Map.from_struct/1)
  end

  def fetch_tweets(user_id, friend_id) do
    user_id
    |> Accounts.get_last_tweet(friend_id)
    |> case do
      nil -> [user_id: friend_id]
      tweet_id -> [since_id: tweet_id, user_id: friend_id]
    end
    |> user_timeline()
    |> Enum.reverse()
  end

  def friend_matches?(%{name: n, username: u} = _friend, text) do
    contains_name? = n |> String.downcase() |> String.contains?(text)
    contains_username? = u |> String.downcase() |> String.contains?(text)
    contains_username? or contains_name?
  end

  def remove_older_tweets(tweets, tweet_id) do
    Enum.filter(tweets, &(&1.id > tweet_id))
  end

  def ideal_chunk_size(items) do
    num_schedulers = System.schedulers_online()

    items
    |> length()
    |> Integer.floor_div(num_schedulers)
    |> max(num_schedulers)
  end

  defp integer_id(id) when is_integer(id), do: id
  defp integer_id(id) when is_binary(id), do: id |> Integer.parse() |> elem(0)
end
