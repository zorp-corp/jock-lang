/+  jock,
    test
::
|%
++  text
  'let a = ~[1];\0alet b = ~[1 2];\0alet c = ~[1 2 3];\0alet d = ~[[1 2] [3 4]];\0a\0a~[a b c d]'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%literal [[%number 1] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%literal [[%number 1] %.n]] [%literal [[%number 2] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%literal [[%number 1] %.n]] [%literal [[%number 2] %.n]] [%literal [[%number 3] %.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%punctuator %'['] [%literal [[%number 1] %.n]] [%literal [[%number 2] %.n]] [%punctuator %']'] [%punctuator %'['] [%literal [[%number 3] %.n]] [%literal [[%number 4] %.n]] [%punctuator %']'] [%punctuator %']'] [%punctuator %';'] [%punctuator %'~'] [%punctuator %'['] [%name %a] [%name %b] [%name %c] [%name %d] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[p=[%atom p=[[%number 1] %.n]] q=[%atom p=[[%number 0] %.n]]] next=[%let type=[p=[%none ~] name=%b] val=[p=[%atom p=[[%number 1] %.n]] q=[%atom p=[[%number 2] %.n]]] next=[%let type=[p=[%none ~] name=%c] val=[p=[%atom p=[[%number 1] %.n]] q=[p=[%atom p=[[%number 2] %.n]] q=[p=[%atom p=[[%number 3] %.n]] q=[%atom p=[[%number 0] %.n]]]]] next=[%let type=[p=[%none ~] name=%d] val=[p=[p=[%atom p=[[%number 1] %.n]] q=[%atom p=[[%number 2] %.n]]] q=[p=[%atom p=[[%number 3] %.n]] q=[%atom p=[[%number 4] %.n]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[p=[%limb p=~[[%name p=%c]]] q=[p=[%limb p=~[[%name p=%d]]] q=[%atom p=[[%number 0] %.n]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [[1 1] 1 0] 8 [[1 1] 1 2] 8 [[1 1] [1 2] [1 3] 1 0] 8 [[[1 1] 1 2] [1 3] 1 4] [0 30] [0 14] [0 6] [0 2] 1 0]
    !>  (mint:jock text)
--