defmodule Mix.Tasks.Ct do
  use Mix.Task

  @shortdoc "Run the project's Common Test suite"

  def run(_args) do
    Mix.env :test

    Mix.Task.run "loadpaths", []
    Mix.Task.run "compile", []

    test_dir = Mix.Project.compile_path |> String.to_char_list
    for file <- Path.wildcard("test/*_SUITE.erl") do
      # FIXME: we can't use compile.erlang here because it reads source paths
      # from the project config
      :compile.file(String.to_char_list(file), [outdir: test_dir])
    end

    File.mkdir_p!("test/ct")

    :ct.run_test [{:dir,test_dir}, {:logdir, 'test/ct'}, {:auto_compile,false}]
  end
end
