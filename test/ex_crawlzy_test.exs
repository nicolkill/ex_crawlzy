defmodule ExCrawlzyTest do
  use ExUnit.Case
#  doctest ExCrawlzy

  import Tesla.Mock

  @site "http://some.site"

  setup do
    {:ok, content} =
      :ex_crawlzy
      |> :code.priv_dir()
      |> (&"#{&1}/test.html").()
      |> File.read()

    mock(fn
      %{method: :get, url: @site} ->
        %Tesla.Env{status: 200, body: content}
    end)

    :ok
  end

  test "manual evaluate" do
    fields = %{
      body: {"div#the_body", :text}
    }
    assert {:ok, content} = ExCrawlzy.crawl(@site)
    assert {:ok, %{body: "the body"}} = ExCrawlzy.parse(fields, content)
  end
end
