defmodule Chat.TokenAuth do
  @moduledoc """
    JWT authentication plug
  """

  import Joken
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
      ["Bearer " <> jwt] ->
        case validate_token(jwt) do
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

  def validate_token(jwt) do
    jwt_key = Application.get_env(:chat, :jwt_secret_key)

    jwt
    |> token
    |> with_validation("user_id", fn id ->
      case Ecto.UUID.cast(id) do
        {:ok, _id} -> true
        _ -> false
      end
    end)
    |> with_validation("email", &(is_binary(&1)))
    |> with_validation("is_active", &(is_boolean(&1)))
    |> with_validation("is_verified", &(is_boolean(&1)))
    |> with_validation("username", &(is_binary(&1)))
    |> with_validation("exp", &(validate_exp(&1)))
    |> with_signer(hs256(jwt_key))
    |> verify
    |> handle_token
  end

  defp handle_token(%{claims: claims = %{
    "user_id" => user_id,
    "username" => username,
    "email" => email,
    "is_active" => is_active,
    "is_verified" => is_verified,
    "exp" => exp,
  }, errors: []}) do
    case validate_exp(exp) do
      true ->
        user = %AuthUser{
          id: UUID.cast!(user_id),
          username: username,
          email: email,
          verified: is_verified,
          is_active: is_active
        }
        {:ok, user}
      false -> {:fail, "Expired token"}
    end
  end

  defp handle_token(%{claims: claims, errors: errors = [_|_]}) do
    IO.puts("Received bad claims in JWT #{inspect(claims)}")
    {:fail, errors}
  end

  defp handle_token(token) do
    Logger.debug("Auth failed: #{inspect token}")
    {:fail, "Unknown auth error"}
  end

  defp validate_exp(exp) do
    Timex.now
    |> Timex.before?(Timex.from_unix(exp))
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

end