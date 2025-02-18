::  /lib/tests/match-case
/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0aswitch a {\0a  1 -> 2;\0a  2 -> 4;\0a  3 -> 8;\0a  4 -> 16;\0a  _ -> 0;\0a}'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %';'] [%keyword %switch] [%name %a] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=2] q=%.n]] [%punctuator %';'] [%literal [[%number p=2] q=%.n]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=4] q=%.n]] [%punctuator %';'] [%literal [[%number p=3] q=%.n]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=8] q=%.n]] [%punctuator %';'] [%literal [[%number p=4] q=%.n]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=16] q=%.n]] [%punctuator %';'] [%punctuator %'_'] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=0] q=%.n]] [%punctuator %';'] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        ::[%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[[%number p=3] q=%.n]] next=[%cases value=[%limb p=~[[%name p=%a]]] cases=[n=[p=[%atom p=[[%number p=1] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]] l=[n=[p=[%atom p=[[%number p=3] q=%.n]] q=[%atom p=[[%number p=8] q=%.n]]] l=~ r=~] r=[n=[p=[%atom p=[[%number p=2] q=%.n]] q=[%atom p=[[%number p=4] q=%.n]]] l=[[p=[%atom p=[[%number p=4] q=%.n]] q=[%atom p=[[%number p=16] q=%.n]]]] r=~]] default=[~ [%atom p=[[%number p=0] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 8 [1 0 2] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 8] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 2] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 16] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 4] 7 [0 3] 1 1 0]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 3] 8 [1 0 2] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 8] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 2] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 16] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 4] 7 [0 3] 1 1 0])
    !>  .*(0 (mint:jock text))
::
--
