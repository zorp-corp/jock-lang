::  /lib/tests/infix-comparator
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  '(\0a    1 < 0\0a    0 <= 1\0a    0 == 1\0a    1 > 0\0a    0 >= 0\0a    1 != 1\0a)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%punctuator %'<'] [%literal [[%number p=0] q=%.n]] [%literal [[%number p=0] q=%.n]] [%punctuator %'<'] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=0] q=%.n]] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=1] q=%.n]] [%punctuator %'>'] [%literal [[%number p=0] q=%.n]] [%literal [[%number p=0] q=%.n]] [%punctuator %'>'] [%punctuator %'='] [%literal [[%number p=0] q=%.n]] [%literal [[%number p=1] q=%.n]] [%punctuator %'!'] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [p=[%compare comp=%'<' a=[%atom p=[[%number p=1] q=%.n]] b=[%atom p=[[%number p=0] q=%.n]]] q=[p=[%compare comp=%'<=' a=[%atom p=[[%number p=0] q=%.n]] b=[%atom p=[[%number p=1] q=%.n]]] q=[p=[%compare comp=%'==' a=[%atom p=[[%number p=0] q=%.n]] b=[%atom p=[[%number p=1] q=%.n]]] q=[p=[%compare comp=%'>' a=[%atom p=[[%number p=1] q=%.n]] b=[%atom p=[[%number p=0] q=%.n]]] q=[p=[%compare comp=%'>=' a=[%atom p=[[%number p=0] q=%.n]] b=[%atom p=[[%number p=0] q=%.n]]] q=[%compare comp=%'!=' a=[%atom p=[[%number p=1] q=%.n]] b=[%atom p=[[%number p=1] q=%.n]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [p=[%8 p=[%9 p=358.123 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=340 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[p=[%5 p=[%1 p=0] q=[%1 p=1]] q=[p=[%8 p=[%9 p=703 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=94 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[%6 p=[%5 p=[%1 p=1] q=[%1 p=1]] q=[%1 p=1] r=[%1 p=0]]]]]]]
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
        [p=[%8 p=[%9 p=358.123 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=340 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%1 p=1]]]] q=[%0 p=2]]]] q=[p=[%5 p=[%1 p=0] q=[%1 p=1]] q=[p=[%8 p=[%9 p=703 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=1] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=94 q=[%0 p=2]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%1 p=0]]]] q=[%0 p=2]]]] q=[%6 p=[%5 p=[%1 p=1] q=[%1 p=1]] q=[%1 p=1] r=[%1 p=0]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
