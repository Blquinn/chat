defmodule ChatWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ChatWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ChatWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, error) do
    conn
    |> put_status(500)
    |> render(ChatWeb.ErrorView, "error.json", error)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ChatWeb.ErrorView, :"404")
  end
end
