defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}"
  end

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join()

    %{conv | resp_body: "<ul>#{items}</ul>", status: 200}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | resp_body: "<h1>Id: #{bear.id} - Name: #{bear.name}</h1>", status: 200}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status: 201,
        resp_body: "Created a bear with type: #{type} and name: #{name}"
    }
  end

  def delete(conv, _params) do
    %{conv | resp_body: "Deleting a bear is forbidden", status: 403}
  end
end
