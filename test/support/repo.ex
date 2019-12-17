defmodule EctoPaginator.Repo do
  use Ecto.Repo,
    otp_app: :ecto_paginator,
    adapter: Ecto.Adapters.Postgres

  use EctoPaginator
end
