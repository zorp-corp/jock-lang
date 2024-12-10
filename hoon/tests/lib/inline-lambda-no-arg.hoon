/+  jock,
    test
::
|%
++  text
  '(b:@ -> @) {\0a  +(b)\0a}()\0a\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%punctuator %'('] [%name %b] [%punctuator %':'] [%punctuator %'@'] [%punctuator %'-'] [%punctuator %'>'] [%punctuator %'@'] [%punctuator %')'] [%punctuator %'{'] [%punctuator %'+'] [%punctuator %'('] [%name %b] [%punctuator %')'] [%punctuator %'}'] [%punctuator %'('] [%punctuator %')']]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%call func=[%lambda p=[arg=[inp=[~ [p=[%atom p=%number q=%.n] name=%b]] out=[p=[%atom p=%number q=%.n] name=%$]] body=[%increment val=[%limb p=~[[%name p=%b]]]] payload=~]] arg=~]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [7 [8 [1 0] [1 4 0 6] 0 1] 9 2 0 1]
    !>  (mint:jock text)
--
