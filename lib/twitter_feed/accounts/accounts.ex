defmodule TwitterFeed.Accounts do
  alias TwitterFeed.Accounts.{Friend,User}
  alias TwitterFeed.Repo
  import Ecto.Query

  require Logger

  @spec load_friends(Accounts.User.t() | any()) :: Accounts.User.t() | any()
  def load_friends(%{id: id} = user) do
    friends =
      from(u in User, join: f in Friend, where: f.user_id == ^id and u.id == f.friend_id, select: u, order_by: [desc: f.last_tweet])
      |> Repo.all
      |> Enum.map(fn f = %{profile_img: p} ->
        %{f | profile_img: String.replace(p, "_normal", "_400x400")}
      end)

    %{user | friends: friends}
  end
  def load_friends(x), do: x

  @spec get_last_tweet(integer(), integer()) :: integer() | nil
  def get_last_tweet(user_id, friend_id) do
    case Repo.get_by(Friend, [friend_id: friend_id, user_id: user_id]) do
      nil -> nil
      %{last_tweet: id} -> id
    end
  end

  @spec save_last_tweet(integer(), integer(), integer()) :: {atom(), atom() | Accounts.Friend.t()}
  def save_last_tweet(user_id, friend_id, tweet) do
    from(f in Friend, where: f.friend_id == ^friend_id and f.user_id == ^user_id)
    |> Repo.one
    |> case do
      nil -> {:error, :no_friendship}
      schema ->
        schema
        |> Friend.changeset(%{last_tweet: tweet})
        |> Repo.update
    end
  end

  @spec get_user_by_id(integer()) :: Accounts.User.t() | nil
  def get_user_by_id(id), do: User |> Repo.get(id) |> load_friends

  @spec create_user(%{required(:id) => integer(), optional(atom()) => any()}) :: {:ok, Accounts.User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(%{id: id} = attrs) do
    id
    |> get_user_by_id
    |> case do
      nil -> %User{id: id}
      user -> user
    end
    |> User.changeset(attrs)
    |> Repo.insert_or_update
  end

  @spec add_friends(integer(), list(integer())) :: {any(), nil | [any()]}
  def add_friends(user_id, friends) do
    Logger.info "Delete old friends..."
    from(f in Friend, where: f.user_id == ^user_id) |> Repo.delete_all

    Logger.info "Add new friends..."
    friends = Enum.map(friends, &(%{user_id: user_id, friend_id: &1}))

    Repo.insert_all(Friend, friends)
  end

end
