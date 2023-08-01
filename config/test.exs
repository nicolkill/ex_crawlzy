import Config

# Print only warnings and errors during test
config :logger, level: :warn

config :tesla, adapter: Tesla.Mock