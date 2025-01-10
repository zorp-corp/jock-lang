::  /lib/tests/example-atom
/+  jock,
    test
::
|%
++  text
  'let a:@ = 42;\0a\0a(a a a)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%punctuator %'('] [%name %a] [%name %a] [%name %a] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[[%number p=42] q=%.n]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%a]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 42] [0 2] [0 2] 0 2]
    !>  (mint:jock text)
--