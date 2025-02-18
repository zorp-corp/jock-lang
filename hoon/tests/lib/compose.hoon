::  /lib/tests/compose
/+  jock,
    test
::
|%
++  text
  'compose\0a  object {\0a    b = 5\0a    a = lambda (c: @) -> @ {\0a      +(c)\0a    }\0a  };\0aa(b)\0a\0a/*\0a=>\0a  |%\0a  ++  b  5\0a  ++  a  |=(c=@ +(c))\0a  --\0a(a b)\0a*/'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %object] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%literal [[%number p=5] q=%.n]] [%name %a] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %c] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%name %a] [%punctuator %'(('] [%name %b] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%compose p=[%object name=%$ p=[n=[p=%b q=[%atom p=[[%number p=5] q=%.n]]] l=~ r=[n=[p=%a q=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%c]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%c]]]] payload=~]]] l=~ r=~]] q=~] q=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [1 [1 5] 8 [1 0] [1 4 0 6] 0 1] 8 [9 3 0 1] 9 2 10 [6 7 [0 3] 9 2 0 1] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [7 [1 [1 5] 8 [1 0] [1 4 0 6] 0 1] 8 [9 3 0 1] 9 2 10 [6 7 [0 3] 9 2 0 1] 0 2])
    !>  .*(0 (mint:jock text))
::
--