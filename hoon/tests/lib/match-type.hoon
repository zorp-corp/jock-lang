/+  jock,
    test
::
|%
++  text
  'let a: ? = true;\0a\0aa = false;\0a\0aa\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'='] [%literal [%number 3]] [%punctuator %';'] [%keyword %match] [%keyword %type] [%name %a] [%punctuator %'{'] [%symbol [%number 1]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 2]] [%punctuator %';'] [%symbol [%number 2]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 4]] [%punctuator %';'] [%symbol [%number 3]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 8]] [%punctuator %';'] [%symbol [%number 4]] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 16]] [%punctuator %';'] [%punctuator %'_'] [%punctuator %'-'] [%punctuator %'>'] [%literal [%number 0]] [%punctuator %';'] [%punctuator %'}']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%atom p=%number] name=%a] val=[%atom p=[%number 3]] next=[%match value=[%limb p=~[[%name p=%a]]] cases=[n=[p=[%symbol p=[%number 2]] q=[%atom p=[%number 4]]] l=[n=[p=[%symbol p=[%number 3]] q=[%atom p=[%number 8]]] l=** r=**] r=[n=[p=[%symbol p=[%number 1]] q=[%atom p=[%number 2]]] l={[p=[%symbol p=[%number 4]] q=[%atom p=[%number 16]]]} r=**]] default=[~ [%atom p=[%number 0]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 3] 8 [1 0 2] 6 [5 [1 3] 0 2] [7 [0 3] 1 1 8] 6 [5 [1 2] 0 2] [7 [0 3] 1 1 4] 6 [5 [1 4] 0 2] [7 [0 3] 1 1 16] 6 [5 [1 1] 0 2] [7 [0 3] 1 1 2] 7 [0 3] 1 1 0]
    !>  (mint:jock text)
--
