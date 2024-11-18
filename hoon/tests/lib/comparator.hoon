/+  jock,
    test
::
|%
++  text
  '\0alet a = true;\0alet b = a == true;\0alet c = a < 1;\0alet d = a > 2;\0alet e = b != true;\0alet f = a <= 1;\0alet g = a >= 2;\0a\0ag\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%punctuator %'{'] [%keyword %let] [%name %b] [%punctuator %'='] [%literal [%number 3]] [%punctuator %';'] [%literal [%number 3]] [%punctuator %'}'] [%punctuator %';'] [%name %a]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%untyped ~] name=%a] val=[%let type=[p=[%untyped ~] name=%b] val=[%atom p=[%number 3]] next=[%atom p=[%number 3]]] next=[%limb p=~[[%name p=%a]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [8 [1 3] 1 3] 0 2]
    !>  (mint:jock text)
--
