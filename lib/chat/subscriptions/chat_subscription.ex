defmodule Chat.Subscriptions.ChatSubscription do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Subscriptions.ChatSubscription


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_subscriptions" do
    field :user_id, :binary_id
    field :room_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%ChatSubscription{} = chat_subscription, attrs) do
    chat_subscription
    |> cast(attrs, [:user_id, :room_id])
    |> validate_required([:user_id, :room_id])
  end
end
