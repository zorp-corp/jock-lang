/+  jock,
    test
::
|%
++  text
  '\0alet a = {\0a    eval [42 55] [0 2]\0a};\0a\0aa\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'{'] [%keyword %eval] [%punctuator %'['] [%literal [%number 42]] [%literal [%number 55]] [%punctuator %']'] [%punctuator %'['] [%literal [%number 0]] [%literal [%number 2]] [%punctuator %']'] [%punctuator %'}'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%eval p=[p=[%atom p=[%number 42] q=%.n] q=[%atom p=[%number 55] q=%.n]] q=[p=[%atom p=[%number 0] q=%.n] q=[%atom p=[%number 2] q=%.n]]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [2 [[1 42] 1 55] [1 0] 1 2] 0 2]
    !>  (mint:jock text)
--
