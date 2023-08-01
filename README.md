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
# extract the pinned repos in this github
site = "https://github.com/nicolkill"

fields = %{
  body: {"div#the_body", :text} # shortcut for use a function from ExCrawlzy.Utils
#  body: {"div#the_body", fn content -> 
#   ExCrawlzy.Utils.text(content)
#  end}
}

{:ok, content} = ExCrawlzy.crawl(site)
{:ok, %{body: body}} = ExCrawlzy.parse(fields, content)
```
