:- module(
  tts,
  [
    tts/1,             % +Line
    write_tts/2,       % +Sink, +Lines
    test_tts_to_file/1 % +Poem:oneof(["Biden","One Art"])
  ]
).

/** <module> Text-to-Speech (TTS)

@author Wouter Beek
@version 2015/10, 2015/12, 2016/04, 2016/07
*/

:- use_module(library(apply)).
:- use_module(library(error)).
:- use_module(library(process)).
:- use_module(library(uri)).
:- use_module(library(yall)).

:- use_module(library(dcg)).
:- use_module(library(os_ext)).

:- multifile
    user:module_uses/2.

user:module_uses(tts, program(espeak)).





%! tts(+Line) is det.
%
% Uses the external program /espeak/ in order to turn the given text
% message into speech.
%
% @throws existence_error if `espeak' is not installed.

tts(Line):-
  process_create(path(espeak), ['--',Line], []).



%! write_tts(+Lines, +Sink) is det.
%
% Uses the limited but free TTS feature of Google Translate.
%
% The lines must be sufficiently small (exact upper limit?).
%
% The lines must not contain non-ASCII characters (why not?).

write_tts(Sink, Lines):-
  call_to_stream(Sink, [Out]>>maplist(line_to_mp3(Out), Lines)).


line_to_mp3(Out, Line):-
  google_tts_link(Line, Uri),
  call_on_stream(
    uri(Uri),
    {Out}/[In,InPath,InPath]>>copy_stream_data(In, Out)
  ).


google_tts_link(Line, Uri):-
  google_tts_link("UTF-8", "en", Line, Uri).


google_tts_link(Enc, Lang, Line, Uri):-
  string_phrase(space_to_plus, Line, NormLine),
  uri_comps(
    Uri,
    uri(
      http,
      'translate.google.com',
      ['translate_tts'],
      [ie=Enc,tl=Lang,q=NormLine],
      _
    )
  ).

space_to_plus, [0'+] --> [0' ], !, space_to_plus.
space_to_plus, [C]   --> [C],   !, space_to_plus.
space_to_plus        --> [].





% TEST %

test("One Art", "The art of losing isn't hard to master;").
test("One Art", "so many things seem filled with the intent").
test("One Art", "to be lost that their loss is no disaster.").

test("One Art", "Lose something every day. Accept the fluster").
test("One Art", "of lost door keys, the hour badly spent.").
test("One Art", "The art of losing isn't hard to master.").

test("One Art", "Then practice losing farther, losing faster:").
test("One Art", "places, and names, and where it was you meant").
test("One Art", "to travel. None of these will bring disaster.").

test("One Art", "I lost my mother's watch. And look! my last, or").
test("One Art", "next-to-last, of three loved houses went.").
test("One Art", "The art of losing isn't hard to master.").

test("One Art", "I lost two cities, lovely ones. And, vaster,").
test("One Art", "some realms I owned, two rivers, a continent.").
test("One Art", "I miss them, but it wasn't a disaster.").

test("One Art", "Even losing you (the joking voice, a gesture").
test("One Art", "I love) I shan't have lied.  It's evident").
test("One Art", "the art of losing's not too hard to master").
test("One Art", "though it may look like (Write it!) like disaster.").

test_tts_to_file(Poem):-
  findall(Line, test(Poem, Line), Lines),
  atom_string(Base, Poem),
  absolute_file_name(Base, File, [access(write),extensions([mp3])]),
  write_tts(File, Lines).
