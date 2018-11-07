defmodule ChatWeb.UserView do
  use ChatWeb, :view

  def render("user.json", %{user: user}) do
    Map.take(user, [:id, :username, :first_name, :last_name])
  end

end