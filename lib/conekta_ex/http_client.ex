defmodule ConektaEx.HTTPClient do
  @base "https://api.conekta.io"

  def get(endpoint) do
    request(:get, endpoint, "")
  end

  def post(endpoint, body) do
    request(:post, endpoint, body)
  end

  def put(endpoint, body) do
    request(:put, endpoint, body)
  end

  def delete(endpoint) do
    request(:delete, endpoint, "")
  end

  def request(method, endpoint, body) do
    url = "#{@base}#{endpoint}"
    headers = req_headers()
    opts = req_options()

    res = HTTPoison.request(method, url, body, headers, opts)

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

  def handle_response({:error, err}) do
    raise "request error, #{err.reason}"
  end

  defp req_headers() do
    b_auth = "Basic #{Base.encode64(private_key())}"

    [
      {"Accept", "application/vnd.conekta-v2.0.0+json"},
      {"Content-type", "application/json"},
      {"Authorization", b_auth}
    ]
  end

  defp req_options() do
    timeout = Application.get_env(:conekta_ex, :timeout) || 15_000
    recv_timeout = Application.get_env(:conekta_ex, :recv_timeout) || 15_000
    [timeout: timeout, recv_timeout: recv_timeout]
  end

  defp private_key do
    case Application.get_env(:conekta_ex, :private_key) do
      nil ->
        raise """
        Conekta private key is not set. You can get the private
        key from 'https://admin.conekta.com/settings/keys' then
        add it to your config file:

          config :conekta_ex, :private_key, "private_key"
        """

      p_key ->
        p_key
    end
  end
end
