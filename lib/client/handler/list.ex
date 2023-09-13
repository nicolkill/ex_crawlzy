defmodule ExCrawlzy.Client.Handlers.List do
  @moduledoc """
  Internal module to handle json fields, mainly helps to create modules with defined list selector match on compile

  add to the module the `use` and use the macro `list_selector/1` to specify the multiple selector and `list_size/1` to
  specify the amount of elements to take

  ```elixir
  defmodule Some.Module do
    use ExCrawlzy.Client.Handlers.List

    list_size(5)
    list_selector("div.element-1/3")
    ...
  ```

  and adds the functions `list_size/0` and `get_list_selector_selector/0` to the module

  ```elixir
  > Some.Module.list_size()
  5
  > Some.Module.get_list_selector_selector()
  "div.element-1/3"
  ```
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
