/+  jock,
    test
::
|%
++  text
  'let a: ? = true;\0a\0aa = false;\0a\0aa\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'?'] [%punctuator %'='] [%literal [%loobean %.y]] [%punctuator %';'] [%name %a] [%punctuator %'='] [%literal [%loobean %.n]] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
     :: [%let type=[p=[%atom p=%loobean q=%.n] name=%a] val=[%atom p=[%loobean %.y] q=%.n] next=[%edit limb=~[[%name p=%a]] val=[%atom p=[%loobean %.n] q=%.n] next=[%limb p=~[[%name p=%a]]]]]
        [%let type=[p=[%atom p=%loobean q=%.n] name=%a] val=[%atom p=[[%loobean %.y] %.n]] next=[%edit limb=~[[%name p=%a]] val=[%atom p=[[%loobean %.n] %.n]] next=[%limb p=~[[%name p=%a]]]]]
     :: [%let type=[p=[%atom p=%loobean q=%.n] name=%a] val=[%limb p=~[[%name p=%true]]] next=[%edit limb=~[[%name p=%a]] val=[%limb p=~[[%name p=%false]]] next=[%limb p=~[[%name p=%a]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 0] 7 [10 [2 1 1] 0 1] 0 2]
    !>  (mint:jock text)
--
