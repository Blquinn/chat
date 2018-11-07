defmodule Chat.User do
  require Logger

  use Ecto.Schema

  alias Chat.User
  alias Chat.Repo
  alias Comeonin.Bcrypt

  import Ecto.Query
  import Ecto.Changeset
  import Joken

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users_user" do
    field :username, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :first_name, :last_name, :password])
    |> validate_required([:username, :email, :first_name, :last_name, :password])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def authenticate(params = %{"password" => password}) do
    case get_user(params) do
      user ->
        if Bcrypt.checkpw(password, user.password) do
          {:ok, user}
        else
          {:error, "Password does not match"}
        end
      :error -> {:error, "Invalid params supplied"}
      nil -> {:error, "User not found"}
    end
  end

  defp hash_pass(password) do
    Bcrypt.hashpwsalt(password)
  end

  defp get_user(%{"username" => username}), do: Repo.one(from u in User, where: u.username == ^username)

  defp get_user(%{"email" => email}), do: Repo.one(from u in User, where: u.email == ^email)

  defp get_user(_params), do: :error

  def generate_jwt(user) do
    jwt_key = Application.get_env(:chat, :jwt_secret_key)

    token
    |> with_claims(Map.take(user, [:id, :username, :email]))
    |> with_exp(Timex.now |> Timex.shift(minutes: 15))
    |> sign(hs256(jwt_key))
    |> get_compact
  end

end