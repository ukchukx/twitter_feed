defmodule TwitterFeed.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :friend_id, references(:users, on_delete: :delete_all)
    end

    create index(:friends, [:user_id])
    create index(:friends, [:friend_id])
    create unique_index(:friends, [:user_id, :friend_id])
  end
end
