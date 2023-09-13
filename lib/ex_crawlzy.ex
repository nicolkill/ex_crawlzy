defmodule ExCrawlzy do
  @moduledoc """
  Documentation for `ExCrawlzy`.
  """

  alias ExCrawlzy.Utils
  alias ExCrawlzy.BrowserClients

  @type result() :: :ok | :error
  @type map_key() :: String.t() | atom()
  @type post_processing() :: atom() | {module(), atom()} | (any() -> String.t())
  @type selector_tuple() :: {String.t(), post_processing()}

  @doc """
  Request link and returns the raw content.

  ## Examples

      iex> ExCrawlzy.crawl("http://some.site")
      {:ok, "<!doctype html><html>  <head>    <title>the title</title>  </head>  <body>    <div id=\\\"the_body\\\">      the body      <div id=\\\"inner_field\\\">        inner field      </div>      <div id=\\\"inner_second_field\\\">        inner second field        <div id=\\\"the_number\\\">          2023        </div>      </div>      <div id=\\\"exist\\\">        this field exist      </div>      <a class=\\\"link_class\\\" href=\\\"http://some_external.link\\\"></a>      <img class=\\\"img_class\\\" src=\\\"http://some_external.link/image_path.jpg\\\" alt=\\\"some image\\\">    </div>  </body></html>"}

  """
  @spec crawl(String.t(), [BrowserClients.client()]) :: {result(), String.t()}
  def crawl(link, clients \\ []) do
    clients = if Enum.empty?(clients),
                 do: BrowserClients.clients(),
                 else: Enum.map(clients, &BrowserClients.create_client/1)

    client = Enum.random(clients)
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

      iex> raw_content = "<html><head><title>the title</title></head><body><div id=\\\"the_body\\\">the body</div></body></html>"
      iex> ExCrawlzy.parse(%{body: {"#the_body", :text}}, raw_content)
      {:ok, %{body: "the body"}}

  """
  @spec parse(%{map_key() => selector_tuple()}, String.t() | Floki.html_tree() | Floki.html_node()) :: {result(), %{map_key() => String.t()}}
  def parse(mapping, raw_content) when is_bitstring(raw_content) do

    case Floki.parse_document(raw_content) do
      {:ok, document} ->
        parse(mapping, document)
      _ ->
        {:error, nil}
    end
  end
  def parse(mapping, document) do
    data =
      mapping
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, acc ->
        {selector, post_processing} = Map.get(mapping, key)
        crawled_data = Floki.find(document, selector)
        data =
          case post_processing do
            post_processing when is_function(post_processing) ->
              post_processing.(crawled_data)
            {mod, func} ->
              apply(mod, func, [crawled_data])
            post_processing ->
              apply(Utils, post_processing, [crawled_data])
          end

        Map.put(acc, key, data)
      end)
    {:ok, data}
  end
end
