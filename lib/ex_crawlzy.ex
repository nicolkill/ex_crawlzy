defmodule ExCrawlzy do
  @moduledoc """
  Documentation for `ExCrawlzy`.
  """

  use ExCrawlzy.Clients

  alias ExCrawlzy.Utils

  @type result() :: :ok | :error
  @type map_key() :: String.t() | atom()
  @type selector_tuple() :: {String.t(), post_processing()}
  @type post_processing() :: atom() | (any() -> String.t())

  @doc """
  Request link and returns the raw content.

  ## Examples

      iex> ExCrawlzy.crawl("http://some.site")
      {:ok, "<html><head><title>the title</title></head><body><div id=\"the_body\">the body</div></body></html>"}

  """
  @spec crawl(String.t()) :: {result(), String.t()}
  def crawl(link) do
    client = Enum.random(@clients)
    opts = [
      method: :get,
      url: link
    ]

    case Tesla.request(client, opts) do
      {:ok, %Tesla.Env{status: status, body: body}} when status >= 200 and status < 300 ->
        content =
          body
          |> String.replace("\n", "")
          |> Utils.binary_to_string()
        {:ok, content}
      {:ok, %Tesla.Env{status: status}} when status == 301 ->
        # implement redirection
        {:error, :failure_redirect}
      _ ->
        {:error, :failure_on_call}
    end
  rescue
    _ ->
      nil
  end

  @doc """
  Request link and returns the raw content.

  ## Examples

      iex> raw_content = "<html><head><title>the title</title></head><body><div id=\"the_body\">the body</div></body></html>"
      iex> ExCrawlzy.parse(%{body: {"#the_body", :text}}, raw_content)
      {:ok, }

  """
  @spec parse(%{map_key() => selector_tuple()}, String.t()) :: {result(), %{map_key() => String.t()}}
  def parse(mapping, raw_content) do
    case Floki.parse_document(raw_content) do
      {:ok, document} ->
        data =
          mapping
          |> Map.keys()
          |> Enum.reduce(%{}, fn key, acc ->
            {selector, post_processing} = Map.get(mapping, key)
            crawled_data = Floki.find(document, selector)
            data =
              if is_function(post_processing) do
                post_processing
              else
                apply(Utils, post_processing, [crawled_data])
              end

            Map.put(acc, key, data)
          end)
        {:ok, data}
      _ ->
        {:error, nil}
    end
  end
end
