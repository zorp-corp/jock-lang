/+  jock
/*  let-edit              %jock  /lib/tests/let-edit/jock
/*  let-inner-exp         %jock  /lib/tests/let-inner-exp/jock
/*  call                  %jock  /lib/tests/call/jock
/*  axis-call             %jock  /lib/tests/axis-call/jock
/*  inline-lambda-call    %jock  /lib/tests/inline-lambda-call/jock
/*  in-subj-call          %jock  /lib/tests/in-subj-call/jock
/*  if-else               %jock  /lib/tests/if-else/jock
/*  if-elseif-else        %jock  /lib/tests/if-elseif-else/jock
/*  assert                %jock  /lib/tests/assert/jock
/*  call-let-edit         %jock  /lib/tests/call-let-edit/jock
/*  inline-point          %jock  /lib/tests/inline-point/jock
/*  inline-lambda-no-arg  %jock  /lib/tests/inline-lambda-no-arg/jock
/*  dec                   %jock  /lib/tests/dec/jock
/*  eval                  %jock  /lib/tests/eval/jock
/*  multi-limb            %jock  /lib/tests/multi-limb/jock
/*  compose               %jock  /lib/tests/compose/jock
/*  compose-cores         %jock  /lib/tests/compose-cores/jock
:: /*  baby                  %jock  /lib/tests/baby/jock
/*  comparator            %jock  /lib/tests/comparator/jock
/*  lists                 %jock  /lib/tests/lists/jock
/*  lists-nested          %jock  /lib/tests/lists-nested/jock
/*  match-case            %jock  /lib/tests/match-case/jock
/*  match-type            %jock  /lib/tests/match-type/jock
/*  example-atom          %jock  /lib/tests/example-atom/jock
/*  sets                  %jock  /lib/tests/sets/jock
/*  type-point            %jock  /lib/tests/type-point/jock
/*  type-point-2          %jock  /lib/tests/type-point-2/jock
/*  type-point-3          %jock  /lib/tests/type-point-3/jock
/*  class-state           %jock  /lib/tests/class-state/jock
/*  class-ops             %jock  /lib/tests/class-ops/jock
/*  infix-comparator      %jock  /lib/tests/infix-comparator/jock
/*  infix-arithmetic      %jock  /lib/tests/infix-arithmetic/jock
/*  hoon-ffi              %jock  /lib/tests/hoon-ffi/jock
/*  hoon-arithmetic       %jock  /lib/tests/hoon-arithmetic/jock
/*  hoon-alias            %jock  /lib/tests/hoon-alias/jock
/*  fib                   %jock  /lib/tests/fib/jock
/*  lists-indexing        %jock  /lib/tests/lists-indexing/jock
::
/*  test-let-edit         %hoon  /tests/lib/let-edit/hoon
/*  test-let-inner-exp    %hoon  /tests/lib/let-inner-exp/hoon
/*  test-call             %hoon  /tests/lib/call/hoon
/*  test-axis-call        %hoon  /tests/lib/axis-call/hoon
/*  test-inline-lambda-call  %hoon  /tests/lib/inline-lambda-call/hoon
/*  test-in-subj-call     %hoon  /tests/lib/in-subj-call/hoon
/*  test-if-else          %hoon  /tests/lib/if-else/hoon
/*  test-if-elseif-else   %hoon  /tests/lib/if-elseif-else/hoon
/*  test-assert           %hoon  /tests/lib/assert/hoon
/*  test-call-let-edit    %hoon  /tests/lib/call-let-edit/hoon
/*  test-inline-point     %hoon  /tests/lib/inline-point/hoon
/*  test-inline-lambda-no-arg  %hoon  /tests/lib/inline-lambda-no-arg/hoon
/*  test-dec              %hoon  /tests/lib/dec/hoon
/*  test-eval             %hoon  /tests/lib/eval/hoon
/*  test-multi-limb       %hoon  /tests/lib/multi-limb/hoon
/*  test-compose          %hoon  /tests/lib/compose/hoon
/*  test-compose-cores    %hoon  /tests/lib/compose-cores/hoon
/*  test-comparator       %hoon  /tests/lib/comparator/hoon
/*  test-lists            %hoon  /tests/lib/lists/hoon
/*  test-lists-nested     %hoon  /tests/lib/lists-nested/hoon
/*  test-match-case       %hoon  /tests/lib/match-case/hoon
/*  test-match-type       %hoon  /tests/lib/match-type/hoon
/*  test-example-atom     %hoon  /tests/lib/example-atom/hoon
/*  test-sets             %hoon  /tests/lib/sets/hoon
/*  test-type-point       %hoon  /tests/lib/type-point/hoon
/*  test-type-point-2     %hoon  /tests/lib/type-point-2/hoon
:: /*  test-type-point-3     %hoon  /tests/lib/type-point-3/hoon
:: /*  test-class-state      %hoon  /tests/lib/class-state/hoon
:: /*  test-class-ops        %hoon  /tests/lib/class-ops/hoon
:: /*  test-infix-comparator  %hoon  /tests/lib/infix-comparator/hoon
:: /*  test-infix-arithmetic  %hoon  /tests/lib/infix-arithmetic/hoon
:: /*  test-hoon-ffi       %hoon  /tests/lib/hoon-ffi/hoon
:: /*  test-hoon-arithmetic   %hoon  /tests/lib/hoon-arithmetic/hoon
:: /*  test-hoon-alias      %hoon  /tests/lib/hoon-alias/hoon
:: /*  test-fib            %hoon  /tests/lib/fib/hoon
:: /*  test-lists-indexing  %hoon  /tests/lib/lists-indexing/hoon
::
|_  libs=(map term cord)
++  list-jocks
  ^-  (list [term @t])
  :~  [%let-edit q.let-edit]                          :: 0
      [%let-inner-exp q.let-inner-exp]                :: 1
      [%call q.call]                                  :: 2
      [%axis-call q.axis-call]                        :: 3
      [%inline-lambda-call q.inline-lambda-call]      :: 4
      [%inline-lambda-no-arg q.inline-lambda-no-arg]  :: 5
      [%in-subj-call q.in-subj-call]                  :: 6
      [%if-else q.if-else]                            :: 7
      [%if-elseif-else q.if-elseif-else]              :: 8
      [%assert q.assert]                              :: 9
      [%call-let-edit q.call-let-edit]                :: 10
      [%inline-point q.inline-point]                  :: 11
      [%dec q.dec]                                    :: 12
      [%eval q.eval]                                  :: 13
      [%multi-limb q.multi-limb]                      :: 14
      [%compose q.compose]                            :: 15
      [%compose-cores q.compose-cores]                :: 16
      [%comparator q.comparator]                      :: 17
      [%lists q.lists]                                :: 18
      [%lists-nested q.lists-nested]                  :: 19
      [%match-case q.match-case]                      :: 20
      [%match-type q.match-type]                      :: 21
      [%example-atom q.example-atom]                  :: 22
      [%sets q.sets]                                  :: 23
      [%type-point q.type-point]                      :: 24
      [%type-point-2 q.type-point-2]                  :: 25
      [%type-point-3 q.type-point-3]                  :: 26
      [%class-state q.class-state]                    :: 27
      [%class-ops q.class-ops]                        :: 28
      [%infix-comparator q.infix-comparator]          :: 29
      [%infix-arithmetic q.infix-arithmetic]          :: 30
      [%hoon-ffi q.hoon-ffi]                          :: 31
      [%hoon-arithmetic q.hoon-arithmetic]            :: 32
      [%hoon-alias q.hoon-alias]                      :: 33
      [%fib q.fib]                                    :: 34
      [%lists-indexing q.lists-indexing]              :: 35
 ==
::
++  test-jocks
  ~+
  ^-  (list [term tang])
  :~  [%test-let-edit-tokens test-tokenize:test-let-edit]
      [%test-let-edit-jeam test-jeam:test-let-edit]
      [%test-let-edit-mint test-mint:test-let-edit]
      [%test-let-edit-nock test-nock:test-let-edit]
      [%test-let-inner-exp-tokens test-tokenize:test-let-inner-exp]
      [%test-let-inner-exp-jeam test-jeam:test-let-inner-exp]
      [%test-let-inner-exp-mint test-mint:test-let-inner-exp]
      [%test-let-inner-exp-noc test-nock:test-let-inner-exp]
      [%test-call-tokens test-tokenize:test-call]
      [%test-call-jeam test-jeam:test-call]
      [%test-call-mint test-mint:test-call]
      [%test-call-nock test-nock:test-call]
      [%test-axis-call-tokens test-tokenize:test-axis-call]
      [%test-axis-call-jeam test-jeam:test-axis-call]
      [%test-axis-call-mint test-mint:test-axis-call]
      [%test-axis-call-nock test-nock:test-axis-call]
      [%test-inline-lambda-call-tokens test-tokenize:test-inline-lambda-call]
      [%test-inline-lambda-call-jeam test-jeam:test-inline-lambda-call]
      [%test-inline-lambda-call-mint test-mint:test-inline-lambda-call]
      [%test-inline-lambda-call-nock test-nock:test-inline-lambda-call]
      [%test-inline-lambda-no-arg-tokens test-tokenize:test-inline-lambda-no-arg]
      [%test-inline-lambda-no-arg-jeam test-jeam:test-inline-lambda-no-arg]
      [%test-inline-lambda-no-arg-mint test-mint:test-inline-lambda-no-arg]
      [%test-inline-lambda-no-arg-nock test-nock:test-inline-lambda-no-arg]
      [%test-in-subj-call-tokens test-tokenize:test-in-subj-call]
      [%test-in-subj-call-jeam test-jeam:test-in-subj-call]
      [%test-in-subj-call-mint test-mint:test-in-subj-call]
      [%test-in-subj-call-nock test-nock:test-in-subj-call]
      [%test-if-else-tokens test-tokenize:test-if-else]
      [%test-if-else-jeam test-jeam:test-if-else]
      [%test-if-else-mint test-mint:test-if-else]
      [%test-if-else-nock test-nock:test-if-else]
      [%test-if-elseif-else-tokens test-tokenize:test-if-elseif-else]
      [%test-if-elseif-else-jeam test-jeam:test-if-elseif-else]
      [%test-if-elseif-else-mint test-mint:test-if-elseif-else]
      [%test-if-elseif-else-nock test-nock:test-if-elseif-else]
      [%test-assert-tokens test-tokenize:test-assert]
      [%test-assert-jeam test-jeam:test-assert]
      [%test-assert-mint test-mint:test-assert]
      [%test-assert-nock test-nock:test-assert]
      [%test-call-let-edit-tokens test-tokenize:test-call-let-edit]
      [%test-call-let-edit-jeam test-jeam:test-call-let-edit]
      [%test-call-let-edit-mint test-mint:test-call-let-edit]
      [%test-call-let-edit-nock test-nock:test-call-let-edit]
      [%test-inline-point-tokens test-tokenize:test-inline-point]
      [%test-inline-point-jeam test-jeam:test-inline-point]
      [%test-inline-point-mint test-mint:test-inline-point]
      [%test-inline-point-nock test-nock:test-inline-point]
      [%test-dec-tokens test-tokenize:test-dec]
      [%test-dec-jeam test-jeam:test-dec]
      [%test-dec-mint test-mint:test-dec]
      [%test-dec-nock test-nock:test-dec]
      [%test-eval-tokens test-tokenize:test-eval]
      [%test-eval-jeam test-jeam:test-eval]
      [%test-eval-mint test-mint:test-eval]
      [%test-eval-nock test-nock:test-eval]
      [%test-multi-limb-tokens test-tokenize:test-multi-limb]
      [%test-multi-limb-jeam test-jeam:test-multi-limb]
      [%test-multi-limb-mint test-mint:test-multi-limb]
      [%test-multi-limb-nock test-nock:test-multi-limb]
      [%test-compose-tokens test-tokenize:test-compose]
      [%test-compose-jeam test-jeam:test-compose]
      [%test-compose-mint test-mint:test-compose]
      [%test-compose-nock test-nock:test-compose]
      [%test-compose-cores-tokens test-tokenize:test-compose-cores]
      [%test-compose-cores-jeam test-jeam:test-compose-cores]
      [%test-compose-cores-mint test-mint:test-compose-cores]
      [%test-compose-cores-nock test-nock:test-compose-cores]
      [%test-comparator-tokens test-tokenize:test-comparator]
      [%test-comparator-jeam test-jeam:test-comparator]
      [%test-comparator-mint test-mint:test-comparator]
      [%test-comparator-nock test-nock:test-comparator]
      [%test-lists-tokens test-tokenize:test-lists]
      [%test-lists-jeam test-jeam:test-lists]
      [%test-lists-mint test-mint:test-lists]
      [%test-lists-nock test-nock:test-lists]
      [%test-lists-nested-tokens test-tokenize:test-lists-nested]
      [%test-lists-nested-jeam test-jeam:test-lists-nested]
      [%test-lists-nested-mint test-mint:test-lists-nested]
      [%test-lists-nested-nock test-nock:test-lists-nested]
      [%test-match-case-tokens test-tokenize:test-match-case]
      [%test-match-case-jeam test-jeam:test-match-case]
      [%test-match-case-mint test-mint:test-match-case]
      [%test-match-case-nock test-nock:test-match-case]
      [%test-match-type-tokens test-tokenize:test-match-type]
      [%test-match-type-jeam test-jeam:test-match-type]
      [%test-match-type-mint test-mint:test-match-type]
      [%test-match-type-nock test-nock:test-match-type]
      [%test-example-atom-tokens test-tokenize:test-example-atom]
      [%test-example-atom-jeam test-jeam:test-example-atom]
      [%test-example-atom-mint test-mint:test-example-atom]
      [%test-example-atom-nock test-nock:test-example-atom]
      [%test-sets-tokens test-tokenize:test-sets]
      [%test-sets-jeam test-jeam:test-sets]
      [%test-sets-mint test-mint:test-sets]
      [%test-sets-nock test-nock:test-sets]
      [%test-type-point-tokens test-tokenize:test-type-point]
      [%test-type-point-jeam test-jeam:test-type-point]
      [%test-type-point-mint test-mint:test-type-point]
      [%test-type-point-nock test-nock:test-type-point]
      :: [%test-type-point-2-tokens test-tokenize:test-type-point-2]
      :: [%test-type-point-2-jeam test-jeam:test-type-point-2]
      :: [%test-type-point-2-mint test-mint:test-type-point-2]
      :: [%test-type-point-2-nock test-nock:test-type-point-2]
      :: [%test-type-point-3-tokens test-tokenize:test-type-point-3]
      :: [%test-type-point-3-jeam test-jeam:test-type-point-3]
      :: [%test-type-point-3-mint test-mint:test-type-point-3]
      :: [%test-type-point-3-nock test-nock:test-type-point-3]
      :: [%test-class-state-tokens test-tokenize:test-class-state]
      :: [%test-class-state-jeam test-jeam:test-class-state]
      :: [%test-class-state-mint test-mint:test-class-state]
      :: [%test-class-state-nock test-nock:test-class-state]
      :: [%test-infix-comparator-tokens test-tokenize:test-infix-comparator]
      :: [%test-infix-comparator-jeam test-jeam:test-infix-comparator]
      :: [%test-infix-comparator-mint test-mint:test-infix-comparator]
      :: [%test-infix-comparator-nock test-nock:test-infix-comparator]
      :: [%test-infix-arithmetic-tokens test-tokenize:test-infix-arithmetic]
      :: [%test-infix-arithmetic-jeam test-jeam:test-infix-arithmetic]
      :: [%test-infix-arithmetic-mint test-mint:test-infix-arithmetic]
      :: [%test-infix-arithmetic-nock test-nock:test-infix-arithmetic]
      :: [%test-hoon-ffi-tokens test-tokenize:test-hoon-ffi]
      :: [%test-hoon-ffi-jeam test-jeam:test-hoon-ffi]
      :: [%test-hoon-ffi-mint test-mint:test-hoon-ffi]
      :: [%test-hoon-ffi-nock test-nock:test-hoon-ffi]
      :: [%test-hoon-arithmetic-tokens test-tokenize:test-hoon-arithmetic]
      :: [%test-hoon-arithmetic-jeam test-jeam:test-hoon-arithmetic]
      :: [%test-hoon-arithmetic-mint test-mint:test-hoon-arithmetic]
      :: [%test-hoon-arithmetic-nock test-nock:test-hoon-arithmetic]
      :: [%test-hoon-alias-tokens test-tokenize:test-hoon-alias]
      :: [%test-hoon-alias-jeam test-jeam:test-hoon-alias]
      :: [%test-hoon-alias-mint test-mint:test-hoon-alias]
      :: [%test-hoon-alias-nock test-nock:test-hoon-alias]
      :: [%test-fib-tokens test-tokenize:test-fib]
      :: [%test-fib-jeam test-jeam:test-fib]
      :: [%test-fib-mint test-mint:test-fib]
      :: [%test-fib-nock test-nock:test-fib]
      :: [%test-lists-indexing-tokens test-tokenize:test-lists-indexing]
      :: [%test-lists-indexing-jeam test-jeam:test-lists-indexing]
      :: [%test-lists-indexing-mint test-mint:test-lists-indexing]
      :: [%test-lists-indexing-nock test-nock:test-lists-indexing]
  ==
::
++  parse
  |=  =cord
  ^-  (list token:jock)
  ~|  %parse
  (rash cord parse-tokens:~(. jock libs))
::
++  parse-all
  ^-  (list (pair term (list token:jock)))
  %+  turn  list-jocks
  |=  [=term t=@t]
  ~|  term
  [term (parse t)]
::
++  jeam
  |=  =cord
  ^-  jock:jock
  ~|  %jeam
  =/  res=(unit jock:jock)
    %-  mole
    |.
    (jeam:~(. jock libs) cord)
  ?~  res
    *jock:jock
  u.res
::
++  jeam-all
  :: ^-  (list (pair term jock:jock))
  %+  turn
    %+  turn  list-jocks
    |=  [=term t=@t]
    ~|  term
    [term (jeam t)]
  |=  [=term =jock:jock]
  ^-  cord
  (crip "{<term>}: {<jock>}")
::
++  mint
  |=  =cord
  ^-  nock:jock
  ~|  %mint
  =/  res=(unit *)
    %-  mole
    |.
    (mint:~(. jock libs) cord)
  ?~  res
    *nock:jock
  ;;(nock:jock u.res)
::
++  mint-all
  :: ^-  (list (pair term nock:jock))
  %+  turn
    %+  turn  list-jocks
    |=  [=term t=@t]
    ~|  term
    [term (mint t)]
  |=  [=term =nock:jock]
  ^-  cord
  (crip "{<term>}: {<nock>}")
::
++  jype
  |=  =cord
  ^-  jype:jock
  ~|  %jype
  =/  res=(unit jype:jock)
    %-  mole
    |.
    (jypist:~(. jock libs) cord)
  ?~  res
    *jype:jock
  u.res
::
++  jype-all
  :: ^-  (list (pair term jype:jock))
  %+  turn
    %+  turn  list-jocks
    |=  [=term t=@t]
    ~|  term
    [term (jype t)]
  |=  [=term =jype:jock]
  ^-  cord
  (crip "{<term>}: {<jype>}")
::
++  nock
  |=  =cord
  ^-  *
  ~|  %nock
  =/  res=(unit *)
    %-  mole
    |.
    .*(%0 (mint:~(. jock libs) cord))
  ?~  res
    *nock:jock
  u.res
::
++  nock-all
  :: ^-  (list (pair term nock:jock))
  %+  turn
    %+  turn  list-jocks
    |=  [=term t=@t]
    ~|  term
    [term (nock t)]
  |=  [=term noun=*]
  ^-  cord
  (crip "{<term>}: {<noun>}")
::
++  test
  |=  i=@
  ::  four indices in test-jocks list
  =/  a  (mul i 4)
  =/  b  +(a)
  =/  c  +(b)
  =/  d  +(c)
  ~&  [a b c d]
  =/  [tag=@tas tan=tang]  (snag a test-jocks)
  ~&  "{<tag>}"
  ~&  tan
  ~&  ["{<tag>}" tag `tape`(zing (turn tan |=(=tank ~(ram re tank))))]
  =/  [tag=@tas tan=tang]  (snag b test-jocks)
  ~&  >  "{<tag>}"
  ~&  >  ["{<tag>}" tag `tape`(zing (turn tan |=(=tank ~(ram re tank))))]
  =/  [tag=@tas tan=tang]  (snag c test-jocks)
  ~&  >>  "{<tag>}"
  ~&  >>  ["{<tag>}" tag `tape`(zing (turn tan |=(=tank ~(ram re tank))))]
  =/  [tag=@tas tan=tang]  (snag d test-jocks)
  ~&  >>>  "{<tag>}"
  ~&  >>>  ["{<tag>}" tag `tape`(zing (turn tan |=(=tank ~(ram re tank))))]
  ~
::
++  test-all
  =|  i=@
  =/  len  (lent list-jocks)
  |-
  ?:  =(i len)  ~
  =/  [tag=@tas =cord]  (snag i list-jocks)
  =/  par  (parse cord)
  ~&  "{<i>}: parse {<par>}"
  =/  jem  (jeam cord)
  ~&  >  "{<i>}: jeam {<jem>}"
  =/  min  (mint cord)
  ~&  >>  "{<i>}: mint {<min>}"
  =/  nok  (nock cord)
  ~&  >>>  "{<i>}: nock {<nok>}"
  $(i +(i))
++  run-details
  ^-  (list ?)
  =|  i=@
  =/  len  (lent test-jocks)
  =|  lis=(list ?)
  |-
  ?:  =(i len)
    (flop lis)
  =/  [tag=@tas tan=tang]  (snag i test-jocks)
  ~&  ["{<i>}" tag `tape`(zing (turn tan |=(=tank ~(ram re tank))))]
  =.  lis
    [?=(~ tan) lis]
  $(i +(i))
::
++  exec
  |=  i=@
  ^-  *
  =/  nok  (mint i)
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
    =/  nok  (mint +:(snag i list-jocks))
    =/  jok  .*(+:!>(..ap) nok)
    jok
  =.  lis
    [?=(^ res) lis]
  $(i +(i))
--
