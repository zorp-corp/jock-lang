::  /lib/tests/call
/+  jock,
    test
::
|%
++  text
  'func a(b:@) -> @ {\0a  +(b)\0a};\0a\0aa(23)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %a] [%punctuator %'(('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%name %a] [%punctuator %'(('] [%literal [[%number p=23] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]]] q=~] name=%a] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] next=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%atom p=[[%number p=23] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [0 2] 9 2 10 [6 7 [0 3] 1 23] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [8 [1 0] [1 4 0 6] 0 1] 8 [0 2] 9 2 10 [6 7 [0 3] 1 23] 0 2])
    !>  .*(0 (mint:jock text))
::
--