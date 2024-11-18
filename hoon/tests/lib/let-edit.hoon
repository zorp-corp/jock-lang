/+  jock,
    test
::
|%
++  text
  'let a:? = true;\0aa = false;\0aa'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'?'] [%punctuator %'='] [%literal [%loobean %.y]] [%punctuator %';'] [%name %a] [%punctuator %'='] [%literal [%loobean %.n]] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [[%let type=[p=[%atom p=%loobean] name=%a] val=[%atom p=[%loobean %.y]] next=[%edit limb=~[[%name p=%a]] val=[%atom p=[%loobean %.n]] next=[%limb p=~[[%name p=%a]]]]]]
    !>  (jeam:jock txt)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 0] 7 [10 [2 1 1] 0 1] 0 2]
    !>  (mint:jock txt)
--
