|%
+$  goof    [mote=term =tang]
+$  wire    path
+$  ovum    [=wire =input]
+$  crud    [=goof =input]
+$  input   [eny=@ our=@ux now=@da cause=*]
::
++  keep
  |*  inner=mold
  =>
  |%
  +$  inner-state  inner
  +$  outer-state
    $%  [%0 desk-hash=(unit @uvI) internal=inner]
    ==
  +$  outer-fort
    $_  ^|
    |_  outer-state
    ++  load
      |~  arg=*
      **
    ++  peek
      |~  arg=path
      *(unit (unit *))
    ++  poke
      |~  [num=@ ovum=*]
      *[(list *) *]
    ++  wish
      |~  txt=@
      **
    --
  ::
  +$  fort
    $_  ^|
    |_  state=inner-state
    ++  load
      |~  arg=inner-state
      *inner-state
    ++  peek
      |~  arg=path
      *(unit (unit *))
    ++  poke
      |~  arg=input
      [*(list *) *inner-state]
    --
  --
  ::
  |=  inner=fort
  |=  hash=@uvI
  =<  .(desk-hash.outer `hash)
  |_  outer=outer-state
  +*  inner-fort  ~(. inner internal.outer)
  ++  load
    |=  arg=outer-state
    =/  new-internal  (load:inner-fort internal.arg)
    ..load(internal.outer new-internal)
  ::
  ++  peek
    |=  arg=path
    ^-  (unit (unit *))
    (peek:inner-fort arg)
  ::
  ++  wish
    |=  txt=@
    ^-  *
    q:(slap !>(~) (ream txt))
  ::
  ++  poke
    |=  [num=@ ovum=*]
    ^-  [(list *) _..poke]
    ?+   ovum  ~&("invalid arg: {<ovum>}" ~^..poke)
        [[%$ %arvo ~] *]
      =/  g  ((soft crud) +.ovum)
      ?~  g  ~&(%invalid-goof ~^..poke)
      =-  [~ ..poke]
      (slog tang.goof.u.g)
    ::
        [[%poke %one-punch @ ~] *]
      =/  ovum  ((soft ^ovum) ovum)
      ?~  ovum  ~&("invalid arg: {<ovum>}" ~^..poke)
      =/  o  ((soft input) input.u.ovum)
      ?~  o
        ~&  "could not mold poke type: {<ovum>}"
        =+  (road |.(;;(^^ovum ovum)))
        ~^..poke
      =^  effects  internal.outer
        (poke:inner-fort input.u.ovum)
      [effects ..poke(internal.outer internal.outer)]
    ==
  --
--