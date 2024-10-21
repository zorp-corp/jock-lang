/+  jock
::/*  let-edit  %jock  /lib/tests/let-edit/jock
::/*  let-inner-exp  %jock  /lib/tests/let-inner-exp/jock
::/*  call  %jock  /lib/tests/call/jock
::/*  axis-call  %jock  /lib/tests/axis-call/jock
::/*  inline-lambda-call  %jock  /lib/tests/inline-lambda-call/jock
::/*  in-subj-call  %jock  /lib/tests/in-subj-call/jock
::/*  if-else  %jock  /lib/tests/if-else/jock
::/*  assert  %jock  /lib/tests/assert/jock
::/*  call-let-edit  %jock  /lib/tests/call-let-edit/jock
::/*  inline-point  %jock  /lib/tests/inline-point/jock
::/*  inline-lambda-no-arg  %jock  /lib/tests/inline-lambda-no-arg/jock
::/*  dec-jock  %jock  /lib/tests/dec/jock
::/*  eval  %jock  /lib/tests/eval/jock
::/*  multi-limb  %jock  /lib/tests/multi-limb/jock
::/*  compose  %jock  /lib/tests/compose/jock
::/*  compose-cores  %jock  /lib/tests/compose-cores/jock
::/*  baby  %jock  /lib/tests/baby/jock
::/*  comparator  %jock  /lib/tests/comparator/jock
|%
::
++  list-jocks
  ^-  (list [term @t])
  :~  ex+''
  ==
::  :~  let-edit+let-edit
::      let-inner-exp+let-inner-exp
::      call+call
::      axis-call+axis-call
::      inline-lambda-call+inline-lambda-call
::      in-subj-call+in-subj-call
::      if-else+if-else
::      assert+assert
::      call-let-edit+call-let-edit
::      inline-point+inline-point
::      inline-lambda-no-arg+inline-lambda-no-arg
::      dec-jock+dec-jock
::      eval+eval
::      multi-limb+multi-limb
::      compose+compose
::      compose-cores+compose-cores
::      baby+baby
::      ::comparator+comparator
::  ==
::
++  jeam
  |=  i=@
  ^-  jock:jock
  =/  p  (snag i list-jocks)
  ~|  -.p
  (jeam:jock +.p)
::
++  jeam-all
  ^-  (list jock:jock)
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  (jeam:jock t)
::
++  mint-all
  ^-  (list *)
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  (mint:jock t)
::
++  mint
  |=  i=@
  ^-  [term *]
  =/  p  (snag i list-jocks)
  :-  -.p
  (mint:jock +.p)
::
++  exec
  |=  i=@
  ^-  *
  =/  nok  (mint i)
  ~&  nok
  .*(%jock +.nok)
::
++  exec-all
  ^-  (list ?)
  =|  i=@
  =/  len  (lent list-jocks)
  =|  lis=(list ?)
  |-
  ?:  =(i len)
    (flop lis)
  =/  res=(unit *)
    %-  mole
    |.
    =/  nok  (mint i)
    .*(%jock +.nok)
  =.  lis
    [?=(^ res) lis]
  $(i +(i))
--
