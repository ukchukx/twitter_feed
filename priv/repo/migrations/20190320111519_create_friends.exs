defmodule TwitterFeed.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :friend_id, references(:users, on_delete: :delete_all), primary_key: true
      add :last_tweet, :bigint, null: true
    end
    create unique_index(:friends, [:user_id, :friend_id])
  end
end
