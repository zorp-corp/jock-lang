::  /lib/tests/example-atom
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a:@ = 42;\0a\0a(a a a)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%punctuator %'('] [%name %a] [%name %a] [%name %a] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name='a'] val=[%atom p=[[%number p=42] q=%.n]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%a]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=42] q=[p=[%0 p=2] q=[p=[%0 p=2] q=[%0 p=2]]]]
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
        [%8 p=[%1 p=42] q=[p=[%0 p=2] q=[p=[%0 p=2] q=[%0 p=2]]]]
    !>  .*(0 (mint:jock text))
::
--
