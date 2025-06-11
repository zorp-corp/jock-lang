::  /lib/tests/assert
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a: @ = 5;\0alet b: @ = 0;\0a\0aassert a != 0;\0alet c = ?((a a));\0aloop;\0a\0aif a == +(b) {\0a  b\0a} else {\0a  b = +(b);\0a  recur\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %'{'] [%literal [[%number p=42] q=%.n]] [%punctuator %'}'] [%keyword %else] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=5] q=%.n]] [%punctuator %'{'] [%literal [[%number p=17] q=%.n]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%literal [[%number p=15] q=%.n]] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name='a'] val=[%atom p=[[%number p=3] q=%.n]] next=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=3] q=%.n]]] then=[%atom p=[[%number p=42] q=%.n]] after=[%else-if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=5] q=%.n]]] then=[%atom p=[[%number p=17] q=%.n]] after=[%else then=[%atom p=[[%number p=15] q=%.n]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=3] q=[%6 p=[%5 p=[%0 p=2] q=[%1 p=3]] q=[%1 p=42] r=[%6 p=[%5 p=[%0 p=2] q=[%1 p=5]] q=[%1 p=17] r=[%1 p=15]]]]
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
        [%8 p=[%1 p=3] q=[%6 p=[%5 p=[%0 p=2] q=[%1 p=3]] q=[%1 p=42] r=[%6 p=[%5 p=[%0 p=2] q=[%1 p=5]] q=[%1 p=17] r=[%1 p=15]]]]
    !>  .*(0 (mint:jock text))
::
--
