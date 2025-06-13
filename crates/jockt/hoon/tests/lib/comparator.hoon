::  /lib/tests/comparator
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a = true;\0alet b = a == true;\0alet c = a < 1;\0alet d = a > 2;\0alet e = b != true;\0alet f = a <= 1;\0alet g = a >= 2;\0a\0ag\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%literal [[%number p=1] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%literal [[%number p=2] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %'='] [%name %b] [%punctuator %'!'] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %f] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %g] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%punctuator %'='] [%literal [[%number p=2] q=%.n]] [%punctuator %';'] [%name %g]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%atom p=[[%loobean p=%.y] q=%.n]] next=[%let type=[p=[%none p=~] name='b'] val=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%loobean p=%.y] q=%.n]]] next=[%let type=[p=[%none p=~] name='c'] val=[%compare comp=%'<' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=1] q=%.n]]] next=[%let type=[p=[%none p=~] name='d'] val=[%compare comp=%'>' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=2] q=%.n]]] next=[%let type=[p=[%none p=~] name='e'] val=[%compare comp=%'!=' a=[%limb p=~[[%name p=%b]]] b=[%atom p=[[%loobean p=%.y] q=%.n]]] next=[%let type=[p=[%none p=~] name='f'] val=[%compare comp=%'<=' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=1] q=%.n]]] next=[%let type=[p=[%none p=~] name='g'] val=[%compare comp=%'>=' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=2] q=%.n]]] next=[%limb p=~[[%name p=%g]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [[%8 p=[%1 p=0] q=[%8 p=[%5 p=[%0 p=2] q=[%1 p=0]] q=[%8 p=[%8 p=[%9 p=358.123 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=6] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%8 p=[%8 p=[%9 p=703 q=[%0 p=30]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=14] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%8 p=[%6 p=[%5 p=[%0 p=14] q=[%1 p=0]] q=[%1 p=1] r=[%1 p=0]] q=[%8 p=[%8 p=[%9 p=340 q=[%0 p=126]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=62] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%8 p=[%8 p=[%9 p=94 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=126] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%0 p=2]]]]]]]]]
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
        [q=[%8 p=[%1 p=0] q=[%8 p=[%5 p=[%0 p=2] q=[%1 p=0]] q=[%8 p=[%8 p=[%9 p=358.123 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=6] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%8 p=[%8 p=[%9 p=703 q=[%0 p=30]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=14] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%8 p=[%6 p=[%5 p=[%0 p=14] q=[%1 p=0]] q=[%1 p=1] r=[%1 p=0]] q=[%8 p=[%8 p=[%9 p=340 q=[%0 p=126]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=62] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[%8 p=[%8 p=[%9 p=94 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=126] q=[%1 p=2]]]] q=[%0 p=2]]]] q=[%0 p=2]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
