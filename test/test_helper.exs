Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto)

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.Postgres.storage_down(EctoPaginator.Repo.config())
:ok = Ecto.Adapters.Postgres.storage_up(EctoPaginator.Repo.config())
{:ok, _} = EctoPaginator.Repo.start_link()
:ok = Ecto.Migrator.up(EctoPaginator.Repo, 0, EctoPaginator.TestMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(EctoPaginator.Repo, :manual)

ExUnit.start()
