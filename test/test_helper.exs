ExUnit.start()

Application.put_env(:conekta_ex, :private_key, "key_eYvWV7gSDkNYXsmr")
Application.put_env(:conekta_ex, :timeout, 20_000)
Application.put_env(:conekta_ex, :recv_timeout, 20_000)
