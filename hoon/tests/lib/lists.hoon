/+  jock,
    test
::
|%
++  text
  'let a = [1 2 3 4 5 0];\0a\0alet b = ~[6 7 8 9 10];\0a\0a[a b]\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [%number 1]] [%literal [%number 2]] [%literal [%number 3]] [%literal [%number 4]] [%literal [%number 5]] [%literal [%number 0]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%literal [%number 6]] [%literal [%number 7]] [%literal [%number 8]] [%literal [%number 9]] [%literal [%number 10]] [%punctuator %']'] [%punctuator %';'] [%punctuator %'['] [%name %a] [%name %b] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[p=[%atom p=[%number 1] q=%.n] q=[p=[%atom p=[%number 2] q=%.n] q=[p=[%atom p=[%number 3] q=%.n] q=[p=[%atom p=[%number 4] q=%.n] q=[p=[%atom p=[%number 5] q=%.n] q=[%atom p=[%number 0] q=%.n]]]]]] next=[%let type=[p=[%none ~] name=%b] val=[p=[%atom p=[%number 6] q=%.n] q=[p=[%atom p=[%number 7] q=%.n] q=[p=[%atom p=[%number 8] q=%.n] q=[p=[%atom p=[%number 9] q=%.n] q=[p=[%atom p=[%number 10] q=%.n] q=[%atom p=[%number 0] q=%.n]]]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    :: !>  [1 [1 2 3 4 5 0] 6 7 8 9 10 0]
    !>  [8 [[1 1] [1 2] [1 3] [1 4] [1 5] 1 0] 8 [[1 1] [1 2] [1 3] [1 4] [1 5] 1 0] [0 6] 0 2]
    !>  (mint:jock text)
--