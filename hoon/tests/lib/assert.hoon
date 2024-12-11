/+  jock,
    test
::
|%
++  text
  'let a: @ = 5;\0alet b: @ = 0;\0a\0aassert a != 0;\0alet c = ?([a a]);\0aloop;\0a\0aif a == +(b) {\0a  b\0a} else {\0a  b = +(b);\0a  recur\0a}\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 5]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 0]] [%punctuator %';'] [%keyword %assert] [%name %a] [%punctuator %'!'] [%punctuator %'='] [%literal [%number 0]] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%punctuator %'?'] [%punctuator %'('] [%punctuator %'['] [%name %a] [%name %a] [%punctuator %']'] [%punctuator %')'] [%punctuator %';'] [%keyword %loop] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'{'] [%name %b] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%name %b] [%punctuator %'='] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %';'] [%keyword %recur] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[%number 5] q=%.n] next=[%let type=[p=[%atom p=%number q=%.n] name=%b] val=[%atom p=[%number 0] q=%.n] next=[%assert cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'!=' b=[%atom p=[%number 0] q=%.n]] then=[%let type=[p=[%none ~] name=%c] val=[%cell-check val=[p=[%limb p=~[[%name p=%a]]] q=[%limb p=~[[%name p=%a]]]]] next=[%loop next=[%if cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%increment val=[%limb p=~[[%name p=%b]]]]] then=[%limb p=~[[%name p=%b]]] after=[%else then=[%edit limb=~[[%name p=%b]] val=[%increment val=[%limb p=~[[%name p=%b]]]] next=[%call func=[%limb p=~[[%axis p=0]]] arg=~]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 5] 8 [1 0] 6 [6 [5 [0 6] 1 0] [1 1] 1 0] [8 [3 [0 6] 0 6] 8 [1 6 [5 [0 30] 4 0 14] [0 14] 7 [10 [14 4 0 14] 0 1] 9 2 0 1] 9 2 0 1] 0 0]
    !>  (mint:jock text)
--
