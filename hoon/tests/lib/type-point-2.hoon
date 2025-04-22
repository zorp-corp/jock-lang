::  /lib/tests/type-point-2
/+  jock,
    test
::
|%
++  text
  'compose\0a  class Point(x:@ y:@) {\0a    add(p:(x:@ y:@)) -> Point {\0a      (p.x p.y)\0a    }\0a    sub(p:(x:@ y:@)) -> Point {\0a      (p.x p.x p.x)\0a    }\0a  };\0a\0alet origin = Point(50 60);\0a(origin.add(70 80) origin.sub(90 100))'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Point'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %add] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%punctuator %'('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %p] [%punctuator %'.'] [%name %x] [%name %p] [%punctuator %'.'] [%name %y] [%punctuator %')'] [%punctuator %'}'] [%name %sub] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%punctuator %'('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %p] [%punctuator %'.'] [%name %x] [%name %p] [%punctuator %'.'] [%name %x] [%name %p] [%punctuator %'.'] [%name %x] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %origin] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=50] q=%.n]] [%literal [[%number p=60] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%punctuator %'('] [%name %origin] [%punctuator %'.'] [%name %add] [%punctuator %'(('] [%literal [[%number p=70] q=%.n]] [%literal [[%number p=80] q=%.n]] [%punctuator %')'] [%name %origin] [%punctuator %'.'] [%name %sub] [%punctuator %'(('] [%literal [[%number p=90] q=%.n]] [%literal [[%number p=100] q=%.n]] [%punctuator %')'] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        ::[%compose p=[%class state=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point'] arms=[n=[p=%add q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']]] q=~] name='add'] body=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']] body=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[%limb p=~[[%name p=%p] [%name p=%y]]]] context=~]]]] l=~ r=[n=[p=%sub q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']]] q=~] name='sub'] body=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[p=[%limb p=~[[%type p='Point']]] name='Point']] body=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[%limb p=~[[%name p=%p] [%name p=%x]]]]] context=~]]]] l=~ r=~]]] q=[%let type=[p=[%none p=~] name='origin'] val=[%call func=[%limb p=~[[%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=50] q=%.n]] q=[%atom p=[[%number p=60] q=%.n]]]]] next=[p=[%call func=[%limb p=~[[%name p=%origin] [%name p=%add]]] arg=[~ [p=[%atom p=[[%number p=70] q=%.n]] q=[%atom p=[[%number p=80] q=%.n]]]]] q=[%call func=[%limb p=~[[%name p=%origin] [%name p=%sub]]] arg=[~ [p=[%atom p=[[%number p=90] q=%.n]] q=[%atom p=[[%number p=100] q=%.n]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [[1 0] 1 0] [1 [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] 8 [[1 0] 1 0] [1 [0 12] [0 12] 0 12] 0 1] 0 1] 8 [[1 50] 1 60] [8 [9 4 0 3] 9 2 10 [6 7 [0 3] [1 70] 1 80] 0 2] 8 [9 5 0 3] 9 2 10 [6 7 [0 3] [1 90] 1 100] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [[70 80] 90 90 90])
    !>  .*(0 (mint:jock text))
::
--
