::  /lib/tests/if-else
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  42\0a} else {\0a  17\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%number p=17] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%name %c] [%punctuator %':'] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%keyword %if] [%name %c] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=18] q=%.n]] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%name %b] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %'('] [%literal [[%number p=23] q=%.n]] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'&'] [%literal [[%number p=1] q=%.n]]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%atom p=[[%number p=17] q=%.n]] next=[%let type=[p=[%none p=~] name='b'] val=[%call func=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='b'] q=[p=[%limb p=~[[%axis p=1]]] name='c']] name='']] out=[p=[%atom p=%number q=%.n] name='']] body=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%c]]] b=[%atom p=[[%number p=18] q=%.n]]] then=[%increment val=[%limb p=~[[%name p=%b]]]] after=[%else then=[%limb p=~[[%name p=%b]]]]] context=~]] arg=[~ [p=[%atom p=[[%number p=23] q=%.n]] q=[%limb p=~[[%axis p=1]]]]]] next=[%limb p=~[[%axis p=1]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=17] q=[%8 p=[%7 p=[%8 p=[p=[%1 p=0] q=[p=[%1 p=0] q=[p=[%1 p=0] q=[%1 p=0]]]] q=[p=[%1 p=[6 [5 [0 13] 1 18] [4 0 12] 0 12]] q=[%0 p=1]]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=23] q=[%0 p=1]]]] q=[%0 p=1]]]] q=[%0 p=1]]]
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
        [%8 p=[%1 p=17] q=[%8 p=[%7 p=[%8 p=[p=[%1 p=0] q=[p=[%1 p=0] q=[p=[%1 p=0] q=[%1 p=0]]]] q=[p=[%1 p=[6 [5 [0 13] 1 18] [4 0 12] 0 12]] q=[%0 p=1]]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=23] q=[%0 p=1]]]] q=[%0 p=1]]]] q=[%0 p=1]]]
    !>  .*(0 (mint:jock text))
::
--
