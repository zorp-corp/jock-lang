::  /lib/tests/type-point
/+  jock,
    test
::
|%
++  text
  'compose\0a  class Foo(x:@) {\0a    bar(p:@) -> Foo {\0a      p\0a    }\0a  };\0a\0alet a:Foo = Foo(41);\0alet b = Foo(42);\0alet c:@ = 43;\0a\0a(Foo(40) a b c)'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %class] [%type 'Foo'] [%punctuator %'(('] [%name %x] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%name %bar] [%punctuator %'(('] [%name %p] [%punctuator %':'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'-'] [%punctuator %'>'] [%type 'Foo'] [%punctuator %'{'] [%name %p] [%punctuator %'}'] [%punctuator %'}'] [%punctuator %';'] [%keyword %let] [%name %a] [%punctuator %':'] [%type 'Foo'] [%punctuator %'='] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=41] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=42] q=%.n]] [%punctuator %')'] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=43] q=%.n]] [%punctuator %';'] [%punctuator %'('] [%type 'Foo'] [%punctuator %'(('] [%literal [[%number p=40] q=%.n]] [%punctuator %')'] [%name %a] [%name %b] [%name %c] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        *jock:jock
        :: [%compose p=[%class state=[p=[%atom p=%number q=%.n] name='Foo'] arms=[n=[p=%bar q=[%method type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number q=%.n] name='p']] out=[p=[%limb p=~[[%type p='Foo']]] name='Foo']]] q=~] name='bar'] body=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name='p']] out=[p=[%limb p=~[[%type p='Foo']]] name='Foo']] body=[%limb p=~[[%name p=%p]]] context=~]]]] l=~ r=~]] q=[%let type=[p=[%limb p=~[[%type p='Foo']]] name='a'] val=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=41] q=%.n]]]] next=[%let type=[p=[%none p=~] name='b'] val=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=42] q=%.n]]]] next=[%let type=[p=[%atom p=%number q=%.n] name='c'] val=[%atom p=[[%number p=43] q=%.n]] next=[p=[%call func=[%limb p=~[[%type p='Foo']]] arg=[~ [%atom p=[[%number p=40] q=%.n]]]] q=[p=[%limb p=~[[%name p=%a]]] q=[p=[%limb p=~[[%name p=%b]]] q=[%limb p=~[[%name p=%c]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [1 0] [1 8 [1 0] [1 0 6] 0 1] 0 1] 8 [1 41] 8 [1 42] 8 [1 43] [1 40] [0 14] [0 6] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  ^-  *
        [40 41 42 43]
    !>  .*(0 (mint:jock text))
::
--
