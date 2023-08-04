defmodule ExCrawlzy.Utils do
  @moduledoc """
  Utilities for the whole library

  helping to parsing data and extract from css docs
  """

  @doc """
  Transform binary to readable strings

      iex> ExCrawlzy.Utils.binary_to_string(<<115, 111, 109, 101, 32, 115, 116, 114, 105, 110, 103>>)
      "some string"
  """
  @spec binary_to_string(binary()) :: String.t()
  def binary_to_string(data) when is_binary(data) do
    codepoints =
      data
      |> String.codepoints()
      |> Enum.map(&if &1 == <<0>>, do: <<1>>, else: &1)

    Enum.reduce(codepoints, fn w, result ->
      if String.valid?(w) do
        result <> w
      else
        <<parsed::8>> = w
        result <> <<parsed::utf8>>
      end
    end)
  end

  def binary_to_string(data), do: data

  @doc """
    Returns if some element exist

    Examples:

        iex> ExCrawlzy.Utils.exist([{"h1", [{"class", "some_class"}], ["My text inside a h1"]}])
        true

        iex> ExCrawlzy.Utils.exist([])
        false
  """
  @spec exist(String.t() | Floki.html_tree() | Floki.html_node()) :: String.t()
  def exist(crawled_data) do
    crawled_data
    |> length()
    |> (&(&1 > 0)).()
  end

  @doc """
    Extract specific data based on html inner element as text, works great for html simple elements like `span`, `p`, `h1` and even more

    For example on a simple link `<h1>My text inside a h1</h1>` you can extract the text inside the element

    Examples:

        iex> ExCrawlzy.Utils.text([{"h1", [{"class", "some_class"}], ["My text inside a h1"]}])
        "My text inside a h1"
  """
  @spec text(String.t() | Floki.html_tree() | Floki.html_node()) :: String.t()
  def text([]), do: ""
  def text([element]), do: text(element)
  def text([element | _]), do: text(element)
  def text({_, _, [text]}), do: String.trim(text)
  def text({_, _, [text | _]}), do: String.trim(text)
  def text({_, _, _}), do: ""

  @doc """
    Extract specific data from html element props

    For example on a simple link `<a href="http://site.example">My Link</a>` you can extract just the data of the `href` prop

    Examples:

      iex> ExCrawlzy.Utils.props("href", [{"a", [{"href", "http://site.example"}], []}])
      "http://site.example"
      iex> ExCrawlzy.Utils.props("target", [{"span", [{"target", "some_value"}], []}])
      "some_value"
  """
  @spec props(String.t(), String.t() | Floki.html_tree() | Floki.html_node()) :: String.t()
  def props(_, []), do: ""
  def props(prop_keys, [html_element]), do: props(prop_keys, html_element)
  def props(prop_keys, {_html_element, props, _}) do
    prop_keys = if is_list(prop_keys), do: prop_keys, else: [prop_keys]

    props
    |> Enum.flat_map(
         &if Enum.member?(prop_keys, elem(&1, 0)), do: [elem(&1, 1)], else: []
       )
    |> case do
         [] -> ""
         [value] -> String.trim(value)
         [value | _] -> String.trim(value)
       end
  end

  @html_elements [
    {:link, "a", ["href"]},
    {:img, "img", ["data-old-hires", "src"]},
    {:iframe, "iframe", ["src"]}
  ]

  for {func_name, html_element, prop_keys} <- @html_elements do

    quote do
      @doc """
        Extract specific data based on html element

        for html element `#{unquote(html_element)}` you can use `#{unquote(prop_keys)}`

          iex> ExCrawlzy.Utils.#{unquote(func_name)}([{"#{unquote(html_element)}", [{"#{unquote(Enum.at(prop_keys, 0))}", "some data in inner tag"}], []}])
          "some data in inner tag"
      """
    end
    @spec unquote(func_name)(String.t() | Floki.html_tree() | Floki.html_node()) :: String.t()
    def unquote(func_name)([]), do: ""
    def unquote(func_name)([element]), do: unquote(func_name)(element)
    def unquote(func_name)({unquote(html_element), _, _} = html_element), do: props(unquote(prop_keys), html_element)
  end

end