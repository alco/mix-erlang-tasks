defmodule MixErlangTasks.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mix_erlang_tasks,
      version: "0.1.0",
      elixir: "~> 1.0",
      description: description(),
      package: package(),
    ]
  end

  defp description do
    "This project provides a few Mix tasks that make it more convenient to use Mix " <>
    "as a build tool and package manager when developing applications in Erlang."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Alexei Sholik"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/alco/mix-erlang-tasks",
      }
    ]
  end

  # no deps
  # --alco
end
