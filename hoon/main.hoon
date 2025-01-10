/+  jock,
    test-jock,
    *wrapper
=>
|%
+$  test-state  [%0 ~]
++  moat  (keep test-state)
+$  cause
  $%  [%test-n n=@]
      [%test-all ~]
      [%exec-all ~]
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
  |=  arg=test-state
  ^-  test-state
  arg
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
  :: |=  [eny=@ our=@ux now=@da dat=*]
  |=  input:moat
  ^-  [(list effect) test-state]
  ~&  "poked at {<now^cause>}"
  =/  soft-cau  ((soft ^cause) cause)
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
  ::
      %exec-all
    ~&  exec-all:test-jock
    [~ k]
  ::
      %test-all
    ~&  test-all:test-jock
    [~ k]
  ==
--

