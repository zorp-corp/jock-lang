# The Philosophy of Jock

* Jock is a high-level language which compiles directly to Nock.

* The reference implementation of Jock is written in Hoon at `/lib/jock.hoon`.

* Jock should not rely on any external preprocessing or runtime functionality to correctly compile an entire Jock program.

* Jock exposes several entry points and may be compiled to an executable Nock noun or interpreted dynamically.

* Wrappers may be used to structure and supply Jock programs with nouns and events.

* The Jock compiler may maintain context (such as libraries and command-line arguments) using a door.

* Above all else, strive for legibility.  While names should not be verbose, they should be descriptive rather than lapidary.

* Jock's design inspirations include Swift, Ruby, Python, and Rust.

* Jock is agnostic to whitespace (including tabs).
