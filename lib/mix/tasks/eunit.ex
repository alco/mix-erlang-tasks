defmodule Mix.Tasks.Eunit do
  use Mix.Task

  @shortdoc "Run the project's EUnit test suite"

  def run(args) do
    # use a different env from :test because compilation options differ
    Mix.env :etest

    Mix.Task.run "loadpaths", []

    paths =
      ["etest"|Mix.Project.config[:erlc_paths]]
      |> Enum.flat_map(&["--erlc-paths", &1])
    compile_opts = [{:d,:TEST}|Mix.Project.config[:erlc_options]]
    System.put_env "ERL_COMPILER_OPTIONS", :io_lib.format("~p", [compile_opts]) |> List.to_string

    Mix.Task.run "compile", paths ++ args

    :eunit.test {:application, Mix.Project.config[:app]}
  end
end
