import Config

# Print only warnings and errors during test
config :logger, level: :warning

config :tesla, adapter: Tesla.Mock