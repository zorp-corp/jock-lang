/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  72\0a} else {\0a  17\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'{'] [%keyword %eval] [%punctuator %'['] [%literal [%number 42]] [%literal [%number 55]] [%punctuator %']'] [%punctuator %'['] [%literal [%number 0]] [%literal [%number 2]] [%punctuator %']'] [%punctuator %'}'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%untyped ~] name=%a] val=[%eval p=[p=[%atom p=[%number 42]] q=[%atom p=[%number 55]]] q=[p=[%atom p=[%number 0]] q=[%atom p=[%number 2]]]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [2 [[1 42] 1 55] [1 0] 1 2] 0 2]
    !>  (mint:jock text)
--
