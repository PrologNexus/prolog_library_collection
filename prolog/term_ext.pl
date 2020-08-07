:- module(
  term_ext,
  [
    compound_name/2,       % +Term, ?Name
    number_of_variables/2, % +Term, -NumberOfVariables
    replace_blobs/2,       % +Term1, -Term2
    write_fact/1,          % @Term
    write_term/1           % @Term
  ]
).

/** <module> Extended support for terms

Extends the support for terms in the SWI-Prolog standard library.

*/

:- use_module(library(apply)).





%! compound_name(+Term:compound, +Name:atom) is semidet.
%! compound_name(+Term:compound, -Name:atom) is det.

compound_name(Term, Name) :-
  compound_name_arity(Term, Name, _).



%! number_of_variables(+Term:term, -NumberOfVariables:nonneg) is det.

number_of_variables(Term, N) :-
  term_variables(Term, Vars),
  length(Vars, N).



%! replace_blobs(+Term1, -Term2) is det.
%
% Copy Term1 to Term2, replacing non-text blobs.  This is required for
% error messages that may hold streams and other handles to
% non-readable objects.

replace_blobs(X, X) :-
  var(X), !.
replace_blobs([], []) :- !.
replace_blobs(Atom, Atom) :-
  atom(Atom), !.
replace_blobs(Blob, Atom) :-
  blob(Blob, Type),
  Type \== text, !,
  format(atom(Atom), '~p', [Blob]).
replace_blobs(Term0, Term) :-
  compound(Term0), !,
  compound_name_arguments(Term0, Pred, Args0),
  maplist(replace_blobs, Args0, Args),
  compound_name_arguments(Term, Pred, Args).
replace_blobs(Term, Term).



%! write_fact(@Term) is det.

write_fact(Term) :-
  write_term(Term),
  write(.),
  nl.



%! write_term(@Term) is det.
%
% Alternative to write_canonical/[1,2] that lives up to the promise
% that "terms written with this predicate can always be read back".

write_term(Term) :-
  replace_blobs(Term, BloblessTerm),
  write_term(BloblessTerm, [numbervars(true),quoted(true)]).
