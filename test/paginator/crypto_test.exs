defmodule EctoPaginator.CryptoTest do
  use ExUnit.Case, async: true
  import EctoPaginator.Crypto

  def valid_key_func() do
    "1234123412341234"
  end

  def invalid_key_func() do
    "123412341234123"
  end

  test "default_key_func() - valid default key" do
    Application.put_env(
      :ecto_paginator,
      :default_encryption_key,
      "1234123412341234"
    )

    assert "1234123412341234" == default_key_func()
  end

  test "default_key_func() - no default key" do
    Application.delete_env(
      :ecto_paginator,
      :default_encryption_key
    )

    assert_raise(ArgumentError, &default_key_func/0)
  end

  test "key() - invalid key returned" do
    Application.put_env(
      :ecto_paginator,
      :key_func,
      fn -> invalid_key_func() end
    )

    assert_raise(RuntimeError, &key/0)
  end

  test "key() - valid key returned" do
    assert :ok ==
             Application.put_env(
               :ecto_paginator,
               :key_func,
               fn -> valid_key_func() end,
               persistent: true
             )

    assert true == is_function(Application.get_env(:ecto_paginator, :key_func))

    assert valid_key_func() == key()
  end

  test "pad(data, block_size) - padding needed" do
    assert <<0, 49, 50, 51, 52, 49, 50, 51, 52, 49, 50, 51, 52, 49, 50, 51>> ==
             pad("123412341234123", 16)
  end

  test "pad(data, block_size) - padding not needed" do
    assert "1234123412341234" == pad("1234123412341234", 16)
  end

  test "unpad(data) - unpad needed" do
    assert "123412341234123" == unpad(to_string(pad("123412341234123", 16)))
  end

  test "encrypt(data) -> decrypt(data)" do
    assert :ok ==
             Application.put_env(
               :ecto_paginator,
               :key_func,
               fn -> valid_key_func() end,
               persistent: true
             )

    encrypted = encrypt("test data")

    assert {:ok, "test data"} == decrypt(encrypted)
  end

  test "decrypt(data) - valid ciphered data" do
    assert :ok ==
             Application.put_env(
               :ecto_paginator,
               :key_func,
               fn -> valid_key_func() end,
               persistent: true
             )

    packed_wrong_ciphered =
      {<<100, 166, 83, 128, 114, 157, 190, 217, 166>>,
       <<112, 135, 9, 47, 85, 79, 143, 27, 104, 23, 15, 253, 25, 129, 53, 206>>}
      |> :erlang.term_to_binary()

    iv = <<59, 255, 201, 230, 197, 48, 27, 152, 44, 26, 251, 22, 217, 36, 55, 255>>

    candidate = Base.encode64(iv <> ":::" <> packed_wrong_ciphered)

    assert {:ok, "test data"} = decrypt(candidate)
  end

  test "decrypt(data) - wrong ciphered data" do
    assert :ok ==
             Application.put_env(
               :ecto_paginator,
               :key_func,
               fn -> valid_key_func() end,
               persistent: true
             )

    packed_wrong_ciphered =
      {<<200, 166, 83, 128, 114, 157, 190, 217, 166>>,
       <<112, 135, 9, 47, 85, 79, 143, 27, 104, 23, 15, 253, 25, 129, 53, 206>>}
      |> :erlang.term_to_binary()

    iv = <<59, 255, 201, 230, 197, 48, 27, 152, 44, 26, 251, 22, 217, 36, 55, 255>>

    candidate = Base.encode64(iv <> ":::" <> packed_wrong_ciphered)

    assert {:error, :error} = decrypt(candidate)
  end

  test "decrypt(data) - wrong iv" do
    assert :ok ==
             Application.put_env(
               :ecto_paginator,
               :key_func,
               fn -> valid_key_func() end,
               persistent: true
             )

    packed_ciphered =
      {<<100, 166, 83, 128, 114, 157, 190, 217, 166>>,
       <<112, 135, 9, 47, 85, 79, 143, 27, 104, 23, 15, 253, 25, 129, 53, 206>>}
      |> :erlang.term_to_binary()

    wrong_iv = <<69, 255, 201, 230, 197, 48, 27, 152, 44, 26, 251, 22, 217, 36, 55, 255>>

    candidate = Base.encode64(wrong_iv <> ":::" <> packed_ciphered)

    assert {:error, :error} = decrypt(candidate)
  end
end
