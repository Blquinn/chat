defmodule ChatWeb.Router do
  use ChatWeb, :router
  alias Chat.TokenAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TokenAuth
  end

  pipeline :public_api do
    plug :accepts, ["json"]
  end

  scope "/", ChatWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", ChatWeb do
    pipe_through :public_api

    post "/auth", AuthController, :log_in
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatWeb do
    pipe_through :api

    resources "/subscriptions", ChatSubscriptionController, only: [:create, :show]
    
    resources "/rooms", ChatRoomController, only: [:create, :index]
    get "/rooms/:room_id/messages", MessageController, :list_room_messages
  end
end
