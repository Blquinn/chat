defmodule ChatWeb.ChatSubscriptionController do
  use ChatWeb, :controller

  alias Chat.Subscriptions
  alias Chat.Subscriptions.ChatSubscription

  action_fallback ChatWeb.FallbackController

  def index(conn, _params) do
    chat_subscriptions = Subscriptions.list_chat_subscriptions()
    render(conn, "index.json", chat_subscriptions: chat_subscriptions)
  end

  @doc """
  Add a user to a chat room. 
  """
  def create(conn, %{"chat_subscription" => chat_subscription_params}) do
    with {:ok, %ChatSubscription{} = chat_subscription} <- Subscriptions.create_chat_subscription(chat_subscription_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", chat_subscription_path(conn, :show, chat_subscription))
      |> render("show.json", chat_subscription: chat_subscription)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   chat_subscription = Subscriptions.get_chat_subscription!(id)
  #   render(conn, "show.json", chat_subscription: chat_subscription)
  # end

  # def update(conn, %{"id" => id, "chat_subscription" => chat_subscription_params}) do
  #   chat_subscription = Subscriptions.get_chat_subscription!(id)

  #   with {:ok, %ChatSubscription{} = chat_subscription} <- Subscriptions.update_chat_subscription(chat_subscription, chat_subscription_params) do
  #     render(conn, "show.json", chat_subscription: chat_subscription)
  #   end
  # end
  
  @doc """
  Remove the user's subscription the the chat room.
  """
  def delete(conn, %{"id" => id}) do
    chat_subscription = Subscriptions.get_chat_subscription!(id)
    with {:ok, %ChatSubscription{}} <- Subscriptions.delete_chat_subscription(chat_subscription) do
      send_resp(conn, :no_content, "")
    end
  end
end
