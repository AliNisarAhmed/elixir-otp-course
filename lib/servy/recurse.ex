defmodule Recurse do
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
