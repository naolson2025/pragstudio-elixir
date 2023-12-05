defmodule Servy.Api.BearController do
  def index(conv) do
    json = Servy.Wildthings.list_bears()
    |> Poison.encode!()

    %{ conv | resp_body: json, status: 200, resp_content_type: "application/json" }
  end
end
