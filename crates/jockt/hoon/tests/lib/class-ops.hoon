::  /lib/tests/class-ops
/+  jock,
    test
/*  hoon  %txt  /lib/mini/txt
::
|%
++  text
  'compose\0a  class Point(x:@ y:@) {\0a   add(p:(x:@ y:@)) -> Point {\0a     (x + p.x\0a      y + p.y)\0a   }\0a  }\0a;\0a\0alet point_1 = Point(14 104);\0apoint_1 = point_1.add(28 38);\0a(point_1.x() point_1.y())\0a\0a/*\0a!=\0a=>  mini=mini\0a=>\0a  ^=  door\0a  |_  [x=@ y=@]\0a  ++  add\0a    |=  p=[x=@ y=@]\0a    [(add:mini x x.p) (add:mini y y.p)]\0a  --\0a=/  point_1\0a  ~(. door [14 104])\0a=.  point_1  ~(. door (add:point_1 [28 38]))\0a[+12 +13]:point_1\0a\0a!=\0a=>  mini=mini\0a=>\0a  ^=  door\0a  |_  [x=@ y=@]\0a  ++  add\0a    |=  p=[x=@ y=@]\0a    [(add:mini x x.p) (add:mini y y.p)]\0a  --\0a~(. door [14 104])\0a*/\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Point'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %add] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%punctuator %'('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'+'] [%name %p] [%punctuator %'.'] [%name %x] [%name %y] [%punctuator %'+'] [%name %p] [%punctuator %'.'] [%name %y] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %point_1] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=14] q=%.n]] [%literal [[%number p=104] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %point_1] [%punctuator %'='] [%name %point_1] [%punctuator %'.'] [%name %add] [%punctuator %'(('] [%literal [[%number p=28] q=%.n]] [%literal [[%number p=38] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'('] [%name %point_1] [%punctuator %'.'] [%name %x] [%punctuator %'(('] [%punctuator %')'] [%name %point_1] [%punctuator %'.'] [%name %y] [%punctuator %'(('] [%punctuator %')'] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%compose p=[%class state=[p=[%state p=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='']] name='Point'] arms=[n=[p=%add q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']]] q=~] name='add'] body=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']] body=[p=[%operator op=%'+' a=[%limb p=~[[%name p=%x]]] b=[~ [%limb p=~[[%name p=%p] [%name p=%x]]]]] q=[%operator op=%'+' a=[%limb p=~[[%name p=%y]]] b=[~ [%limb p=~[[%name p=%p] [%name p=%y]]]]]] context=~]]]] l=~ r=~]] q=[%let type=[p=[%none p=~] name='point_1'] val=[%call func=[%limb p=~[[%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=14] q=%.n]] q=[%atom p=[[%number p=104] q=%.n]]]]] next=[%edit limb=~[[%name p=%point_1]] val=[%call func=[%limb p=~[[%name p=%point_1] [%name p=%add]]] arg=[~ [p=[%atom p=[[%number p=28] q=%.n]] q=[%atom p=[[%number p=38] q=%.n]]]]] next=[p=[%call func=[%limb p=~[[%name p=%point_1] [%name p=%x]]] arg=~] q=[%call func=[%limb p=~[[%name p=%point_1] [%name p=%y]]] arg=~]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%7 p=[%8 p=[p=[%1 p=0] q=[%1 p=0]] q=[p=[%1 p=[8 [[1 0] 1 0] [1 8 [0 7] 10 [6 7 [0 3] [8 [9 348 0 62] 9 2 10 [6 7 [0 3] [0 60] 0 12] 0 2] 8 [9 348 0 62] 9 2 10 [6 7 [0 3] [0 61] 0 13] 0 2] 0 2] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=14] q=[%1 p=104]]]] q=[%0 p=2]]] q=[%7 p=[%10 p=[p=2 q=[%8 p=[%7 p=[%0 p=2] q=[%9 p=2 q=[%0 p=1]]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=28] q=[%1 p=38]]]] q=[%0 p=2]]]]] q=[%0 p=1]] q=[p=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=3]]]]]]]
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
        [%7 p=[%8 p=[p=[%1 p=0] q=[%1 p=0]] q=[p=[%1 p=[8 [[1 0] 1 0] [1 8 [0 7] 10 [6 7 [0 3] [8 [9 348 0 62] 9 2 10 [6 7 [0 3] [0 60] 0 12] 0 2] 8 [9 348 0 62] 9 2 10 [6 7 [0 3] [0 61] 0 13] 0 2] 0 2] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=14] q=[%1 p=104]]]] q=[%0 p=2]]] q=[%7 p=[%10 p=[p=2 q=[%8 p=[%7 p=[%0 p=2] q=[%9 p=2 q=[%0 p=1]]] q=[%9 p=2 q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[p=[%1 p=28] q=[%1 p=38]]]] q=[%0 p=2]]]]] q=[%0 p=1]] q=[p=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=2]]] q=[%7 p=[%0 p=2] q=[%7 p=[%0 p=6] q=[%0 p=3]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
