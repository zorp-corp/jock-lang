/+  jock,
    test
::
|%
++  text
  'let a = (c:@ -> @) {\0a  +(c)\0a};\0a\0alet b: @ = 42;\0a\0ab = a(23);\0a\0ab\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %c] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 42]] [%punctuator %';'] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'('] [%literal [%number 23]] [%punctuator %')'] [%punctuator %';'] [%name %b]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%c]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%c]]]] payload=~]] next=[%let type=[p=[%atom p=%number q=%.n] name=%b] val=[%atom p=[%number 42] q=%.n] next=[%edit limb=~[[%name p=%b]] val=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%atom p=[%number 23] q=%.n]]] next=[%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [1 42] 7 [10 [2 8 [0 6] 9 2 10 [6 7 [0 3] 1 23] 0 2] 0 1] 0 2]
    !>  (mint:jock text)
--
