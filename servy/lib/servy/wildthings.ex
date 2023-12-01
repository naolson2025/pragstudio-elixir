defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears do
    [
      %Bear{id: 1, name: "Teddy", type: "Grizzly", hibernating: false},
      %Bear{id: 2, name: "Pooh", type: "Honey", hibernating: true},
      %Bear{id: 3, name: "Yogi", type: "Grizzly", hibernating: false},
      %Bear{id: 4, name: "Baloo", type: "Grizzly", hibernating: false},
      %Bear{id: 5, name: "Paddington", type: "Grizzly", hibernating: false},
      %Bear{id: 6, name: "Gummy", type: "Gummy", hibernating: false},
      %Bear{id: 7, name: "Fozzie", type: "Black", hibernating: false},
      %Bear{id: 8, name: "Gentle Ben", type: "Panda", hibernating: false},
      %Bear{id: 9, name: "Smokey", type: "Polar", hibernating: false},
      %Bear{id: 10, name: "Beorn", type: "Were", hibernating: false}
    ]
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(bear) -> bear.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear()
  end
end
