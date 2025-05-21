::  /lib/tests/let-edit
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a: ? = true;\0a\0aa = false;\0a\0aa\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'?'] [%punctuator %'='] [%literal [[%loobean p=%.y] q=%.n]] [%punctuator %';'] [%name %a] [%punctuator %'='] [%literal [[%loobean p=%.n] q=%.n]] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%loobean q=%.n] name='a'] val=[%atom p=[[%loobean p=%.y] q=%.n]] next=[%edit limb=~[[%name p=%a]] val=[%atom p=[[%loobean p=%.n] q=%.n]] next=[%limb p=~[[%name p=%a]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=0] q=[%7 p=[%10 p=[p=2 q=[%1 p=1]] q=[%0 p=1]] q=[%0 p=2]]]
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
        [%8 p=[%1 p=0] q=[%7 p=[%10 p=[p=2 q=[%1 p=1]] q=[%0 p=1]] q=[%0 p=2]]]
    !>  .*(0 (mint:jock text))
::
--
