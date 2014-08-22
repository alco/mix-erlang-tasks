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
    File.mkdir_p!(ebin_test)
    for path <- Path.wildcard("etest/**/*_tests.erl") do
      :compile.file(String.to_char_list(path), [{:outdir, String.to_char_list(ebin_test)}])
      IO.puts "Compiled #{path}"
    end
    Code.prepend_path(ebin_test)

    options = if Keyword.get(opts, :verbose, false), do: [:verbose], else: []
    :eunit.test {:application, Mix.Project.config[:app]}, options
  end

  defp format_compile_opts(opts) do
    :io_lib.format("~p", [opts]) |> List.to_string
  end
end
