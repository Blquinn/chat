defmodule Chat.Repo.Migrations.AlterForeignKeyNames do
  use Ecto.Migration

  def change do
    # alter table(:chat_messages) do
    #   rename :room_id, :chat_room_id
    # end

    # alter table(:chat_subscriptions) do
    rename table(:chat_subscriptions), :room_id, to: :chat_room_id
    # end
    
    # alter table(:chat_messages) do
    rename table(:chat_messages), :room_id, to: :chat_room_id
    # end
  end
end
