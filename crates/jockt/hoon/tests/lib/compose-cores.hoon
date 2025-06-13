::  /lib/tests/compose-cores
/+  jock,
    test,
    hoon
::
|%
++  text
  'func g(a:@) -> @ {\0a  29\0a};\0a\0acompose\0a  with this; object {\0a    b = lambda (c:@) -> @ {\0a      g(5)\0a    }\0a    c = 89\0a  };\0a\0ab(3)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %func] [%name %g] [%punctuator %'(('] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%literal [[%number p=29] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%keyword %compose] [%keyword %with] [%keyword %this] [%punctuator %';'] [%keyword %object] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%keyword %lambda] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%name %g] [%punctuator %'(('] [%literal [[%number p=5] q=%.n]] [%punctuator %')'] [%punctuator %'}'] [%name %c] [%punctuator %'='] [%literal [[%number p=89] q=%.n]] [%punctuator %'}'] [%punctuator %';'] [%name %b] [%punctuator %'(('] [%literal [[%number p=3] q=%.n]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%func type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='a']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='g'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='a']] out=[p=[%atom p=%number q=%.n] name='']] body=[%atom p=[[%number p=29] q=%.n]] context=~]] next=[%compose p=[%object name=%$ p=[n=[p=%b q=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='c']] out=[p=[%atom p=%number q=%.n] name='']] body=[%call func=[%limb p=~[[%name p=%g]]] arg=[~ [%atom p=[[%number p=5] q=%.n]]]] context=~]]] l=~ r=[n=[p=%c q=[%atom p=[[%number p=89] q=%.n]]] l=~ r=~]] q=[~ [%limb p=~[[%axis p=1]]]]] q=[%call func=[%limb p=~[[%name p=%b]]] arg=[~ [%atom p=[[%number p=3] q=%.n]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[1 29]] q=[%0 p=1]]] q=[%7 p=[p=[%1 p=[[8 [1 0] [1 8 [0 30] 9 2 10 [6 7 [0 3] 1 5] 0 2] 0 1] 1 89]] q=[%0 p=1]] q=[%8 p=[%9 p=4 q=[%0 p=1]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=3]]] q=[%0 p=2]]]]]]
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
        [%8 p=[%8 p=[%1 p=0] q=[p=[%1 p=[1 29]] q=[%0 p=1]]] q=[%7 p=[p=[%1 p=[[8 [1 0] [1 8 [0 30] 9 2 10 [6 7 [0 3] 1 5] 0 2] 0 1] 1 89]] q=[%0 p=1]] q=[%8 p=[%9 p=4 q=[%0 p=1]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=3]]] q=[%0 p=2]]]]]]
    !>  .*(0 (mint:jock text))
::
--
