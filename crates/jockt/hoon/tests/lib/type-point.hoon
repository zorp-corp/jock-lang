::  /lib/tests/type-point
/+  jock,
    test,
    hoon
::
|%
++  text
  '/*  A class is broadly equivalent to a Hoon door. It has a top-level\0a    sample which represents its state, along with methods that have\0a    each their own samples.\0a\0a    A class must be composed into the subject to be accessible.\0a*/\0acompose\0a  class Foo(x:@) {\0a    bar(p:@) -> Foo {\0a      p\0a    }\0a  }\0a; // end compose\0a\0a//  let name:Type = value;\0alet a:Foo = Foo(41);\0a//  let name = Type(value);\0alet b = Foo(42);\0a//  let name:type = value;\0alet c:@ = 43;\0a\0a(Foo(40) a b c)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Foo'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %bar] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Foo'] [%punctuator %'{'] [%name %p] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %a] [%punctuator %':'] [%type 'Foo'] [%punctuator %'='] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=41] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=42] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=43] q=%.n]] [%punctuator %';'] [%punctuator %'('] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=40] q=%.n]] [%punctuator %')'] [%name %a] [%name %b] [%name %c] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%compose p=[%class state=[p=[%state p=[p=[%atom p=%number q=%.n] name='x']] name='Foo'] arms=[n=[p=%bar q=[%method type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='p']] out=[p=[%limb p=~[[%type p='Foo']]] name='Foo']]] q=~] name='bar'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='p']] out=[p=[%limb p=~[[%type p='Foo']]] name='Foo']] body=[%limb p=~[[%name p=%p]]] context=~]]]] l=~ r=~]] q=[%let type=[p=[%limb p=~[[%type p='Foo']]] name='a'] val=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=41] q=%.n]]]] next=[%let type=[p=[%none p=~] name='b'] val=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=42] q=%.n]]]] next=[%let type=[p=[%atom p=%number q=%.n] name='c'] val=[%atom p=[[%number p=43] q=%.n]] next=[p=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=40] q=%.n]]]] q=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[%limb p=~[[%name p=%c]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%7 p=[%8 p=[%1 p=0] q=[p=[%1 p=[8 [1 0] [1 8 [0 7] 10 [6 7 [0 3] 0 6] 0 2] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=41]]] q=[%0 p=2]]] q=[%8 p=[%8 p=[%0 p=3] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=42]]] q=[%0 p=2]]] q=[%8 p=[%1 p=43] q=[p=[%8 p=[%0 p=15] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=40]]] q=[%0 p=2]]] q=[p=[%0 p=14] q=[p=[%0 p=6] q=[%0 p=2]]]]]]]]
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
        [%7 p=[%8 p=[%1 p=0] q=[p=[%1 p=[8 [1 0] [1 8 [0 7] 10 [6 7 [0 3] 0 6] 0 2] 0 1]] q=[%0 p=1]]] q=[%8 p=[%8 p=[%0 p=1] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=41]]] q=[%0 p=2]]] q=[%8 p=[%8 p=[%0 p=3] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=42]]] q=[%0 p=2]]] q=[%8 p=[%1 p=43] q=[p=[%8 p=[%0 p=15] q=[%10 p=[p=6 q=[%7 p=[%0 p=3] q=[%1 p=40]]] q=[%0 p=2]]] q=[p=[%0 p=14] q=[p=[%0 p=6] q=[%0 p=2]]]]]]]]
    !>  .*(0 (mint:jock text))
::
--
