defmodule Chat.User do
  use Ecto.Schema
  
  @primary_key {:id, :binary_id, []}

  schema "users_user" do
      field :username, :string
      field :first_name, :string
      field :last_name, :string
      field :email, :string
      field :verified, :boolean
      field :account_number, :string
      field :etna_account_id, :string
  end
end