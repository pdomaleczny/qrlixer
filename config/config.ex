import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:module]

config :logger, level: :debug
