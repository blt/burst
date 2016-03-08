-module(burst).

-export([run/2]).

%% private
-export([wrkr/3]).

%%%===================================================================
%%% API
%%%===================================================================

-spec run(Concurrency :: non_neg_integer(),
          LogsToEmit :: non_neg_integer()) -> ok.
run(Concurrency, LogsToEmit) ->
    Self = self(),
    lists:foreach(fun(I) ->
                          spawn(?MODULE, wrkr, [Self, I, LogsToEmit])
                  end, lists:seq(1, Concurrency)),
    loop(Concurrency).

%%%===================================================================
%%% Private API
%%%===================================================================

wrkr(Parent, Idx, LogsToEmit) ->
    lists:foreach(fun(I) ->
                          lager:notice("[~p] sup: ~p", [Idx, I])
                  end, lists:seq(1, LogsToEmit)),
    erlang:send(Parent, {done, thanks_so_much}).

%%%===================================================================
%%% Internal Functions
%%%===================================================================

loop(0) ->
    ok;
loop(N) ->
    receive
        {done, thanks_so_much} ->
            loop(N-1)
    end.
