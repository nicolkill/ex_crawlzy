defmodule ExCrawlzy.Client.Json do
  @moduledoc """
  Module that helps to create clients to crawl some sites

  The point its create other module that uses this module and add fields using the macro `add_field/3`

  Then just use the client function `crawl/1`
  """

  defmacro __using__(_) do
    quote do
      use ExCrawlzy.Client.Handlers.Fields
      import ExCrawlzy.Client.Json

      def crawl(site) do
        case ExCrawlzy.crawl(site) do
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
