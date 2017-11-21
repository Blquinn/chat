defmodule Chat.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.ChatRoom
  alias Chat.Repo


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_rooms" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%ChatRoom{} = chat_room, attrs) do
    chat_room
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def create_room(%{"name" => name}) do
    room = %ChatRoom{name: name}
    Repo.insert(room)
  end
end
