::  /lib/tests/dec
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'func dec(a:@) -> @ {\0a  let b = 0;\0a  loop;\0a  if a == +(b) {\0a    b\0a  } else {\0a    b = +(b);\0a    recur\0a  }\0a};\0a\0adec(43)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %dec] [%punctuator %'(('] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%keyword %let] [%name %b] [%punctuator %'='] [%literal [[%number p=0] q=%.n]] [%punctuator %';'] [%keyword %loop] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'{'] [%name %b] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %';'] [%keyword %recur] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%name %dec] [%punctuator %'(('] [%literal [[%number p=43] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='a']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='dec'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='a']] out=[p=[%atom p=%number q=%.n] name='']] body=[%let type=[p=[%none p=~] name='b'] val=[%atom p=[[%number p=0] q=%.n]] next=[%loop next=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%increment val=[%limb p=~[[%name p=%b]]]]] then=[%limb p=~[[%name p=%b]]] after=[%else then=[%edit limb=~[[%name p=%b]] val=[%increment val=[%limb p=~[[%name p=%b]]]] next=[%call func=[%limb p=~[[%axis p=0]]] arg=~]]]]]] context=~]] next=[%call func=[%limb p=~[[%name p=%dec]]] arg=[~ [%atom p=[[%number p=43] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[8 [1 0] 8 [1 6 [5 [0 30] 4 0 6] [0 6] 7 [10 [6 4 0 6] 0 1] 9 2 0 1] 9 2 0 1]] q=[%0 p=1]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=43]]] q=[%0 p=2]]]]]
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
        [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[8 [1 0] 8 [1 6 [5 [0 30] 4 0 6] [0 6] 7 [10 [6 4 0 6] 0 1] 9 2 0 1] 9 2 0 1]] q=[%0 p=1]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=43]]] q=[%0 p=2]]]]]
    !>  .*(0 (mint:jock text))
::
--
