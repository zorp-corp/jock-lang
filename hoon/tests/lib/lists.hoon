/+  jock,
    test
::
|%
++  text
  'let d = [11];\0alet c = [9 10];\0alet b = [6 7 8];\0alet a = [1 2 3 4 5];\0a\0a(a b c d)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %d] [%punctuator %'='] [%punctuator %'['] [%literal [[%number 11] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%punctuator %'['] [%literal [[%number 9] %.n]] [%literal [[%number 10] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'['] [%literal [[%number 6] %.n]] [%literal [[%number 7] %.n]] [%literal [[%number 8] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [[%number 1] %.n]] [%literal [[%number 2] %.n]] [%literal [[%number 3] %.n]] [%literal [[%number 4] %.n]] [%literal [[%number 5] %.n]] [%punctuator %']'] [%punctuator %';'] [%punctuator %'('] [%name %a] [%name %b] [%name %c] [%name %d] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%d] val=[%list type=[%atom p=%number q=%.n] val=~[[%atom p=[[%number 11] %.n]] [%atom p=[[%number 0] %.n]]]] next=[%let type=[p=[%none ~] name=%c] val=[%list type=[%atom p=%number q=%.n] val=~[[%atom p=[[%number 9] %.n]] [%atom p=[[%number 10] %.n]] [%atom p=[[%number 0] %.n]]]] next=[%let type=[p=[%none ~] name=%b] val=[%list type=[%atom p=%number q=%.n] val=~[[%atom p=[[%number 6] %.n]] [%atom p=[[%number 7] %.n]] [%atom p=[[%number 8] %.n]] [%atom p=[[%number 0] %.n]]]] next=[%let type=[p=[%none ~] name=%a] val=[%list type=[%atom p=%number q=%.n] val=~[[%atom p=[[%number 1] %.n]] [%atom p=[[%number 2] %.n]] [%atom p=[[%number 3] %.n]] [%atom p=[[%number 4] %.n]] [%atom p=[[%number 5] %.n]] [%atom p=[[%number 0] %.n]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[p=[%limb p=~[[%name p=%c]]] q=[%limb p=~[[%name p=%d]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    :: !>  [1 [1 2 3 4 5 0] 6 7 8 9 10 0]
    !>  [8 [[1 11] 1 0] 8 [[1 9] [1 10] 1 0] 8 [[1 6] [1 7] [1 8] 1 0] 8 [[1 1] [1 2] [1 3] [1 4] [1 5] 1 0] [0 2] [0 6] [0 14] 0 30]
    !>  (mint:jock text)
--