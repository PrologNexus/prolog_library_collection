:- module(
  pagination,
  [
    pagination/3,       % +Pattern, :Goal_0, -Result
    pagination/4,       % +Pattern, :Goal_0, +Opts, -Result
    pagination_empty/2, % +Opts, -Result
    pagination_result/2 % +Result, :Goal_1
  ]
).

/** <module> Pagination

@author Wouter Beek
@verson 2016/03, 2016/05-2016/08
*/

:- use_module(library(dict_ext)).
:- use_module(library(print_ext)).
:- use_module(library(settings)).

:- setting(
     def_page_size,
     positive_integer,
     20,
     "The default number of results per page."
   ).

:- meta_predicate
    pagination(+, 0, -),
    pagination(+, 0, +, -),
    pagination_result(+, 1).





%! pagination(+Pattern, :Goal_0, -Result) is nondet.
%! pagination(+Pattern, :Goal_0, +Opts, -Result) is nondet.
%
% The following options are supported:
%
%   * page_size(+nonneg) Default is 100.
%
%   * page(+nonneg) Default is 1.
%
% The following keys are in Result:
%   * number_of_results
%   * page
%   * page_size
%   * results

pagination(Pattern, Goal_0, Result) :-
  pagination(Pattern, Goal_0, _{}, Result).


pagination(Pattern, Goal_0, Opts1, Result) :-
  setting(def_page_size, DefPageSize),
  mod_dict(page_size, Opts1, DefPageSize, PageSize, Opts2),
  mod_dict(page, Opts2, 1, StartPage, Opts3),
  put_dict(page0, Opts3, 0, Opts4),
  %%%%flag(aap, _, 0),%DEB
  % NONDET
  findnsols(PageSize, Pattern, Goal_0, Results),
  length(Results, NumResults),
  %%%%flag(aap, N, N + 1),%DEB
  %%%%(N =:= 36 -> gtrace ; true),%DEB
  dict_inc(page0, Opts4),
  (   % No more results.
      NumResults =:= 0
  ->  true
  ;   % The start page or a page after the start page.
      Opts4.page0 >= StartPage
  ->  true
  ;   false
  ),
  dict_pairs(Result, [
    number_of_results-NumResults,
    page-Opts4.page0,
    page_size-PageSize,
    results-Results
  ]).



%! pagination_empty(+Opts, -Result) is det.

pagination_empty(Opts, Result) :-
  pagination(_, fail, Opts, Result).



%! pagination_result(+Result, :Goal_1) is det.

pagination_result(Result, Goal_1) :-
  call(Goal_1, Result.results),
  nl,
  Opts = [fg(green)],
  (   Result.results == []
  ->  ansi_format(Opts, "No results for query.~n", [])
  ;   Low is (Result.page - 1) * Result.page_size,
      LowDisplay is Low + 1,
      High is Low + Result.number_of_results,
      ansi_format(
        Opts,
        "Showing results ~D -- ~D for query.~n",
        [LowDisplay,High]
      )
  ).
