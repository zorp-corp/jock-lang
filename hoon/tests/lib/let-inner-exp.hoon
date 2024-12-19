/+  jock,
    test
::
|%
++  text
  'let a = {\0a  3\0a};\0a\0aa\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'{'] [%literal [%number 3]] [%punctuator %'}'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%atom p=[%number 3] q=%.n]] next=[%limb p=~[[%name p=%a]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 3] 1 3] 0 2]
    !>  (mint:jock text)
--
