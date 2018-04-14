:- module(
  debug_ext,
  [
    call_collect_messages/1,    % :Goal_0
    call_collect_messages/3,    % :Goal_0, -Status, -Messages
    debug_call/2,               % +Flags, :Goal_0
    debug_collect_messages/1,   % :Goal_0
    debug_concurrent_maplist/3, % +Flag, :Goal_1, +Args1
    debug_concurrent_maplist/4, % +Flag, :Goal_2, +Args1, +Args2
    debug_concurrent_maplist/5, % +Flag, :Goal_3, +Args1, +Args2, +Args3
    debug_peek_string/2,        % +Flag, +In
    debug_maplist/3,            % +Flag, :Goal_1, +Args1
    debug_verbose/2,            % +Flag, :Goal_0
    debug_verbose/3,            % +Flag, :Goal_0, +Format
    debug_verbose/4,            % +Flag, :Goal_0, +Format, +Args
    if_debug/2,                 % ?Flag, :Goal_0
    indent_debug_call/3         % +Flag, +Format, :Goal_0
  ]
).
:- reexport(library(debug)).

/** <module> Debug extensions

Tools that ease debugging SWI-Prolog programs.

@author Wouter Beek
@version 2015/07-2015/11, 2016/01-2016/05, 2016/07, 2016/12
*/

:- use_module(library(aggregate)).
:- use_module(library(apply)).
:- use_module(library(atom_ext)).
:- use_module(library(check_installation)). % Private predicates.
:- use_module(library(dcg)).
:- use_module(library(debug)).
:- use_module(library(default)).
:- use_module(library(file_ext)).
:- use_module(library(lists)).
:- use_module(library(portray_text)).
:- use_module(library(print_ext)).
:- use_module(library(thread)).

:- meta_predicate
    call_collect_messages(0),
    call_collect_messages(0, -, -),
    debug_call(+, 0),
    debug_collect_messages(0),
    debug_concurrent_maplist(+, 1, +),
    debug_concurrent_maplist(+, 2, +, +),
    debug_concurrent_maplist(+, 3, +, +, +),
    debug_maplist(+, 1, +),
    debug_maplist0(+, 1, +, +, +),
    debug_verbose(?, 0),
    debug_verbose(?, 0, +),
    debug_verbose(?, 0, +, +),
    if_debug(?, 0),
    indent_debug_call(+, +, 0).





%! call_collect_messages(:Goal_0) is det.
%! call_collect_messages(:Goal_0, -Status, -Messages) is det.

call_collect_messages(Goal_0) :-
  call_collect_messages(Goal_0, Status, Es),
  process_warnings(Es),
  process_status(Status).


call_collect_messages(Goal_0, Status, Messages) :-
  check_installation:run_collect_messages(Goal_0, Status, Messages).


process_warnings([]) :- !.
process_warnings(Es) :-
  maplist(print_error, Es).
%process_warnings(Es) :-
%  length(Es, N),
%  (N =:= 0 -> true ; print_message(warnings, number_of_warnings(N))).


process_status(true) :- !.
process_status(fail) :- !, fail.
process_status(E) :-
  print_error(E).



%! debug_call(+Flags, :Goal_0) is det.
%
% Calls Goal_0 with the given debug Flags.
%
% Debug flags that are already enabled beforehand are not disabled
% afterwards.

debug_call(Flags, Goal_0) :-
  exclude(debugging, Flags, NewFlags),
  maplist(debug, NewFlags),
  call(Goal_0),
  maplist(nodebug, NewFlags).



%! debug_collect_messages(:Goal_0) is det.

debug_collect_messages(Goal_0) :-
  call_collect_messages(Goal_0, Status, Warns),
  process_warnings(Warns),
  process_status(Status),
  (   Status == true
  ->  true
  ;   Status == false
  ->  false
  ;   print_error(Status)
  ).



%! debug_concurrent_maplist(+Flag, :Goal_1, +Args1) is det.

debug_concurrent_maplist(Flag, Goal_1, Args1) :-
  debugging(Flag), !,
  maplist(Goal_1, Args1).
debug_concurrent_maplist(_, Goal_1, Args1) :-
  concurrent_maplist(Goal_1, Args1).


%! debug_concurrent_maplist(+Flag, :Goal_2, +Args1, +Args2) is det.

debug_concurrent_maplist(Flag, Goal_2, Args1, Args2) :-
  debugging(Flag), !,
  maplist(Goal_2, Args1, Args2).
debug_concurrent_maplist(_, Goal_2, Args1, Args2) :-
  concurrent_maplist(Goal_2, Args1, Args2).


%! debug_concurrent_maplist(+Flag, :Goal_3, +Args1, +Args2, +Args3) is det.

debug_concurrent_maplist(Flag, Goal_3, Args1, Args2, Args3) :-
  debugging(Flag), !,
  maplist(Goal_3, Args1, Args2, Args3).
debug_concurrent_maplist(_, Goal_3, Args1, Args2, Args3) :-
  concurrent_maplist(Goal_3, Args1, Args2, Args3).



%! debug_maplist(+Flag, :Goal_1, +Args1) .

debug_maplist(Flag, Goal_1, L1) :-
  debugging(Flag), !,
  length(L1, Len1),
  debug_maplist0(Flag, Goal_1, L1, 1, Len1).
debug_maplist(_, Goal_1, L1) :-
  maplist(Goal_1, L1).

debug_maplist0(_, _, [], _, _).
debug_maplist0(Flag, Goal_1, [H|T], Len1, Len) :-
  call(Goal_1, H),
  (Len1 mod 100 =:= 0 -> debug(Flag, "~D out of ~D calls.", [Len1,Len]) ; true),
  Len2 is Len1 + 1,
  debug_maplist0(Flag, Goal_1, T, Len2, Len).



%! debug_peek_string(+Flag, +In) is det.

debug_peek_string(Flag, In) :-
  debugging(Flag), !,
  peek_string(In, 1000, Str),
  debug(Flag, "~s", [Str]).



%! debug_verbose(+Flag, :Goal_0) is det.

debug_verbose(Flag, Goal_0) :-
  debug_with_output_to(Flag, verbose(Goal_0)).


%! debug_verbose(+Flag, :Goal_0, +Fragment) is det.

debug_verbose(Flag, Goal_0, Fragment) :-
  debug_with_output_to(Flag, verbose(Goal_0, Fragment)).


%! debug_verbose(+Flag, :Goal_0, +Fragment, +Args) is det.

debug_verbose(Flag, Goal_0, Fragment, Args) :-
  debug_with_output_to(Flag, verbose(Goal_0, Fragment, Args)).



%! if_debug(?Flag, :Goal_0) is det.
%
% Calls the given goal only if the given flag is an active debugging
% topic.  Succeeds if Flag is uninstantiated.
%
% @see library(debug)

if_debug(Flag, _) :-
  var(Flag), !.
if_debug(Flag, _) :-
  \+ debugging(Flag), !.
if_debug(_, Goal_0) :-
  call(Goal_0).



%! indent_debug_call(+Flag, +Format, :Goal_0) is det.

indent_debug_call(Flag, Format, Goal_0) :-
  indent_debug(in, Flag, Format, []),
  call(Goal_0),
  indent_debug(out, Flag, Format, []).



%! print_error(+Error:compound) is det.

print_error(exception(E)) :- !,
  print_error(E).
print_error(E) :-
  print_message(error, E).





% MESSAGES %

:- multifile(prolog:message//1).
prolog:message(loading_module(File)) --> ['[M] ',File].
prolog:message(number_of_warnings(N)) --> ['~D warnings'-[N]].
