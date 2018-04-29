defmodule Mix.Tasks.Ct do
  use Mix.Task

  @shortdoc "Run the project's Common Test suite"

  @moduledoc """
  # Command line options

    * `--log-dir` - change the output directory; default: ctest/logs
    * other options supported by `compile*` tasks

  """

  def run(args) do
    {opts, args, rem_opts} = OptionParser.parse(args, strict: [log_dir: :string])
    new_args = args ++ MixErlangTasks.Util.filter_opts(rem_opts)

    Mix.env :test

    Mix.Task.run "compile", new_args

    # This is run independently, so that the test modules don't end up in the
    # .app file
    ebin_dir = Path.join([Mix.Project.app_path, "test_beams"])
    MixErlangTasks.Util.compile_files(Path.wildcard("ctest/**/*_SUITE.erl"), ebin_dir)

    logdir = Keyword.get(opts, :log_dir, "ctest/logs")
    File.mkdir_p!(logdir)

    :ct.run_test [
      {:dir, String.to_charlist(ebin_dir)},
      {:logdir, String.to_charlist(logdir)},
      {:auto_compile, false}
    ]
  end
end
