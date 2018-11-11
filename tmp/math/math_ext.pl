:- module(
  math_ext,
  [
    absolute/2, % ?Number:number
                % ?Abs:number
    between_float/3, % ?Low:float
                     % ?High:float
                     % +Number:float
    betwixt/3, % +Low, +High, ?Value
    binomial_coefficient/3, % +M:integer
                            % +N:integer
                            % -BinomialCoefficient:integer
    circumfence/2, % +Radius:float
                   % -Circumfence:float
    clpfd_between/3, % ?Low:integer
                     % ?High:integer
                     % ?Integer:integer
    clpfd_copysign/3, % ?Abs:nonneg
                      % ?Sign:integer
                      % ?Integer:integer
    combinations/3, % +NumObjects:integer
                    % +CombinationLength:integer
                    % -NumCombinations:integer
    euclidean_distance/3, % +Coordinate1:coordinate
                          % +Coordinate2:coordinate
                          % -EuclideanDistance:float
    factorial/2, % +N:integer
                 % -F:integer
    fibonacci/2, % ?Index:integer
                 % ?Fibonacci:integer
    float_div_zero/3, % ?X
                      % ?Y
                      % ?Z
    int_div_zero/3, % ?X
                    % ?Y
                    % ?Z
    is_even/1, % +Number:number
    is_odd/1, % +Number:number
    log/3, % +Base:integer
           % +X:float
           % +Y:float
    max/3, % +X:number
           % +Y:number
           % ?Maximum:number
    median/2, % +Ms, -N
    min_max_range/3, % +Min, +Max, -Range
    mod/3,
    normalized_number/3, % +Decimal:compound
                         % -NormalizedDecimal:compound
                         % -Exponent:nonneg
    permutations/2, % +NumObjects, -NumPermutations
    permutations/3, % +NumbersOfObjects:list(integer)
                    % +PermutationLength:integer
                    % -NumPermutations:integer
    permutations/3, % +NumObjects:integer
                    % +PermutationLength:integer
                    % -NumPermutations:integer
    plus_float/3, % ?X, ?Y, ?Z
    pred/2, % +X:integer
            % -Y:integer
    square/2, % ?N:float
              % ?Square:float
    succ_inf/2 % ?X:integer
               % ?Y:integer
  ]
).

/** <module> Math extensions

Extra arithmetic operations for use in SWI-Prolog.

# Library `apply`

Notice that many arithmetic operations can be defined with `library(apply)`.

The following produces the same result as `sum_list([1,-2,3], X)`:

```prolog
?- foldl(plus, [1,-2,3], 0, X).
X = 2.
```

The following calculates the outcome of the given `minus list':

```prolog
?- foldl(\Y^X^Z^(Z is X - Y), [1,-2,3], 0, X).
X = -2.
```

The following calculates the outcome of the given `multiplication list':

```prolog
?- foldl(\Y^X^Z^(Z is X * Y), [1,-2,3], 1, X).
X = -6.
```

---

@Author Wouter Beek
@version 2015/07, 2015/10-2015/11, 2016/01, 2016/05
*/

:- use_module(library(apply)).
:- use_module(library(clpfd)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(library(math/rational_ext)).
:- use_module(library(typecheck)).
:- use_module(library(yall)).

:- multifile(clpfd:run_propagator/2).





%! absolute(+Number:number, +Abs:number) is semidet.
%! absolute(+Number:number, -Abs:number) is det.
%! absolute(-Number:number, +Abs:number) is multi.
% Succeeds if Abs is the absolute value of Number.
%
% @throws instantiation_error
% @throws type_error
%
% # Examples
%
% ```prolog
% ?- absolute(1, Y).
% Y = 1.
%
% ?- absolute(-1, Y).
% Y = 1.
%
% ?- absolute(X, 1).
% X = 1 ;
% X = -1.
% ```
%
% # CLP(FD)
%
% The integer version of this predicate could have been written
% in CLP(FD):
%
% ```prolog
% :- use_module(library(clpfd)).
% absolute(X, Y):- Y #= abs(X), label([X,Y]).
% ```

absolute(N, Abs):-
  nonvar(N),
  must_be(number, N), !,
  Abs is abs(N).
absolute(N, Abs):-
  nonvar(Abs),
  must_be(number, Abs), !,
  (   N is Abs
  ;   N is -1 * Abs
  ).
absolute(_, _):-
  instantiation_error(_).



%! between_float(?Low:float, ?High:float, +Number:float) is semidet.

between_float(Low, High, Number):-
  % Meet the lower boundary requirement.
  (var(Low) -> true ; Low =< Number),
  % Meet the higher boundary requirement.
  (var(High) -> true ; Number =< High).



%! betwixt(+Low:integer, +High:integer, +Value:integer) is semidet.
%! betwixt(+Low:integer, +High:integer, -Value:integer) is multi.
%! betwixt(-Low:integer, +High:integer, +Value:integer) is semidet.
%! betwixt(-Low:integer, +High:integer, -Value:integer) is multi.
%! betwixt(+Low:integer, -High:integer, +Value:integer) is semidet.
%! betwixt(+Low:integer, -High:integer, -Value:integer) is multi.
% Like ISO between/3, but allowing either `Low` or `High`
% to be uninstantiated.
%
% In line with CLP(FD), `Low` can be `∞` and `High` can be `sup`.

betwixt(Low, High, N):-
  clpfd_between(Low, High, N),
  label([N]).



binomial_coefficient(M, N, BC):-
  factorial(M, F_M),
  factorial(N, F_N),
  MminN is M - N,
  factorial(MminN, F_MminN),
  BC is F_M / (F_N * F_MminN).


%! circumfence(+Radius:float, -Circumfence:float) is det.
% Returns the circumfence of a circle with the given radius.

circumfence(Rad, Circ):-
  Circ is Rad * pi * 2.



%! clpfd_between(?Low:integer, ?High:integer, ?Integer:integer) is det.

clpfd_between(Low, High, N):-
  Low #=< N,
  N #=< High.



%! clpfd_copysign(?Abs:nonneg, Sign:integer, ?Integer:integer) .

clpfd_copysign(Abs, Sg, N):-
  clpfd:make_propagator(clpfd_copysign(Abs, Sg, N), Prop),
  clpfd:init_propagator(Abs, Prop),
  clpfd:init_propagator(Sg, Prop),
  clpfd:init_propagator(N, Prop),
  clpfd:trigger_once(Prop).

% If we do not include the `var/1` cases then the following will
% run out of global stack: `?- phrase(signed_integer(1.1), Cs)`.
% Since 1.1 is not an integer clpfd_copysign/3 should not succeed here.
% Otherwise, integer//1 will be called with `N` uninstantiated,
% which starts generating all integers.
clpfd:run_propagator(clpfd_copysign(Abs, Sg, N), MState):-
  (   integer(N)
  ->  clpfd:kill(MState),
      Abs is abs(N),
      Sg is sign(N)
  ;   integer(Abs),
      integer(Sg)
  ->  clpfd:kill(MState),
      N is copysign(Abs, Sg)
  ;   var(N)
  ->  true
  ;   var(Abs),
      var(Sg)
  ).



%! combinations(
%!   +NumObjects:integer,
%!   +CombinationLength:integer,
%!   -NumCombinations:integer
%! ) is det.
% Returns the number of combinations from the given objects and
% of the given size.
%
% *Definition*: A combination is a permutation in which the order
%               neglected. Therefore, $r!$ permutations correspond to
%               one combination (with r the combination length).

combinations(NObjects, CombinationLength, NCombinations):-
  permutations(NObjects, CombinationLength, NPermutations),
  factorial(CombinationLength, F),
  NCombinations is NPermutations / F.



%! euclidean_distance(
%!   +Coordinate1:coordinate,
%!   +Coordinate2:coordinate,
%!   -EuclideanDistance:float
%! ) is det.
% Returns the Euclidean distance between two coordinates.

euclidean_distance(
  coordinate(Dimension, Args1),
  coordinate(Dimension, Args2),
  EuclideanDistance
):-
  maplist(minus, Args1, Args2, X1s),
  maplist(square, X1s, X2s),
  sum_list(X2s, X2),
  EuclideanDistance is sqrt(X2).



%! factorial(+N:integer, -F:integer) is det.
% Returns the factorial of the given number.
%
% The standard notation for the factorial of _|n|_ is _|n!|_.
%
% *Definition*: $n! = \prod_{i = 1}^n i$

factorial(N, F):-
  numlist(1, N, Ns), !,
  foldl([Y,X,Z]>>(Z is X * Y), Ns, 1, F).
% E.g., $0!$.
factorial(_, 1).

fibonacci(0, 1):- !.
fibonacci(1, 1):- !.
fibonacci(N, F):-
  N1 is N - 1,
  N2 is N - 2,
  fibonacci(N1, F1),
  fibonacci(N2, F2),
  F is F1 + F2.



%! float_div_zero(?X, ?Y, ?Z) is nondet.

float_div_zero(_, Y, Z):-
  Y =:= 0.0, !,
  Z = 0.0.
float_div_zero(X, Y, Z):-
  maplist(number, [X,Y]), !,
  Z is X / Y.
float_div_zero(X, Y, Z):-
  maplist(number, [X,Z]), !,
  Y is X / Z.
float_div_zero(X, Y, Z):-
  maplist(number, [Y,Z]), !,
  X is Y * Z.



%! int_div_zero(?X, ?Y, ?Z) is nondet.

int_div_zero(_, 0, 0):- !.
int_div_zero(X, Y, Z):-
  Z #= X // Y.



%! is_even(+Number:number) is semidet.
% Succeeds if the number is even.

is_even(N):-
  mod(N, 2, 0).



%! is_odd(+Number:number) is semidet.
% Succeeds if the number is odd.

is_odd(N):-
  mod(N, 2, 1).



%! log(+Base:integer, +X:integer, -Y:double) is det.
% Logarithm with arbitrary base `Y = log_{Base}(X)`.
%
% @arg Base An integer.
% @arg X An integer.
% @arg Y A double.

log(Base, X, Y):-
  Numerator is log(X),
  Denominator is log(Base),
  Y is Numerator / Denominator.



%! max(+X:number, +Y:number, +Maximum:number) is semidet.
%! max(+X:number, +Y:number, -Maximum:number) is det.

max(X, Y, Z):-
  Z is max(X,Y).



%! median(+Ms, -N) is det.

median(Ms, N) :-
  length(Ms, Len),
  I is Len // 2,
  (   is_odd(Len)
  ->  nth1(I, Ms, N)
  ;   I1 is I - 1,
      I2 is I + 1,
      nth1(I1, Ms, N1),
      nth1(I2, Ms, N2),
      N is (N1 + N2) / 2
  ).


%! min_max_range(+Min, +Max, -Range) is det.
% Range is of the form `range(Begin,End,Step)`.

min_max_range(Min, Max, range(Begin,End,Step)) :-
  Min =< Max,
  Diff is Max - Min,
  Step is 10 ** ceil(log10(Diff / 100)),
  Begin is floor(Min / Step) * Step,
  End is ceil(Max / Step) * Step.



%! mod(+X:rational, +Y:rational, -Z:rational) is det.
%! mod(+X:float, +Y:float, -Z:float) is det.

mod(X, Y, Z):-
  rational(X),
  rational(Y), !,
  rational_mod(X, Y, Z).
mod(X, Y, Z):-
  float(X),
  float(Y), !,
  DIV is X / Y,
  Z is X - round(DIV) * Y.



%! normalized_number(
%!   +Decimal:compound,
%!   -NormalizedDecimal:compound,
%!   -Exponent:integer
%! ) is det.
% A form of **Scientific notation**, i.e., $a \times 10^b$,
% in which $0 \leq a < 10$.
%
% The exponent $b$ is negative for a number with absolute value between
% $0$ and $1$ (e.g. $0.5$ is written as $5×10^{-1}$).
%
% The $10$ and exponent are often omitted when the exponent is $0$.

normalized_number(D, D, 0):-
  1.0 =< D,
  D < 10.0, !.
normalized_number(D1, ND, Exp1):-
  D1 >= 10.0, !,
  D2 is D1 / 10.0,
  normalized_number(D2, ND, Exp2),
  Exp1 is Exp2 + 1.
normalized_number(D1, ND, Exp1):-
  D1 < 1.0, !,
  D2 is D1 * 10.0,
  normalized_number(D2, ND, Exp2),
  Exp1 is Exp2 - 1.



%! permutations(
%!   +NumbersOfObjects:list(integer),
%!   -NumPermutations:integer
%! ) is det.
%! permutations(
%!   +NumObjects:integer,
%!   -NumPermutations:integer
%! ) is det.
% Returns the number of permutations that can be created with
% the given number of distinct objects.
%
% @see permutations/3

permutations(NumbersOfObjects, NumPermutations):-
  is_list(NumbersOfObjects), !,
  sum_list(NumbersOfObjects, NumObjects),
  permutations(NumbersOfObjects, NumObjects, NumPermutations).
permutations(NumObjects, NumPermutations):-
  permutations([NumObjects], NumPermutations).

%! permutations(
%!   +NumbersOfObjects:list(integer),
%!   +PermutationLength:integer,
%!   -NumPermutations:integer
%! ) is det.
%! permutations(
%!   +NumObjects:integer,
%!   +PermutationLength:integer,
%!   -NumPermutations:integer
%! ) is det.
% Returns the number of permutations that can be created with
% the given numbers of distinct objects and that have (exactly)
% the given length.
%
% *Definition*: The number of permutations of _|m|_ groups of unique objects
%               (i.e., types) and with _|n_i|_ group members or occurences
%               (i.e., tokens), for $0 \leq i \leq m$ and that are (exactly)
%               of length _|r|_ is $\frac{n!}{\mult_{i = 1}^m(n_i!)(n - r)!}$.
%
% @arg NumbersOfObject A list of numbers, each indicating the number of
%      objects in a certain group.
% @arg PermutationLength The (exact) number of objects that occur
%      in a permutation.
% @arg NumPermutations The number of permutations that can be created.

permutations(NumbersOfObjects, PermutationLength, NumPermutations):-
  is_list(NumbersOfObjects), !,

  % The objects.
  sum_list(NumbersOfObjects, NumObjects),
  factorial(NumObjects, F1),

  % The length compensation.
  Compensation is NumObjects - PermutationLength,
  factorial(Compensation, F3),

  % The groups.
  maplist(factorial, NumbersOfObjects, F2s),
  foldl([Y,X,Z]>>(Z is X * Y), [F3|F2s], 1, F23),

  NumPermutations is F1 / F23.
permutations(NumObjects, PermutationLength, NumPermutations):-
  factorial(NumObjects, F1),
  Compensation is NumObjects - PermutationLength,
  factorial(Compensation, F2),
  NumPermutations is F1 / F2.



%! plus_float(+X:number, +Y:number, -Z:number) is det.
%! plus_float(+X:number, -Y:number, +Z:number) is det.
%! plus_float(-X:number, +Y:number, +Z:number) is det.

plus_float(X, Y, Z):- number(X), number(Y), !, Z is X + Y.
plus_float(X, Y, Z):- nonvar(X), nonvar(Z), !, Y is Z - X.
plus_float(X, Y, Z):- nonvar(Y), nonvar(Z), !, X is Z - Y.
plus_float(_, _, _):- instantiation_error(_).



%! pred(?X:integer, ?Y:integer)
% Succeeds if Y is the direct predecessor of X.
%
% Variant of built-in succ/2.

pred(X, Y):-
  succ(Y, X).



%! square(+X:float, +Square:float) is semidet.
%! square(+X:float, -Square:float) is det.
%! square(-X:float, +Square:float) is det.
% Returns the square of the given number.

square(N, Sq):-
  nonvar(N), !,
  Sq is N ** 2.
square(N, Sq):-
  N is sqrt(Sq).



%! succ_inf(+X:integer, +Y:integer) is semidet.
%! succ_inf(+X:integer, -Y:integer) is det.
%! succ_inf(-X:integer, +Y:integer) is det.
%
% Variant of succ/2 that allows the value `∞` to be used.

succ_inf(∞, ∞):- !.
succ_inf(X, Y):-
  succ(X, Y).
