::  /lib/tests/call-let-edit
/+  jock,
    test
::
|%
++  text
  'func a(c:@) -> @ {\0a  +(c)\0a};\0a\0alet b: @ = 42;\0ab = a(23);\0a\0ab'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %a] [%punctuator %'(('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %c] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'(('] [%literal [[%number p=23] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %b]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name=%c]] out=[p=[%atom p=%number q=%.n] name=%$]]] q=~] name=%a] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%c]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%c]]]] payload=~]] next=[%let type=[p=[%atom p=%number q=%.n] name=%b] val=[%atom p=[[%number p=42] q=%.n]] next=[%edit limb=~[[%name p=%b]] val=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%atom p=[[%number p=23] q=%.n]]]] next=[%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [1 42] 7 [10 [2 8 [0 6] 9 2 10 [6 7 [0 3] 1 23] 0 2] 0 1] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [8 [1 0] [1 4 0 6] 0 1] 8 [1 42] 7 [10 [2 8 [0 6] 9 2 10 [6 7 [0 3] 1 23] 0 2] 0 1] 0 2])
    !>  .*(0 (mint:jock text))
::
--
