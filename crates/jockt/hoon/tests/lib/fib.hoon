::  /lib/tests/fib
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  '// fibonacci\0a\0afunc fib(n:@) -> @ {\0a  if n == 0 {\0a    1\0a  } else if n == 1 {\0a    1\0a  } else {\0a    $(n - 1) + $(n - 2)\0a  }\0a};\0a\0a(\0a  fib(0)\0a  fib(1)\0a  fib(2)\0a  fib(3)\0a  fib(4)\0a  fib(5)\0a  fib(6)\0a  fib(7)\0a  fib(8)\0a  fib(9)\0a  fib(10)\0a)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %fib] [%punctuator %'(('] [%name %n] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%keyword %if] [%name %n] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=0] q=%.n]] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%punctuator %'}'] [%keyword %else] [%keyword %if] [%name %n] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%punctuator %'{'] [%literal [[%number p=1] q=%.n]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%punctuator %'$'] [%punctuator %'('] [%name %n] [%punctuator %'-'] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%punctuator %'+'] [%punctuator %'$'] [%punctuator %'('] [%name %n] [%punctuator %'-'] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%punctuator %'('] [%name %fib] [%punctuator %'(('] [%literal [[%number p=0] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=3] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=4] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=5] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=6] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=7] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=8] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=9] q=%.n]] [%punctuator %')'] [%name %fib] [%punctuator %'(('] [%literal [[%number p=10] q=%.n]] [%punctuator %')'] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='n']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='fib'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='n']] out=[p=[%atom p=%number q=%.n] name='']] body=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%n]]] b=[%atom p=[[%number p=0] q=%.n]]] then=[%atom p=[[%number p=1] q=%.n]] after=[%else-if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%n]]] b=[%atom p=[[%number p=1] q=%.n]]] then=[%atom p=[[%number p=1] q=%.n]] after=[%else then=[%operator op=%'+' a=[%call func=[%limb p=~[[%axis p=0]]] arg=[~ [%operator op=%'-' a=[%limb p=~[[%name p=%n]]] b=[~ [%atom p=[[%number p=1] q=%.n]]]]]] b=[~ [%call func=[%limb p=~[[%axis p=0]]] arg=[~ [%operator op=%'-' a=[%limb p=~[[%name p=%n]]] b=[~ [%atom p=[[%number p=2] q=%.n]]]]]]]]]]] context=~]] next=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=0] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=1] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=2] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=3] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=4] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=5] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=6] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=7] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=8] q=%.n]]]] q=[p=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=9] q=%.n]]]] q=[%call func=[%limb p=~[[%name p=%fib]]] arg=[~ [%atom p=[[%number p=10] q=%.n]]]]]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[6 [5 [0 6] 1 0] [1 1] 6 [5 [0 6] 1 1] [1 1] 8 [9 348 0 14] 9 2 10 [6 7 [0 3] [9 2 10 [6 7 [0 1] 8 [9 3.061 0 14] 9 2 10 [6 7 [0 3] [0 6] 1 1] 0 2] 0 1] 9 2 10 [6 7 [0 1] 8 [9 3.061 0 14] 9 2 10 [6 7 [0 3] [0 6] 1 2] 0 2] 0 1] 0 2]] q=[%0 p=1]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=0]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=1]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=2]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=3]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=4]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=5]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=6]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=7]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=8]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=9]]] q=[%0 p=2]]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=10]]] q=[%0 p=2]]]]]]]]]]]]]]]
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
        [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[6 [5 [0 6] 1 0] [1 1] 6 [5 [0 6] 1 1] [1 1] 8 [9 348 0 14] 9 2 10 [6 7 [0 3] [9 2 10 [6 7 [0 1] 8 [9 3.061 0 14] 9 2 10 [6 7 [0 3] [0 6] 1 1] 0 2] 0 1] 9 2 10 [6 7 [0 1] 8 [9 3.061 0 14] 9 2 10 [6 7 [0 3] [0 6] 1 2] 0 2] 0 1] 0 2]] q=[%0 p=1]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=0]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=1]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=2]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=3]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=4]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=5]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=6]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=7]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=8]]] q=[%0 p=2]]]] q=[p=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=9]]] q=[%0 p=2]]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=10]]] q=[%0 p=2]]]]]]]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
