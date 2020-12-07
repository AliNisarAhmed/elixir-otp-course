defmodule Servy.PowerNapper do
  def power_nap do
    time = :rand.uniform(10_000)
    :timer.sleep(time)
    time
  end
end

# parent = self()
# spawn(fn -> send({ :slept, Servy.PowerNapper.power_nap() }) end)
# receive do {:slept, time} -> "slept for #{time}"
