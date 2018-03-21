defmodule ChatWeb.ChatRoomView do
  use ChatWeb, :view
  alias ChatWeb.ChatRoomView
  alias ChatWeb.UserView

  def render("index.json", %{chat_rooms: chat_rooms, user: user}) do
    %{
      data: render_many(chat_rooms, ChatRoomView, "chat_room.json"),
      user: render_one(user, UserView, "user.json")
    }
  end

  def render("show.json", %{chat_room: chat_room}) do
    %{data: render_one(chat_room, ChatRoomView, "chat_room.json")}
  end

  def render("chat_room.json", %{chat_room: chat_room}) do
    Map.take(chat_room, [:id, :name, :inserted_at, :updated_at])
  end
end
