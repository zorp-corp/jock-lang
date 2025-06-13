::  /lib/tests/lists-indexing
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a = [100 200 300 400 500];\0alet b:List(@ @) = [(10 20) (30 40) (50 60)];\0a\0a(hoon.snag(0 a) hoon.snag(2 b))\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=100] q=%.n]] [%literal [[%number p=200] q=%.n]] [%literal [[%number p=300] q=%.n]] [%literal [[%number p=400] q=%.n]] [%literal [[%number p=500] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'@'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%punctuator %'('] [%literal [[%number p=10] q=%.n]] [%literal [[%number p=20] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=30] q=%.n]] [%literal [[%number p=40] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=50] q=%.n]] [%literal [[%number p=60] q=%.n]] [%punctuator %')'] [%punctuator %']'] [%punctuator %';'] [%punctuator %'('] [%name %hoon] [%punctuator %'.'] [%name %snag] [%punctuator %'(('] [%literal [[%number p=0] q=%.n]] [%name %a] [%punctuator %')'] [%name %hoon] [%punctuator %'.'] [%name %snag] [%punctuator %'(('] [%literal [[%number p=2] q=%.n]] [%name %b] [%punctuator %')'] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=100] q=%.n]] [%atom p=[[%number p=200] q=%.n]] [%atom p=[[%number p=300] q=%.n]] [%atom p=[[%number p=400] q=%.n]] [%atom p=[[%number p=500] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%list type=[[p=[p=[%atom p=%number q=%.n] name=''] q=[p=[%atom p=%number q=%.n] name='']] name='']] name='b'] val=[%list type=[%none p=~] val=~[[p=[%atom p=[[%number p=10] q=%.n]] q=[%atom p=[[%number p=20] q=%.n]]] [p=[%atom p=[[%number p=30] q=%.n]] q=[%atom p=[[%number p=40] q=%.n]]] [p=[%atom p=[[%number p=50] q=%.n]] q=[%atom p=[[%number p=60] q=%.n]]] [%atom p=[[%number p=0] q=%.n]]]] next=[p=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%snag]]] arg=[~ [p=[%atom p=[[%number p=0] q=%.n]] q=[%limb p=~[[%name p=%a]]]]]] q=[%call func=[%limb p=~[[%name p=%hoon] [%name p=%snag]]] arg=[~ [p=[%atom p=[[%number p=2] q=%.n]] q=[%limb p=~[[%name p=%b]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[p=[%1 p=100] q=[p=[%1 p=200] q=[p=[%1 p=300] q=[p=[%1 p=400] q=[p=[%1 p=500] q=[%1 p=0]]]]]] q=[%8 p=[p=[p=[%1 p=10] q=[%1 p=20]] q=[p=[p=[%1 p=30] q=[%1 p=40]] q=[p=[p=[%1 p=50] q=[%1 p=60]] q=[%1 p=0]]]] q=[p=[%8 p=[%9 p=84 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%0 p=6]]]] q=[%0 p=2]]]] q=[%8 p=[%9 p=84 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%0 p=2]]]] q=[%0 p=2]]]]]]]
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
        [%8 p=[p=[%1 p=100] q=[p=[%1 p=200] q=[p=[%1 p=300] q=[p=[%1 p=400] q=[p=[%1 p=500] q=[%1 p=0]]]]]] q=[%8 p=[p=[p=[%1 p=10] q=[%1 p=20]] q=[p=[p=[%1 p=30] q=[%1 p=40]] q=[p=[p=[%1 p=50] q=[%1 p=60]] q=[%1 p=0]]]] q=[p=[%8 p=[%9 p=84 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=0] q=[%0 p=6]]]] q=[%0 p=2]]]] q=[%8 p=[%9 p=84 q=[%0 p=14]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=2] q=[%0 p=2]]]] q=[%0 p=2]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
