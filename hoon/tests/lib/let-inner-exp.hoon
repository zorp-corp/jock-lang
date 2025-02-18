::  /lib/tests/let-inner-exp
/+  jock,
    test
::
|%
++  text
  'let a = {\0a  3\0a};\0a\0aa'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'{'] [%literal [[%number p=3] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        :: [%let type=[p=[%none ~] name=%a] val=[%set type=[%none ~] val=`(set jype:jock)`(silt [%atom p=[[%number p=3] q=%.n]])] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 [1 3] 0 0] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [8 [1 [1 3] 0 0] 0 2])
    !>  .*(0 (mint:jock text))
::
--
