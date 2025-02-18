::  /lib/tests/type-point-2
/+  jock,
    test
::
|%
++  text
  'compose\0a  class Point(x:@ y:@) {\0a    // new() is the required constructor\0a    new(p:Point) -> Point {\0a      // the return from any method must match the state shape\0a      (x.p y.p)\0a    }\0a    add(p:Point q:Point) -> Point {\0a      // we do not have infix operators yet so this is just a weird hack\0a      (x.p y.q)\0a    }\0a    copy(p:Point) -> Point {\0a      // return the current state\0a      (x.p y.p)\0a    }\0a  }; // end compose\0a\0a// uses the implicit new() constructor\0alet origin = Point(50 60);\0alet vector = Point(70 80);\0a\0avector.add(vector origin)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Point'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %new] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %p] [%punctuator %')'] [%punctuator %'}'] [%name %add] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%name %q] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %q] [%punctuator %')'] [%punctuator %'}'] [%name %copy] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %p] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %origin] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=50] q=%.n]] [%literal [[%number p=60] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %vector] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=70] q=%.n]] [%literal [[%number p=80] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %vector] [%punctuator %'.'] [%name %add] [%punctuator %'(('] [%name %vector] [%name %origin] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        :: [%compose p=[%class state=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point'] arms=[n=[p=%add q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p'] q=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='q']] name='']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']]] q=~] name='add'] body=[%lambda p=[arg=[inp=[~ [[p=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p'] q=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='q']] name='']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']] body=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[%limb p=~[[%name p=%q] [%name p=%y]]]] payload=~]]]] l=[n=[p=%new q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']]] q=~] name='new'] body=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']] body=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[%limb p=~[[%name p=%p] [%name p=%y]]]] payload=~]]]] l={[p=%copy q=[%method type=[p=[%core p=[%.y p=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']]] q=~] name='copy'] body=[%lambda p=[arg=[inp=[~ [[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='p']] out=[[p=[p=[%atom p=%number q=%.n] name='x'] q=[p=[%atom p=%number q=%.n] name='y']] name='Point']] body=[p=[%limb p=~[[%name p=%p] [%name p=%x]]] q=[%limb p=~[[%name p=%p] [%name p=%y]]]] payload=~]]]]} r={}] r=~]] q=[%let type=[p=[%none p=~] name='origin'] val=[%call func=[%limb p=~[[%name p=%new] [%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=50] q=%.n]] q=[%atom p=[[%number p=60] q=%.n]]]]] next=[%let type=[p=[%none p=~] name='vector'] val=[%call func=[%limb p=~[[%name p=%new] [%type p='Point']]] arg=[~ [p=[%atom p=[[%number p=70] q=%.n]] q=[%atom p=[[%number p=80] q=%.n]]]]] next=[%call func=[%limb p=~[[%name p=%add] [%name p=%vector]]] arg=[~ [p=[%limb p=~[[%name p=%vector]]] q=[%limb p=~[[%name p=%origin]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [[1 0] 1 0] 1 [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] 8 [[[1 0] 1 0] [1 0] 1 0] [1 [0 24] 0 27] 0 1] 8 [8 [9 62 0 1] 9 2 10 [6 7 [0 3] [1 50] 1 60] 0 2] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [7 [8 [[1 0] 1 0] 1 [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] 8 [[[1 0] 1 0] [1 0] 1 0] [1 [0 24] 0 27] 0 1] 8 [8 [9 62 0 1] 9 2 10 [6 7 [0 3] [1 50] 1 60] 0 2] 0 2])
    !>  .*(0 (mint:jock text))
::
--
