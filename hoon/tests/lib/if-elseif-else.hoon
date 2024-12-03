/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  72\0a} else if a == 5 {\0a  17\0a} else {\0a  15\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 3]] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [%number 3]] [%punctuator %'{'] [%literal [%number 72]] [%punctuator %'}'] [%keyword %else] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [%number 5]] [%punctuator %'{'] [%literal [%number 17]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%literal [%number 15]] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[%number 3] q=%.n] next=[%if cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[%number 3] q=%.n]] then=[%atom p=[%number 72] q=%.n] after=[%else-if cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[%number 5] q=%.n]] then=[%atom p=[%number 17] q=%.n] after=[%else then=[%atom p=[%number 15] q=%.n]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 6 [5 [0 2] 1 3] [1 72] 6 [5 [0 2] 1 5] [1 17] 1 15]
    !>  (mint:jock text)
--
