defmodule ExCrawlzy.Client.List do
  @moduledoc """
  Module that helps to create clients to crawl some sites

  The point its create other module that uses this module and add fields using the macro `add_field/3`

  Then just use the client function `crawl/1`
  """

  defmacro __using__(_) do
    quote do
      use ExCrawlzy.Client.Handlers.Fields
      use ExCrawlzy.Client.Handlers.List
      import ExCrawlzy.Client.List

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
