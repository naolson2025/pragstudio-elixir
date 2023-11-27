defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> log()
    |> route()
    |> format_response()
  end

  def log(cov), do: IO.inspect(cov)

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end


  def route(conv, "GET", "/wildthings") do
    # this syntax below is shorthand for: Map.put(conv, :resp_body, "Bears, Lions, Tigers")
    # this shorthand only works when the key already exists in the map
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv, "GET", "/bears") do
    %{ conv | resp_body: "Teddy, Grizzly, Pooh", status: 200}
  end

  def route(conv, "GET", "/bears/" <> id) do
    %{ conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(conv, _method, path) do
    %{ conv | resp_body: "No #{path} found!", status: 404 }
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
