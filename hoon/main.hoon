/+  jock,
    test-jock,
    *wrapper
=>
|%
+$  test-state  ~
++  moat  (keep test-state)
+$  cause
  $%  [%test-n n=@]
      [%test-all ~]
  ==
+$  effect  ~
--
%-  moat
^-  fort:moat
|_  k=test-state
::
::  +load: upgrade from previous state
::
++  load
  |=  arg=*
  ^-  [(list *) *]
  !!
::
::  +peek: external inspect
::
++  peek
  |=  =path
  ~
::
::  +poke: external apply
::
++  poke
  |=  [eny=@ our=@ux now=@da dat=*]
  ^-  [(list effect) test-state]
  ~&  "poked at {<now^dat>}"
  =/  soft-cau  ((soft cause) dat)
  ?~  soft-cau
   ~&  "could not mold poke type: {<dat>}"  !!
  =/  c=cause  u.soft-cau
  ~&  exec-all:test-jock
  :: ~&  >  " "
  :: ~&  =|  results=(list tank)
  ::     =/  pa  parse-all:test-jock
  ::     |-
  ::     ?~  pa  results
  ::     $(pa t.pa, results `(list tank)`[leaf+"{<i.pa>}" results])
  :: ~&  >  " "
  :: ~&  =|  results=(list tank)
  ::     =/  pa  jeam-all:test-jock
  ::     |-
  ::     ?~  pa  results
  ::     $(pa t.pa, results `(list tank)`[leaf+"{<i.pa>}" results])
  :: ~&  >  " "
  :: ~&  =|  results=(list tank)
  ::     =/  pa  mint-all:test-jock
  ::     |-
  ::     ?~  pa  results
  ::     $(pa t.pa, results `(list tank)`[leaf+"{<i.pa>}" results])
  :: ~&  >  " "
  ~&  test-jocks:test-jock
  ?-  -.c
    %test-n  [~ k]
    %test-all  [~ k]
  ==
--

