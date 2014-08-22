defmodule MixErlangTasks.Util do
  def filter_opts(opts) do
    Enum.reduce(opts, [], fn
      {name, nil}, acc -> [name|acc]
      {name, val}, acc -> [name, val | acc]
    end)
  end
end
