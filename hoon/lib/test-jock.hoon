/+  jock
/*  let-edit              %jock  /lib/tests/let-edit
/*  let-inner-exp         %jock  /lib/tests/let-inner-exp
:: /*  call                  %jock  /lib/tests/call
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
:: /*  baby                  %jock  /lib/tests/baby
/*  comparator            %jock  /lib/tests/comparator
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
 ==
::
++  test-jocks
  ^-  (list [term tang])
  :~  [%test-let-edit-tokens test-tokenize:test-let-edit]
      [%test-let-edit-jeam test-jeam:test-let-edit]
      [%test-let-edit-mint test-mint:test-let-edit]
      [%test-let-inner-exp-tokens test-tokenize:test-let-inner-exp]
      [%test-let-inner-exp-jeam test-jeam:test-let-inner-exp]
      [%test-let-inner-exp-mint test-mint:test-let-inner-exp]
      :: [%test-call-tokens test-tokenize:test-call]
      :: [%test-call-jeam test-jeam:test-call]
      :: [%test-call-mint test-mint:test-call]
      [%test-axis-call-tokens test-tokenize:test-axis-call]
      [%test-axis-call-jeam test-jeam:test-axis-call]
      [%test-axis-call-mint test-mint:test-axis-call]
      [%test-inline-lambda-call-tokens test-tokenize:test-inline-lambda-call]
      [%test-inline-lambda-call-jeam test-jeam:test-inline-lambda-call]
      [%test-inline-lambda-call-mint test-mint:test-inline-lambda-call]
      [%test-in-subj-call-tokens test-tokenize:test-in-subj-call]
      [%test-in-subj-call-jeam test-jeam:test-in-subj-call]
      [%test-in-subj-call-mint test-mint:test-in-subj-call]
      [%test-if-else-tokens test-tokenize:test-if-else]
      [%test-if-else-jeam test-jeam:test-if-else]
      [%test-if-else-mint test-mint:test-if-else]
      [%test-if-elseif-else-tokens test-tokenize:test-if-elseif-else]
      [%test-if-elseif-else-jeam test-jeam:test-if-elseif-else]
      [%test-if-elseif-else-mint test-mint:test-if-elseif-else]
      [%test-assert-tokens test-tokenize:test-assert]
      [%test-assert-jeam test-jeam:test-assert]
      [%test-assert-mint test-mint:test-assert]
      [%test-call-let-edit-tokens test-tokenize:test-call-let-edit]
      [%test-call-let-edit-jeam test-jeam:test-call-let-edit]
      [%test-call-let-edit-mint test-mint:test-call-let-edit]
      [%test-inline-point-tokens test-tokenize:test-inline-point]
      [%test-inline-point-jeam test-jeam:test-inline-point]
      [%test-inline-point-mint test-mint:test-inline-point]
      [%test-inline-lambda-no-arg-tokens test-tokenize:test-inline-lambda-no-arg]
      [%test-inline-lambda-no-arg-jeam test-jeam:test-inline-lambda-no-arg]
      [%test-inline-lambda-no-arg-mint test-mint:test-inline-lambda-no-arg]
      [%test-dec-tokens test-tokenize:test-dec]
      [%test-dec-jeam test-jeam:test-dec]
      [%test-dec-mint test-mint:test-dec]
      [%test-eval-tokens test-tokenize:test-eval]
      [%test-eval-jeam test-jeam:test-eval]
      [%test-eval-mint test-mint:test-eval]
      [%test-multi-limb-tokens test-tokenize:test-multi-limb]
      [%test-multi-limb-jeam test-jeam:test-multi-limb]
      [%test-multi-limb-mint test-mint:test-multi-limb]
      [%test-compose-tokens test-tokenize:test-compose]
      [%test-compose-jeam test-jeam:test-compose]
      [%test-compose-mint test-mint:test-compose]
      [%test-compose-cores-tokens test-tokenize:test-compose-cores]
      [%test-compose-cores-jeam test-jeam:test-compose-cores]
      [%test-compose-cores-mint test-mint:test-compose-cores]
      :: [%test-baby-tokens test-tokenize:test-baby]
      :: [%test-baby-jeam test-jeam:test-baby]
      :: [%test-baby-mint test-mint:test-baby]
      [%test-comparator-tokens test-tokenize:test-comparator]
      [%test-comparator-jeam test-jeam:test-comparator]
      [%test-comparator-mint test-mint:test-comparator]
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
  ~&  >>  (mint:jock +.p)
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
