defmodule EctoPaginator.Customer do
  use Ecto.Schema

  import Ecto.Query

  schema "customers" do
    field(:name, :string)
    field(:active, :boolean)

    has_many(:payments, EctoPaginator.Payment)
    has_one(:address, EctoPaginator.Address)

    timestamps()
  end

  def active(query) do
    query |> where([c], c.active == true)
  end
end
