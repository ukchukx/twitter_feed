defmodule TwitterFeed.Accounts.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  alias TwitterFeed.Accounts.User

  @fields [:user_id, :friend_id, :last_tweet]
  @required_fields [:user_id, :friend_id]
  @primary_key false

  @type t :: %__MODULE__{
    user_id: integer(),
    friend_id: integer(),
    last_tweet: integer()
  }

  schema "friends" do
    field :last_tweet, :integer
    belongs_to :user, User, primary_key: true
    belongs_to :friend, User, primary_key: true
  end

  @doc false
  def changeset(%__MODULE__{} = friend, attrs) do
    friend
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:friend_id)
  end
end
