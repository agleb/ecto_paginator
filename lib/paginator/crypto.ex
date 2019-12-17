defmodule EctoPaginator.Crypto do
  @aad Application.get_env(
         :ecto_paginator,
         :aad,
         <<"SOME_AAD">>
       )

  def key() do
    key_func =
      Application.get_env(
        :ecto_paginator,
        :key_func,
        &EctoPaginator.Crypto.default_key_func/0
      )

    with key when is_binary(key) and key != "" <- key_func.(),
         true <- String.length(key) >= 16 do
      String.slice(key, 0..15)
    else
      error -> raise "Invalid encryption key " <> key_func.() <> ">>" <> inspect(error)
    end
  end

  def pad(data, block_size) do
    padding_bits =
      case rem(byte_size(data), block_size) do
        0 -> 0
        r -> (block_size - r) * 8
      end

    <<0::size(padding_bits)>> <> data
  end

  def unpad(data) do
    String.trim_leading(data, <<0>>)
  end

  def encrypt(data) do
    iv =
      case Application.get_env(
             :ecto_paginator,
             :fixed_iv
           ) do
        nil -> :crypto.strong_rand_bytes(16)
        fixed_iv -> fixed_iv
      end

    Base.encode64(
      iv <>
        ":::" <>
        :erlang.term_to_binary(
          :crypto.crypto_one_time_aead(
            :aes_128_gcm,
            key(),
            iv,
            data,
            @aad,
            true
          )
        )
    )
  end

  def decrypt(raw) do
    with {:ok, data} <- Base.decode64(raw),
         <<iv::binary-size(16), ":::", raw_encrypted::binary>> <- data,
         {cipher_text, tag} <- :erlang.binary_to_term(raw_encrypted),
         decrypted when decrypted != :error <-
           :crypto.crypto_one_time_aead(
             :aes_128_gcm,
             key(),
             iv,
             cipher_text,
             @aad,
             tag,
             false
           ) do
      {:ok, unpad(decrypted)}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  def default_key_func() do
    Application.fetch_env!(:ecto_paginator, :default_encryption_key)
  end
end
