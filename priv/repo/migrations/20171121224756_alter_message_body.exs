defmodule Chat.Repo.Migrations.AlterMessageBody do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      modify :body, :text
    end
  end
end
