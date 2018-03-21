defmodule Chat.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Messages.Message
  alias Chat.User
  alias Chat.ChatRoom

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_messages" do
    field :body, :string
    field :message_type, :string

    belongs_to :user, User
    belongs_to :chat_room, ChatRoom
    # field :user_id, :binary_id
    # field :room_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:body, :user_id, :chat_room_id, :message_type])
    |> validate_required([:body, :user_id, :chat_room_id, :message_type])
    |> validate_inclusion(:message_type, ["user_message", "init_message"])
  end
end
