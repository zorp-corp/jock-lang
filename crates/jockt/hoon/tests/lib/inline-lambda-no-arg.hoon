::  /lib/tests/inline-lambda-no-arg
/+  jock,
    test,
    hoon
::
|%
++  text
  'lambda (b:@) -> @ {\0a  +(b)\0a}()\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=5] q=%.n]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [[%number p=0] q=%.n]] [%punctuator %';'] [%keyword %loop] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'{'] [%name %b] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %';'] [%punctuator %'$'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name='a'] val=[%atom p=[[%number p=5] q=%.n]] next=[%let type=[p=[%atom p=%number q=%.n] name='b'] val=[%atom p=[[%number p=0] q=%.n]] next=[%loop next=[%if cond=[%compare comp=%'==' a=[%limb p=~[[%name p=%a]]] b=[%increment val=[%limb p=~[[%name p=%b]]]]] then=[%limb p=~[[%name p=%b]]] after=[%else then=[%edit limb=~[[%name p=%b]] val=[%increment val=[%limb p=~[[%name p=%b]]]] next=[%call func=[%limb p=~[[%axis p=0]]] arg=[~ [%limb p=~[[%name p=%b]]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [%8 p=[%1 p=5] q=[%8 p=[%1 p=0] q=[%8 p=[%1 p=[6 [5 [0 14] 4 0 6] [0 6] 7 [10 [6 4 0 6] 0 1] 9 2 10 [6 7 [0 1] 0 6] 0 1]] q=[%9 p=2 q=[%0 p=1]]]]]
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
        [%8 p=[%1 p=5] q=[%8 p=[%1 p=0] q=[%8 p=[%1 p=[6 [5 [0 14] 4 0 6] [0 6] 7 [10 [6 4 0 6] 0 1] 9 2 10 [6 7 [0 1] 0 6] 0 1]] q=[%9 p=2 q=[%0 p=1]]]]]
    !>  .*(0 (mint:jock text))
::
--
