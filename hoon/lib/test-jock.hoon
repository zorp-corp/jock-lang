/+  jock
/*  let-edit              %jock  /lib/tests/let-edit
/*  let-inner-exp         %jock  /lib/tests/let-inner-exp
<<<<<<< HEAD
/*  call                  %jock  /lib/tests/call
=======
:: /*  call                  %jock  /lib/tests/call
>>>>>>> ef5e79acca352b1484a3b63aa31b8badce0e376a
/*  axis-call             %jock  /lib/tests/axis-call
/*  inline-lambda-call    %jock  /lib/tests/inline-lambda-call
/*  in-subj-call          %jock  /lib/tests/in-subj-call
/*  if-else               %jock  /lib/tests/if-else
/*  if-elseif-else        %jock  /lib/tests/if-elseif-else
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
/*  match-type            %jock  /lib/tests/match-type
/*  match-case            %jock  /lib/tests/match-case
|%
::
/*  test-let-edit         %hoon  /tests/lib/let-edit
/*  test-let-inner-exp    %hoon  /tests/lib/let-inner-exp
:: /*  test-call             %hoon  /tests/lib/call
/*  test-axis-call        %hoon  /tests/lib/axis-call
/*  test-inline-lambda-call  %hoon  /tests/lib/inline-lambda-call
/*  test-in-subj-call     %hoon  /tests/lib/in-subj-call
/*  test-if-else          %hoon  /tests/lib/if-else
/*  test-if-elseif-else   %hoon  /tests/lib/if-elseif-else
/*  test-assert           %hoon  /tests/lib/assert
/*  test-call-let-edit    %hoon  /tests/lib/call-let-edit
/*  test-inline-point     %hoon  /tests/lib/inline-point
/*  test-inline-lambda-no-arg  %hoon  /tests/lib/inline-lambda-no-arg
/*  test-dec              %hoon  /tests/lib/dec
/*  test-eval             %hoon  /tests/lib/eval
/*  test-multi-limb       %hoon  /tests/lib/multi-limb
/*  test-compose          %hoon  /tests/lib/compose
/*  test-compose-cores    %hoon  /tests/lib/compose-cores
:: /*  test-baby             %hoon  /tests/lib/baby
/*  test-comparator       %hoon  /tests/lib/comparator
::
|%
++  list-jocks
  ^-  (list [term @t])
  :~  [%let-edit q.let-edit]
      [%let-inner-exp q.let-inner-exp]
      :: [%call q.call]
      [%axis-call q.axis-call]
      [%inline-lambda-call q.inline-lambda-call]
      [%in-subj-call q.in-subj-call]
      [%if-else q.if-else]
      [%if-elseif-else q.if-elseif-else]
      [%assert q.assert]
      [%call-let-edit q.call-let-edit]
      [%inline-point q.inline-point]
      [%inline-lambda-no-arg q.inline-lambda-no-arg]
      [%dec q.dec]
      [%eval q.eval]
      [%multi-limb q.multi-limb]
      [%compose q.compose]
      [%compose-cores q.compose-cores]
      :: [%baby q.baby]
      [%comparator q.comparator]
      [%match-type q.match-type]
      [%match-case q.match-case]
  ==
::
++  parse
  |=  i=@
  ^-  (list token:jock)
  =/  p  (snag i list-jocks)
  ~|  -.p
  (rash +.p parse-tokens:jock)
::
++  parse-all
  ^-  (list (pair term (list token:jock)))
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  [term (rash t parse-tokens:jock)]
::
++  jeam
  |=  i=@
  ^-  jock:jock
  =/  p  (snag i list-jocks)
  ~|  -.p
  (jeam:jock +.p)
::
++  jeam-all
  ^-  (list (pair term jock:jock))
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  [term (jeam:jock t)]
::
++  mint-all
  ^-  (list (pair term *))
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  [term (mint:jock t)]
::
++  mint
  |=  i=@
  ^-  [term *]
  =/  p  (snag i list-jocks)
  :-  -.p
  (mint:jock +.p)
::
++  test-all
  ^-  (list ?)
  =|  i=@
  =/  len  (lent test-jocks)
  =|  lis=(list ?)
  |-
  ?:  =(i len)
    (flop lis)
  =/  res=(unit *)
    %-  mole
    |.
    =/  arm  (snag i test-jocks)
    ~&  ["{<i>}" `@tas`-.arm `tape`(zing (turn +.arm |=(=tank ~(ram re tank))))]
    +.arm
  =.  lis
    [?=(^ res) lis]
  $(i +(i))
::
:: ++  test
::   |=  i=@
::   ^-  [term *]
::   =/  p  (snag i test-jocks)
::   ~&  test-tokenize:p
::   ~
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
    =/  jok  .*(%jock +.nok)
    ~&  [i `@tas`-.nok jok]
    jok
  =.  lis
    [?=(^ res) lis]
  $(i +(i))
--
