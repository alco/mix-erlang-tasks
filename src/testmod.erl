-module(testmod).

-export([foo/1, bar/0]).

% @type sometype() = abc | [integer()].
% Just a random type.

% @doc This if foo of the Foos.
%
foo(X) -> -X.

% @doc barrista
%
bar() -> ok.
