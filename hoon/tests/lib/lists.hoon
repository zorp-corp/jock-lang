/+  jock,
    test
::
|%
++  text
  'let a = [1 2 3 4 5 0];\0a\0alet b = ~[1 2 3 4 5];\0a\0a[a b]\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [%number 1]] [%literal [%number 2]] [%literal [%number 3]] [%literal [%number 4]] [%literal [%number 5]] [%literal [%number 0]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'~'] [%punctuator %'['] [%literal [%number 1]] [%literal [%number 2]] [%literal [%number 3]] [%literal [%number 4]] [%literal [%number 5]] [%punctuator %']'] [%punctuator %';'] [%punctuator %'['] [%name %a] [%name %b] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%untyped ~] name=%a] val=[p=[%atom p=[%number 1]] q=[p=[%atom p=[%number 2]] q=[p=[%atom p=[%number 3]] q=[p=[%atom p=[%number 4]] q=[p=[%atom p=[%number 5]] q=[%atom p=[%number 0]]]]]]] next=[%let type=[p=[%untyped ~] name=%b] val=[p=[%atom p=[%number 1]] q=[p=[%atom p=[%number 2]] q=[p=[%atom p=[%number 3]] q=[p=[%atom p=[%number 4]] q=[p=[%atom p=[%number 5]] q=[%atom p=[%number 0]]]]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    :: !>  [1 [1 2 3 4 5 0] 1 2 3 4 5 0]
    !>  [8 [[1 1] [1 2] [1 3] [1 4] [1 5] 1 0] 8 [[1 1] [1 2] [1 3] [1 4] [1 5] 1 0] [0 6] 0 2]
    !>  (mint:jock text)
--
