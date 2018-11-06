# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chat,
  ecto_repos: [Chat.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :chat, ChatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GgswnpODIymsuLxqyr7U742TbFyOJ0dwb5k1/815AxhO+UEQ92VwlB/ozMlV3pEJ",
  render_errors: [view: ChatWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Chat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :chat, MyApp.Guardian,
  issuer: "matador",
  secret_key: "replace_me"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
