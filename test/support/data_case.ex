defmodule EctoPaginator.DataCase do
  use ExUnit.CaseTemplate

  using _opts do
    quote do
      alias EctoPaginator.Repo

      import Ecto
      import Ecto.Query
      import EctoPaginator.Factory

      alias EctoPaginator.{Page, Page.Metadata}
      alias EctoPaginator.{Customer, Address, Payment}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoPaginator.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoPaginator.Repo, {:shared, self()})
    end

    :ok
  end
end
