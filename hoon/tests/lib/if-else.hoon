::  /lib/tests/if-else
/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  72\0a} else {\0a  17\0a}'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %'{'] [%literal [[%number p=72] q=%.n]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%literal [[%number p=17] q=%.n]] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[[%number p=3] q=%.n]] next=[%if cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[[%number p=3] q=%.n]]] then=[%atom p=[[%number p=72] q=%.n]] after=[%else then=[%atom p=[[%number p=17] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 6 [5 [0 2] 1 3] [1 72] 1 17]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 3] 6 [5 [0 2] 1 3] [1 72] 1 17])
    !>  .*(0 (mint:jock text))
::
--
