defmodule ChatWeb.ChatRoomController do
  use ChatWeb, :controller

  alias Chat.ChatRoom
  alias Chat.Subscriptions

  action_fallback ChatWeb.FallbackController

  def create(conn, %{"chat_room" => params}) do
    with {:ok, %ChatRoom{} = chat_room} <- ChatRoom.create_room(params) do
      with {:ok, chat_sub} <- Subscriptions.create_chat_subscription(
          %{"user_id" => conn.assigns[:user_id], "room_id" => chat_room.id}) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", chat_subscription_path(conn, :show, chat_room))
        |> render("show.json", chat_room: chat_room)
      end
    end
  end

  @doc """
  List a user's subscribed chat rooms 
  """
  def index(conn, _params) do
    chat_rooms = Subscriptions.list_subscribed_rooms(conn.assigns[:user_id])
    render(conn, "index.json", chat_rooms: chat_rooms, user_id: conn.assigns[:user_id])
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
