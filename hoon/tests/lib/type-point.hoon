::  /lib/tests/type-point
/+  jock,
    test
::
|%
++  text
  'compose\0a  class Point(x:@ y:@) {\0a    // new() is the required constructor\0a    new(p:Point) -> Point {\0a      // the return from any method must match the state shape\0a      (x.p y.p)\0a    }\0a    add(p:Point q:Point) -> Point {\0a      // we do not have infix operators yet so this is just a weird hack\0a      (x.p y.q)\0a    }\0a    copy(p:Point) -> Point {\0a      // return the current state\0a      (x.p y.p)\0a    }\0a  }; // end compose\0a\0a// uses the implicit new() constructor\0alet origin = Point(50 60);\0a\0aorigin'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Point'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%name %y] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %new] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %p] [%punctuator %')'] [%punctuator %'}'] [%name %add] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%name %q] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %q] [%punctuator %')'] [%punctuator %'}'] [%name %copy] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%type 'Point'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Point'] [%punctuator %'{'] [%punctuator %'('] [%name %x] [%punctuator %'.'] [%name %p] [%name %y] [%punctuator %'.'] [%name %p] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %origin] [%punctuator %'='] [%type 'Point'] [%punctuator %'(('] [%literal [[%number p=50] q=%.n]] [%literal [[%number p=60] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%name %origin]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        ::[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%a] val=[%set type=[%none ~] val=[[%atom p=[[%number p=1] q=%.n]]]] next=[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%b] val=[%set type=[%none ~] val=[[%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]]]] next=[%let type=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%c] val=[%set type=[%none ~] val=[[%atom p=[[%number p=3] q=%.n]] [%atom p=[[%number p=1] q=%.n]] [%atom p=[[%number p=2] q=%.n]]]] next=[%let type=[p=[%set type=[[p=[p=[%atom p=%number q=%.n] name=%$] q=[p=[%atom p=%number q=%.n] name=%$]] name=%$]] name=%d] val=[%set type=[%none ~] val=[[p=[%atom p=[[%number p=3] q=%.n]] q=[%atom p=[[%number p=4] q=%.n]]] [p=[%atom p=[[%number p=1] q=%.n]] q=[%atom p=[[%number p=2] q=%.n]]]]] next=[%let type=[p=[%set type=[[p=[p=[%atom p=%number q=%.n] name=%$] q=[p=[%set type=[p=[%atom p=%number q=%.n] name=%$]] name=%$]] name=%$]] name=%e] val=[%set type=[%none ~] val=[[p=[%atom p=[[%number p=3] q=%.n]] q=[%set type=[%none ~] val=[[%atom p=[[%number p=5] q=%.n]] [%atom p=[[%number p=4] q=%.n]]]]] [p=[%atom p=[[%number p=1] q=%.n]] q=[%set type=[%none ~] val=[[%atom p=[[%number p=2] q=%.n]]]]]]] next=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[p=[%limb p=~[[%name p=%c]]] q=[p=[%limb p=~[[%name p=%d]]] q=[%limb p=~[[%name p=%e]]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [[1 0] 1 0] 1 [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] [8 [[1 0] 1 0] [1 [0 12] 0 13] 0 1] 8 [[[1 0] 1 0] [1 0] 1 0] [1 [0 24] 0 27] 0 1] 8 [8 [9 62 0 1] 9 2 10 [6 7 [0 3] [1 50] 1 60] 0 2] 0 2]
    !>  (mint:jock text)
--
