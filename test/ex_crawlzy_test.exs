defmodule ExCrawlzyTest do
  use ExUnit.Case
#  doctest ExCrawlzy

  import Tesla.Mock

  @site "http://some.site"
  @site_list "http://some_list.site"
  @github_profile "https://github.com/nicolkill"

  setup do
    {:ok, content} =
      :ex_crawlzy
      |> :code.priv_dir()
      |> (&"#{&1}/test.html").()
      |> File.read()

    {:ok, content_list} =
      :ex_crawlzy
      |> :code.priv_dir()
      |> (&"#{&1}/test_list.html").()
      |> File.read()

    {:ok, content_github} =
      :ex_crawlzy
      |> :code.priv_dir()
      |> (&"#{&1}/github_profile.html").()
      |> File.read()

    mock(fn
      %{method: :get, url: @site} ->
        %Tesla.Env{status: 200, body: content}
      %{method: :get, url: @site_list} ->
        %Tesla.Env{status: 200, body: content_list}
      %{method: :get, url: @github_profile} ->
        %Tesla.Env{status: 200, body: content_github}
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
    use ExCrawlzy.Client.Json

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

  defmodule ExampleCrawlerList do
    use ExCrawlzy.Client.List

    list_size(2)
    list_selector("div.possible_value")
    add_field(:field_1, "div.field_1", :text)
    add_field(:field_2, "div.field_2", :text)
  end

  test "using client list" do
    assert [
             %{
               field_1: "field 1 value first element",
               field_2: "field 2 value first element"
             },
             %{
               field_1: "field 1 value second element",
               field_2: "field 2 value second element"
             }
           ] = ExampleCrawlerList.crawl(@site_list)
  end

  defmodule GithubProfilePinnedRepos do
    use ExCrawlzy.Client.List

    list_selector("div.pinned-item-list-item")
    add_field(:name, "a.mr-1 span.repo", :text)
    add_field(:link, "a.mr-1", :link)
    add_field(:access, "span.Label", :text)
    add_field(:description, "p.pinned-item-desc", :text)

    def link(doc) do
      path = ExCrawlzy.Utils.link(doc)
      "https://github.com#{path}"
    end
  end

  test "crawling a github profile" do
    assert [
             %{
               access: "Public",
               description: "An API Prototype Platform",
               link: "https://github.com/nicolkill/dbb",
               name: "dbb"
             },
             %{
               access: "Public",
               description: "JSON Schema verifier in Elixir",
               link: "https://github.com/nicolkill/map_schema_validator",
               name: "map_schema_validator"
             },
             %{
               access: "Public",
               description: "",
               link: "https://github.com/nicolkill/ex_crawlzy",
               name: "ex_crawlzy"
             }
           ] = GithubProfilePinnedRepos.crawl(@github_profile)
  end
end
