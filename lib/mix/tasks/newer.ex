defmodule Mix.Tasks.Newer do
  use Mix.Task

  @shortdoc "Create a new mix project from template"

  @moduledoc """
  ## Usage

      mix newer -t <template> <name>

  The template can be one of:

    * local directory
    * URL to a repository
    * URL to a zip or tar archive that will be fetched and unpacked

  """

  def run(args) do
    options = [
      strict: [template: :string],
      aliases: [t: :template],
    ]
    {name, template} = case OptionParser.parse(args, options) do
      {opts, [name], []} ->
        {name, Keyword.get(opts, :template, ":default")}
      {_, [_, arg | _], []} ->
        Mix.raise "Extraneous argument: #{arg}"
      {_, _, [{invalid, _}|_]} ->
        Mix.raise "Undefined option: #{invalid}"
    end

    instantiate_template(name, fetch_template(template, name))
  end

  defp instantiate_template(name, path) do
    config = %{
      APP_NAME: name,
      MODULE_NAME: Mix.Utils.camelize(name),
      MIX_VERSION: System.version,
      MIX_VERSION_SHORT: Path.rootname(System.version),
    }

    File.cd!(path)

    init_code = File.read!("init_template.exs")
    env =
      __ENV__
      |> Map.update!(:functions, &[{__MODULE__, [param: 2]}|&1])
      |> Map.put(:vars, [])
    {_, bindings} =
      Code.string_to_quoted!(init_code)
      |> Code.eval_quoted([config: config, user_config: []], env)
    user_config = Map.merge(config, Keyword.fetch!(bindings, :user_config) |> Enum.into(%{}))

    postprocess_file_hierarchy(user_config)
  end

  defmacro param(name, value) do
    quote do
      var!(user_config) = Keyword.put(var!(user_config), unquote(name), unquote(value))
    end
  end

  defp fetch_template(template, dest) do
    Mix.SCM.Git.checkout(git: template, dest: dest)
    dest
  end

  defp postprocess_file_hierarchy(user_config) do
    {files, _directories} = get_files_and_directories()

    new_files =
      files
      |> reject_auxilary_files
      |> substitute_variables(user_config)

    substitute_variables_in_files(new_files, user_config)

    cleanup()
  end

  defp get_files_and_directories() do
    Path.wildcard("**") |> Enum.partition(&File.regular?/1)
  end

  defp reject_auxilary_files(paths) do
    paths -- ["init_template.exs"]
  end

  defp substitute_variables(paths, config) do
    paths
    |> Enum.map(fn path ->
      new_path = substitute_variables_in_string(path, config)
      if path != new_path do
        :ok = :file.rename(path, new_path)
      end
      new_path
    end)
  end

  defp substitute_variables_in_string(string, config) do
    Enum.reduce(config, string, fn {k, v}, string ->
      String.replace(string, "{{#{k}}}", v)
    end)
  end

  defp substitute_variables_in_files(files, config) do
    files
    |> Enum.each(fn path ->
      new_contents = path |> File.read! |> substitute_variables_in_string(config)
      File.write!(path, new_contents)
    end)
  end

  defp cleanup() do
    [".git", "init_template.exs"]
    |> Enum.each(&File.rm_rf!/1)
  end
end
