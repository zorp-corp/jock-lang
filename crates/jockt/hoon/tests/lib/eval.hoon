::  /lib/tests/eval
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a = eval (42 55) (0 2);\0a\0aa\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%keyword %eval] [%punctuator %'('] [%literal [[%number p=42] q=%.n]] [%literal [[%number p=55] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=0] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%eval p=[p=[%atom p=[[%number p=42] q=%.n]] q=[%atom p=[[%number p=55] q=%.n]]] q=[p=[%atom p=[[%number p=0] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%2 p=[p=[%1 p=42] q=[%1 p=55]] q=[p=[%1 p=0] q=[%1 p=2]]] q=[%0 p=2]]
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
        [%8 p=[%2 p=[p=[%1 p=42] q=[%1 p=55]] q=[p=[%1 p=0] q=[%1 p=2]]] q=[%0 p=2]]
    !>  .*(0 (mint:jock text))
::
--
