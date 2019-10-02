defmodule TwitterFeed.Accounts do
  alias TwitterFeed.Accounts.{Friend,User}
  alias TwitterFeed.Repo
  import Ecto.Query

  require Logger

  @spec get_friends(pos_integer) :: list()
  @spec load_friends(Accounts.User.t() | any) :: Accounts.User.t() | any
  @spec get_last_tweet(pos_integer, pos_integer) :: pos_integer | nil
  @spec save_last_tweet(pos_integer, pos_integer, pos_integer) :: {atom, atom | Accounts.Friend.t()}
  @spec get_user_by_id(pos_integer) :: Accounts.User.t() | nil
  @spec create_user(%{required(:id) => pos_integer, optional(atom) => any}) :: {:ok, Accounts.User.t()} | {:error, Ecto.Changeset.t()}
  @spec add_friends(pos_integer, list(pos_integer)) :: {any, nil | [any]}


  def get_friends(id) do
    from(u in User, join: f in Friend, where: f.user_id == ^id and u.id == f.friend_id, select: u, order_by: [desc: f.last_tweet])
    |> Repo.all
    |> Enum.map(fn f = %{profile_img: p} ->
      %{f | profile_img: String.replace(p, "_normal", "_400x400")}
    end)
  end

  def load_friends(%{id: id} = user) do
    %{user | friends: get_friends(id)}
  end
  def load_friends(x), do: x

  def get_last_tweet(user_id, friend_id) do
    case Repo.get_by(Friend, [friend_id: friend_id, user_id: user_id]) do
      nil -> nil
      %{last_tweet: id} -> id
    end
  end

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

  def get_user_by_id(id), do: User |> Repo.get(id) |> load_friends

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

  def add_friends(user_id, friends) do
    existing_friends = from(f in Friend, where: f.user_id == ^user_id) |> Repo.all
    existing_friend_ids = Enum.map(existing_friends, fn %{friend_id: id} -> id end)

    Logger.info "#{user_id} has #{length(existing_friends)} existing friends"

    for_deletion = Enum.filter(existing_friends, fn %{friend_id: id } -> id not in friends end)

    Logger.info "#{length(for_deletion)} friends to be deleted for #{user_id}"

    Enum.each(for_deletion, &Repo.delete/1)

    prospective_friends =
      friends
      |> Enum.filter(&(&1 not in existing_friend_ids))
      |> Enum.map(&(%{user_id: user_id, friend_id: &1}))

    Logger.info "#{length(prospective_friends)} new friends to be created for #{user_id}"

    Repo.insert_all(Friend, prospective_friends)
  end

end
