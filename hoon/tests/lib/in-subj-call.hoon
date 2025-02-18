::  /lib/tests/in-subj-call
/+  jock,
    test
::
|%
++  text
  'let a = 17;\0a\0alet b = lambda ((b:@ c:&1)) -> @ {\0a  if c == 18 {\0a    +(b)\0a  } else {\0a    b\0a  }\0a}(23 &1);\0a\0a&1'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%number p=17] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%name %c] [%punctuator %':'] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%keyword %if] [%name %c] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=18] q=%.n]] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%name %b] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %'('] [%literal [[%number p=23] q=%.n]] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none ~] name=%a] val=[%atom p=[[%number p=17] q=%.n]] next=[%let type=[p=[%none ~] name=%b] val=[%call func=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name=%b] q=[p=[%limb p=~[[%axis p=1]]] name=%c]] name=%$]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%if cond=[%compare a=[%limb p=~[[%name p=%c]]] comp=%'==' b=[%atom p=[[%number p=18] q=%.n]]] then=[%increment val=[%limb p=~[[%name p=%b]]]] after=[%else then=[%limb p=~[[%name p=%b]]]]] payload=~]] arg=[~ [p=[%atom p=[[%number p=23] q=%.n]] q=[%limb p=~[[%axis p=1]]]]]] next=[%limb p=~[[%axis p=1]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 17] 8 [7 [8 [[1 0] [1 0] 1 0] [1 6 [5 [0 13] 1 18] [4 0 12] 0 12] 0 1] 9 2 10 [6 7 [0 3] [1 23] 0 1] 0 1] 0 1]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 17] 8 [7 [8 [[1 0] [1 0] 1 0] [1 6 [5 [0 13] 1 18] [4 0 12] 0 12] 0 1] 9 2 10 [6 7 [0 3] [1 23] 0 1] 0 1] 0 1])
    !>  .*(0 (mint:jock text))
::
--
