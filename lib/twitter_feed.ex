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

  def save_last_tweet(user_id, friend_id, tweet_id) do
    tweet_id = integer_id(tweet_id)
    friend_id = integer_id(friend_id)

    case TwitterFeed.Accounts.save_last_tweet(user_id, friend_id, tweet_id) do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(TwitterFeed.PubSub, @topic, {@topic, @tweet_marked, [friend_id, tweet_id]})
        Phoenix.PubSub.broadcast(TwitterFeed.PubSub, @friends_topic, {@friends_topic, @friend_updated, friend_id})
      {:error, _} -> :ok
    end
  end

  def user_timeline(opts \\ []) do
    opts
    |> Keyword.put_new(:count, 50)
    |> ExTwitter.user_timeline()
    |> Enum.map(&Map.from_struct/1)
  end

  defp integer_id(id) when is_integer(id), do: id
  defp integer_id(id) when is_binary(id), do: id |> Integer.parse() |> elem(0)
end
