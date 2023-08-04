defmodule ExCrawlzy.Client.Handlers.Fields do
  @moduledoc """
  Internal module to handle json fields, mainly helps to create modules with defined keys on compile

  add to the module the `use` and use the macro `add_field/3`

  ```elixir
  defmodule Some.Module do
    use ExCrawlzy.Client.Handlers.Fields

    add_field(:name, "a.mr-1 span.repo", :text)
    ...
  ```

  and adds the function `fields/0` to the module

  ```elixir
  > Some.Module.fields()
  %{name: {"a.mr-1 span.repo", :text}}
  ```
  """

  defmacro __using__(_) do
    quote do
      import ExCrawlzy.Client.Handlers.Fields

      @moduledoc """
      Get all the fields added with the macro `add_field/3`
      """
      def fields() do
        mod_functions = __MODULE__.__info__(:functions)

        get_available_selectors()
        |> Enum.reduce(%{}, fn k, acc ->
          {selector, func} = get_selector_data(k)
          func = if Keyword.has_key?(mod_functions, func), do: {__MODULE__, func}, else: func

          Map.put(acc, k, {selector, func})
        end)
      end

      Module.register_attribute(__MODULE__, :selectors, accumulate: true)
      @before_compile ExCrawlzy.Client.Handlers.Fields
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
      defp get_available_selectors(), do: unquote(available_selectors)
    end
  end

  @doc """
  Add the params in the inner data, all are saved on the module and you can get the whole data using the function `fields/0`
  """
  defmacro add_field(field_name, selector, func) do
    quote do
      @selectors %{field_name: unquote(field_name), selector: unquote(selector), func: unquote(func)}
    end
  end

end
