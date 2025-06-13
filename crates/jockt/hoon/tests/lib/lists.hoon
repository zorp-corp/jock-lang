::  /lib/tests/lists
/+  jock,
    test,
    hoon
::
|%
++  text
  'let d = [11];\0a\0alet c = [9 10];\0a\0alet b = [6 7 8];\0a\0alet a = [1 2 3 4 5];\0a\0a\0a[a b c d]'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %d] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=11] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=9] q=%.n]] [%literal [[%number p=10] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=6] q=%.n]] [%literal [[%number p=7] q=%.n]] [%literal [[%number p=8] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%literal [[%number p=3] q=%.n]] [%literal [[%number p=4] q=%.n]] [%literal [[%number p=5] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%punctuator %'['] [%name %a] [%name %b] [%name %c] [%name %d] [%punctuator %']']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='d'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=11] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none p=~] name='c'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=9] q=%.n]] [%atom p=[[%number p=10] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none p=~] name='b'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=6] q=%.n]] [%atom p=[[%number p=7] q=%.n]] [%atom p=[[%number p=8] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%none p=~] name='a'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]] [%atom p=[[%number p=3] q=%.n]] [%atom p=[[%number p=4] q=%.n]] [%atom p=[[%number p=5] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%list type=[%none p=~] val=~[[%limb p=~[[%name p=%a]]] [%limb p=~[[%name p=%b]]] [%limb p=~[[%name p=%c]]] [%limb p=~[[%name p=%d]]] [%atom p=[[%number p=0] q=%.n]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[p=[%1 p=11] q=[%1 p=0]] q=[%8 p=[p=[%1 p=9] q=[p=[%1 p=10] q=[%1 p=0]]] q=[%8 p=[p=[%1 p=6] q=[p=[%1 p=7] q=[p=[%1 p=8] q=[%1 p=0]]]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[p=[%1 p=3] q=[p=[%1 p=4] q=[p=[%1 p=5] q=[%1 p=0]]]]]] q=[p=[%0 p=2] q=[p=[%0 p=6] q=[p=[%0 p=14] q=[p=[%0 p=30] q=[%1 p=0]]]]]]]]]
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
        [%8 p=[p=[%1 p=11] q=[%1 p=0]] q=[%8 p=[p=[%1 p=9] q=[p=[%1 p=10] q=[%1 p=0]]] q=[%8 p=[p=[%1 p=6] q=[p=[%1 p=7] q=[p=[%1 p=8] q=[%1 p=0]]]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[p=[%1 p=3] q=[p=[%1 p=4] q=[p=[%1 p=5] q=[%1 p=0]]]]]] q=[p=[%0 p=2] q=[p=[%0 p=6] q=[p=[%0 p=14] q=[p=[%0 p=30] q=[%1 p=0]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
