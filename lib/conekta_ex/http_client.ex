defmodule ConektaEx.HTTPClient do
  @base "https://api.conekta.io"

  def get(endpoint, headers \\ []) do
    request(:get, endpoint, "", headers)
  end

  def post(endpoint, body, headers \\ []) do
    request(:post, endpoint, body, headers)
  end

  def put(endpoint, body, headers \\ []) do
    request(:put, endpoint, body, headers)
  end

  def delete(endpoint, headers \\ []) do
    request(:delete, endpoint, "", headers)
  end

  def request(method, endpoint, body, headers) do
    url = "#{@base}#{endpoint}"
    headers = req_headers(headers)
    res = HTTPoison.request(method, url, body, headers)
    handle_response(res)
  end

  def handle_response({:ok, resp}) do
    case resp.status_code do
      code when code >= 400 and code <= 500 ->
        ConektaEx.Error.decode(resp.body)

      _code ->
        {:ok, resp}
    end
  end

  def handle_response({:error, resp}) do
    {:error, resp}
  end

  defp req_headers(extra_headers) do
    b_auth = Base.encode64(private_key())

    base_headers = [
      {"Accept", "application/vnd.conekta-v2.0.0+json"},
      {"Content-type", "application/json"},
      {"Authorization", "Basic #{b_auth}"}
    ]

    base_headers ++ extra_headers
  end

  defp private_key do
    case Application.get_env(:conekta_ex, :private_key) do
      nil ->
        raise """
        Conekta private key is not set. You can get the private
        key from 'https://admin.conekta.com/settings/keys' then
        add it to your config file:

          config :conekta_ex, private_key: "private_key"
        """

      p_key ->
        p_key
    end
  end
end
