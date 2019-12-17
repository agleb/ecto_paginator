defmodule EctoPaginator.Address do
  use Ecto.Schema

  @primary_key {:city, :string, autogenerate: false}

  schema "addresses" do
    belongs_to(:customer, EctoPaginator.Customer)
  end
end
