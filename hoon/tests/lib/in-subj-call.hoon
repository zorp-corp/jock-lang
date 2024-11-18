/+  jock,
    test
::
|%
++  text
  'let a = 17;\0a\0alet b = ([b:@ c:&1] -> @) {\0a  if c == 18 {\0a    +(b)\0a  } else {\0a    b\0a  }\0a}([23 &1]);\0a\0a&1\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'['] [%name %p] [%punctuator %':'] [%punctuator %'@'] [%name %q] [%punctuator %':'] [%punctuator %'['] [%name %k] [%punctuator %':'] [%punctuator %'@'] [%name %v] [%punctuator %':'] [%punctuator %'@'] [%punctuator %']'] [%punctuator %']'] [%punctuator %'='] [%punctuator %'['] [%literal [%number 52]] [%literal [%number 30]] [%literal [%number 45]] [%punctuator %']'] [%punctuator %';'] [%name %v] [%punctuator %'.'] [%name %q] [%punctuator %'.'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[[p=[p=[%atom p=%number] name=%p] q=[[p=[p=[%atom p=%number] name=%k] q=[p=[%atom p=%number] name=%v]] name=%q]] name=%a] val=[p=[%atom p=[%number 52]] q=[p=[%atom p=[%number 30]] q=[%atom p=[%number 45]]]] next=[%limb p=~[[%name p=%a] [%name p=%q] [%name p=%v]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [[1 52] [1 30] 1 45] 0 11]
    !>  (mint:jock text)
--
