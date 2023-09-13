defmodule ExCrawlzy.Client.Handlers.BrowserClients do
  @moduledoc """
  Module to add more browser clients to the predefined client module

  add to the module the `use` and use the macro `add_browser_client/1`

  ```elixir
  defmodule Some.Module do
    use ExCrawlzy.Client.Handlers.BrowserClients

    add_browser_client([
      {"referer", "https://your_site.com"},
      {"user-agent", "Custom User Agent"}
    ])
    ...
  ```

  and adds the function `fields/0` to the module

  ```elixir
  > Some.Module.clients()
  [
    %Tesla.Client{
      fun: nil,
      pre: [
        {Tesla.Middleware.Compression, :call, [[format: "gzip"]]},
        {Tesla.Middleware.Headers, :call,
         [
           [
             {"referer", "https://your_site.com"},
             {"user-agent", "Custom User Agent"}
           ]
         ]}
      ],
      post: [],
      adapter: nil
    }
  ]
  ```
  """

  defmacro __using__(_) do
    quote do
      import ExCrawlzy.Client.Handlers.BrowserClients

      Module.register_attribute(__MODULE__, :browser_clients, accumulate: true)
      @before_compile ExCrawlzy.Client.Handlers.BrowserClients
    end
  end

  defmacro __before_compile__(env) do
    browser_clients = Module.get_attribute(env.module, :browser_clients)

    quote do
      def browser_clients(), do: unquote(browser_clients)
    end
  end

  @doc """
  Add a new browser client to the module sending headers

  Example headers

  ```
  {"referer", "https://your_site.com"},
  {"user-agent", "Custom User Agent"}
  ```
  """
  defmacro add_browser_client(selector) do
    quote do
      @browser_clients unquote(selector)
    end
  end
end
