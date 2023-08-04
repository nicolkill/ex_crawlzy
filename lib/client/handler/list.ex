defmodule ExCrawlzy.Client.Handlers.List do
  @moduledoc """
  Internal module to handle json fields
  """

  defmacro __using__(_) do
    quote do
      import ExCrawlzy.Client.Handlers.List

      Module.register_attribute(__MODULE__, :list_size, accumulate: false)
      Module.register_attribute(__MODULE__, :list_selector, accumulate: false)
      @before_compile ExCrawlzy.Client.Handlers.List
    end
  end

  defmacro __before_compile__(env) do
    list_size = Module.get_attribute(env.module, :list_size)
    list_size = if is_nil(list_size), do: 20, else: list_size
    list_selector = Module.get_attribute(env.module, :list_selector)


    quote do
      def list_size(), do: unquote(list_size)
      def get_list_selector_selector(), do: unquote(list_selector)
    end
  end

  @doc """
  To specify the number of elements to take on the crawl
  """
  defmacro list_size(selector) do
    quote do
      @list_size unquote(selector)
    end
  end

  @doc """
  Add the a selector to multiple items
  """
  defmacro list_selector(selector) do
    quote do
      @list_selector unquote(selector)
    end
  end

end
