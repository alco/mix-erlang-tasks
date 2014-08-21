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

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

foo_test() ->
    ?assertEqual(-4, foo(4)),
    ?assertEqual(-5, foo(5)),
    ?assertEqual(4, foo(-4)),
    ?assertEqual(0, foo(0)).

bar_test() ->
    ?assertEqual(ok, bar()).

-endif.
