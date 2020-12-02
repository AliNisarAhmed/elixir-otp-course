defmodule Servy.View do
  require EEx

  @templates_path Path.expand("templates", File.cwd!())

  EEx.function_from_file(:def, :index, Path.join(@templates_path, "index.eex"), [:bears])

  EEx.function_from_file(:def, :show, Path.join(@templates_path, "show.eex"), [:bear])

  def render(conv, template_file, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template_file)
      |> EEx.eval_file(bindings)

    %{conv | resp_body: content, status: 200}
  end
end
