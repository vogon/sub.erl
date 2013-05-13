-module(networker).
-export([start/2]).

start(Socket, HandlerPid) ->
	Write = spawn(fun() -> writeloop(Socket) end),
	Read = spawn(fun() -> readloop(Socket, Write) end).

readloop(Socket, Write) ->
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			handler ! { recv, self(), Write, Data };
		{error, closed} ->
			ok
	end,
	readloop(Socket, Write).

writeloop(Socket) ->
	receive
		{send, Data} ->
			io:format("~w: sending ~w~n", [self(), Data]),
			gen_tcp:send(Socket, Data)
	end,
	writeloop(Socket).