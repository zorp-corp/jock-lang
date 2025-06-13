::  /lib/tests/inline-point
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a: @ = 5;\0alet b: @ = 0;\0aloop;\0aif a == +(b) {\0a  b\0a} else {\0a  b = +(b);\0a  $(b)\0a}\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %a] [%punctuator %'(('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %c] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'(('] [%literal [[%number p=23] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %b]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='c']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='a'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='c']] out=[p=[%atom p=%number q=%.n] name='']] body=[%increment val=[%limb p=~[[%name p=%c]]]] context=~]] next=[%let type=[p=[%atom p=%number q=%.n] name='b'] val=[%atom p=[[%number p=42] q=%.n]] next=[%edit limb=~[[%name p=%b]] val=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%atom p=[[%number p=23] q=%.n]]]] next=[%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%8 p=[%1 p=42] q=[%7 p=[%10 p=[p=2 q=[%8 p=[%0 p=6] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=23]]] q=[%0 p=2]]]]] q=[%0 p=1]] q=[%0 p=2]]]]
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
        [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%8 p=[%1 p=42] q=[%7 p=[%10 p=[p=2 q=[%8 p=[%0 p=6] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=23]]] q=[%0 p=2]]]]] q=[%0 p=1]] q=[%0 p=2]]]]
    !>  .*(0 (mint:jock text))
::
--
