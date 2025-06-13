::  /lib/tests/compose
/+  jock,
    test,
    hoon
::
|%
++  text
  'compose\0a  object {\0a    b = 5\0a    a = lambda (c: @) -> @ {\0a      +(c)\0a    }\0a  };\0aa(b)\0a\0a/*\0a=>\0a  |%\0a  ++  b  5\0a  ++  a  |=(c=@ +(c))\0a  --\0a(a b)\0a\0a[7 [1 [1 5] 8 [1 0] [1 4 0 6] 0 1] 8 [9 3 0 1] 9 2 10 [6 7 [0 3] 9 2 0 1] 0 2]\0a*/\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %object] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%literal [[%number p=5] q=%.n]] [%name %a] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %c] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%name %a] [%punctuator %'(('] [%name %b] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%compose p=[%object name=%$ p=[n=[p=%b q=[%atom p=[[%number p=5] q=%.n]]] l=~ r=[n=[p=%a q=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='c']] out=[p=[%atom p=%number q=%.n] name='']] body=[%increment val=[%limb p=~[[%name p=%c]]]] context=~]]] l=~ r=~]] q=~] q=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%limb p=~[[%name p=%b]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%7 p=[%1 p=[[1 5] 8 [1 0] [1 4 0 6] 0 1]] q=[%8 p=[%9 p=3 q=[%0 p=1]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%9 p=2 q=[%0 p=1]]]] q=[%0 p=2]]]]]
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
        [%7 p=[%1 p=[[1 5] 8 [1 0] [1 4 0 6] 0 1]] q=[%8 p=[%9 p=3 q=[%0 p=1]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%9 p=2 q=[%0 p=1]]]] q=[%0 p=2]]]]]
    !>  .*(0 (mint:jock text))
::
--
