defmodule Mix.Tasks.Newer do
  use Mix.Task

  @shortdoc "Create a new mix project from template"

  @moduledoc """
  ## Usage

      mix newer -t <template> [options] <name>

  The template can be one of:

    * local directory
    * URL to a repository
    * URL to a zip or tar archive that will be fetched and unpacked

  Any parameters used or defined in the template can be overriden on the
  command line. For example, the default parameter `MODULE_NAME` and
  user-defined parameter `some_name` can be overriden as follows:

      mix newer -t <template> --module-name Othername --some-name myname

  """

  def run(args) do
    options = [
      switches: [template: :string],
      aliases: [t: :template],
    ]
    {name, template, overrides} = case OptionParser.parse(args, options) do
      {opts, [name], []} ->
        {name, Keyword.get(opts, :template, ":default"), Keyword.delete(opts, :template)}
      {_, [_, arg | _], _} ->
        Mix.raise "Extraneous argument: #{arg}"
    end

    instantiate_template(name, fetch_template(template, name), parse_overrides(overrides))
  end

  defmacro param(name, value) do
    quote do
      var!(user_config) = Keyword.put(var!(user_config), unquote(name), unquote(value))
    end
  end

  defp fetch_template(template, dest) do
    cond do
      String.ends_with?(template, ".git") or File.dir?(Path.join([template, ".git"])) ->
        Mix.SCM.Git.checkout(git: template, dest: dest)

      String.starts_with?(template, "http") ->
        id = :crypto.rand_bytes(4) |> Base.encode16
        unique_name = "mix_newer_template_#{id}"
        tmp_path = Path.join(System.tmp_dir!, unique_name)

        # FIXME
        :httpc.download_file(template, tmp_path)

      File.dir?(template) ->
        File.cp_r!(template, dest)
    end
    dest
  end

  @builtin_params [
      :APP_NAME,
      :MODULE_NAME,
      :MIX_VERSION,
      :MIX_VERSION_SHORT,
  ]

  defp parse_overrides(overrides) do
    Enum.map(overrides, fn {opt_name, value} ->
      param_name =
        opt_name |> Atom.to_string |> String.upcase |> String.to_atom

      if not Enum.member?(@builtin_params, param_name) do
        param_name = opt_name
      end
      {param_name, value}
    end)
    |> Enum.into(%{})
  end

  defp instantiate_template(name, path, overrides) do
    config = %{
      APP_NAME: Dict.get(overrides, :APP_NAME, name),
      MODULE_NAME: Dict.get(overrides, :MODULE_NAME, Mix.Utils.camelize(name)),
      MIX_VERSION: Dict.get(overrides, :MIX_VERSION, System.version),
      MIX_VERSION_SHORT: Dict.get(overrides, :MIX_VERSION_SHORT, Path.rootname(System.version)),
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
    user_config =
      config
      |> Map.merge(Keyword.fetch!(bindings, :user_config) |> Enum.into(%{}))
      |> apply_overrides(overrides)

    postprocess_file_hierarchy(user_config)
  end

  defp apply_overrides(config, overrides) do
    Enum.map(config, fn {k,v} ->
      {k, Dict.get(overrides, k, v)}
    end) |> Enum.into(%{})
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
