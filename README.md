## ExCrawlzy

Another crawling library but with more than just crawl

You can crawl sites and transform content to json/map using CSS selectors with no other libraries, utilities included
and more than a simple integration, you can transform a simple site to json with fields like lists or another sub-json
structures

## Installation

If [available in Hex](https://hexdocs.pm/ex_crawlzy), the package can be installed
by adding `ex_crawlzy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_crawlzy, "~> 0.1.1"}
  ]
end
```

## Usage

Just use the function [`ExCrawlzy.crawl/1`](https://hexdocs.pm/ex_crawlzy/ExCrawlzy.html#crawl/1) to
crawl and [`ExCrawlzy.parse/2`](https://hexdocs.pm/ex_crawlzy/ExCrawlzy.html#parse/2) to parse to json

#### Basic usage

```elixir
site = "https://example.site"

fields = %{
  # shortcut for use a function from ExCrawlzy.Utils
  body: {"div#the_body", :text}
#  module/function way
#  body: {"div#the_body", {ExCrawlzy.Utils, :text}}
#  body: {"div#the_body", fn content -> 
#   ExCrawlzy.Utils.text(content)
#  end}
}

{:ok, content} = ExCrawlzy.crawl(site)
{:ok, %{body: body}} = ExCrawlzy.parse(fields, content)
```

#### Using Client

You can create a module pre-configured with key, selector and processing functions and just call using the function
`crawl/1` inside the same module

```elixir
defmodule ExampleCrawler do
  use ExCrawlzy.Client.Json
  
  add_field(:title, "head title", :text)
  add_field(:body, "div#the_body", :text)
  add_field(:inner_field, "div#the_body div#inner_field", :text)
  add_field(:inner_second_field, "div#inner_second_field", :text_alt)
  add_field(:number, "div#the_number", :text)
  add_field(:exist, "div#the_body div#exist", :exist)
  add_field(:not_exist, "div#the_body div#not_exist", :exist)
  add_field(:link, "a.link_class", :link)
  add_field(:img, "img.img_class", :img)

  def text_alt(sub_doc) do
    ExCrawlzy.Utils.text(sub_doc)
  end
end

site = "https://example.site"

{:ok, data} = ExampleCrawler.crawl(site)
```

#### List of elements

You can create a client that parses multiple elements from html using css selectors

Using `list_selector/1` you can define the selector that all elements matches, the next is define as the client 
`ExCrawlzy.Client.Json` and this are the inner elements

```elixir
defmodule ExampleCrawlerList do
  use ExCrawlzy.Client.JsonList

  list_size(2)
  list_selector("div.possible_value")
  add_field(:field_1, "div.field_1", :text)
  add_field(:field_2, "div.field_2", :text)
end

site = "https://example_list.site"

{:ok, data} = ExampleCrawlerList.crawl(site)
```

#### A good example

```elixir
defmodule GithubProfilePinnedRepos do
  use ExCrawlzy.Client.JsonList

  list_selector("div.pinned-item-list-item")
  add_field(:name, "a.mr-1 span.repo", :text)
  add_field(:link, "a.mr-1", :link)
  add_field(:access, "span.Label", :text)
  add_field(:description, "p.pinned-item-desc", :text)
  add_field(:language, "span.d-inline-block span[itemprop=\"programmingLanguage\"]", :text)

  def link(doc) do
    path = ExCrawlzy.Utils.props("href", doc)
    "https://github.com#{path}"
  end
end

site = "https://github.com/nicolkill"

{
  :ok, 
  [
    %{
      access: "Public",
      description: "An API Prototype Platform",
      link: "https://github.com/nicolkill/dbb",
      name: "dbb",
      language: "Elixir"
    },
    %{
      access: "Public",
      description: "JSON Schema verifier in Elixir",
      link: "https://github.com/nicolkill/map_schema_validator",
      name: "map_schema_validator",
      language: "Elixir"
    },
    %{
      access: "Public",
      description: "",
      link: "https://github.com/nicolkill/ex_crawlzy",
      name: "ex_crawlzy",
      language: "Elixir"
    }
  ]
} == ExampleCrawlerList.crawl(site)
```

## Add clients

You can define you own browser clients on the requests, just use the function `add_browser_client/1` and your headers
on this shape `[{"header_name", "header value"}]`

> Add your own browser clients will replace the predefined ones

```elixir
site = "https://example.site"

fields = %{
  body: {"div#the_body", :text}
}

clients = [
  [
    {"referer", "https://your_site.com"},
    {"user-agent", "Custom User Agent"}
  ]
]

{:ok, content} = ExCrawlzy.crawl(site, clients)
{:ok, %{body: body}} = ExCrawlzy.parse(fields, content)

defmodule ExampleCrawlerList do
  use ExCrawlzy.Client.JsonList

  add_browser_client([
    {"referer", "https://your_site.com"},
    {"user-agent", "Custom User Agent"}
  ])
  list_size(2)
  list_selector("div.possible_value")
  add_field(:field_1, "div.field_1", :text)
  add_field(:field_2, "div.field_2", :text)
end

site = "https://example_list.site"

{:ok, data} = ExampleCrawlerList.crawl(site)
```
