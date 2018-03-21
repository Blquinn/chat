defmodule ChatWeb.RoomChannel do
  use Phoenix.Channel
  require Logger

  alias Chat.TokenAuth
  alias ChatWeb.Endpoint
  alias Chat.Messages.Message
  alias Chat.Messages

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  `{:ok, socket}` to authorize subscription for channel for requested topic

  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  # def join("room:lobby", auth_message, socket) do
  #   Process.flag(:trap_exit, true)
  #   :timer.send_interval(5000, :ping)
  #   send(self, {:after_join, auth_message})

  #   {:ok, socket}
  # end

  def join("room:" <> room_id, auth_message, socket) do
    case TokenAuth.authenticate_chat_room(auth_message) do
      {:ok, user} -> 
        Process.flag(:trap_exit, true)
        :timer.send_interval(5000, :ping)
        send(self, {:after_join, %{"info" => "User joined", "user" => user.username}})

        {:ok, socket}
      _ -> {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, msg}, socket) do
    Endpoint.broadcast!(socket.topic, "user:entered", %{user: msg["user"]})
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  # def leave(_reason, socket) do
  #   broadcast! socket.topic, "user:left", %{body: "user left the room"}
  # end

  def terminate(reason, socket) do
    # broadcast! socket.topic, "user:left", %{body: "user left the room"}
    # Endpoint.broadcast!(socket.topic, "user:left" %{body})
    Logger.debug("> leave #{inspect reason} #{inspect socket}")
    :ok
  end

  def handle_in("new:msg", %{"user" => user, "body" => body, "room_id" => room_id}, socket) do
    user_id = Map.get(user, "id")
    message = %{user_id: user_id, chat_room_id: room_id, body: body, message_type: "user_message"}

    spawn(fn -> Messages.create_message(message) end)

    Endpoint.broadcast! socket.topic, "new:msg", %{user: user, message: message}
    {:reply, {:ok, %{msg: body}}, assign(socket, :user, user_id)}
  end
end
