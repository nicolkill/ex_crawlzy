defmodule ExCrawlzy.BrowserClients do
  @moduledoc """
  Simulation of real clients from different browsers in order to avoid bot detection
  """

  @type header() :: {String.t(), String.t()}
  @type client() :: [header()]

  @clients [
    Tesla.client([
      {Tesla.Middleware.Compression, [format: "gzip"]},
      {Tesla.Middleware.Headers, [
        {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
        {"sec-ch-ua",
          "\"Chromium\";v=\"106\", \"Google Chrome\";v=\"106\", \"Not;A=Brand\";v=\"99\""},
        {"user-agent",
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"}
      ]}
    ]),
    Tesla.client([
      {Tesla.Middleware.Compression, [format: "gzip"]},
      {Tesla.Middleware.Headers, [
        {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
        {"user-agent",
          "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0"}
      ]}
    ]),
    Tesla.client([
      {Tesla.Middleware.Compression, [format: "gzip"]},
      {Tesla.Middleware.Headers, [
        {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
        {"user-agent",
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"}
      ]}
    ]),
    Tesla.client([
      {Tesla.Middleware.Compression, [format: "gzip"]},
      {Tesla.Middleware.Headers, [
        {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
        {"user-agent",
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 Edg/106.0.1370.52"}
      ]}
    ])
  ]
  |> IO.inspect(label: "clients")

  @doc """
  Creates a client adding the headers in the config
  """
  @spec create_client(client()) :: Tesla.Client.t()
  def create_client(headers) do
    Tesla.client([
      {Tesla.Middleware.Compression, [format: "gzip"]},
      {Tesla.Middleware.Headers, headers}
    ])
  end

  def clients, do: @clients
  
end