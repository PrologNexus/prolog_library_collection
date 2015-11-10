:- module(
  rfc2616_header,
  [
    'Connection'//1, % ?ConnectionTokens:list(string)
    'Connection0'//1, % ?ConnectionTokens:list(string)
    'Content-Disposition'//1, % ?Value:dict
    'Content-Disposition0'//1, % ?Value:dict
    'Content-Language'//1, % ?LanguageTags:list(list(string)))
    'Content-Language0'//1, % ?LanguageTags:list(list(string)))
    'Content-Type'//1, % ?MediaType:dict
    'Content-Type0'//1, % ?MediaType:dict
    'Date'//1, % ?Value:compound
    'Date0'//1, % ?Value:compound
    http_parsed_header_pair/2, % +Header:compound
                               % -ParsedHeaderPair:pair(atom)
    'Server'//1, % ?Value:list([dict,string])
    'Server0'//1, % ?Value:list([dict,string])
    'Transfer-Encoding'//1, % ?TransferEncoding:list(or([oneof([chunked]),dict])))
    'Transfer-Encoding0'//1 % ?TransferEncoding:list(or([oneof([chunked]),dict])))
  ]
).

/** <module> RFC 2616: Headers

@author Wouter Beek
@compat RFC 2616
@deprecated
@version 2015/11
*/

:- use_module(library(apply)).
:- use_module(library(atom_ext)).
:- use_module(library(dcg/dcg_abnf)).
:- use_module(library(dcg/dcg_phrase)).
:- use_module(library(dcg/dcg_pl)).
:- use_module(library(http/abnf_list)).
:- use_module(library(http/rfc2616)).
:- use_module(library(http/rfc2616_code)).
:- use_module(library(http/rfc2616_date)).
:- use_module(library(http/rfc2616_helpers)).
:- use_module(library(http/rfc2616_token)).
:- use_module(library(http/rfc6266)).





%! 'Connection'(?ConnectionTokens:list(string))// .
%! 'Connection0'(?ConnectionTokens:list(string))// .
% ```abnf
% 'Connection'(S) --> "Connection:", +(connection-token)
% ```

'Connection'(L) --> "Connection:", 'Connection0'(L).
'Connection0'(L) --> ++('connection-token', L, []).



%! 'connection-token'(?ConnectionToken:string)// .
% ```abnf
% connection-token = token
% ```

'connection-token'(T) --> token(T).



%! 'Content-Disposition'(?Value:compound)// .
%! 'Content-Disposition0'(?Value:compound)// .

'Content-Disposition'(D) --> "Content-Disposition:", 'Content-Disposition0'(D).
'Content-Disposition0'(content_disposition{type: Type, params: Params}) -->
  'content-disposition'(Type, Params).



%! 'Content-Language'(?LanguageTags:list(list(string)))// .
%! 'Content-Language0'(?LanguageTags:list(list(string)))// .
% ```abnf
% Content-Language = "Content-Language" ":" 1#language-tag
% ```

'Content-Language'(L) --> "Content-Language:", 'Content-Language0'(L).
'Content-Language0'(L) --> ++('language-tag', L, []).



%! 'Content-Type'(?MediaType:dict)// .
%! 'Content-Type0'(?MediaType:dict)// .
% ```abnf
% Content-Type = "Content-Type" ":" media-type
% ```

'Content-Type'(MT) --> "Content-Type:", 'Content-Type0'(MT).
'Content-Type0'(MT) --> 'media-type'(MT).




%! 'Date'(?DateTime:compound)// .
%! 'Date0'(?DateTime:compound)// .
% ```
% Date = "Date" ":" HTTP-date
% ```

'Date'('Date'(DT)) --> "Date:", 'Date0'(DT).
'Date0'(DT) --> 'HTTP-date'(DT).



%! http_parsed_header_pair(+Header:compound, -ParsedHeaderPair:pair(atom)) is det.

http_parsed_header_pair(Comp, N-V):-
  Comp =.. [N0,V0],
  http_restore_header_name(N0, N),
  http_parse_header_value(N, V0, V),
  dcg_with_output_to(current_output, pl_term(N-V)),
  nl(current_output),
  flush_output(current_output).


http_restore_header_name(N0, N):-
  atomic_list_concat(L0, '_', N0),
  maplist(capitalize_atom, L0, L),
  atomic_list_concat(L, -, N).


http_parse_header_value(N0, V0, V):-
  atom(V0), !,
  atom_concat(N0, '0', N),
  Dcg_0 =.. [N,V],
  atom_phrase(Dcg_0, V0).
% @tbd Some header values are already parsed by http_open/3.
http_parse_header_value(_, V, V).



%! 'Server'(?Server:list(or[dict,string]))// .
%! 'Server0'(?Server:list(or[dict,string]))// .
% ```abnf
% Server = "Server" ":" 1*( product | comment )
% ```

'Server'(D) --> "Server:", 'Server0'(D).
'Server0'(L) --> +(server, L, [separator('LWS')]).
server(D) --> product(D).
server(S) --> comment(S).



%! 'Transfer-Encoding'(?TransferEncoding:list(or([oneof([chunked]),dict])))// .
%! 'Transfer-Encoding0'(?TransferEncoding:list(or([oneof([chunked]),dict])))// .
% ```abnf
% Transfer-Encoding = "Transfer-Encoding" ":" 1#transfer-coding
% ```

'Transfer-Encoding'(L) --> "Transfer-Encoding:", 'Transfer-Encoding0'(L).
'Transfer-Encoding0'(L) --> ++('transfer-coding', L, []).



%! 'transfer-coding'(?TransferCoding:or([oneof([chunked]),dict]))// .
% ```abnf
% transfer-coding = "chunked" | transfer-extension
% ```

'transfer-coding'(chunked) --> "chunked".
'tarnsfer-coding'(D) --> 'transfer-extension'(D).



%! 'transfer-extension'(?TransferExtension:dict)// .
% ```abnf
% transfer-extension = token *( ";" parameter )
% ```

'transfer-extension'('transfer-extension'{token: H, parameters: T}) -->
  token(H),
  parameters(T).
