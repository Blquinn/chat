defmodule AuthUser do

  @moduledoc """
  Represents the claims from a valid JWT
  """
  defstruct id: "", username: "", email: "", is_active: false, verified: false

end
