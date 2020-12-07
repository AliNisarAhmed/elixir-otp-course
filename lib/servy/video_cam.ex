defmodule Servy.VideoCam do
  def get_snapshot(camera_name) do
    :timer.sleep(500)

    {:result, "#{camera_name}-snapshot.jpg"}
  end
end
