defmodule TwitterFeed.Accounts do
  alias TwitterFeed.Accounts.{Friend, User}
  alias TwitterFeed.{PubSub, Repo}
  import Ecto.Query

  require Logger

  @friends_topic Application.get_env(:twitter_feed, :topics)[:friends]

  @spec get_friends(pos_integer) :: list()
  @spec load_friends(User.t() | any) :: User.t() | any
  @spec get_last_tweet(pos_integer, pos_integer) :: pos_integer | nil
  @spec save_last_tweet(pos_integer, pos_integer, pos_integer) :: {atom, atom | Friend.t()}
  @spec get_user_by_id(pos_integer) :: User.t() | nil
  @spec create_user(%{required(:id) => pos_integer, optional(atom) => any}) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @spec fetch_friends(pos_integer) :: :ok

  def fetch_friends(user_id) do
    Logger.info("Fetching friends for #{user_id}")
    friend_added = Application.get_env(:twitter_feed, :events)[:friend_added]

    friends =
      user_id
      |> ExTwitter.friends(count: 200)
      |> Map.get(:items, [])
      |> Stream.map(&params_from_result/1)
      |> Stream.map(&create_user/1)
      |> Stream.filter(fn
        {:ok, %{id: id}} -> is_integer(id)
        _ -> false
      end)
      |> Stream.map(fn {:ok, %{id: id} = friend} ->
        Logger.info("Created friend #{inspect(friend)}")
        Phoenix.PubSub.broadcast(PubSub, @friends_topic, {@friends_topic, friend_added, friend})

        id
      end)
      |> Enum.to_list()

    add_friends(user_id, friends)

    Logger.info("Done fetching friends for #{user_id}.")
  end

  def get_friends(id) do
    from(u in User,
      join: f in Friend,
      where: f.user_id == ^id and u.id == f.friend_id,
      select: {u, f},
      order_by: [desc: f.last_tweet]
    )
    |> Repo.all()
    |> Enum.map(fn {u, f} -> %{u | friend: f} end)
    |> Enum.map(fn f = %{profile_img: p} ->
      %{f | profile_img: String.replace(p, "_normal", "_400x400")}
    end)
  end

  def load_friends(%{id: id} = user), do: %{user | friends: get_friends(id)}
  def load_friends(x), do: x

  def get_last_tweet(user_id, friend_id) do
    Friend
    |> Repo.get_by(friend_id: friend_id, user_id: user_id)
    |> case do
      %{last_tweet: id} -> id
      nil -> nil
    end
  end

  def save_last_tweet(user_id, friend_id, tweet) do
    from(f in Friend, where: f.friend_id == ^friend_id and f.user_id == ^user_id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :no_friendship}

      schema ->
        schema
        |> Friend.changeset(%{last_tweet: tweet})
        |> Repo.update()
    end
  end

  def get_user_by_id(id), do: Repo.get(User, id)

  def create_user(%{id: id} = attrs) do
    id
    |> get_user_by_id
    |> case do
      nil -> %User{id: id}
      user -> user
    end
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end

  defp add_friends(user_id, friend_ids) do
    friend_removed = Application.get_env(:twitter_feed, :events)[:friend_removed]

    removed_friends_query =
      user_id
      |> friends_query
      |> where([f], f.friend_id not in ^friend_ids)

    removed_friends_query
    |> Repo.all()
    |> Enum.each(
      &Phoenix.PubSub.broadcast(PubSub, @friends_topic, {@friends_topic, friend_removed, &1})
    )

    Repo.delete_all(removed_friends_query)

    existing =
      user_id
      |> friends_query
      |> Repo.all()
      |> Enum.map(& &1.friend_id)

    new_friends =
      friend_ids
      |> Enum.filter(&(&1 not in existing))
      |> Enum.map(&%{user_id: user_id, friend_id: &1})

    Repo.insert_all(Friend, new_friends)
  end

  defp friends_query(id), do: from(f in Friend, where: f.user_id == ^id)

  defp params_from_result(result) do
    %{
      id: result.id,
      username: result.screen_name,
      name: result.name,
      profile_img: result.profile_image_url_https
    }
  end
end
