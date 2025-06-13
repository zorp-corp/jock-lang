::  /lib/tests/if-elseif-else
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  42\0a} else if a == 5 {\0a  17\0a} else {\0a  15\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [[%number p=3] q=%.n]] [%punctuator %'{'] [%literal [[%number p=42] q=%.n]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%literal [[%number p=17] q=%.n]] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name='a'] val=[%atom p=[[%number p=3] q=%.n]] next=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%atom p=[[%number p=3] q=%.n]]] then=[%atom p=[[%number p=42] q=%.n]] after=[%else then=[%atom p=[[%number p=17] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=3] q=[%6 p=[%5 p=[%0 p=2] q=[%1 p=3]] q=[%1 p=42] r=[%1 p=17]]]
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
        [%8 p=[%1 p=3] q=[%6 p=[%5 p=[%0 p=2] q=[%1 p=3]] q=[%1 p=42] r=[%1 p=17]]]
    !>  .*(0 (mint:jock text))
::
--
