defmodule ConektaEx.StructList do
  alias ConektaEx.HTTPClient

  @moduledoc ~S"""
  Struct for Conekta representation of lists.
  """

  defstruct [
    :has_more,
    :object,
    :total,
    :data,
    :next_page_url,
    :previous_page_url
  ]

  @doc ~S"""
  Request a 'next_page_url' from ConektaEx.StructList

  ## Examples
      iex> request_next(struct_list_with_ok_url, 1)
      {:ok, %HTTPoison.Response{}}

      iex> request_next(struct_list_with_ok_url, 100000)
      {:error, %ConektaEx.Error{}}

      # this response means either Conekta returned a
      # bad url or is not returning one at all in this
      # case check 'has_more' first.
      iex> request_next(struct_list_with_bad_url, 1)
      {:error, %HTTPoison.Error{}}
  """
  def request_next(%__MODULE__{next_page_url: url}, limit) do
    url
    |> create_pagination_url(limit)
    |> HTTPClient.get()
  end

  @doc ~S"""
  Request a 'previous_page_url' from ConektaEx.StructList

  ## Examples
      iex> request_previous(struct_list_with_ok_url, 1)
      {:ok, %HTTPoison.Response{}}

      iex> request_previous(struct_list_with_ok_url, 100000)
      {:error, %ConektaEx.Error{}}

      # this response means either Conekta returned a
      # bad url or is not returning one at all in this
      # case check 'has_more' first.
      iex> request_previous(struct_list_with_bad_url, 1)
      {:error, %HTTPoison.Error{}}
  """
  def request_previous(%__MODULE__{previous_page_url: url}, limit) do
    url
    |> create_pagination_url(limit)
    |> HTTPClient.get()
  end

  defp create_pagination_url(url, limit) do
    uri =
      case url do
        nil -> URI.parse("")
        _ -> URI.parse(url)
      end

    params =
      case uri.query do
        nil -> %{}
        q -> URI.decode_query(q)
      end

    params =
      case limit do
        nil -> params
        _ -> Map.put(params, "limit", limit)
      end

    path = uri.path

    "#{path}?#{URI.encode_query(params)}"
  end
end
