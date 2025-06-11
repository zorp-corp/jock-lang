::  /lib/tests/in-subj-call
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'let a = 17;\0a\0alet b = lambda ((b:@ c:&1)) -> @ {\0a  if c == 18 {\0a    +(b)\0a  } else {\0a    b\0a  }\0a}(23 &1);\0a\0a&1\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %lambda] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'('] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%call func=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='b']] out=[p=[%atom p=%number q=%.n] name='']] body=[%increment val=[%limb p=~[[%name p=%b]]]] context=~]] arg=~]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%7 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%9 p=2 q=[%0 p=1]]]
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
        [%7 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%9 p=2 q=[%0 p=1]]]
    !>  .*(0 (mint:jock text))
::
--
