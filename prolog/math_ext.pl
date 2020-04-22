:- encoding(utf8).
:- module(
  math_ext,
  [
    avg_list/2,           % +Numbers, -Avg
    between/4,            % +Low, +High, +Interval, ?Value
    decimal_parts/3,      % ?Decimal, ?Integer, ?Fractorial
    fractional_integer/2, % +Number, -Fractorial
    fractional_weights/2, % ?Fractional, ?Weights
    inf_max/3,            % +X, +Y, -Z
    inf_min/3,            % +X, +Y, -Z
    integer_weights/2,    % ?Integer, ?Weights
    integer_weights/3     % ?Integer, +Base, ?Weights
  ]
).

/** <module> Mathematics extensions

*/

:- use_module(library(aggregate)).
:- use_module(library(clpfd)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(library(plunit)).





%! avg_list(+Numbers:list(number), +Avg:number) is semidet.
%! avg_list(+Numbers:list(number), -Avg:number) is det.
%
% # Examples
%
% ```prolog
% ?- avg_list([1 rdiv 3, 1 rdiv 6], X).
% X = 1 rdiv 4.
% ```
%
% # Special cases
%
% Avg is the integer 0 in case Numbers is the empty list.  This is
% in line with how sum_list/2 works.
%
% @throws instantiation_error if Numbers is non-ground.

avg_list([], 0):- !.
avg_list(L, Avg):-
  aggregate(count+sum(X), member(X, L), Len+Sum),
  Avg is Sum / Len.



%! between(+Low:integer, +High:integer, +Interval:integer,
%!         +Value:integer) is semidet.
%! between(+Low:integer, +High:integer, +Interval:integer,
%!         -Value:integer) is nondet.

between(Low, _, _, Low).
between(Low1, High, Interval, Value):-
  Low2 is Low1 + Interval,
  (High == ∞ -> true ; Low2 =< High),
  between(Low2, High, Interval, Value).



%! decimal_parts(+Decimal:number, -Integer:integer, -Frac:nonneg) is det.
%! decimal_parts(-Decimal:number, +Integer:integer, +Frac:nonneg) is det.
%
% @throws instantation_error
% @throws type_error

decimal_parts(N, Int, Frac):-
  ground(N),
  must_be(number, N), !,
  Int is floor(float_integer_part(N)),
  fractional_integer(N, Frac).
decimal_parts(N, Int, Frac):-
  must_be(integer, Int),
  must_be(nonneg, Frac),
  number_length(Frac, Length),
  N is copysign(abs(Int) + (Frac rdiv (10 ^ Length)), Int).



%! fractional_integer(+Frac:number, -Int:integer) is det.
%
% Variant of float_fractional_part/2 where the integer value instead
% of the fractional part is returned.

fractional_integer(Frac, _) :-
  \+ ground(Frac), !,
  instantiation_error(Frac).
fractional_integer(Frac, Int) :-
  Frac = A rdiv B, !,
  FloatFrac is A / B,
  fractional_integer(FloatFrac, Int).
fractional_integer(Frac, Int) :-
  atom_number(FracAtom, Frac),
  % We assume that there is at most one occurrence of `.'.
  sub_atom(FracAtom, IndexOfDot, 1, _, .), !,
  Skip is IndexOfDot + 1,
  sub_atom(FracAtom, Skip, _, 0, IntAtom),
  atom_number(IntAtom, Int).
fractional_integer(_, 0).



%! fractional_weights(-Frac:number, +Weights:list(between(0,9))) is det.
%! fractional_weights(+Frac:number, -Weights:list(between(0,9))) is det.

fractional_weights(Frac, Weights):-
  ground(Weights), !,
  aggregate_all(
    sum(N),
    (
      nth1(Position, Weights, Weight),
      N is Weight rdiv (10 ^ Position)
    ),
    Frac
  ).
fractional_weights(Frac, Weights):-
  ground(Frac), !,
  fractional_integer(Frac, Int),
  integer_weights(Int, Weights).
fractional_weights(_, _):-
  instantiation_error(_).



%! inf_max(+X, +Y, -Z) is det.

inf_max(∞, _, ∞) :- !.
inf_max(_, ∞, ∞) :- !.
inf_max(-∞, Y, Y) :- !.
inf_max(X, -∞, X) :- !.
inf_max(X, Y, Z) :-
  Z is max(X, Y).



%! inf_min(+X, +Y, -Z) is det.

inf_min(-∞, _, -∞) :- !.
inf_min(_, -∞, -∞) :- !.
inf_min(∞, Y, Y) :- !.
inf_min(X, ∞, X) :- !.
inf_min(X, Y, Z) :-
  Z is min(X, Y).



%! integer_weights(+Int:nonneg, +Weights:list(between(0,9))) is semidet.
%! integer_weights(-Int:nonneg, +Weights:list(between(0,9))) is det.
%! integer_weights(+Int:nonneg, -Weights:list(between(0,9))) is det.

integer_weights(Int, Weights):-
  integer_weights(Int, 10, Weights).


%! integer_weights(+Int:nonneg, +Base:nonneg, +Weights:list(between(0,9))) is semidet.
%! integer_weights(-Int:nonneg, +Base:nonneg, +Weights:list(between(0,9))) is det.
%! integer_weights(+Int:nonneg, +Base:nonneg, -Weights:list(between(0,9))) is det.
%
% @see http://stackoverflow.com/questions/4192063/reversible-binary-to-number-predicate/28442760#28442760

integer_weights(Int, Base, Weights):-
  (nonvar(Int), nonvar(Base) ; nonvar(Weights)), !,
  integer_weights0(Int, Base, Weights, 0, Int).

integer_weights0(Int, _, [], Int, _) :- !.
integer_weights0(Int, Base, [Weight|Weights], Int0, M):-
  in_base(Weight, Base),
  Int1 #= Weight + Base * Int0,
  M #>= Int1,
  integer_weights0(Int, Base, Weights, Int1, M).

in_base(Weight, Base):-
  Base #= Max + 1,
  Weight in 0..Max.

:- begin_tests('integer_weights/3').

test(
  'integer_weights(+,+,+) is semidet. TRUE',
  [forall(integer_weights_test(Int,Base,Weights))]
):-
  integer_weights(Int, Base, Weights).
test(
  'integer_weights(+,+,-) is multi. TRUE',
  [forall(integer_weights_test(Int,Base,Weights)),nondet]
):-
  integer_weights(Int, Base, Weights0),
  Weights0 = Weights.
test(
  'integer_weights(-,+,+) is multi. TRUE',
  [forall(integer_weights_test(Int, Base, Weights)),nondet]
):-
  integer_weights(Int, Base, Weights0),
  Weights0 = Weights.

integer_weights_test(1226, 10, [1,2,2,6]).
integer_weights_test(120, 60, [2,0]).

:- end_tests('integer_weights/3').



%! number_length(+Number:number, -Length:integer) is det.
%! number_length(+Number:number, +Radix:integer, -Length:integer) is det.
%
% Returns the length of the given number ‘before the dot’.
%
% @arg An integer representing a decimal number.
%
% @arg Radix An integer representing the radix used.  Common values
%      are `2.0` (binary), `8.0` (octal), `10.0` (decimal, used by
%      number_length/2, and `16.0` (hexadecimal).
%
% @arg Length An integer representing the number of digits in the
%      given number.

number_length(M, L):-
  number_length(M, 10.0, L).


number_length(N1, Radix, L1):-
  N2 is N1 / Radix,
  N2 >= 1.0, !,
  number_length(N2, Radix, L2),
  L1 is L2 + 1.
number_length(_N, _Radix, 1):- !.
