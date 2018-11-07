defmodule ChatWeb.AuthView do
  use ChatWeb, :view

  alias ChatWeb.UserView

  def render("auth-success.json", %{user: user, access_token: access_token}) do
    %{user: render_one(user, UserView, "user.json"), access_token: access_token}
  end

  def render("auth-fail.json", %{error: error}), do: %{detail: error}

end