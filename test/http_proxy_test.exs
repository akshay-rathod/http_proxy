defmodule HttpProxyTest do
  use ExUnit.Case, async: true
  use ExUnit.Parametarized
  use Plug.Test

  test "check subversion tree" do
    pid = Process.whereis HttpProxy.Supervisor
    assert pid != nil

    children = Supervisor.which_children HttpProxy.Supervisor
    {id, _, _, modules} = hd(children)

    assert Enum.count(children) == 2
    assert id == :"HttpProxy.Handle8080"
    assert modules == [HttpProxy.Handle]
  end

  test_with_params "should convert urls",
    fn local_url, proxied_url ->
      conn = conn(:get, local_url)
      assert HttpProxy.Handle.uri(conn) == proxied_url
    end do
      [
        "root":  {"http://localhost:8080/", "http://google.com/" },
        "path":  {"https://localhost:8081/neko", "http://neko.com/neko"},
        "query": {"http://localhost:8081/neko?hoge=1", "http://neko.com/neko?hoge=1"},
        "no proxy with http":  {"http://localhost:8082/", "http://localhost/" },
        "no proxy with https":  {"https://localhost:8082/", "https://localhost/" },
      ]
  end

  test "send request and response" do
    # move to setup
    File.rm_rf!(Application.get_env(:http_proxy, :export_path))

    con = conn(:get, "http://localhost:8080/hoge/inu?email=neko&pass=123")
    HttpProxy.Handle.dispatch(con, "")

    assert File.exists?("example/8080") == true
  end

end
