defmodule ExCrawlzy.Client.List do
  @moduledoc """
  Module that helps to create clients to crawl some sites and extract the data as list of json/map

  The point its create other module that uses this module, add the list selector with `list_selector/1` and add fields
  using the macro `add_field/3`

  By default takes 20 elements but you can customize using `list_size/1`

  Then just use the client function `crawl/1` with your url and will crawl and parse the data and return the list of json/map

  Example:

  ```elixir
  defmodule GithubProfilePinnedRepos do
    use ExCrawlzy.Client.List

    list_selector("div.pinned-item-list-item")
    add_field(:name, "a.mr-1 span.repo", :text)
    add_field(:link, "a.mr-1", :link)
    add_field(:access, "span.Label", :text)
    add_field(:description, "p.pinned-item-desc", :text)
    add_field(:language, "span.d-inline-block span[itemprop=\"programmingLanguage\"]", :text)

    def link(doc) do
      path = ExCrawlzy.Utils.props("href", doc)
      "https://github.com\#{path}"
    end
  end

  GithubProfilePinnedRepos.crawl("https://github.com/nicolkill")
  ```
  """

  defmacro __using__(_) do
    quote do
      use ExCrawlzy.Client.Handlers.Fields
      use ExCrawlzy.Client.Handlers.List
      import ExCrawlzy.Client.List

      @behaviour ExCrawlzy.Client.Crawler.Interface

      @impl ExCrawlzy.Client.Crawler.Interface
      def crawl(site) do
        case ExCrawlzy.crawl(site) do
          {:ok, content} ->
            list_size = list_size()
            list_selector = get_list_selector_selector()
            fields = fields()

            content
            |> Floki.find(list_selector)
            |> Enum.take(list_size)
            |> Enum.map(fn sub_document ->
              {:ok, data} = ExCrawlzy.parse(fields, sub_document)
              data
            end)
          error ->
            error
        end
      end
    end
  end
end
