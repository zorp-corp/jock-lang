::  /lib/tests/let-edit
/+  jock,
    test
::
|%
++  text
  'let a: ? = true;\0a\0aa = false;\0a\0aprint a;\0a\0aa'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'?'] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%name %a] [%punctuator %'='] [%literal [[%loobean p=%.n] q=%.n]] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%loobean q=%.n] name=%a] val=[%atom p=[[%loobean p=%.y] q=%.n]] next=[%edit limb=~[[%name p=%a]] val=[%atom p=[[%loobean p=%.n] q=%.n]] next=[%limb p=~[[%name p=%a]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 0] 7 [10 [2 1 1] 0 1] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 0] 7 [10 [2 1 1] 0 1] 0 2])
    !>  .*(0 (mint:jock text))
::
--
