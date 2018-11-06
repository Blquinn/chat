defmodule Chat.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :string
      add :user_id, references(:users_user, on_delete: :nothing, type: :binary_id)
      add :room_id, references(:chat_rooms, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

#    create index(:chat_messages, [:user_id])
#    create index(:chat_messages, [:room_id])
  end
end
