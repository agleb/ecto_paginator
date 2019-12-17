use Mix.Config

config :ecto_paginator, ecto_repos: [EctoPaginator.Repo]

config :ecto_paginator, EctoPaginator.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres",
  password: "postgres",
  database: "EctoPaginator_test",
  hostname: "postgres"

config :logger, :console, level: :warn

config :ecto_paginator, :default_encryption_key, "1234123412341234"

config :ecto_paginator,
       :fixed_iv,
       <<59, 255, 201, 230, 197, 48, 27, 152, 44, 26, 251, 22, 217, 36, 55, 255>>
