::  /lib/tests/lists-nested
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a:List(@) = [1];\0a\0alet b:List(@) = [1 2];\0a\0alet c:List(@) = [1 2 3];\0a\0alet d:List((@ @)) = [(1 2) (3 4)];\0a\0alet e:List((@ List(@))) = [(1 [2]) (3 [4 5])];\0a\0a(a b c d e)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=1] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%literal [[%number p=3] q=%.n]] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'('] [%punctuator %'@'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%literal [[%number p=2] q=%.n]] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=3] q=%.n]] [%literal [[%number p=4] q=%.n]] [%punctuator %')'] [%punctuator %']'] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %':'] [%type 'List'] [%punctuator %'(('] [%punctuator %'('] [%punctuator %'@'] [%type 'List'] [%punctuator %'(('] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'['] [%punctuator %'('] [%literal [[%number p=1] q=%.n]] [%punctuator %'['] [%literal [[%number p=2] q=%.n]] [%punctuator %']'] [%punctuator %')'] [%punctuator %'('] [%literal [[%number p=3] q=%.n]] [%punctuator %'['] [%literal [[%number p=4] q=%.n]] [%literal [[%number p=5] q=%.n]] [%punctuator %']'] [%punctuator %')'] [%punctuator %']'] [%punctuator %';'] [%punctuator %'('] [%name %a] [%name %b] [%name %c] [%name %d] [%name %e] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%list type=[p=[%atom p=%number q=%.n] name='']] name='a'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%list type=[p=[%atom p=%number q=%.n] name='']] name='b'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%list type=[p=[%atom p=%number q=%.n] name='']] name='c'] val=[%list type=[%none p=~] val=~[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]] [%atom p=[[%number p=3] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%list type=[[p=[p=[%atom p=%number q=%.n] name=''] q=[p=[%atom p=%number q=%.n] name='']] name='']] name='d'] val=[%list type=[%none p=~] val=~[[p=[%atom p=[[%number p=1] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]] [p=[%atom p=[[%number p=3] q=%.n]] q=[%atom p=[[%number p=4] q=%.n]]] [%atom p=[[%number p=0] q=%.n]]]] next=[%let type=[p=[%list type=[[p=[p=[%atom p=%number q=%.n] name=''] q=[p=[%list type=[p=[%atom p=%number q=%.n] name='']] name='List']] name='']] name='e'] val=[%list type=[%none p=~] val=~[[p=[%atom p=[[%number p=1] q=%.n]] q=[%list type=[%none p=~] val=~[[%atom p=[[%number p=2] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]]] [p=[%atom p=[[%number p=3] q=%.n]] q=[%list type=[%none p=~] val=~[[%atom p=[[%number p=4] q=%.n]] [%atom p=[[%number p=5] q=%.n]] [%atom p=[[%number p=0] q=%.n]]]]] [%atom p=[[%number p=0] q=%.n]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[p=[%limb p=~[[%name p=%c]]] q=[p=[%limb p=~[[%name p=%d]]] q=[%limb p=~[[%name p=%e]]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[p=[%1 p=1] q=[%1 p=0]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[%1 p=0]]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[p=[%1 p=3] q=[%1 p=0]]]] q=[%8 p=[p=[p=[%1 p=1] q=[%1 p=2]] q=[p=[p=[%1 p=3] q=[%1 p=4]] q=[%1 p=0]]] q=[%8 p=[p=[p=[%1 p=1] q=[p=[%1 p=2] q=[%1 p=0]]] q=[p=[p=[%1 p=3] q=[p=[%1 p=4] q=[p=[%1 p=5] q=[%1 p=0]]]] q=[%1 p=0]]] q=[p=[%0 p=62] q=[p=[%0 p=30] q=[p=[%0 p=14] q=[p=[%0 p=6] q=[%0 p=2]]]]]]]]]]
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
        [%8 p=[p=[%1 p=1] q=[%1 p=0]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[%1 p=0]]] q=[%8 p=[p=[%1 p=1] q=[p=[%1 p=2] q=[p=[%1 p=3] q=[%1 p=0]]]] q=[%8 p=[p=[p=[%1 p=1] q=[%1 p=2]] q=[p=[p=[%1 p=3] q=[%1 p=4]] q=[%1 p=0]]] q=[%8 p=[p=[p=[%1 p=1] q=[p=[%1 p=2] q=[%1 p=0]]] q=[p=[p=[%1 p=3] q=[p=[%1 p=4] q=[p=[%1 p=5] q=[%1 p=0]]]] q=[%1 p=0]]] q=[p=[%0 p=62] q=[p=[%0 p=30] q=[p=[%0 p=14] q=[p=[%0 p=6] q=[%0 p=2]]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
