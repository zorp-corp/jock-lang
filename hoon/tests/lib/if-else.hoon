/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0aif a == 3 {\0a  72\0a} else {\0a  17\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 3]] [%punctuator %';'] [%keyword %if] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [%number 3]] [%punctuator %'{'] [%literal [%number 72]] [%punctuator %'}'] [%keyword %else] [%punctuator %'{'] [%literal [%number 17]] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number] name=%a] val=[%atom p=[%number 3]] next=[%if cond=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[%number 3]]] then=[%atom p=[%number 72]] after=[%else then=[%atom p=[%number 17]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 6 [5 [0 2] 1 3] [1 72] 1 17]
    !>  (mint:jock text)
--
