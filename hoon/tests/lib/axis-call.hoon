::  /lib/tests/axis-call
/+  jock,
    test
::
|%
++  text
  'func a(b:@) -> @ {\0a  +(b)\0a};\0a\0a&2(17)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %a] [%punctuator %'(('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%punctuator %'&'] [%literal [[%number p=2] q=%.n]] [%punctuator %'('] [%literal [[%number p=17] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]]] q=~] name=%a] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] next=[%call func=[%limb p=~[[%axis p=2]]] arg=[~ [%atom p=[[%number p=17] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [0 2] 9 2 10 [6 7 [0 3] 1 17] 0 2]
    !>  (mint:jock text)
--