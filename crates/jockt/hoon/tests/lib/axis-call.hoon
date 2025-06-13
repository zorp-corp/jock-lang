::  /lib/tests/axis-call
/+  jock,
    test,
    hoon
::
|%
++  text
  'func a(b:@) -> @ {\0a  +(b)\0a};\0a\0a&2(17)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %a] [%punctuator %'(('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%punctuator %'&'] [%literal [[%number p=2] q=%.n]] [%punctuator %'('] [%literal [[%number p=17] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='b']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='a'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='b']] out=[p=[%atom p=%number q=%.n] name='']] body=[%increment val=[%limb p=~[[%name p=%b]]]] context=~]] next=[%call func=[%limb p=~[[%axis p=2]]] arg=[~ [%atom p=[[%number p=17] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=17]]] q=[%0 p=2]]]]]
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
        [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[4 0 6]] q=[%0 p=1]]] q=[%8 p=[%0 p=2] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=17]]] q=[%0 p=2]]]]]
    !>  .*(0 (mint:jock text))
::
--
