::  /lib/tests/lists
/+  jock,
    test
::
|%
++  text
  'let d = [11];\0a\0alet c = [9 10];\0a\0alet b = [6 7 8];\0a\0alet a = [1 2 3 4 5];\0a\0a\0a[a b c d]'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %d] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=11] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=9] q=%.n]] [%literal [[%number p=10] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=6] q=%.n]] [%literal [[%number p=7] q=%.n]] [%literal [[%number p=8] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%literal [[%number p=3] q=%.n]] [%literal [[%number p=4] q=%.n]] [%literal [[%number p=5] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%punctuator %'['] [%name %a] [%name %b] [%name %c] [%name %d] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%d] val=[%list type=[%none ~] val=~[[%atom p=[[%number p=11] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none ~] name=%c] val=[%list type=[%none ~] val=~[[%atom p=[[%number p=9] q=%.n]] [%atom p=[[%number p=10] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none ~] name=%b] val=[%list type=[%none ~] val=~[[%atom p=[[%number p=6] q=%.n]] [%atom p=[[%number p=7] q=%.n]] [%atom p=[[%number p=8] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none ~] name=%a] val=[%list type=[%none ~] val=~[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]] [%atom p=[[%number p=3] q=%.n]] [%atom p=[[%number p=4] q=%.n]] [%atom p=[[%number p=5] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%list type=[%none ~] val=~[[%limb p=~[[%name p=%a]]] [%limb p=~[[%name p=%b]]] [%limb p=~[[%name p=%c]]] [%limb p=~[[%name p=%d]]] [%atom p=[[%number p=0] q=%.n]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 11] 8 [[1 9] 1 10] 8 [[1 6] [1 7] 1 8] 8 [[1 1] [1 2] [1 3] [1 4] 1 5] [0 2] [0 6] [0 14] 0 30]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 11] 8 [[1 9] 1 10] 8 [[1 6] [1 7] 1 8] 8 [[1 1] [1 2] [1 3] [1 4] 1 5] [0 2] [0 6] [0 14] 0 30])
    !>  .*(0 (mint:jock text))
::
--
