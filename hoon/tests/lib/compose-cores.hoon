::  /lib/tests/compose-cores
/+  jock,
    test
::
|%
++  text
  'func g(a:@) -> @ {\0a  29\0a};\0a\0acompose\0a  with this; object {\0a    b = lambda (c:@) -> @ {\0a      g(5)\0a    }\0a    c = 89\0a  };\0a\0ab(3)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %g] [%punctuator %'(('] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%literal [[%number p=29] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%keyword %compose] [%keyword %with] [%keyword %this] [%punctuator %';'] [%keyword %object] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%name %g] [%punctuator %'(('] [%literal [[%number p=5] q=%.n]] [%punctuator %')'] [%punctuator %'}'] [%name %c] [%punctuator %'='] [%literal [[%number p=89] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%name %b] [%punctuator %'(('] [%literal [[%number p=3] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name=%a]] out=[p=[%atom p=%number q=%.n] name=%$]]] q=~] name=%g] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%a]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%atom p=[[%number p=29] q=%.n]] payload=~]] next=[%compose p=[%object name=%$ p=[n=[p=%b q=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%c]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%call func=[%limb p=~[[%name p=%g]]] arg=[~ [%atom p=[[%number p=5] q=%.n]]]] payload=~]]] l=~ r=[n=[p=%c q=[%atom p=[[%number p=89] q=%.n]]] l=~ r=~]] q=[~ [%limb p=~[[%axis p=1]]]]] q=[%call func=[%limb p=~[[%name p=%b]]] arg=[~ [%atom p=[[%number p=3] q=%.n]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 1 29] 0 1] 7 [[1 [8 [1 0] [1 8 [0 30] 9 2 10 [6 7 [0 3] 1 5] 0 2] 0 1] 1 89] 0 1] 8 [9 4 0 1] 9 2 10 [6 7 [0 3] 1 3] 0 2]
    !>  (mint:jock text)
--