defmodule Chat.Repo.Migrations.AddFieldTypeToChatMessage do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      add :message_type, :string
    end
  end
end
