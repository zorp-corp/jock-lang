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
  ~&  >>>  "could not mold poke type: {<cause>}"  !!
  =/  c=^cause  u.soft-cau
  |^
  ~&  exec-all:test-jock
  :: ~&  test-all:test-jock
  :: ~&  (parse:test-jock 19)
  :: ~&  (jeam:test-jock 19)
  :: ~&  (mint:test-jock 19)
  ~&  (parse:test-jock 23)
  ~&  (jeam:test-jock 23)
  ~&  (mint:test-jock 23)
  :: ~&  dump-output
  ?-  -.c
    %test-n  [~ k]
    %test-all  [~ k]
  ==
  ++  dump-output
    |-
    ~&  >  " - parsing - "
    ~&  =|  results=(list tank)
        =/  pa  parse-all:test-jock
        |-
        ?~  pa  results
        $(pa t.pa, results `(list tank)`[(crip "{<i.pa>}") results])
    ~&  >  " - jeaming - "
    ~&  =|  results=(list tank)
        =/  pa  jeam-all:test-jock
        |-
        ?~  pa  results
        $(pa t.pa, results `(list tank)`[(crip "{<i.pa>}") results])
    ~&  >  " - minting - "
    ~&  =|  results=(list tank)
        =/  pa  mint-all:test-jock
        |-
        ?~  pa  results
        $(pa t.pa, results `(list tank)`[(crip "{<i.pa>}") results])
    ~&  >  " "
    ~
  --
--

