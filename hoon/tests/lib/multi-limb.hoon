::  /lib/tests/multi-limb
/+  jock,
    test
::
|%
++  text
  'let a: (p:@ q:(k:@ v:@)) = (52 30 45);\0a\0a(a.q.v)  // reduces to a.q.v, so also testing tuple-of-one'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'('] [%name %p] [%punctuator %':'] [%punctuator %'@'] [%name %q] [%punctuator %':'] [%punctuator %'('] [%name %k] [%punctuator %':'] [%punctuator %'@'] [%name %v] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'('] [%literal [[%number p=52] q=%.n]] [%literal [[%number p=30] q=%.n]] [%literal [[%number p=45] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'('] [%name %a] [%punctuator %'.'] [%name %q] [%punctuator %'.'] [%name %v] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[[p=[p=[%atom p=%number q=%.n] name=%p] q=[[p=[p=[%atom p=%number q=%.n] name=%k] q=[p=[%atom p=%number q=%.n] name=%v]] name=%q]] name=%a] val=[p=[%atom p=[[%number p=52] q=%.n]] q=[p=[%atom p=[[%number p=30] q=%.n]] q=[%atom p=[[%number p=45] q=%.n]]]] next=[%limb p=~[[%name p=%a] [%name p=%q] [%name p=%v]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [[1 52] [1 30] 1 45] 0 11]
    !>  (mint:jock text)
--