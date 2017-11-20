defmodule Chat.TokenAuth do
  # require Logger
  use Timex
  import Ecto.Query
  import Plug.Conn
  alias Chat.User
  alias Chat.Repo
  alias Ecto.UUID
  alias Ecto.Adapters.SQL

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      [] -> fail(conn)
      ["Bearer " <> token] ->
        case validate_token(token) do
          {:fail, reason} -> fail(conn)
          {:ok, user_id} -> assign(conn, :user_id, user_id)
        end
    end
  end
  
  def authenticate_chat_room(%{"Authorization" => "Bearer " <> token}) do
    case validate_token(token) do
      {:fail, _reason} -> false
      {:ok, user_id} -> {:ok, user_id}
    end
  end
  
  def authenticate_chat_room(_) do
    false
  end

  defp fail(conn) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(401, "{\"detail\": \"Authentication credentials were not provided.\"}")
    |> halt()
  end

  defp validate_token(token) do
    SQL.query!(Repo, "
  		SELECT
  		\"oauth2_provider_accesstoken\".\"expires\",
  		\"oauth2_provider_accesstoken\".\"user_id\",
  		\"users_user\".\"verified\",
  		\"users_user\".\"is_active\"

  		FROM \"oauth2_provider_accesstoken\"

  		LEFT OUTER JOIN \"users_user\"
  		ON (\"oauth2_provider_accesstoken\".\"user_id\" = \"users_user\".\"id\")

  		INNER JOIN \"oauth2_provider_application\"
  		ON (\"oauth2_provider_accesstoken\".\"application_id\" = \"oauth2_provider_application\".\"id\")

      WHERE \"oauth2_provider_accesstoken\".\"token\" = $1
    ", [token])
    |> Map.get(:rows)
    |> case do
      [] -> {:fail, "Token not found"}
      [[expires, user_id, verified, is_active]] ->
        now = DateTime.utc_now
        expiry = Timex.to_datetime(expires)
        cond do
          :gt == DateTime.compare(now, expiry) -> {:fail, "Token expired"}
          verified != true -> {:fail, "Unverified user"}
          is_active != true -> {:fail, "Inactive user"}
          true -> {:ok, UUID.cast!(user_id)}
        end
    end
  end

  # defp return_user(user_id) do
  #   user = Repo.one!(from u in User, where: u.id == ^user_id)
  #   {:ok, user}
  # end
end