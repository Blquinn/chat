defmodule ChatWeb.AuthController do
  use ChatWeb, :controller

  alias Chat.User

  action_fallback ChatWeb.FallbackController

  def log_in(conn, params = %{"username" => username, "password" => password}), do: do_log_in(conn, params)

  def log_in(conn, params = %{"email" => username, "password" => password}), do: do_log_in(conn, params)

  defp do_log_in(conn, params) do
    case User.authenticate(params) do
      {:ok, user} -> conn |> render("auth-success.json", user: user, access_token: User.generate_jwt(user))
      {:error, error} -> conn |> render("auth-fail.json", error: error)
    end
  end

end
