defmodule ExCrawlzy.Client do
  @moduledoc """
  Module that helps to create clients to crawl some sites

  The point its create other module that uses this module and add fields using the macro `add_field/3`

  Then just use the client function `crawl/1`
  """

  defmacro __using__(_) do
    quote do
      import ExCrawlzy.Client

      def fields() do
        mod_functions = __MODULE__.__info__(:functions)

        available_selectors()
        |> Enum.reduce(%{}, fn k, acc ->
          {selector, func} = get_selector_data(k)
          func = if Keyword.has_key?(mod_functions, func), do: {__MODULE__, func}, else: func

          Map.put(acc, k, {selector, func})
        end)
      end

      def crawl(site) do
        case ExCrawlzy.crawl(site) do
          {:ok, content} ->
            fields = fields()
            ExCrawlzy.parse(fields, content)
          error ->
            error
        end
      end

      Module.register_attribute(__MODULE__, :selectors, accumulate: true)
      @before_compile ExCrawlzy.Client
    end
  end

  defmacro __before_compile__(env) do
    selectors = Module.get_attribute(env.module, :selectors)
    available_selectors = Enum.map(selectors, &Map.get(&1, :field_name))

    selectors =
      Enum.map(selectors, fn %{field_name: field_name, selector: selector, func: func} ->
        quote do
          defp get_selector_data(unquote(field_name)), do: {unquote(selector), unquote(func)}
        end
      end)

    quote do
      unquote(selectors)
      defp available_selectors(), do: unquote(available_selectors)
    end
  end

  defmacro add_field(field_name, selector, func) do
    quote do
      @selectors %{field_name: unquote(field_name), selector: unquote(selector), func: unquote(func)}
    end
  end

end