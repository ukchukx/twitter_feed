defmodule TwitterFeed.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:access_token, :access_token_secret, :id, :profile_img, :username, :name]
  @primary_key {:id, :id, autogenerate: false}

  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
    id: integer(),
    access_token: String.t(),
    access_token_secret: String.t(),
    profile_img: String.t(),
    username: String.t(),
    name: String.t(),
    friends: list(map()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t()
  }

  schema "users" do
    field :access_token, :string
    field :access_token_secret, :string
    field :profile_img, :string
    field :username, :string
    field :name, :string
    field :friends, {:array, :map}, default: [], virtual: true

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:id])
  end
end
