=,  eyre
|_  own=@t
::
++  grow                                                ::  convert to
  |%
  ++  mime  `^mime`[/text/x-hoon (as-octs:mimes:html own)] ::  convert to %mime
  ++  txt
    (to-wain:format own)
  --
++  grab
  |%                                            ::  convert from
  ++  mime  |=([p=mite q=octs] q.q)
  ++  noun  @t                                  ::  clam from %noun
  ++  txt   of-wain:format
  --
++  grad  %txt
--
