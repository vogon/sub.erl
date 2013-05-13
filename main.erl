-module(main).
-export([main/0]).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true}]).

main() ->
	register(handler, self()),
	{ok, LSocket} = gen_tcp:listen(3569, ?TCP_OPTIONS),
	spawn(fun() -> accept(LSocket) end),
	handleloop().

handleloop() ->
	receive
		{ recv, FromPid, ToPid, Data } ->
			io:format("received from ~w: ~w~n", [FromPid, Data]),
			ToPid ! { send, Data }
	end,
	handleloop().

accept(LSocket) ->
	{ok, Socket} = gen_tcp:accept(LSocket),
	spawn(networker, start, [Socket, handler]),
	accept(LSocket).
