/+  jock,
    test
::
|%
++  text
  'let a: @ = 5;\0alet b: @ = 0;\0a\0aassert a != 0;\0alet c = ?([a a]);\0aloop;\0a\0aif a == +(b) {\0a  b\0a} else {\0a  b = +(b);\0a  recur\0a}\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'('] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%call func=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number] name=%b]] out=[p=[%atom p=%number] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] arg=~]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [1 0] [1 4 0 6] 0 1] 9 2 0 1]
    !>  (mint:jock text)
--
