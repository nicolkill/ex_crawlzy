defmodule ExCrawlzy.Client.Json do
  @moduledoc """
  Module that helps to create clients to crawl some sites and extract the data as json/map

  The point its create other module that uses this module and add fields using the macro `add_field/3`

  Then just use the client function `crawl/1` with your url and will crawl and parse the data and return the json/map

  ```elixir
  defmodule ExampleCrawler do
    use ExCrawlzy.Client.Json

    add_field(:title, "head title", :text)
    add_field(:field_1, "div#some_id", :text_alt)
    add_field(:link, "a#external_reference", :link)
    add_field(:open_new_tab, "a#external_reference", :external_target)

    def text_alt(sub_doc) do
      ExCrawlzy.Utils.text(sub_doc)
    end

    def external_target(sub_doc) do
      ExCrawlzy.Utils.props("target", sub_doc) == "_blank"
    end
  end

  ExampleCrawler.crawl("http://some.site")
  ```
  """

  defmacro __using__(_) do
    quote do
      use ExCrawlzy.Client.Handlers.Fields
      use ExCrawlzy.Client.Handlers.BrowserClients
      import ExCrawlzy.Client.Json

      @behaviour ExCrawlzy.Client.Crawler.Interface

      @impl ExCrawlzy.Client.Crawler.Interface
      def crawl(site) do
        browser_clients = browser_clients()

        case ExCrawlzy.crawl(site, browser_clients) do
          {:ok, content} ->
            fields = fields()
            ExCrawlzy.parse(fields, content)
          error ->
            error
        end
      end
    end
  end
end
