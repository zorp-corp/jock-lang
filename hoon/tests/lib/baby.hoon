/+  jock,
    test
::
|%
++  text
  'compose with 0; object {\0a  load = crash\0a  peek = crash\0a  poke = (a:* -> [* &1]) {\0a    [a &1]\0a  }\0a  wish = crash\0a};\0a\0apoke(3)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'('] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%name %a] [%punctuator %'('] [%literal [%number 23]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number] name=%$]] out=[p=[%atom p=%number] name=%$]]] q=~] name=%a] val=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number] name=%b]] out=[p=[%atom p=%number] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] next=[%call func=[%limb p=~[[%name p=%a]]] arg=[~ [%atom p=[%number 23]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [0 2] 9 2 10 [6 7 [0 3] 1 23] 0 2]
    !>  (mint:jock text)
--
