## ExCrawlzy

Another crawling library but with more than just crawl

You can crawl sites and transform content to json/map using CSS selectors with no other libraries, utilities included
and more than a simple integration, you can transform a simple site to json with fields like lists or another sub-json
structures

Easy client creation and implementation

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_crawlzy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_crawlzy, "~> 0.1.0"}
  ]
end
```

## Usage

Just use the function [`ExCrawlzy.crawl/1`](https://hexdocs.pm/ex_crawlzy/0.1.0/ExCrawlzy.html#crawl/1) to
crawl and [`ExCrawlzy.parse/2`](https://hexdocs.pm/ex_crawlzy/0.1.0/ExCrawlzy.html#parse/2) to parse to json

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

site = "https://example.site"

{:ok, data} = ExampleCrawler.crawl(site)
```
