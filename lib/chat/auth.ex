defmodule Chat.TokenAuth do
  require Logger
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
          {:fail, reason} ->
            Logger.debug("Auth failed: #{inspect reason}")
            fail(conn)
          {:ok, user} -> assign(conn, :current_user, user)
        end
      other ->
        Logger.debug("Auth failed: malformed auth token #{inspect other}")
        fail(conn)
    end
  end
  
  def authenticate_chat_room(%{"Authorization" => "Bearer " <> token}) when token != "" do
    case validate_token(token) do
      {:fail, reason} -> 
        Logger.debug("Auth failed: #{inspect reason}")
        false
      {:ok, user} -> {:ok, user}
    end
  end
  
  def authenticate_chat_room(_map) do
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
      \"users_user\".\"id\",
      \"users_user\".\"username\",
      \"users_user\".\"first_name\",
      \"users_user\".\"last_name\",
      \"users_user\".\"email\",
  		\"users_user\".\"verified\",
      \"users_user\".\"is_active\",
      \"users_user\".\"account_number\",
      \"users_user\".\"etna_account_id\"

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
      [[expires, user_id, username, first_name, last_name, email,
        verified, is_active, account_number, etna_account_id]] ->
        now = DateTime.utc_now
        expiry = Timex.to_datetime(expires)
        cond do
          :gt == DateTime.compare(now, expiry) -> {:fail, "Token expired"}
          verified != true -> {:fail, "Unverified user"}
          is_active != true -> {:fail, "Inactive user"}
          true -> 
            user = %User{
              id: UUID.cast!(user_id),
              username: username,
              first_name: first_name,
              last_name: last_name,
              email: email,
              verified: verified,
              account_number: account_number,
              etna_account_id: etna_account_id
            }
            {:ok, user}
        end
    end
  end

  # defp return_user(user_id) do
  #   user = Repo.one!(from u in User, where: u.id == ^user_id)
  #   {:ok, user}
  # end
end