defmodule Servy.Handler do
  @moduledoc "handles http requests"

  @pages_path Path.expand("../pages", __DIR__)

  import Servy.Plugins, only: [track: 1, rewrite_path: 1, log: 1]
  import Servy.Parser, only: [parse: 1]
  alias Servy.Conv
  alias Servy.BearController

  @doc "Transforms a request into a response"
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file = Path.expand("../pages", __DIR__)
  #   |> Path.join("about.html")
  #   # path = Path.absname("servy/lib/pages/about.html")

  #   case File.read(file) do
  #     {:ok, content} -> %{ conv | resp_body: content, status: 200}
  #     {:error, :enoent} -> %{ conv | resp_body: "File not found", status: 404}
  #     {:error, reason} -> %{ conv | resp_body: "File error: #{reason}", status: 200}
  #   end
  # end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    # this syntax below is shorthand for: Map.put(conv, :resp_body, "Bears, Lions, Tigers")
    # this shorthand only works when the key already exists in the map
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} found!", status: 404}
  end

  def handle_file({:ok, content}, conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | resp_body: "File error: #{reason}", status: 200}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
