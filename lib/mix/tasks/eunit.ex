defmodule Mix.Tasks.Eunit do
  use Mix.Task

  @shortdoc "Run the project's EUnit test suite"

  @moduledoc """
  # Command line options

    * `--verbose`, `-v` - verbose mode
    * other options supported by `compile*` tasks

  """

  def run(args) do
    {opts, args, rem_opts} = OptionParser.parse(args, strict: [verbose: :boolean], aliases: [v: :verbose])
    new_args = args ++ MixErlangTasks.Util.filter_opts(rem_opts)

    # use a different env from :test because compilation options differ
    Mix.env :etest

    compile_opts = [{:d,:TEST}|Mix.Project.config[:erlc_options]]
    System.put_env "ERL_COMPILER_OPTIONS", format_compile_opts(compile_opts)

    Mix.Task.run "compile", new_args

    # This is run independently, so that the test modules don't end up in the
    # .app file
    ebin_test = Path.join([Mix.Project.app_path, "test_beams"])
    MixErlangTasks.Util.compile_files(Path.wildcard("etest/**/*_tests.erl"), ebin_test)

    all_beam_folders = for i <- [ebin_test | Mix.Project.load_paths] do
      String.to_charlist(i)
    end

    options = if Keyword.get(opts, :verbose, false), do: [:verbose], else: []
    :eunit.test {:application, Mix.Project.config[:app]}, options

    :eunit.test all_beam_folders, options
  end

  defp format_compile_opts(opts) do
    :io_lib.format("~p", [opts]) |> List.to_string
  end
end
