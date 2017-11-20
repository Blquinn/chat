defmodule Chat.Repo.Migrations.CreateChatSubscriptions do
  use Ecto.Migration

  def change do
    create table(:chat_subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users_user, on_delete: :nothing, type: :binary_id)
      add :room_id, references(:chat_rooms, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:chat_subscriptions, [:user_id])
    create index(:chat_subscriptions, [:room_id])
  end
end
