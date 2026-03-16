::  /lib/tests/class-state
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'compose\0a  class Point(x:@ y:@) {\0a    inc(q:@) -> @ {\0a      +(q)\0a    }\0a  }\0a;\0a\0alet point_1 = Point(70 80);\0alet point_2 = Point(90 100);\0a((point_2.x() point_2.y()) (point_1.x() point_1.y()))\0a\0a/*\0a!=\0a=>  mini=mini\0a=>\0a  ^=  door\0a  |_  [x=@ y=@]\0a  ++  add\0a    |=  p=[x=@ y=@]\0a    [(add:mini x x.p) (add:mini y y.p)]\0a  ++  inc\0a    |=  q=@\0a    +(q)\0a  --\0a=/  point_1\0a  ~(. door [70 80])\0a=/  point_2\0a  ~(. door [90 100])\0a[[+13 +12]:point_2 [+13 +12]:point_1]\0a*/\0a'
 ++  test-tokenize
   %+  expect-eq:test
     !>  ~[[%keyword %compose] [%keyword %class] [%type 'Point'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %inc] [%punctuator %'(('] [%name %q] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %q] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %point-1] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=70] q=%.n]] [%literal [[%number p=80] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %point-2] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=90] q=%.n]] [%literal [[%number p=100] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'('] [%punctuator %'('] [%name %point-2] [%punctuator %'.'] [%name %x] [%punctuator %'(('] [%punctuator %')'] [%name %point-2] [%punctuator %'.'] [%name %y] [%punctuator %'(('] [%punctuator %')'] [%punctuator %')'] [%punctuator %'('] [%name %point-1] [%punctuator %'.'] [%name %x] [%punctuator %'(('] [%punctuator %')'] [%name %point-1] [%punctuator %'.'] [%name %y] [%punctuator %'(('] [%punctuator %')'] [%punctuator %')'] [%punctuator %')']]
     !>  (rash text parse-tokens:jock)
::
 ++  test-jeam
   %+  expect-eq:test
     !>  ^-  jock:jock
         [%compose p=[%class state=[p=[%state p=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='']] name='Point'] arms=[n=[p=%inc q=[%method type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='q']] out=[p=[%atom p=%number q=%.n] name='']]] q=~] name='inc'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='q']] out=[p=[%atom p=%number q=%.n] name='']] body=[%increment val=[%limb p=~[[%name p=%q]]]] context=~]]]] l=~ r=~]] q=[%let type=[p=[%none p=~] name='point_1'] val=[%call func=[%limb p=~[[%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=70] q=%.n]] q=[%atom p=[[%number p=80] q=%.n]]]]] next=[%let type=[p=[%none p=~] name='point_2'] val=[%call func=[%limb p=~[[%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=90] q=%.n]] q=[%atom p=[[%number p=100] q=%.n]]]]] next=[p=[p=[%call func=[%limb p=~[[%name p=%point-2] [%name p=%x]]] arg=~] q=[%call func=[%limb p=~[[%name p=%point-2] [%name p=%y]]] arg=~]] q=[p=[%call func=[%limb p=~[[%name p=%point-1] [%name p=%x]]] arg=~] q=[%call func=[%limb p=~[[%name p=%point-1] [%name p=%y]]] arg=~]]]]]]
     !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%7 p=[%8 p=[p=[%1 p=0] q=[%1 p=0]] q=[p=[%1 p=[8 [1 0] [1 4 0 6] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=70] q=[%1 p=80]]]] q=[%0 p=2]]] q=[%8 p=[%8 p=[%0 p=3] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=90] q=[%1 p=100]]]] q=[%0 p=2]]] q=[p=[p=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=3]]]] q=[p=[%7 p=[%0 p=6] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=6] q=[%7 p=[%0 p=6] q=[%0 p=3]]]]]]]]
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
        [%7 p=[%8 p=[p=[%1 p=0] q=[%1 p=0]] q=[p=[%1 p=[8 [1 0] [1 4 0 6] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=70] q=[%1 p=80]]]] q=[%0 p=2]]] q=[%8 p=[%8 p=[%0 p=3] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=90] q=[%1 p=100]]]] q=[%0 p=2]]] q=[p=[p=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=3]]]] q=[p=[%7 p=[%0 p=6] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=6] q=[%7 p=[%0 p=6] q=[%0 p=3]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
