defmodule Recurse do

  @ranks ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  @suits ["♣", "♦", "♥", "♠"]

  def getDeckCompre() do
    for r <- @ranks, s <- @suits, do: { r, s}
  end

  def getHand() do
    getDeckCompre()
    |> Enum.shuffle()
    |> Enum.take(13)
  end

  def getFourHands() do
    getDeckCompre()
    |> Enum.shuffle()
    |> Enum.chunk_every(13)
  end

  def sum([head | tail], sum) do
    sum(tail, sum + head)
  end

  def sum([], sum), do: sum

  def triple(list) do
    triple(list, [])
  end

  def triple([head | tail], result) do
    triple(tail, [head * 3 | result])
  end

  def triple([], result), do: Enum.reverse(result)

  def my_map([head | tail], f) do
    [f.(head) | my_map(tail, f)]
  end

  def my_map([], _), do: []


end
