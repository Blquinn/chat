defmodule ChatWeb.ChatRoomController do
  use ChatWeb, :controller

  import Ecto.Query
  alias Chat.User
  alias Chat.ChatRoom
  alias Chat.Subscriptions
  alias Chat.Messages

  action_fallback ChatWeb.FallbackController

  def create(conn, params = %{"name" => _room_name}) do
    user_id = Map.get(conn.assigns[:current_user], :id)
    username = Map.get(conn.assigns[:current_user], :username)
    with {:ok, %ChatRoom{} = chat_room} <- ChatRoom.create_room(params),
         {:ok, chat_sub} <- Subscriptions.create_chat_subscription(%{"user_id" => user_id, "chat_room_id" => chat_room.id}),
         {:ok, _message} <- Messages.create_message(%{
           "chat_room_id" => chat_room.id, "user_id" => user_id, 
           "message_type" => "init_message", "body" => "#{username} created the chat room."})
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", chat_subscription_path(conn, :show, chat_room))
      |> render("show.json", chat_room: chat_room)
    end
  end

  @doc """
  List a user's subscribed chat rooms 
  """
  def index(conn, _params) do
    IO.puts(inspect(conn.assigns))
    chat_rooms = Subscriptions.list_subscribed_rooms(Map.get(conn.assigns[:current_user], :id))
    IO.puts(inspect(chat_rooms))
    render(conn, "index.json", chat_rooms: chat_rooms, user: conn.assigns[:current_user])
  end

  @doc """
  List all of the users in the chat room, if the requesting user is
  subscribed to it. 
  """
  def list_users(conn, %{"room_id" => room_id}) do
    query = from u in User,
      join: s in Subscriptions,
        on: u.id == s.user_id,
      where: s.chat_room_id == ^room_id
    
    Repo.all(query)
  end
 
  # def show(conn, %{"id" => id}) do
  #   chat_subscription = Subscriptions.get_chat_subscription!(id)
  #   render(conn, "show.json", chat_subscription: chat_subscription)
  # end

  # def update(conn, %{"id" => id, "chat_room" => params}) do
  #   chat_room = ChatRoom.get_chat_subscription!(id)

  #   with {:ok, %ChatRoom{} = chat_room} <- ChatRoom.update_chat_room(chat_subscription, chat_subscription_params) do
  #     render(conn, "show.json", chat_subscription: chat_subscription)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   chat_subscription = Subscriptions.get_chat_subscription!(id)
  #   with {:ok, %ChatSubscription{}} <- Subscriptions.delete_chat_subscription(chat_subscription) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
