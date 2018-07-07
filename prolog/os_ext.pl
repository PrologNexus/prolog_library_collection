:- module(
  os_ext,
  [
    exists_program/1,  % +Program
    open_file/1,       % +File
    open_file/2,       % +MediaType, +File
    os/1,              % ?Os
    os_path/1          % ?Directory
  ]
).

/** <module> OS extensions

@author Wouter Beek
@version 2017/04-2018/01
*/

:- use_module(library(file_ext)).
:- use_module(library(media_type)).
:- use_module(library(option)).
:- use_module(library(process)).
:- use_module(library(thread_ext)).
:- use_module(library(yall)).





%! exists_program(+Program:atom) is semidet.
%
% Succeeds if the given program can be run from PATH.

exists_program(Program) :-
  os_path(Prefix),
  atomic_list_concat([Prefix,Program], /, Exe),
  access_file(Exe, execute), !.



%! open_file(+File:atom) is semidet.
%! open_file(+MediaType:compound, +File:atom) is det.
%
% Open the file using the first existing program that is registered
% with the Media Type denote by its file name extension.
%
% Fails if there is no file name extension, or if the file name
% extension cannot be mapped to a Media Type, or if the Media Type
% cannot be mapped to a program, or if none of the mapped to programs
% exists.

open_file(File) :-
  file_media_type(File, MediaType),
  open_file(MediaType, File).


open_file(MediaType, File) :-
  media_type_program(MediaType, Program, Args),
  exists_program(Program),
  process_create(path(Program), [file(File)|Args], []).



%! os(+Os:oneof([mac,unix,windows])) is semidet.
%! os(-Os:oneof([mac,unix,windows])) is det.
%
% Succeeds if Os denotes the current Operating System.

os(mac) :-
  current_prolog_flag(apple, true), !.
os(unix) :-
  current_prolog_flag(unix, true), !.
os(windows) :-
  current_prolog_flag(windows, true), !.



%! os_path(+Directory:atom) is semidet.
%! os_path(-Directory:atom) is nondet.
%
% Succeeds if Directory is on the OS PATH.

os_path(Dir) :-
  getenv('PATH', Path),
  os_path_separator(Sep),
  atomic_list_concat(Dirs0, Sep, Path),
  member(Dir0, Dirs0),
  prolog_to_os_filename(Dir, Dir0).



%! os_path_separator(-Separator:oneof([:,;])) is det.

os_path_separator(Sep) :-
  os(Os),
  os_path_separator(Os, Sep).

os_path_separator(mac, :).
os_path_separator(unix, :).
os_path_separator(windows, ;).
