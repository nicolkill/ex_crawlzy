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
      title: {"head title", :text},
      body: {"div#the_body", :text},
      inner_field: {"div#the_body div#inner_field", :text},
      inner_second_field: {"div#inner_second_field", :text},
      number: {"div#the_number", :text},
      exist: {"div#the_body div#exist", :exist},
      not_exist: {"div#the_body div#not_exist", :exist},
      link: {"a.link_class", :link},
      img: {"img.img_class", :img}
    }
    assert {:ok, content} = ExCrawlzy.crawl(@site)
    assert {
             :ok,
             %{
               title: "the title",
               body: "the body",
               inner_field: "inner field",
               inner_second_field: "inner second field",
               number: "2023",
               exist: true,
               not_exist: false,
               link: "http://some_external.link",
               img: "http://some_external.link/image_path.jpg"
             }
           } = ExCrawlzy.parse(fields, content)
  end

  defmodule ExampleCrawler do
    use ExCrawlzy.Client

    add_field(:title, "head title", :text)
    add_field(:body, "div#the_body", :text)
    add_field(:inner_field, "div#the_body div#inner_field", :text)
    add_field(:inner_second_field, "div#inner_second_field", :private_text)
    add_field(:number, "div#the_number", :text)
    add_field(:exist, "div#the_body div#exist", :exist)
    add_field(:not_exist, "div#the_body div#not_exist", :exist)
    add_field(:link, "a.link_class", :link)
    add_field(:img, "img.img_class", :img)

    def private_text(data) do
      ExCrawlzy.Utils.text(data)
    end
  end

  test "using client" do
    assert {
             :ok,
             %{
               title: "the title",
               body: "the body",
               inner_field: "inner field",
               inner_second_field: "inner second field",
               number: "2023",
               exist: true,
               not_exist: false,
               link: "http://some_external.link",
               img: "http://some_external.link/image_path.jpg"
             }
           } = ExampleCrawler.crawl(@site)
  end
end
