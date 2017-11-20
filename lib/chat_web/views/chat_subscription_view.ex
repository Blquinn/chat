defmodule ChatWeb.ChatSubscriptionView do
  use ChatWeb, :view
  alias ChatWeb.ChatSubscriptionView

  def render("index.json", %{chat_subscriptions: chat_subscriptions}) do
    %{data: render_many(chat_subscriptions, ChatSubscriptionView, "chat_subscription.json")}
  end

  def render("show.json", %{chat_subscription: chat_subscription}) do
    %{data: render_one(chat_subscription, ChatSubscriptionView, "chat_subscription.json")}
  end

  def render("chat_subscription.json", %{chat_subscription: chat_subscription}) do
    %{id: chat_subscription.id}
  end
end
