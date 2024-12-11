/+  jock,
    test
::
|%
++  text
  'let a: @ = 3;\0a\0amatch type a {\0a  %1 -> 2;\0a  %2 -> 4;\0a  %3 -> 8;\0a  %4 -> 16;\0a  _ -> 0;\0a}\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 3]] [%punctuator %';'] [%keyword %match] [%keyword %type] [%name %a] [%punctuator %'{'] [%atom [%number 1]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 2]] [%punctuator %';'] [%atom [%number 2]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 4]] [%punctuator %';'] [%atom [%number 3]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 8]] [%punctuator %';'] [%atom [%number 4]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 16]] [%punctuator %';'] [%punctuator %'_'] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 0]] [%punctuator %';'] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock  *jock:jock
        :: [%let type=[p=[%atom p=%number q=%.n] name=%a] val=[%atom p=[%number 3]] next=[%match value=[%limb p=~[[%name p=%a]]] cases=[n=[p=[%atom p=[%number 2] q=%.y] q=[%atom p=[%number 4] q=%.n]] l=[n=[p=[%atom p=[%number 3] q=%.y] q=[%atom p=[%number 8] q=%.n]] l=~ r=~] r=[n=[p=[%atom p=[%number 1] q=%.y] q=[%atom p=[%number 2] q=%.n]] l=[[p=[%atom p=[%number 4] q=%.y] q=[%atom p=[%number 16] q=%.n]]] r=~]] default=[~ [%atom p=[%number 0] q=%.n]]]]
        :: TODO depends on getting map representation right here
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 8 [1 0 2] 6 [5 [1 3] 0 2] [7 [0 3] 1 1 8] 6 [5 [1 2] 0 2] [7 [0 3] 1 1 4] 6 [5 [1 4] 0 2] [7 [0 3] 1 1 16] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 2] 7 [0 3] 1 1 0]
    !>  (mint:jock text)
--
