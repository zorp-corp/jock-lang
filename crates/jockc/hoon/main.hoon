/+  jock,
    runner,
    *wrapper
=>
|%
+$  test-state  [%0 ~]
++  moat  (keep test-state)
+$  cause
  $%  [%jock name=@t text=@t args=(list @)]
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
  =/  cau=^cause  u.soft-cau
  ?>  ?=(%jock -.cau)
  |^
  ~&  "running code {<name.cau>} with args {<args.cau>}"
  =/  args  (turn args.cau (cury scot %ud))
  =/  code  (preprocess text.cau args)
  ~&  code+[code]
  ~&  parse+(parse:runner code)
  ~&  jeam+(jeam:runner code)
  =/  res  `*`(mint:runner code)
  ~&  mint+res
  ~&  jype+(jype:runner code)
  ~&  nock+(nock:runner code)
  [~ k]
  ::
  ++  preprocess
    |=  [body=@t arg=(list @t)]
    =|  idx=@
    =/  body  (trip body)
    |-  ^-  @t
    ?:  ?|  =(~ arg)
            =((lent arg) idx)
        ==
      (crip body)  :: TMI
    =/  off  (find "#{(scow %ud idx)}" body)
    ?~  off  $(idx +(idx))
    =/  top  (scag u.off body)
    =/  bot  (slag (dec (add u.off (lent (scow %ud u.off)))) body)
    =/  new  :(weld top (trip (snag idx arg)) bot)
    $(body new, idx +(idx))
  --
::
--
