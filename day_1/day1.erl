-module(day1).
-include_lib("eunit/include/eunit.hrl").

-export([solve_part1/1
        ,solve_part2/1
        ]).

%%========================================================================================
%% Part 1
%%========================================================================================
-spec solve_part1(Input::string() | [integer()]) ->
  integer().
solve_part1(Input) ->
  case io_lib:printable_list(Input) of
    true -> sum(get_integer_list(Input)); %% string
    false -> sum(Input) %% list of numbers
  end.

-spec sum(FreqChanges::[integer()]) -> integer().
sum(FreqChanges) ->
  sum(FreqChanges, 0).

-spec sum(FreqChanges::[integer()], Acc::integer()) ->
  integer().
sum([H | T], Acc) ->
  sum(T, Acc + H);
sum([], Acc) ->
  Acc.


%%========================================================================================
%% Part 2
%%========================================================================================
-spec solve_part2(Input::string() | [integer()]) ->
  integer().
solve_part2(Input) ->
  case io_lib:printable_list(Input) of
    true -> find_first_frequency_reached_twice(get_integer_list(Input)); %% string
    false -> find_first_frequency_reached_twice(Input) %% list of numbers
  end.

-spec find_first_frequency_reached_twice(FreqChanges::[integer()]) ->
  integer().
find_first_frequency_reached_twice(FreqChanges) ->
  find_first_frequency_reached_twice(FreqChanges, FreqChanges, [0]).

-spec find_first_frequency_reached_twice(FreqChanges::[integer()]
                                        ,FreqChangesCopy::[integer()] %% Used in case it cannot find a frequency reached twice in the first pass.
                                        ,FoundFreqs::[integer()]
                                        ) ->
  integer().
find_first_frequency_reached_twice([Change | Changes]
                                  ,FreqChangesCopy
                                  ,[LastFreq | _] = FoundFreqs
                                  ) ->
  NewFreq =  LastFreq + Change,
  case lists:member(NewFreq, FoundFreqs) of
    true ->
      NewFreq; %% reached twice
    false ->
      find_first_frequency_reached_twice(Changes, FreqChangesCopy, [NewFreq | FoundFreqs])
  end;
find_first_frequency_reached_twice([], FreqChangesCopy, FoundFreqs) ->
  %% Not frequency reached twice found in this pass, try again.
  find_first_frequency_reached_twice(FreqChangesCopy, FreqChangesCopy, FoundFreqs).


%%% ======================================================================================
%%% Helpers
%%% ======================================================================================
-spec get_integer_list(FilePath::string()) -> [integer()].
get_integer_list(FilePath) ->
  get_integer_list(FilePath, file:read_file(FilePath)).

-spec get_integer_list(FilePath::string()
                      ,Result::{ok, file:io_device()} |
                               {error, file:posix() | badarg | system_limit}
                      ) -> [integer()].
get_integer_list(_FilePath, {ok, Binary}) ->
  [list_to_integer(X) || X <- string:tokens(binary_to_list(Binary), "\n")];
get_integer_list(FilePath, {error, Reason}) ->
  io:format("Failed to read file ~p with reason: ~p~n", [FilePath, Reason]),
  exit(1, Reason).

%%% ======================================================================================
%%% Eunit
%%% ======================================================================================
-spec solve_part1_test_() -> [true].
solve_part1_test_() ->
  [?_assertEqual(595, solve_part1("./input.txt"))
  ,?_assertEqual(3, solve_part1([+1, +1, +1]))
  ,?_assertEqual(0, solve_part1([+1, +1, -2]))
  ,?_assertEqual(-6, solve_part1([-1, -2, -3]))
  ].

-spec solve_part2_test_() -> [{string(), boolean()}].
solve_part2_test_() ->
  %% First test (input) takes a lot of time to find a frequency reached twice so we give
  %% it a minute to finish. It takes several rounds to find the result.
  [{timeout, 60, begin ?_assertEqual(80598, solve_part2("./input.txt")) end}
  ,?_assertEqual(0, solve_part2([+1, -1]))
  ,?_assertEqual(10, solve_part2([+3, +3, +4, -2, -4]))
  ,?_assertEqual(5, solve_part2([-6, +3, +8, +5, -6]))
  ,?_assertEqual(14, solve_part2([+7, +7, -2, -7, -4]))
  ].
