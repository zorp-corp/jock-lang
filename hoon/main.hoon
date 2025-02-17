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
      [%parse-all ~]
      [%jeam-all ~]
      [%mint-all ~]
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
  |=  input:moat
  ^-  [(list effect) test-state]
  ~&  "poked at {<now^cause>}"
  =/  soft-cau  ((soft ^cause) cause)
  ?~  soft-cau  ~|("could not mold poke type: {<cause>}" !!)
  =/  c=^cause  u.soft-cau
  ?-    -.c
      %test-n
    ~&  "running code {<n.c>}"
    ~&       code+[-:(snag n.c list-jocks:test-jock)]
    ~&  >    parse+(parse:test-jock n.c)
    ~&  >>   jeam+(jeam:test-jock n.c)
    ~&  >>>  mint+(mint:test-jock n.c)
    [~ k]
  ::
      %exec-all
    ~&  exec-all:test-jock
    [~ k]
  ::
      %test-all
    ~&  test-all:test-jock
    [~ k]
  ::
      %parse-all
    ~&  parse-all:test-jock
    [~ k]
  ::
      %jeam-all
    ~&  jeam-all:test-jock
    [~ k]
  ::
      %mint-all
    ~&  mint-all:test-jock
    [~ k]
  ::
  ==
--
