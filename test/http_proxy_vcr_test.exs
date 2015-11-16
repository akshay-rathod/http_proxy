defmodule HttpProxyVerTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use Plug.Test

  test "get request" do
    use_cassette "httpoison_get" do
      con = conn(:get, "http://localhost:8080/")
      :hackney.request :get, HttpProxy.Handle.uri(con), con.req_headers, [], []
    end
  end

end