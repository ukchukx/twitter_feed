defmodule TwitterFeed.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :access_token, :string
      add :access_token_secret, :string
      add :username, :string
      add :name, :string
      add :profile_img, :string

      timestamps()
    end
  end
end
