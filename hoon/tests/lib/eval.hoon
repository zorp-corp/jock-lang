::  /lib/tests/eval
/+  jock,
    test
::
|%
++  text
  'let a = eval (42 55) (0 2);\0a\0aa'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%keyword %eval] [%punctuator %'('] [%literal [[%number p=42] q=%.n]] [%literal [[%number p=55] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=0] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%eval p=[p=[%atom p=[[%number p=42] q=%.n]] q=[%atom p=[[%number p=55] q=%.n]]] q=[p=[%atom p=[[%number p=0] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [2 [[1 42] 1 55] [1 0] 1 2] 0 2]
    !>  (mint:jock text)
--