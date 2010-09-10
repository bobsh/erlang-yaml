%% --------------------------
%% @copyright 2010 Bob.sh
%% @doc YAML encoder
%%

%%
%% @end
%% --------------------------
-module(yaml_encoder).

-export([encode/1]).

%% @doc Encode erlang data structure into YAML text.
%%
%% Returns a YAML encoded document as a binary string. See examples.txt in docs/
%% for examples of the corresponding formats.
%%
%% @end 
encode(Data) ->
    % Run iteration functions return results (with header)
    Encoded = encode_data(Data,0),
    <<"---\n", Encoded/binary>>.
    
%% @doc
%%
%% encode_data(Data, Level)
%% returns: CompleteDocument
%% @end
encode_data({Key,Val},Level) ->
    % Its a map, grab the key, and re-run encode_data on the value, using
    % the results in your return
    Indent = indent(Level),

    case Val of
        [_|_] -> 
            EncodedVal = encode_data(Val,Level+1),
            <<Indent/binary, Key/binary, ":\n", EncodedVal/binary>>;
        _Scalar ->
            EncodedVal = encode_data(Val,Level),
            <<Indent/binary, Key/binary, ": ", EncodedVal/binary>>
    end;

encode_data([First|Remainder],Level) ->
    % Its a sequence, so I should iterate across it
    EncodedSequence = encode_data(Remainder,Level),
    Indent = indent(Level),

    case First of
        {_Key,_Val} -> 
            EncodedFirst = encode_data(First,Level),
            <<EncodedFirst/binary, EncodedSequence/binary>>;
        _Scalar -> 
            EncodedFirst = encode_data(First,Level+1),
            <<Indent/binary, "- ", EncodedFirst/binary, EncodedSequence/binary>>
    end;

encode_data([],Level) ->
    % ran out of list items, returning nothing
    <<>>;

encode_data(Scalar,Level) ->
    % Its a scalar, just return it
    <<Scalar/binary, "\n">>.

%% @doc Indent based on level
%% @end
indent(Level) ->
    binary:copy(<<"  ">>, Level).
