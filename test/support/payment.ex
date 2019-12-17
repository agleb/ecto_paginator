defmodule EctoPaginator.Payment do
  use Ecto.Schema

  import Ecto.Query

  schema "payments" do
    field(:amount, :integer)
    field(:charged_at, :utc_datetime)
    field(:description, :string)
    field(:status, :string)

    belongs_to(:customer, EctoPaginator.Customer)

    timestamps()
  end

  def successful(query) do
    query |> where([p], p.status == "success")
  end

  def failed(query) do
    query |> where([p], p.status == "failed")
  end
end
