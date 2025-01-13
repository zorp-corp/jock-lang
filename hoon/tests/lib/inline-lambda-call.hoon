::  /lib/tests/inline-lambda-call
/+  jock,
    test
::
|%
++  text
  'lambda (b:@) -> @ {\0a  +(b)\0a}(23)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %lambda] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'('] [%literal [[%number p=23] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%call func=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] arg=[~ [%atom p=[[%number p=23] q=%.n]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [1 0] [1 4 0 6] 0 1] 9 2 10 [6 7 [0 3] 1 23] 0 1]
    !>  (mint:jock text)
--