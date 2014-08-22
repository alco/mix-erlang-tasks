defmodule MixErlangTasks.Util do
  def filter_opts(opts) do
    Enum.reduce(opts, [], fn
      {name, nil}, acc -> [name|acc]
      {name, val}, acc -> [name, val | acc]
    end)
  end

  def compile_files(files, dir) do
    File.mkdir_p!(dir)
    for path <- files do
      :compile.file(String.to_char_list(path), [{:outdir, String.to_char_list(dir)}])
      IO.puts "Compiled #{path}"
    end
    Code.prepend_path(dir)
  end
end
