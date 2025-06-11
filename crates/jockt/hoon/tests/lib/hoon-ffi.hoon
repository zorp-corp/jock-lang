::  /lib/tests/hoon-ffi
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a = 1;\0alet b = 41;\0alet c = 43;\0alet d = 6;\0alet e = 7;\0alet f = 252;\0a\0a(hoon.add(a b)\0a hoon.sub(c a)\0a hoon.mul(d e)\0a hoon.div(f d)\0a)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%number p=1] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%literal [[%number p=41] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%literal [[%number p=43] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %'='] [%literal [[%number p=6] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %'='] [%literal [[%number p=7] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %f] [%punctuator %'='] [%literal [[%number p=252] q=%.n]] [%punctuator %';'] [%punctuator %'('] [%name %hoon] [%punctuator %'.'] [%name %add] [%punctuator %'(('] [%name %a] [%name %b] [%punctuator %')'] [%name %hoon] [%punctuator %'.'] [%name %sub] [%punctuator %'(('] [%name %c] [%name %a] [%punctuator %')'] [%name %hoon] [%punctuator %'.'] [%name %mul] [%punctuator %'(('] [%name %d] [%name %e] [%punctuator %')'] [%name %hoon] [%punctuator %'.'] [%name %div] [%punctuator %'(('] [%name %f] [%name %d] [%punctuator %')'] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%atom p=[[%number p=1] q=%.n]] next=[%let type=[p=[%none p=~] name='b'] val=[%atom p=[[%number p=41] q=%.n]] next=[%let type=[p=[%none p=~] name='c'] val=[%atom p=[[%number p=43] q=%.n]] next=[%let type=[p=[%none p=~] name='d'] val=[%atom p=[[%number p=6] q=%.n]] next=[%let type=[p=[%none p=~] name='e'] val=[%atom p=[[%number p=7] q=%.n]] next=[%let type=[p=[%none p=~] name='f'] val=[%atom p=[[%number p=252] q=%.n]] next=[p=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%add]]] arg=[~ [p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%b]]]]]] q=[p=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%sub]]] arg=[~ [p=[%limb p=~[[%name p=%c]]] q=[%limb p=~[[%name p=%a]]]]]] q=[p=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%mul]]] arg=[~ [p=[%limb p=~[[%name p=%d]]] q=[%limb p=~[[%name p=%e]]]]]] q=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%div]]] arg=[~ [p=[%limb p=~[[%name p=%f]]] q=[%limb p=~[[%name p=%d]]]]]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=1] q=[%8 p=[%1 p=41] q=[%8 p=[%1 p=43] q=[%8 p=[%1 p=6] q=[%8 p=[%1 p=7] q=[%8 p=[%1 p=252] q=[p=[%8 p=[%9 p=348 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=126] q=[%0 p=62]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=3.061 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=30] q=[%0 p=126]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=4 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=14] q=[%0 p=6]]]] q=[%0 p=2]]]] q=[%8 p=[%9 p=44.764 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=2] q=[%0 p=14]]]] q=[%0 p=2]]]]]]]]]]]]]
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
        [%8 p=[%1 p=1] q=[%8 p=[%1 p=41] q=[%8 p=[%1 p=43] q=[%8 p=[%1 p=6] q=[%8 p=[%1 p=7] q=[%8 p=[%1 p=252] q=[p=[%8 p=[%9 p=348 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=126] q=[%0 p=62]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=3.061 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=30] q=[%0 p=126]]]] q=[%0 p=2]]]] q=[p=[%8 p=[%9 p=4 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=14] q=[%0 p=6]]]] q=[%0 p=2]]]] q=[%8 p=[%9 p=44.764 q=[%0 p=254]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%0 p=2] q=[%0 p=14]]]] q=[%0 p=2]]]]]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
