::  /lib/tests/infix-arithmetic
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  '[ (41 + 5) - 4\0a  (126 * 2) / 6\0a  ((6 ** 2) + 6) % 100\0a  (2 ** 5) + 10\0a  1 + 2 + 39\0a  (50 - 9) + 1\0a]\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%punctuator %'['] [%punctuator %'('] [%literal [[%number p=41] q=%.n]] [%punctuator %'+'] [%literal [[%number p=5] q=%.n]] [%punctuator %')'] [%punctuator %'-'] [%literal [[%number p=4] q=%.n]] [%punctuator %'('] [%literal [[%number p=126] q=%.n]] [%punctuator %'*'] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'/'] [%literal [[%number p=6] q=%.n]] [%punctuator %'('] [%punctuator %'('] [%literal [[%number p=6] q=%.n]] [%punctuator %'*'] [%punctuator %'*'] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'+'] [%literal [[%number p=6] q=%.n]] [%punctuator %')'] [%punctuator %'%'] [%literal [[%number p=100] q=%.n]] [%punctuator %'('] [%literal [[%number p=2] q=%.n]] [%punctuator %'*'] [%punctuator %'*'] [%literal [[%number p=5] q=%.n]] [%punctuator %')'] [%punctuator %'+'] [%literal [[%number p=10] q=%.n]] [%literal [[%number p=1] q=%.n]] [%punctuator %'+'] [%literal [[%number p=2] q=%.n]] [%punctuator %'+'] [%literal [[%number p=39] q=%.n]] [%punctuator %'('] [%literal [[%number p=50] q=%.n]] [%punctuator %'-'] [%literal [[%number p=9] q=%.n]] [%punctuator %')'] [%punctuator %'+'] [%literal [[%number p=1] q=%.n]] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%list type=[%none p=~] val=~[[%operator op=%'-' a=[%operator op=%'+' a=[%atom p=[[%number p=41] q=%.n]] b=[~ [%atom p=[[%number p=5] q=%.n]]]] b=[~ [%atom p=[[%number p=4] q=%.n]]]] [%operator op=%'/' a=[%operator op=%'*' a=[%atom p=[[%number p=126] q=%.n]] b=[~ [%atom p=[[%number p=2] q=%.n]]]] b=[~ [%atom p=[[%number p=6] q=%.n]]]] [%operator op=%'%' a=[%operator op=%'+' a=[%operator op=%'**' a=[%atom p=[[%number p=6] q=%.n]] b=[~ [%atom p=[[%number p=2] q=%.n]]]] b=[~ [%atom p=[[%number p=6] q=%.n]]]] b=[~ [%atom p=[[%number p=100] q=%.n]]]] [%operator op=%'+' a=[%operator op=%'**' a=[%atom p=[[%number p=2] q=%.n]] b=[~ [%atom p=[[%number p=5] q=%.n]]]] b=[~ [%atom p=[[%number p=10] q=%.n]]]] [%operator op=%'+' a=[%atom p=[[%number p=1] q=%.n]] b=[~ [%operator op=%'+' a=[%atom p=[[%number p=2] q=%.n]] b=[~ [%atom p=[[%number p=39] q=%.n]]]]]] [%operator op=%'+' a=[%operator op=%'-' a=[%atom p=[[%number p=50] q=%.n]] b=[~ [%atom p=[[%number p=9] q=%.n]]]] b=[~ [%atom p=[[%number p=1] q=%.n]]]] [%atom p=[[%number p=0] q=%.n]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [p=[%8 p=[%9 p=3.061 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=41] q=[%1 p=5]]]] q=[%0 p=2]]]] q=[%1 p=4]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=44.764 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=4 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=126] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%1 p=6]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=6.014 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.062 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=6] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%1 p=6]]]] q=[%0 p=2]]]] q=[%1 p=100]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.062 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%1 p=5]]]] q=[%0 p=2]]]] q=[%1 p=10]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%1 p=39]]]] q=[%0 p=2]]]]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.061 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=50] q=[%1 p=9]]]] q=[%0 p=2]]]] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%1 p=0]]]]]]]
    !>  +>:(mint:jock text)
::
++  test-nock
  =/  past  (rush q.hoon (ifix [gay gay] tall:(vang | /)))
  ?~  past  ~|("unable to parse Hoon library" !!)
  =/  p  (~(mint ut %noun) %noun u.past)
  %+  expect-eq:test
    !>  .*  0
        :+  %8
          +.p
        [p=[%8 p=[%9 p=3.061 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=41] q=[%1 p=5]]]] q=[%0 p=2]]]] q=[%1 p=4]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=44.764 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=4 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=126] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%1 p=6]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=6.014 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.062 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=6] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%1 p=6]]]] q=[%0 p=2]]]] q=[%1 p=100]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.062 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%1 p=5]]]] q=[%0 p=2]]]] q=[%1 p=10]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%1 p=39]]]] q=[%0 p=2]]]]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=348 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%8 p=[%9 p=3.061 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=50] q=[%1 p=9]]]] q=[%0 p=2]]]] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%1 p=0]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
