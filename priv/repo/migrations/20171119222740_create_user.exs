defmodule Chat.Repo.Migrations.CreateChatRooms do
  use Ecto.Migration

  def change do
    create table(:users_user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :password, :string
      add :username, :string
      add :email, :string
      add :first_name, :string
      add :last_name, :string


      timestamps()
    end

    create unique_index(:users_user, [:username])
    create unique_index(:users_user, [:email])
  end
end