defmodule HttpProxy.Format do
  @moduledoc false

  alias HttpProxy.Data, as: Data

  @type t :: %Plug.Conn{}

  @spec pretty_json(t, boolean) :: binary
  def pretty_json(conn, pretty) when pretty == true, do: pretty_json(conn, false) |> JSX.prettify!
  def pretty_json(conn, _) do
    {a, b, c, d} = conn.remote_ip

    %Data{
      request: %{
        url: url(conn),
        remote: ~s(#{a}.#{b}.#{c}.#{d}),
        method: conn.method,
        headers: conn.req_headers, # Maybe failed to convert
        request_body: readbody(Plug.Conn.read_body(conn, [])),
        options: conn.query_params
      },
      response: %{
        body: conn.resp_body,
        cookies: conn.resp_cookies,
        status_code: conn.status,
        headers: resp_headers(conn)
      }
    }
    |> JSX.encode!
  end

  defp readbody({:ok, body, _}), do: body
  defp readbody({:more, _, conn}), do: readbody(Plug.Conn.read_body(conn, []))

  defp url(conn) do
    uri = %URI{}
    %URI{uri | scheme: Atom.to_string(conn.scheme), host: conn.host, port: conn.port,
                 path: conn.request_path, query: conn.query_string}
    |> URI.to_string
  end

  defp resp_headers(conn) do
    conn.resp_headers
    |> Enum.reduce(Map.new, fn {key, value}, acc ->
      Map.put acc, key, value
    end)
  end
end
