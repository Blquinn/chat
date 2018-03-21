defmodule Chat.Subscriptions.ChatSubscription do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Subscriptions.ChatSubscription
  alias Chat.ChatRoom
  alias Chat.User
  alias Chat.Messages.Message


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_subscriptions" do
    # field :user_id, :binary_id
    # field :chat_room_id, :binary_id
    
    belongs_to :chat_room, ChatRoom
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%ChatSubscription{} = chat_subscription, attrs) do
    chat_subscription
    |> cast(attrs, [:user_id, :chat_room_id])
    |> validate_required([:user_id, :chat_room_id])
  end
end
