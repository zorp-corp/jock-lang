/+  jock,
    test
::
|%
++  text
  'let a = {\0a  let b = 3;\0a  3\0a};\0a\0aa\0a'
++  test-tokenize
  %+  expect-eq:test
    !>  ~[[%keyword %let] [%name %a] [%punctuator %'='] [%literal [%loobean %.y]] [%punctuator %';'] [%keyword %let] [%name %b] [%punctuator %'='] [%name %a] [%punctuator %'='] [%punctuator %'='] [%literal [%loobean %.y]] [%punctuator %';'] [%keyword %let] [%name %c] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%literal [%number 1]] [%punctuator %';'] [%keyword %let] [%name %d] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%literal [%number 2]] [%punctuator %';'] [%keyword %let] [%name %e] [%punctuator %'='] [%name %b] [%punctuator %'!'] [%punctuator %'='] [%literal [%loobean %.y]] [%punctuator %';'] [%keyword %let] [%name %f] [%punctuator %'='] [%name %a] [%punctuator %'<'] [%punctuator %'='] [%literal [%number 1]] [%punctuator %';'] [%keyword %let] [%name %g] [%punctuator %'='] [%name %a] [%punctuator %'>'] [%punctuator %'='] [%literal [%number 2]] [%punctuator %';'] [%name %g]]
    !>  (rash text parse-tokens:jock)
::
++  test-jeam
  %+  expect-eq:test
    !>  ^-  jock:jock
        [%let type=[p=[%untyped ~] name=%a] val=[%atom p=[%loobean %.y]] next=[%let type=[p=[%untyped ~] name=%b] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'==' b=[%atom p=[%loobean %.y]]] next=[%let type=[p=[%untyped ~] name=%c] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'<' b=[%atom p=[%number 1]]] next=[%let type=[p=[%untyped ~] name=%d] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'>' b=[%atom p=[%number 2]]] next=[%let type=[p=[%untyped ~] name=%e] val=[%compare a=[%limb p=~[[%name p=%b]]] comp=%'!=' b=[%atom p=[%loobean %.y]]] next=[%let type=[p=[%untyped ~] name=%f] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'<=' b=[%atom p=[%number 1]]] next=[%let type=[p=[%untyped ~] name=%g] val=[%compare a=[%limb p=~[[%name p=%a]]] comp=%'>=' b=[%atom p=[%number 2]]] next=[%limb p=~[[%name p=%g]]]]]]]]]]
    !>  (jeam:jock text)
::
++  test-mint
  %+  expect-eq:test
    !>  [8 [1 0] 8 [5 [0 2] 1 0] 8 [11 6.845.548 0 0] 8 [11 6.845.543 0 0] 8 [6 [5 [0 14] 1 0] [1 1] 1 0] 8 [11 6.648.940 0 0] 8 [11 6.648.935 0 0] 0 2]
    !>  (mint:jock text)
--
