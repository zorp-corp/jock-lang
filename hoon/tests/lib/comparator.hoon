::  /lib/tests/comparator
/+  jock,
    test
::
|%
++  text
  'let a = true;\0alet b = a == true;\0alet c = a < 1;\0alet d = a > 2;\0alet e = b != true;\0alet f = a <= 1;\0alet g = a >= 2;\0a\0ag'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%literal [[%number p=1] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%literal [[%number p=2] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %'='] [%name %b] [%punctuator %'!'] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %f] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %g] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%punctuator %'='] [%literal [[%number p=2] q=%.n]] [%punctuator %';'] [%name %g]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%atom p=[[%loobean p=%.y] q=%.n]] next=[%let type=[p=[%none ~] name=%b] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[[%loobean p=%.y] q=%.n]]] next=[%let type=[p=[%none ~] name=%c] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'<' b=[%atom p=[[%number p=1] q=%.n]]] next=[%let type=[p=[%none ~] name=%d] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'>' b=[%atom p=[[%number p=2] q=%.n]]] next=[%let type=[p=[%none ~] name=%e] val=[%compare a=[%limb p=~[[%name p=%b]]] comp=%'!=' b=[%atom p=[[%loobean p=%.y] q=%.n]]] next=[%let type=[p=[%none ~] name=%f] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'<=' b=[%atom p=[[%number p=1] q=%.n]]] next=[%let type=[p=[%none ~] name=%g] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'>=' b=[%atom p=[[%number p=2] q=%.n]]] next=[%limb p=~[[%name p=%g]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 0] 8 [5 [0 2] 1 0] 8 [11 6.845.548 0 0] 8 [11 6.845.543 0 0] 8 [6 [5 [0 14] 1 0] [1 1] 1 0] 8 [11 6.648.940 0 0] 8 [11 6.648.935 0 0] 0 2]
    !>  (mint:jock text)
--