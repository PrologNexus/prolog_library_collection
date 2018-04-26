:- module(
  http_io,
  [
    http_delete/1,               % +Uri
    http_delete/2,               % +Uri, :Goal_3
    http_delete/3,               % +Uri, :Goal_3, +Opts
    http_get/1,                  % +Uri
    http_get/2,                  % +Uri, :Goal_3
    http_get/3,                  % +Uri, :Goal_3, +Opts
    http_head/1,                 % +Uri
    http_head/2,                 % +Uri, +Opts
    http_is_scheme/1,            % ?Scheme
    http_options/1,              % +Uri
    http_options/2,              % +Uri, +Opts
    http_post/2,                 % +Uri, +Data
    http_post/3,                 % +Uri, +Data, :Goal_3
    http_post/4,                 % +Uri, +Data, :Goal_3, +Opts
    http_put/2,                  % +Uri, +Data
    http_put/3,                  % +Uri, +Data, :Goal_3
    http_put/4,                  % +Uri, +Data, :Goal_3, +Opts
    http_retry_until_success/1,  % :Goal_0
    http_retry_until_success/2,  % :Goal_0, +Timeout
    http_status_must_be/2,       % +Status, +Succeeds
    http_status_must_be/3,       % +Status, +Succeeds, +Fails
    http_throw_bad_request/1     % :Goal_0
  ]
).

/** <module> HTTP I/O

This module extends the functionality of open_any/5 in module
iostream.

The following additional options are supported:

  * compression(+oneof([deflate,gzip,none]))

    Whether or not compression is used on the opened stream.  Default
    is `none`.

  * max_redirects(+positive_integer)

    The maximum number of redirects that is followed when opening a
    stream over HTTP.  Default is 5.

  * max_retries(+positive_integer)

    The maximum number of retries that is performed when opening a
    stream over HTTP.  A retry is made whenever a 4xx- or 5xx-range
    HTTP status code is returned.  Default is 1.

  * metadata(-dict)

The following debug flags are used:

  * http(error)

  * http(send_request)

  * http(reply)

@author Wouter Beek
@version 2016/07-2017/01
*/

:- meta_predicate
    http_delete(+, 3),
    http_delete(+, 3, +),
    http_get(+, 3),
    http_get(+, 3, +),
    http_post(+, +, 3),
    http_post(+, +, 3, +),
    http_put(+, +, 3),
    http_put(+, +, 3, +),
    http_retry_until_success(0),
    http_retry_until_success(0, +),
    http_throw_bad_request(0).

:- public
    ssl_verify/5.

ssl_verify(_SSL, _ProblemCertificate, _AllCertificates, _FirstCertificate, _Error).

:- setting(
     http:user_agent,
     string,
     "SWI-Prolog",
     "The HTTP User Agent."
   ).





%! http_delete(+Uri) is semidet.
%! http_delete(+Uri, :Goal_3) is semidet.
%! http_delete(+Uri, :Goal_3, +Opts) is semidet.

http_delete(Uri) :-
  http_delete(Uri, http_default_success).


http_delete(Uri, Goal_3) :-
  http_delete(Uri, Goal_3, []).


http_delete(Uri, Goal_3, Opts0) :-
  merge_options(Opts0, [method(delete)], Opts),
  call_on_stream(Uri, Goal_3, Opts).



%! http_get(+Uri) is det.
%! http_get(+Uri, :Goal_3) is det.
%! http_get(+Uri, :Goal_3, +Opts) is det.

http_get(Uri) :-
  http_get(Uri, http_default_success).


http_get(Uri, Goal_3) :-
  http_get(Uri, Goal_3, []).


http_get(Uri, Goal_3, Opts0) :-
  merge_options([method(get)], Opts0, Opts),
  call_on_stream(Uri, Goal_3, Opts).



%! http_head(+Uri) is semidet.
%! http_head(+Uri, +Opts) is semidet.

http_head(Uri) :-
  http_head(Uri, []).


http_head(Uri, Opts0) :-
  merge_options(Opts0, [method(head)], Opts),
  call_on_stream(Uri, ensure_empty0, Opts).

ensure_empty0(In, Path, Path) :-
  copy_stream_data(In, _, Len),
  assertion(Len =:= 0).



%! http_is_scheme(+Scheme) is semidet.

http_is_scheme(http).
http_is_scheme(https).



%! http_open_any(+Uri, -In, -Path, +Opts) is det.
%
% The following options are supported:
%
%   * max_redirects(+nonneg) Default is 5.
%
%   * max_retries(+nonneg) Default is 1.
%
%   * metadata(-list(dict))
%
%     Contains the following keys:
%
%       * '@id'(atom)
%
%       * '@type'(oneof([uri]))
%
%       * headers(list(list(code)))
%
%       * status(between(100,599))
%
%       * time(float)
%
%       * version(dict)
%
%         Contains the following keys:
%
%           * major(nonneg)
%
%           * minor(nonneg)
%
%   * method(+oneof([delete,get,head,options,post,put])
%
%     Default is `true`.
%
%   * status(-between(100,599))
%
%     The HTTP status code of the _last_ reply message.
%
%   * verbose(+oneof([all,error,none]))
%
%     Whether all, error or no messages are printed.  Default is
%     `error`.
%
% Since InPath returns an entry list that may contain headers from
% multiple consecutive HTTP replies, option header/1 is not supported.

http_open_any(Uri, In, InPath, Opts) :-
  option(max_redirects(MaxRedirect), Opts, 5),
  option(max_retries(MaxRetry), Opts, 1),
  State = _{
    max_redirects: MaxRedirect,
    max_retries: MaxRetry,
    redirects: 0,
    retries: 0,
    visited: []
  },
  (   option(verbose(all), Opts)
  ->  Flags = [http(reply),http(send_request)]
  ;   Flags = []
  ),
  option(method(Method), Opts, get),
  debug_call(Flags, http_open1(Uri, Method, State, In, InPath0, Opts)),
  reverse(InPath0, InPath).

http_open1(Uri, Method, State, In2, [InEntry|InPath], Opts) :-
  copy_term(Opts, OldOpts),
  setting(http:user_agent, UA),
  NewOpts = [
    authenticate(false),
    cert_verify_hook(cert_accept_any),
    header(location,Location),
    method(Method),
    raw_headers(Lines),
    redirect(false),
    status_code(Status),
    user_agent(UA),
    version(Major-Minor)
  ],
  merge_options(NewOpts, OldOpts, HttpOpts),
  option(timeout(Time), Opts, inf),
  call_timeout(
    Time,
    call_statistics(
      catch(http_open(Uri, In1, HttpOpts), E, true),
      walltime,
      TS
    )
  ),
  (   % No exception, so http_open/3 was successful.
      var(E)
  ->  http_lines_headers(Lines, Headers),
      (   debugging(http(reply))
      ->  http_msg(http(reply), Status, Lines)
      ;   true
      ),
      atomic_list_concat([Major,Minor], ., Version),
      InEntry = _{
        '@id': Uri,
        '@type': uri,
        headers: Headers,
        status: Status,
        time: TS,
        version: Version
      },
      http_open2(Uri, Method, State, Location, Lines, In1, Status, InPath, In2, Opts)
  ;   throw(E)
  ).

% Authentication error.
http_open2(Uri, Method, State, _, Lines, In1, Status, InPath, In2, Opts) :-
  Status =:= 401,
  http_open:parse_headers(Lines, Headers),
  http:authenticate_client(Uri, auth_reponse(Headers, Opts, AuthOpts)), !,
  close(In1),
  http_open1(Uri, Method, State, In2, InPath, AuthOpts).
% Non-authentication error.
http_open2(Uri, Method, State, _, Lines, In1, Status, InPath, In2, Opts) :-
  between(400, 599, Status), !,
  (option(verbose(error), Opts) -> http_error_msg(Status, Lines, In1) ; true),
  dict_inc(retries, State),
  (   State.retries >= State.max_retries
  ->  In1 = In2,
      InPath = [],
      print_message(warning, http_error_code(Status)),
      ignore(option(status(Status), Opts))
  ;   http_open1(Uri, Method, State, In2, InPath, Opts)
  ).
% Redirect.
http_open2(Uri1, Method, State, Location, _, In1, Status, InPath, In2, Opts) :-
  between(300, 399, Status), !,
  close(In1),
  uri_resolve(Location, Uri1, Uri2),
  dict_prepend(visited, State, Uri2),
  (   http_is_redirect_limit_exceeded(State)
  ->  print_message(warning, http_max_redirect(State.max_redirects,Uri2)),
      ignore(option(status(Status), Opts))
  ;   http_is_redirect_loop(Uri2, State)
  ->  print_message(warning, http_redirect_loop(Uri2)),
      ignore(option(status(Status), Opts))
  ;   http_open:redirect_options(Opts, RedirectOpts),
      http_open1(Uri2, Method, State, In2, InPath, RedirectOpts)
  ).
% Success.
http_open2(_, _, _, _, _, In, Status, [], In, Opts) :-
  ignore(option(status(Status), Opts)).



%! http_options(+Uri) is semidet.
%! http_options(+Uri, +Opts) is semidet.

http_options(Uri) :-
  http_options(Uri, []).


http_options(Uri, Opts0) :-
  merge_options(Opts0, [method(options)], Opts),
  call_on_stream(Uri, true0, Opts).

true0(_, InPath, InPath).



%! http_post(+Uri, +Data:compound) is det.
%! http_post(+Uri, +Data:compound, :Goal_3) is det.
%! http_post(+Uri, +Data:compound, :Goal_3, +Opts) is det.

http_post(Uri, Data) :-
  http_post(Uri, Data, http_default_success).


http_post(Uri, Data, Goal_3) :-
  http_post(Uri, Data, Goal_3, []).


http_post(Uri, Data, Goal_3, Opts0) :-
  merge_options([method(post),post(Data)], Opts0, Opts),
  call_on_stream(Uri, Goal_3, Opts).



%! http_put(+Uri, +Data:compound) is det.
%! http_put(+Uri, +Data:compound, :Goal_3) is det.
%! http_put(+Uri, +Data:compound, :Goal_3, +Opts) is det.

http_put(Uri, Data) :-
  http_put(Uri, Data, http_default_success).


http_put(Uri, Data, Goal_3) :-
  http_put(Uri, Data, Goal_3, []).


http_put(Uri, Data, Goal_3, Opts0) :-
  merge_options([method(put),post(Data)], Opts0, Opts),
  call_on_stream(Uri, Goal_3, Opts).



%! http_retry_until_success(:Goal_0) is det.
%! http_retry_until_success(:Goal_0, +Timeout) is det.
%
% Retry Goal_0 that uses HTTP communication until the HTTP
% communication succeeds.
%
% Timeout is the number of seconds in between consecutive calls of
% Goal_0.  The default timeout is 10 seconds.

http_retry_until_success(Goal_0) :-
  http_retry_until_success(Goal_0, 10).


http_retry_until_success(Goal_0, Timeout) :-
  catch(Goal_0, E, true),
  (   % HTTP success status code
      var(E)
  ->  true
  ;   % HTTP error status code
      E = error(existence_error(_,[InEntry|_]),_),
      Status = InEntry.status,
      (http_status_reason(Status, Reason) -> true ; Reason = "No Reason")
  ->  indent_debug(http(error), "Status: ~D (~s)", [Status,Reason]),
      sleep(Timeout),
      http_retry_until_success(Goal_0)
  ;   % TCP error (Try Again)
      E = error(socket_error('Try Again'), _)
  ->  indent_debug(http(error), "TCP Try Again"),
      sleep(Timeout),
      http_retry_until_success(Goal_0)
  ).



%! http_status_must_be(+Status, +Succeeds) is det.
%! http_status_must_be(+Status, +Succeeds, +Fails) is det.
%
% MustBe is a list of 2xx or 4xx range HTTP status codes.
%
% Succeeds if Status is an anticipated 2xx range HTTP status codes
%
% Fails silently if Status is an anticipated 4xx range HTTP status
% codes
%
% @throws `http_status(Status,MustBe)`

http_status_must_be(Status, Succeeds) :-
  http_status_must_be(Status, Succeeds, []).


http_status_must_be(Status, Succeeds, _) :-
  memberchk(Status, Succeeds), !.
http_status_must_be(Status, _, Fails) :-
  memberchk(Status, Fails), !,
  fail.
http_status_must_be(Status, Succeeds, Fails) :-
  throw(http_status(Status,Succeeds,Fails)).



%! http_throw_bad_request(:Goal_0) is det.

http_throw_bad_request(Goal_0) :-
  catch(Goal_0, E, true),
  (   var(E)
  ->  true
  ;   message_to_string(E, Msg),
      Code = 400,
      http_status_reason(Code, Reason),
      format(string(Status), "~d (~s)", [Code,Reason]),
      reply_json_dict(_{error: Msg, status: Status}, [status(Code)])
  ).





% HELPERS %

%! http_default_success(+In, +InPath1, -InPath2) is det.

http_default_success(In, InPath, InPath) :-
  maplist(print_dict, InPath),
  copy_stream_data(In, user_output).



%! http_error_msg(+Status, +Lines, +In) is det.

http_error_msg(Status, Lines, In) :-
  debug(http(error), "HTTP ERROR:", []),
  http_msg(http(error), Status, Lines),
  peek_string(In, 1000, Str),
  debug(http(error), "  Message content:~n    ~s", [Str]).



%! http_is_redirect_limit_exceeded(+State) is semidet.

http_is_redirect_limit_exceeded(State) :-
  State.max_redirects == inf, !,
  fail.
http_is_redirect_limit_exceeded(State) :-
  length(State.visited, Len),
  Len > State.max_redirects.



%! http_is_redirect_loop(+Uri, +State) is semidet.

http_is_redirect_loop(Uri, State) :-
  include(==(Uri), State.visited, L),
  length(L, Len),
  Len >= 2.



%! http_lines_pairs(+Lines:list(list(code)), -Pairs:list(pair(atom))) is det.

http_lines_pairs(Lines, MergedPairs) :-
  maplist(http_parse_header_pair, Lines, Pairs),
  keysort(Pairs, SortedPairs),
  group_pairs_by_key(SortedPairs, Groups),
  maplist(http_merge_headers, Groups, MergedPairs).

http_parse_header_pair(Line, Key-Value) :-
  phrase(http_parse_header_simple(Key, Value), Line).

http_parse_header_simple(Key, Value) -->
  'field-name'(Key),
  ":",
  'OWS',
  remainder_as_atom(Value).



%! http_lines_headers(+Lines, -Headers) is det.

http_lines_headers(Lines, Headers) :-
  http_lines_pairs(Lines, Pairs),
  dict_pairs(Headers, Pairs).



%! http_merge_headers(+Pair1, -Pair2) is det.
%
% Succeeds iff the given HTTP Key is separable.
%
% “Multiple message-header fields with the same field-name MAY be
% present in a message if and only if the entire field-value for that
% header field is defined as a comma-separated list [i.e., #(values)].
% It MUST be possible to combine the multiple header fields into one
% "field-name: field-value" pair, without changing the semantics of
% the message, by appending each subsequent field-value to the first,
% each separated by a comma.  The order in which header fields with
% the same field-name are received is therefore significant to the
% interpretation of the combined field value, and thus a proxy MUST
% NOT change the order of these field values when a message is
% forwarded.”

http_merge_headers(Key-[Value], Key-Value) :- !.
http_merge_headers(Key-Values, Key-Value) :-
  atomic_list_concat(Values, ', ', Value).



%! http_msg(+Flag, +Status, +Lines) is det.

http_msg(Flag, Status, Lines) :-
  (http_status_reason(Status, Reason) -> true ; Reason = "No Reason"),
  debug(Flag, "< Response: ~d (~a)", [Status,Reason]),
  http_lines_pairs(Lines, Pairs),
  maplist(http_header_msg(Flag), Pairs),
  debug(Flag, "", []).

http_header_msg(Flag, Key1-Value) :-
  (http_known(Key1) -> true ; trace),
  capitalize_atom(Key1, Key2),
  debug(Flag, "< ~a: ~a", [Key2,Value]).
