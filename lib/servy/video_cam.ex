defmodule Servy.VideoCam do
  def get_snapshot(camera_name) do
    :timer.sleep(1000)

    {:result, "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"}
  end
end
