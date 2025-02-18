/+  jock,
    test
::
|%
++  text
  'compose with 0; object {\0a  load = crash\0a  peek = crash\0a  poke = (a:* -> (* &1)) {\0a    (a &1)\0a  }\0a  wish = crash\0a};\0a\0apoke(3)\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %compose] [%keyword %with] [%literal [%number 0]] [%punctuator %';'] [%keyword %object] [%punctuator %'{'] [%name %load] [%punctuator %'='] [%keyword %crash] [%name %peek] [%punctuator %'='] [%keyword %crash] [%name %poke] [%punctuator %'='] [%punctuator %'('] [%name %a] [%punctuator %':'] [%punctuator %'*'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'('] [%punctuator %'*'] [%punctuator %'&'] [%literal [%number 1]] [%punctuator %')'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'('] [%name %a] [%punctuator %'&'] [%literal [%number 1]] [%punctuator %')'] [%punctuator %'}'] [%name %wish] [%punctuator %'='] [%keyword %crash] [%punctuator %'}'] [%punctuator %';'] [%name %poke] [%punctuator %'('] [%literal [%number 3]] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%compose p=[%object name=%$ p=[n=[p=%load q=[%crash ~]] l=[n=[p=%wish q=[%crash ~]] l=~ r=~] r=[n=[p=%peek q=[%crash ~]] l=[p=%poke q=[%lambda p=[arg=[inp=[~ [p=[%none ~] name=%a]] out=[[p=[p=[%none ~] name=%$] q=[p=[%limb p=~[[%axis p=1]]] name=%$]] name=%$]] body=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%axis p=1]]]] payload=~]]] r=~]] q=[~ [%atom p=[%number 0] q=%.n]]] q=[%call func=[%limb p=~[[%name p=%poke]]] arg=[~ [%atom p=[%number 3] q=%.n]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [[1 [0 0] [0 0] [8 [1 0] [1 [0 6] 0 1] 0 1] 0 0] 1 0] 8 [9 22 0 1] 9 2 10 [6 7 [0 3] 1 3] 0 2]
    !>  (mint:jock text)
::
++  test-nock
  %+  expect-eq:test
    !>  .*(0 [7 [[1 [0 0] [0 0] [8 [1 0] [1 [0 6] 0 1] 0 1] 0 0] 1 0] 8 [9 22 0 1] 9 2 10 [6 7 [0 3] 1 3] 0 2])
    !>  .*(0 (mint:jock text))
::
--
