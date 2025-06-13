::  /lib/tests/match-type
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a: @ = 3;\0a\0amatch a {\0a  %1 -> 0;\0a  %2 -> 21;\0a  %3 -> 42;\0a  %4 -> 63;\0a  _ -> 84;\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %';'] [%keyword %match] [%name %a] [%punctuator %'{'] [%literal [[%number p=1] q=%.y]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=0] q=%.n]] [%punctuator %';'] [%literal [[%number p=2] q=%.y]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=21] q=%.n]] [%punctuator %';'] [%literal [[%number p=3] q=%.y]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%literal [[%number p=4] q=%.y]] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=63] q=%.n]] [%punctuator %';'] [%punctuator %'_'] [%punctuator %'-'] [%punctuator %'>'] [%literal [[%number p=84] q=%.n]] [%punctuator %';'] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        :: [%let type=[p=[%atom p=%number q=%.n] name='a'] val=[%atom p=[[%number p=3] q=%.n]] next=[%match value=[%limb p=~[[%name p=%a]]] cases=[n=[p=[%atom p=[[%number p=3] q=%.y]] q=[%atom p=[[%number p=42] q=%.n]]] l=~ r=[n=[p=[%atom p=[[%number p=1] q=%.y]] q=[%atom p=[[%number p=0] q=%.n]]] l=[[p=[%atom p=[[%number p=2] q=%.y]] q=[%atom p=[[%number p=21] q=%.n]]] [p=[%atom p=[[%number p=4] q=%.y]] q=[%atom p=[[%number p=63] q=%.n]]]] r=~]] default=[~ [%atom p=[[%number p=84] q=%.n]]]]]
        *jock:jock
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=3] q=[%8 p=[%1 p=[0 2]] q=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 42]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 21]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 63]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 0]]] r=[%7 p=[%0 p=3] q=[%1 p=[1 84]]]]]]]]]
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
        [%8 p=[%1 p=3] q=[%8 p=[%1 p=[0 2]] q=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 42]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 21]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 63]]] r=[%6 p=[%5 p=[%1 p=0] q=[%0 p=2]] q=[%7 p=[%0 p=3] q=[%1 p=[1 0]]] r=[%7 p=[%0 p=3] q=[%1 p=[1 84]]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
