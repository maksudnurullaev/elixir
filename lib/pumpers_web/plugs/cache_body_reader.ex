defmodule CacheBodyReader do
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    IO.puts("XXX: #{__MODULE__}: #{inspect(body)}")
    conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
    {:ok, body, conn}
  end
end
