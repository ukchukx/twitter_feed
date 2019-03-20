defmodule TwitterFeed.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias TwitterFeed.Accounts.Friend

  @fields [:access_token, :access_token_secret, :id]
  @primary_key {:id, :id, autogenerate: false}

  schema "users" do
    field :access_token, :string
    field :access_token_secret, :string
    has_many :friendships, Friend
    has_many :reverse_friendships, Friend, foreign_key: :friend_id
    has_many :friends, through: [:friendships, :friend]

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
