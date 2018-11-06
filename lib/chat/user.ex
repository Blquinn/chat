defmodule Chat.User do
  use Ecto.Schema
  alias Chat.Repo

  @primary_key {:id, :binary_id, []}

  schema "users_user" do
    field :password, :string
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    timestamps()
  end

#  def changeset(%User{} = user, attrs) do
#    user
#    |> cast(attrs, [:username, :email, :first_name, :last_name])
#    |> validate_required([:username, :email, :first_name, :last_name, :password])
#  end

  def create(%Chat.User{} = user) do
    Repo.insert(user)
  end

end