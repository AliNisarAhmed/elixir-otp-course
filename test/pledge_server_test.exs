defmodule PledgeServerTest do
  use ExUnit.Case, async: true

  alias Servy.PledgeServer

  test "hold on to three items in the cache" do
    PledgeServer.start()

    assert PledgeServer.recent_pledges() == []

    pledges = [{"Ali", 100}, { "Sam", 500}, {"Ammi", 600}, {"Papa", 700}]

    for {name, amount} <- pledges do
      PledgeServer.create_pledge(name, amount)
    end

    cachedPledges = PledgeServer.recent_pledges()

    assert cachedPledges == Enum.drop(pledges, 1) |> Enum.reverse

  end
end
