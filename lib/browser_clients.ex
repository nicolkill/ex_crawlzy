defmodule ExCrawlzy.BrowserClients do
  @moduledoc """
  Simulation of real clients from different browsers in order to avoid bot detection
  """

  defmacro __using__(_) do
    quote do
      @client_chrome Tesla.client([
        {Tesla.Middleware.Compression, [format: "gzip"]},
        {Tesla.Middleware.Headers,
          [
            {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
            {"sec-ch-ua",
              "\"Chromium\";v=\"106\", \"Google Chrome\";v=\"106\", \"Not;A=Brand\";v=\"99\""},
            {"user-agent",
              "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"}
          ]}
      ])

      @client_firefox Tesla.client([
        {Tesla.Middleware.Compression, [format: "gzip"]},
        {Tesla.Middleware.Headers,
          [
            {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
            {"user-agent",
              "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0"}
          ]}
      ])

      @client_safari Tesla.client([
        {Tesla.Middleware.Compression, [format: "gzip"]},
        {Tesla.Middleware.Headers,
          [
            {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
            {"user-agent",
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"}
          ]}
      ])

      @client_edge Tesla.client([
        {Tesla.Middleware.Compression, [format: "gzip"]},
        {Tesla.Middleware.Headers,
          [
            {"referer", "https://www.amazon.com.mx/ref=nav_logo"},
            {"user-agent",
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 Edg/106.0.1370.52"}
          ]}
      ])

      @clients [@client_chrome, @client_firefox, @client_safari, @client_edge]
    end
  end
  
end