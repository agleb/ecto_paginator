defmodule EctoPaginator.Cursor do
  alias EctoPaginator.Crypto
  @moduledoc false

  def decode(nil), do: nil

  def decode(encoded_cursor) do
    case Crypto.decrypt(encoded_cursor) do
      {:ok, decrypted} -> :erlang.binary_to_term(decrypted, [:safe])
      _ -> raise "Invalid cursor"
    end
  end

  def encode(values) when is_list(values) do
    values
    |> :erlang.term_to_binary()
    |> Crypto.encrypt()
  end

  def encode(value) do
    encode([value])
  end
end
