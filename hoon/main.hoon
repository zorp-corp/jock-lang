/+  jock,
    test-jock,
    *wrapper
=>
|%
+$  test-state  [%0 ~]
++  moat  (keep test-state)
+$  cause
  $%  [%test n=@]
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
      %test
    ~&  "running code {<n.c>}"
    =/  code  (snag n.c list-jocks:test-jock)
    ~&       code+[-:code]
    ~&  >    parse+(parse:test-jock +.code)
    ~&  >>   jeam+(jeam:test-jock +.code)
    ~&  >>>  mint+(mint:test-jock +.code)
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
