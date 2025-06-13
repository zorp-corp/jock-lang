::  /lib/tests/let-inner-exp
/+  jock,
    test,
    hoon
::
|%
++  text
  'let a = 42;\0a\0aa\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [[%number p=42] q=%.n]] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%none p=~] name='a'] val=[%atom p=[[%number p=42] q=%.n]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=42] q=[%0 p=2]]
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
        [%8 p=[%1 p=42] q=[%0 p=2]]
    !>  .*(0 (mint:jock text))
::
--
