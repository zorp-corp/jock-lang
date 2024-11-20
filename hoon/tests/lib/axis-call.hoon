/+  jock,
    test
::
|%
++  text
  'let a: (c: @ -> @) = (b:@ -> @) {\0a  +(b)\0a};\0a\0a&2(17)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'('] [%name %c] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'='] [%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %';'] [%punctuator %'&'] [%literal [%number 2]] [%punctuator %'('] [%literal [%number 17]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%core p=[%.y p=[inp=[~ [p=[%atom p=%number] name=%c]] out=[p=[%atom p=%number] name=%$]]] q=~] name=%a] val=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number] name=%b]] out=[p=[%atom p=%number] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] next=[%call func=[%limb p=~[[%axis p=2]]] arg=[~ [%atom p=[%number 17]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 0] [1 4 0 6] 0 1] 8 [0 2] 9 2 10 [6 7 [0 3] 1 17] 0 2]
    !>  (mint:jock text)
--
