defmodule Mix.Tasks.Ct do
  use Mix.Task

  @shortdoc "Run the project's Common Test suite"

  def run(args) do
    Mix.env :test

    Mix.Task.run "loadpaths", []

    paths =
      ["ctest"|Mix.Project.config[:erlc_paths]]
      |> Enum.flat_map(&["--erlc-paths", &1])
    Mix.Task.run "compile", paths ++ args

    File.mkdir_p!("ctest/logs")

    ebin_dir = Mix.Project.compile_path |> String.to_char_list
    :ct.run_test [{:dir,ebin_dir}, {:logdir, 'ctest/logs'}, {:auto_compile,false}]
  end
end
