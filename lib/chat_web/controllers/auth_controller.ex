defmodule ChatWeb.AuthController do
  use ChatWeb, :controller

  import Ecto.Query
  alias Chat.User
  alias Chat.Repo

  action_fallback ChatWeb.FallbackController

  def log_in(conn, params = %{"password" => password}) do
    user = get_user(params)

    if user == :error do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, "{\"detail\": \"Invalid request.\"}")
      |> halt()
    end

    if user == nil do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(401, "{\"detail\": \"Authentication credentials were not provided.\"}")
      |> halt()
    end

    if user.password == password do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, "{\"access_token\": \"#{Chat.TokenAuth.create_jwt(user)}\"}")
    end

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(401, "{\"detail\": \"Authentication credentials were not provided.\"}")
    |> halt()
  end

  defp get_user(%{"username" => username, "password" => password}) do
    query = from u in User, where: u.username == ^username
    Repo.one(query)
  end

  defp get_user(%{"email" => email, "password" => password}) do
    query = from u in User, where: u.email == ^email
    Repo.one(query)
  end

  defp get_user(_params) do
    :error
  end

#  def create(conn, params = %{"name" => _room_name}) do
#  def create(conn, params = %{"username" => username, "password" => password}) do
#    query = from u in User, where: u.username == ^username
#    case Repo.one(query) do
#      {:ok, user} -> true
#      _ -> false
#    end

#    user_id = Map.get(conn.assigns[:current_user], :id)
#    username = Map.get(conn.assigns[:current_user], :username)
#    with {:ok, %ChatRoom{} = chat_room} <- ChatRoom.create_room(params),
#         {:ok, chat_sub} <- Subscriptions.create_chat_subscription(%{"user_id" => user_id, "chat_room_id" => chat_room.id}),
#         {:ok, _message} <- Messages.create_message(%{
#           "chat_room_id" => chat_room.id, "user_id" => user_id,
#           "message_type" => "init_message", "body" => "#{username} created the chat room."})
#    do
#      conn
#      |> put_status(:created)
#      |> put_resp_header("location", chat_subscription_path(conn, :show, chat_room))
#      |> render("show.json", chat_room: chat_room)
#    end
end