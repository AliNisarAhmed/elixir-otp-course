defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.View

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    %{ conv | status: 200, resp_body: View.index(bears)}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{ conv | status: 200, resp_body: View.show(bear)}
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