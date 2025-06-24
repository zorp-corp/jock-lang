/+  jock,
    test-jock,
    *wrapper
=>
|%
+$  test-state  [%0 libs=(map term cord)]
++  moat  (keep test-state)
+$  cause
  $%  [%load-libs libs=*] ::(list (pair term cord))]
      [%test n=@]
      [%test-all ~]
      [%exec n=@]
      [%exec-all ~]
      [%parse-all ~]
      [%jeam-all ~]
      [%mint-all ~]
      [%jype-all ~]
      [%nock-all ~]
      [%run-details ~]
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
      %load-libs
    =/  libs  `(map term cord)`(malt ;;((list (pair term cord)) libs.c))
    ~&  >  "loading libs {<~(tap by libs)>}"
    [~ k(libs libs)]
    ::
      %exec
    ?.  (gth (lent list-jocks:~(. test-jock libs.k)) n.c)
      ~&  >>>  "index out of range: {<n.c>}"
      [~ k]
    ~&  >  "running code {<n.c>}"
    =/  code  (snag n.c list-jocks:~(. test-jock libs.k))
    ~&       code+[-:code]
    ~&  >    parse+(parse:~(. test-jock libs.k) +.code)
    ~&  >>   jeam+(jeam:~(. test-jock libs.k) +.code)
    =/  res  `*`(mint:~(. test-jock libs.k) +.code)
    ~&  >    mint+res
    ~&  >>   jype+(jype:~(. test-jock libs.k) +.code)
    ~&  >>>  nock+(nock:~(. test-jock libs.k) +.code)
    [~ k]
  ::
      %exec-all
    ~&  exec-all:~(. test-jock libs.k)
    [~ k]
  ::
      %test
    ~&  "testing {<n.c>}"
    ~&  (test:~(. test-jock libs.k) n.c)
    [~ k]
  ::
      %test-all
    ~&  test-all:~(. test-jock libs.k)
    [~ k]
  ::
      %parse-all
    ~&  parse-all:~(. test-jock libs.k)
    [~ k]
  ::
      %jeam-all
    ~&  jeam-all:~(. test-jock libs.k)
    [~ k]
  ::
      %mint-all
    ~&  mint-all:~(. test-jock libs.k)
    [~ k]
  ::
      %jype-all
    ~&  jype-all:~(. test-jock libs.k)
    [~ k]
  ::
      %nock-all
    ~&  nock-all:~(. test-jock libs.k)
    [~ k]
  ::
      %run-details
    ~&  run-details:~(. test-jock libs.k)
    [~ k]
  ::
  ==
--
