Erlang tasks for Mix
====================

This project provides a few Mix tasks that make it more convenient to use Mix as a build tool and
package manager when developing applications in Erlang.

Mix automates and simplifies a lot of development tasks: adding and fetching dependencies,
compilation, running test suites, generating documentation from source code, etc. It integrates with
Hex to be able to push and fetch packages from https://hex.pm and it also supports custom tasks. A
few good examples of the latter would be [dialyze](http://github.com/fishcakez/dialyze) and
[release](https://github.com/bitwalker/exrm).

You can get Mix by installing [Elixir](http://elixir-lang.org) or by downloading a standalone `mix`
escript from https://hex.pm (see section `Using with Erlang`) and putting it in your `PATH`.

Once installed, create a new project for your Erlang application.

Choose how you'd like to install the custom tasks:

  1. As an archive:

     ```
     mix archive.install https://github.com/alco/mix-erlang-tasks/releases/download/v0.1.0/mix_erlang_tasks-0.1.0.ez
     ```

     This will make the custom tasks available to `mix` regardless of where it is invoked, just like
     the builtin tasks are.

  2. Add `mix_erlang_tasks` as a dependency to your project:

     ```elixir
     # in your mix.exs

     defp deps do
       [{:mix_erlang_tasks, "0.1.0"}]
     end
     ```

     This will make the new tasks available only in the root directory of your Mix project.

Once installed, you'll have the following tasks available:

```sh
$ mix eunit          # run EUnit tests
$ mix ct             # run Common Test suites
$ mix edoc           # generate HTML documentation from the source
```

See example project at https://github.com/alco/erlang-mix-project.

## License

This software is licensed under [the MIT license](LICENSE).
