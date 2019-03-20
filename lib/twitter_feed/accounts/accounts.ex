defmodule TwitterFeed.Accounts do
  alias TwitterFeed.Accounts.{Friend,User}
  alias TwitterFeed.Repo
  import Ecto.Query

  def load_friends(%{id: id} = user) do
    friends =
      from(u in User, join: f in Friend, where: f.user_id == ^id and u.id == f.friend_id, select: u)
      |> Repo.all
      |> Enum.map(fn f = %{profile_img: p} ->
        %{f | profile_img: String.replace(p, "_normal", "_400x400")}
      end)

    %{user | friends: friends}
  end
  def load_friends(x), do: x

  def get_user_by_id(id), do: User |> Repo.get(id) |> load_friends

  def create_user(%{id: id} = attrs) do
    case get_user_by_id(id) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert

      user -> update_user(user, attrs)
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update
  end

  def add_friend(user_id, friend_id) do
    from(f in Friend, where: f.user_id == ^user_id and f.friend_id == ^friend_id)
    |> Repo.one
    |> case do
      nil ->
        %Friend{}
        |> Friend.changeset(%{user_id: user_id, friend_id: friend_id})
        |> Repo.insert

      f -> {:ok, f}
    end
  end

end
