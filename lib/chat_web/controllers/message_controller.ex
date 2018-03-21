defmodule ChatWeb.MessageController do
  use ChatWeb, :controller

  require Timex
  alias Chat.Messages
  alias Chat.Messages.Message
  alias Ecto.UUID

  action_fallback ChatWeb.FallbackController

  def index(conn, %{"room_id" => room_id}) do
    chat_messages = Messages.list_chat_room_messages(room_id)
    render(conn, "index.json", chat_messages: chat_messages)
  end
  
  @doc """
  List all of the messages in the room, if the user is subscribed to
  the room. 
  """
  def list_room_messages(conn, %{"room_id" => room_id}) do
    user_id = Map.get(conn.assigns[:current_user], :id)
    with {:ok, _} <- UUID.cast(room_id) do
      with "" <> older_than <- Map.get(conn.params, "older_than"),
        {:ok, ot} <- Timex.parse(older_than, "{ISO:Extended}")
      do
        chat_messages = Messages.list_chat_room_messages(room_id, user_id, ot)
        render(conn, "index.json", chat_messages: chat_messages)
      else
        _format_error ->
          chat_messages = Messages.list_chat_room_messages(room_id, user_id)
          render(conn, "index.json", chat_messages: chat_messages)
      end
    end
  end

  # def create(conn, %{"message" => message_params}) do
  # def create(conn, %{"message" => message_params}) do
  #   with {:ok, %Message{} = message} <- Messages.create_message(message_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", message_path(conn, :show, message))
  #     |> render("show.json", message: message)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   message = Messages.get_message!(id)
  #   render(conn, "show.json", message: message)
  # end

  # def update(conn, %{"id" => id, "message" => message_params}) do
  #   message = Messages.get_message!(id)

  #   with {:ok, %Message{} = message} <- Messages.update_message(message, message_params) do
  #     render(conn, "show.json", message: message)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   message = Messages.get_message!(id)
  #   with {:ok, %Message{}} <- Messages.delete_message(message) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
