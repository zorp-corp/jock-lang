/+  jock
/*  let-edit              %jock  /lib/tests/let-edit
/*  let-inner-exp         %jock  /lib/tests/let-inner-exp
/*  call                  %jock  /lib/tests/call
/*  axis-call             %jock  /lib/tests/axis-call
/*  inline-lambda-call    %jock  /lib/tests/inline-lambda-call
/*  in-subj-call          %jock  /lib/tests/in-subj-call
/*  if-else               %jock  /lib/tests/if-else
/*  assert                %jock  /lib/tests/assert
/*  call-let-edit         %jock  /lib/tests/call-let-edit
/*  inline-point          %jock  /lib/tests/inline-point
/*  inline-lambda-no-arg  %jock  /lib/tests/inline-lambda-no-arg
/*  dec                   %jock  /lib/tests/dec
/*  eval                  %jock  /lib/tests/eval
/*  multi-limb            %jock  /lib/tests/multi-limb
/*  compose               %jock  /lib/tests/compose
/*  compose-cores         %jock  /lib/tests/compose-cores
/*  baby                  %jock  /lib/tests/baby
/*  comparator            %jock  /lib/tests/comparator
/*  match                 %jock  /lib/tests/match
|%
::
++  list-jocks
  ^-  (list [term @t])
  :~  [%let-edit q.let-edit]
      [%let-inner-exp q.let-inner-exp]
      [%call q.call]
      [%axis-call q.axis-call]
      [%inline-lambda-call q.inline-lambda-call]
      [%in-subj-call q.in-subj-call]
      [%if-else q.if-else]
      [%assert q.assert]
      [%call-let-edit q.call-let-edit]
      [%inline-point q.inline-point]
      [%inline-lambda-no-arg q.inline-lambda-no-arg]
      [%dec q.dec]
      [%eval q.eval]
      [%multi-limb q.multi-limb]
      [%compose q.compose]
      [%compose-cores q.compose-cores]
      [%baby q.baby]
      [%comparator q.comparator]
      [%match q.match]
  ==
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
