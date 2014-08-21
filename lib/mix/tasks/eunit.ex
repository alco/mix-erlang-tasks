defmodule Mix.Tasks.Eunit do
  use Mix.Task

  @shortdoc "Run the project's EUnit test suite"

  def run(_args) do
    Mix.env :test

    Mix.Task.run "loadpaths", []

    # FIXME: the "compile" task really has to allow overriding options
    # programmatically without using env vars of project config
    System.put_env "ERL_COMPILER_OPTIONS", "{d,'TEST'}"
    Mix.Task.run "compile", []

    :eunit.test {:application, Mix.Project.config[:app]}
  end
end
