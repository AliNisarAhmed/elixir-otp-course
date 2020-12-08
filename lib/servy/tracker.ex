defmodule Servy.Tracker do
  def get_location(wildthing) do

    :timer.sleep(500)

    locations = %{
      "rosco" => %{ lat: "40", lng: "80"},
      "bigfoot" => %{ lat: "50", lng: "50"},
      "smoky" => %{ lat: "30", lng: "40"}
    }

    Map.get(locations, wildthing)
  end
end
