/+  jock,
    runner,
    *wrapper
=>
|%
+$  test-state  [%0 ~]
++  moat  (keep test-state)
+$  cause
  $%  [%jock name=@t text=@t args=(list @) libs-list=(list (pair term cord))]
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
  ~&  "poked at {<now>}"
  =/  soft-cau  ((soft ^cause) cause)
  ?~  soft-cau  ~|("could not mold poke type: {<cause>}" !!)
  =/  cau=^cause  u.soft-cau
  ?>  ?=(%jock -.cau)
  |^
  ~&  "running code {<name.cau>} with args {<args.cau>}"
  =/  args  (turn args.cau (cury scot %ud))
  =/  code  (preprocess text.cau args)
  =/  libs  `(map term cord)`(malt libs-list.cau)
  ~&  libs+[~(key by libs)]
  ~&  code+[code]
  ~&  parse+(parse:~(. runner libs) code)
  ~&  jeam+(jeam:~(. runner libs) code)
  =/  res  `*`(mint:~(. runner libs) code)
  ~&  mint+res
  ~&  jype+(jype:~(. runner libs) code)
  ~&  nock+(nock:~(. runner libs) code)
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
