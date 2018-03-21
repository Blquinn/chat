defmodule ChatWeb.MessageView do
  use ChatWeb, :view
  alias ChatWeb.MessageView
  alias ChatWeb.UserView

  def render("index.json", %{chat_messages: chat_messages}) do
    %{messages: render_many(chat_messages, MessageView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{message: render_one(message, MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{
      message: Map.take(message, [:id, :body, :message_type, :inserted_at]),
      user: render_one(message.user, UserView, "user.json"),
    }
  end
end
