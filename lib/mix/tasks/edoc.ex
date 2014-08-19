defmodule Mix.Tasks.Edoc do
  use Mix.Task

  @shortdoc "Generate edoc documentation from the source"

  def run(_args) do
    try do
      :edoc.application(Mix.Project.config[:app], '.', [])
    catch
      :exit, _reason -> Mix.raise "Encountered some errors."
    end

    Mix.shell.info [:green, "Docs successfully generated."]
    Mix.shell.info [:green, "View them at doc/index.html."]
  end
end
