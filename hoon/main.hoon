/+  jock,
    sequent,
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
  ~&  >>>  "could not mold poke type: {<dat>}"  !!
  =/  c=cause  u.soft-cau
  ?-    -.c
      %test-n
    ~&  -:(snag n.c list-jocks:test-jock)
    ~&  (parse:test-jock n.c)
    ~&  (jeam:test-jock n.c)
    ~&  (mint:test-jock n.c)
    [~ k]
      %test-all
    ~&  exec-all:test-jock
    [~ k]
  ==
--

