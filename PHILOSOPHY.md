# The Philosophy of Jock

* Above all else, strive for legibility.  While names should not be verbose, they should be descriptive rather than lapidary.
* Jock should not rely on any external preprocessing or runtime functionality to correctly compile an entire Jock program.
* Wrappers may be used to structure and supply Jock programs with nouns and events.  The preferred pattern is to maintain the Jock compiler state using a door.
* The reference implementation of Jock is written in Hoon at `/lib/jock.hoon`.
