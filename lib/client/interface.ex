defmodule ExCrawlzy.Client.Crawler do
  @moduledoc """
  Interface to implement a new ExCrawlzy client
  """

  defmodule Interface do
    @callback crawl(String.t()) :: {:ok, map()} | {:error, nil}
  end

end