::  /lib/tests/sets
/+  jock,
    test
::
|%
++  text
  'let a:Set(@) = {1};\0a\0alet b:Set(@) = {1 2};\0a\0alet c:Set(@) = {1 2 3 2 1};\0a\0alet d:Set((@ @)) = {(1 2) (3 4) (1 2)};\0a\0alet e:Set((@ Set(@))) = {(1 {2}) (3 {4 5})};\0a\0a(a b c d e)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%type 'Set'] [%punctuator %'('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%type 'Set'] [%punctuator %'('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %':'] [%type 'Set'] [%punctuator %'('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%literal [[%number p=3] q=%.n]] [%literal [[%number p=2] q=%.n]] [%literal [[%number p=1] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %':'] [%type 'Set'] [%punctuator %'('] [%punctuator %'('] [%punctuator %'@'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'{'] [%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=3] q=%.n]] [%literal [[%number p=4] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %':'] [%type 'Set'] [%punctuator %'('] [%punctuator %'('] [%punctuator %'@'] [%type 'Set'] [%punctuator %'('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'{'] [%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%punctuator %'{'] [%literal [[%number p=2] q=%.n]] [%punctuator %'}'] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=3] q=%.n]] [%punctuator %'{'] [%literal [[%number p=4] q=%.n]] [%literal [[%number p=5] q=%.n]] [%punctuator %'}'] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%punctuator %'('] [%name %a] [%name %b] [%name %c] [%name %d] [%name %e] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        ::[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%a] val=[%set type=[%none ~] val=[[%atom p=[[%number p=1] q=%.n]]]] next=[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%b] val=[%set type=[%none ~] val=[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]]]] next=[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%c] val=[%set type=[%none ~] val=[[%atom p=[[%number p=3] q=%.n]] [%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]]]] next=[%let type=[p=[%set type=[[p=[p=[%atom p=%number q=%.n] name=%$] q=[p=[%atom p=%number q=%.n] name=%$]] name=%$]] name=%d] val=[%set type=[%none ~] val=[[p=[%atom p=[[%number p=3] q=%.n]] q=[%atom p=[[%number p=4] q=%.n]]] [p=[%atom p=[[%number p=1] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]]]] next=[%let type=[p=[%set type=[[p=[p=[%atom p=%number q=%.n] name=%$] q=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%$]] name=%$]] name=%e] val=[%set type=[%none ~] val=[[p=[%atom p=[[%number p=3] q=%.n]] q=[%set type=[%none ~] val=[[%atom p=[[%number p=5] q=%.n]] [%atom p=[[%number p=4] q=%.n]]]]] [p=[%atom p=[[%number p=1] q=%.n]] q=[%set type=[%none ~] val=[[%atom p=[[%number p=2] q=%.n]]]]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[p=[%limb p=~[[%name p=%c]]] q=[p=[%limb p=~[[%name p=%d]]] q=[%limb p=~[[%name p=%e]]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 [1 1] 0 0] 8 [1 [1 2] 0 [1 1] 0 0] 8 [1 [1 3] 0 [1 2] 0 [1 1] 0 0] 8 [1 [[1 3] 1 4] 0 [[1 1] 1 2] 0 0] 8 [1 [[1 1] 1 [1 2] 0 0] 0 [[1 3] 1 [1 5] [[1 4] 0 0] 0] 0 0] [0 62] [0 30] [0 14] [0 6] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 [1 1] 0 0] 8 [1 [1 2] 0 [1 1] 0 0] 8 [1 [1 3] 0 [1 2] 0 [1 1] 0 0] 8 [1 [[1 3] 1 4] 0 [[1 1] 1 2] 0 0] 8 [1 [[1 1] 1 [1 2] 0 0] 0 [[1 3] 1 [1 5] [[1 4] 0 0] 0] 0 0] [0 62] [0 30] [0 14] [0 6] 0 2])
    !>  .*(0 (mint:jock text))
::
--
