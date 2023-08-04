defmodule ExCrawlzy.Utils do
  @moduledoc """
  Utilities for extract data
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

  def exist(crawled_data) do
    crawled_data
    |> length()
    |> (&(&1 > 0)).()
  end

  def text([]), do: ""
  def text([element]), do: text(element)
  def text([element | _]), do: text(element)
  def text({_, _, [text]}), do: String.trim(text)
  def text({_, _, [text | _]}), do: String.trim(text)
  def text({_, _, _}), do: ""

  def link([]), do: ""
  def link([element]), do: link(element)
  def link({_, props, _}) do
    case Enum.find(props, &(elem(&1, 0) == "href")) do
      {"href", link} -> String.trim(link)
      _ -> ""
    end
  end

  def img([]), do: ""
  def img([element]), do: img(element)
  def img({"img", props, _}) do
    props
    |> Enum.flat_map(
         &if Enum.member?(["data-old-hires", "src"], elem(&1, 0)), do: [elem(&1, 1)], else: []
       )
    |> case do
         [] -> ""
         [image] -> String.trim(image)
         [image | _] -> String.trim(image)
       end
  end
end