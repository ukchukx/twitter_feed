defmodule TwitterFeed.Accounts.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  alias TwitterFeed.Accounts.User

  @fields [:user_id, :friend_id]
  @primary_key false

  schema "friends" do
    belongs_to :user, User
    belongs_to :friend, User
  end

  @doc false
  def changeset(%__MODULE__{} = friend, attrs) do
    friend
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:friend_id)
  end
end
