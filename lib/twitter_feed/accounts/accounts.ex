defmodule TwitterFeed.Accounts do
  alias TwitterFeed.Accounts.User
  alias TwitterFeed.Repo

  def get_user_by_id(id), do: Repo.get(User, id)

  def create_user(%{id: id} = attrs) do
    case get_user_by_id(id) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert

      user -> {:ok, user}
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update
  end

end
