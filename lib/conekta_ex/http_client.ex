defmodule ConektaEx.HTTPClient do
  @base "https://api.conekta.io"

  def get(endpoint, opts) do
    request(:get, endpoint, "", opts)
  end

  def post(endpoint, body, opts) do
    request(:post, endpoint, body, opts)
  end

  def put(endpoint, body, opts) do
    request(:put, endpoint, body, opts)
  end

  def delete(endpoint, opts) do
    request(:delete, endpoint, "", opts)
  end

  def request(method, endpoint, body, opts) do
    url = "#{@base}#{endpoint}"
    headers = req_headers()
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
