=<  |%
    ++  jeam
      |=  txt=@
      ^-  jock
      =+  [jok tokens]=(match-jock (rash txt parse-tokens))
      ?.  ?=(~ tokens)
        ~|  'jeam: must parse to a single jock'
        !!
      jok
    ::
    ++  mint
      |=  txt=@
      ^-  *
      =/  jok  (jeam txt)
      =+  [nok jyp]=(~(mint cj [%atom %string %.n]^%$) jok)
      nok
    --
=>
::
::  1: tokenizer
::
::  The tokenizer is a simple state machine that reads a string of text and
::  produces a list of tokens.  The tokens are classified as keywords,
::  punctuators, literals, and names.  The tokenizer is implemented as a
::  function that takes a string of text and returns a list of tokens.  It is
::  agnostic to whitespace.  Comments are ignored at the parser level.
::
|%
+|  %tokenizer
::
+$  keyword
  $+  keyword
  $?  %let
      %if
      %else
      %crash
      %assert
      %object
      %compose
      %loop
      %defer
      %recur
      %match
      %eval
      %with
      %this
      %type
      %case
  ==
::
+$  punctuator
  $+  punctuator
  $?  %'.'  %';'  %','  %':'  %'&'  %'$'
      %'@'  %'?'  %'!'
      %'('  %')'  %'{'  %'}'  %'['  %']'
      %'='  %'<'  %'>'
      %'+'  %'-'  %'*'  %'/'  %'_'
      %'~'
  ==
::
+$  jatom
  $+  jatom
  $~  [[%loobean %.n] %.n]
  $:  $%  [%string term]
          [%number @ud]
          [%hexadecimal @ux]
          [%loobean ?]
      ==
    ?(%.y %.n)
  ==
::
+$  token
  $+  token
  $%  [%keyword keyword]
      [%punctuator punctuator]
      [%literal jatom]
      [%name term]
  ==
::
+$  tokens  (list token)
::
++  val   %+  cold  ~
          ;~  plug  fas  fas
            (star prn)
            (just `@`10)
          ==
++  var   %+  cold  ~
          ;~  plug  ;~(plug fas tar)
              (star ;~(less ;~(plug tar fas) prn))
              ;~(plug tar fas)
          ==
++  gav  (cold ~ (star ;~(pose val var gah)))
++  gae  ;~(pose gav (easy ~))
::
++  tokenize
  |%
  ++  number             (stag %number dem:ag)
  ++  hexadecimal        (stag %hexadecimal ;~(pfix (jest %'0x') hex))
  ++  loobean
    %+  stag  %loobean
    ;~(pose (cold %.y (jest %true)) (cold %.n (jest %false)))
  ::
  ++  string             (stag %string (ifix [soq soq] sym))
  ++  literal            ;~(pose loobean hexadecimal number string)
  ++  tagged-literal     (stag %literal (hart literal %.n))
  ++  symbol             ;~(pfix cen ;~(pose loobean hexadecimal number string))
  ++  tagged-symbol      (stag %literal (hart symbol %.y))
  ::  add a suffix label
  ++  hart
    |*  [sef=rule gob=*]
    |=  tub=nail
    =+  vex=(sef tub)
    ?~  q.vex
      vex
    [p=p.vex q=[~ u=[p=[p.u.q.vex gob] q=q.u.q.vex]]]
  ::
  ++  name               sym
  ++  tagged-name        (stag %name name)
  ::
  ++  keyword
    %-  perk
    :~  %let  %if  %else  %crash  %assert
        %object  %compose  %loop  %defer
        %recur  %match  %eval  %with  %this
        %type  %case
    ==
  ::
  ++  tagged-keyword     (stag %keyword keyword)
  ::
  ++  punctuator
    %-  perk
    :~  %'.'  %';'  %','  %':'  %'&'  %'$'
        %'@'  %'?'  %'!'
        %'('  %')'  %'{'  %'}'  %'['  %']'
        %'='  %'<'  %'>'
        %'+'  %'-'  %'*'  %'/'  %'_'
        %'~'
    ==
  ++  tagged-punctuator  (stag %punctuator punctuator)
  ::
  ++  token
    ;~  pose
        tagged-keyword
        tagged-symbol
        tagged-punctuator
        tagged-literal
        tagged-name
    ==
  ::
  ++  tokens  (star ;~(pose token ;~(pfix gav token)))
  --
::
++  parse-tokens
  |=  =nail
  ^-  (like tokens)
  %.  nail
  %-  full
  (ifix [gae gae] tokens:tokenize)
--
::
=>
::
::  2: jock abstract syntax tree and parser
::
::  The jock abstract syntax tree (AST) is produced from the token list.  A jock
::  represents what will compile to executable Nock expressions.
::
::  The jype, which consists of type information, is generated alongside the
::  jock.  The jype is critical in yielding the final Nock subject from +mint.
::
::  The jlimb is a reference to a known limb in the current subject.
::
::  Ultimately all cases in the Jock AST resolve as one of jock, jype, or jlimb.
::
|%
+|  %ast
::
+$  jock
  $+  jock
  $^  [p=jock q=jock]
  $%  [%let type=jype val=jock next=jock]
      [%edit limb=(list jlimb) val=jock next=jock]
      [%increment val=jock]
      [%cell-check val=jock]
      [%compose p=jock q=jock]
      [%object name=term p=(map term jock) q=(unit jock)]
      [%eval p=jock q=jock]
      [%loop next=jock]
      [%defer next=jock]
      if-expression
      [%assert cond=jock then=jock]
      [%match value=jock cases=(map jock jock) default=(unit jock)]
      [%cases value=jock cases=(map jock jock) default=(unit jock)]
      [%call func=jock arg=(unit jock)]
      [%compare a=jock comp=comparator b=jock]
      [%lambda p=lambda]
      [%limb p=(list jlimb)]
      [%type type=jype val=jock]
      [%atom p=jatom]
      [%crash ~]
  ==
::
+$  if-expression
  $:  %if
      cond=jock
      then=jock
      after=after-if-expression
  ==
::
+$  else-if-expression
  $:  %else-if
      cond=jock
      then=jock
      after=after-if-expression
  ==
::
+$  else-expression
  $:  %else
      then=jock
  ==
::
+$  after-if-expression
  $%  else-if-expression
      else-expression
  ==
::
+$  comparator
  $+  comparator
  $?  %'<'
      %'>'
      %'!='
      %'=='
      %'<='
      %'>='
  ==
::  Jype type base types
+$  jype
  $+  jype
  $:  $^([p=jype q=jype] p=jype-leaf)
      name=term
  ==
::  Jype bottomed-out types
+$  base-jype-leaf
  $%  ::  %atom is a basic numeric type with constant flag (%.y = constant)
      [%atom p=jatom-type q=?(%.y %.n)]
      ::  %core is a callable function with arguments and returns
      [%core p=core-body q=(unit jype)]
      ::  %limb is a reference to a limb in the current core
      [%limb p=(list jlimb)]
      ::  %fork is a branch point (as in an if-else)
      [%fork p=jype q=jype]
      ::  %none is a null type (as for undetermined variable labels)
      [%none ~]
  ==
::  Jype types including recursion and references
+$  jype-leaf
  $%  base-jype-leaf
      ::  %ring is a recursive type with a base case
      [%ring p=[%atom p=jatom-type q=?(%.y %.n)] q=jype]
      ::  %link is a reference to an existing type, or self if null
      [%link p=(unit jlimb)]
  ==
::  Jype atom base types; corresponds to jatom tags
+$  jatom-type
  $+  jatom-type
  $?  %string
      %number
      %hexadecimal
      %loobean
  ==
::  Jype core executable, either a direct lambda or a regular core
+$  core-body  (each lambda-argument (map term jype))
::  Lambda executable
+$  lambda
  $+  lambda
  $:  ::  Argument type
      arg=lambda-argument
      ::  Executable body (battery)
      body=jock
      ::  Supplied [sample context], if applicable
      payload=(unit jock)
  ==
::  Lambda input argument pair
+$  lambda-argument
  $+  lambda-argument
  $:  ::  Sample type, if any
      inp=(unit jype)
      ::  Expected output type
      out=jype
  ==
::  Arm lookups
+$  jlimb
  $%  ::  Arm or leg name
      [%name p=term]
      ::  Numeric axis
      [%axis p=@]
  ==
::
++  match-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)
    ~|("expect jock. token: ~" !!)
  =^  jock  tokens
    ?-    -.-.tokens
        %literal
      ::  TODO: check if we're in a compare
      (match-literal tokens)
    ::
      %name        (match-start-name tokens)
      %keyword     (match-keyword tokens)
      %punctuator  (match-start-punctuator tokens)
    ==
  [jock tokens]
::
++  match-inner-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?~  tokens  ~|("expect inner-jock. token: ~" !!)
  ?:  ?|  (has-keyword -.tokens %object)
          (has-keyword -.tokens %with)
          (has-keyword -.tokens %this)
          (has-keyword -.tokens %crash)
      ==
    (match-jock tokens)
  ?:  (has-punctuator -.tokens %'{')
    =>  .(tokens `(list token)`tokens)
    =^  jock  tokens
      (match-jock +.tokens)
    ?>  (got-punctuator -.tokens %'}')
    [jock +.tokens]
  ?+    -.i.tokens  !!
      %literal
    ::  TODO: check if we're in a compare
    (match-literal tokens)
  ::
    :: %symbol      (match-symbol tokens)
    %name        (match-start-name tokens)
    %punctuator  (match-start-punctuator tokens)
  ==
::
++  match-pair-inner-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?~  tokens  ~|("expect jock. token: ~" !!)
  ?:  (has-punctuator -.tokens %'[')
    =>  .(tokens `(list token)`+.tokens)
    =^  jock-one  tokens
      (match-inner-jock tokens)
    =/  first=?  %.y
    |-  ^-  [jock (list token)]
    =^  jock-nex  tokens
      (match-inner-jock tokens)
    =/  pun  (has-punctuator -.tokens %']')
    ?:  &(first pun)
      [[jock-one jock-nex] +.tokens]
    ?:  pun
      [jock-nex +.tokens]
    ?:  first
      =^  pairs  tokens
        $(first %.n)
      [[jock-one jock-nex pairs] tokens]
    =^  pairs  tokens
      $
    [[jock-nex pairs] tokens]
  ?+  -.i.tokens  !!
    %literal     (match-literal tokens)
    :: %symbol      (match-symbol tokens)
    %name        (match-start-name tokens)
    %punctuator  (match-start-punctuator tokens)
  ==
::
:: ++  match-inner-list
::   |=  =tokens
::   ^-  [jock (list token)]

::
++  match-start-punctuator
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)  ~|("expect jock. token: ~" !!)
  =/  first=token  -.tokens
  ?.  ?=(%punctuator -.first)
    ~|("expect start-punctuator. token: {<-.first>}" !!)
  =.  tokens  +.tokens
  ?+    +.first  ~|(tokens !!)
  ::  Regular cell  [1 2]
      %'['
    (match-pair-inner-jock [[%punctuator %'['] tokens])
  ::  Increment  +(0)
      %'+'
    =^  jock  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)
    ::  TODO: check if we're in a compare
    [[%increment jock] tokens]
  ::
      %'?'
    =^  jock  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)
    ::  TODO: check if we're in a compare
    [[%cell-check jock] tokens]
  ::
      %'$'
    ?.  (has-punctuator -.tokens %'(')
      [[%call [%limb [%axis 0] ~] ~] tokens]
    ?:  (has-punctuator -.tokens %')')
      [[%call [%limb [%axis 0] ~] ~] +.+.tokens]
    =^  arg  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)
    [[%call [%limb [%axis %0] ~] `arg] tokens]
  ::  Axis address  &1
      %'&'
    ::  TODO: check if we're in a compare
    =^  axis-lit  tokens
      (match-axis [[%punctuator %'&'] tokens])
    ?:  =(~ tokens)
      [[%limb axis-lit ~] tokens]
    ?.  (has-punctuator -.tokens %'(')
      [[%limb axis-lit ~] tokens]
    =^  arg  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)
    [[%call [%limb axis-lit ~] `arg] tokens]
  ::  Function call  foo(bar)
      %'('
    =^  lambda  tokens
      (match-lambda [[%punctuator %'('] tokens])
    ?:  =(~ tokens)
      [[%lambda lambda] tokens]
    ?.  (has-punctuator -.tokens %'(')
      [[%lambda lambda] tokens]
    =.  tokens  +.tokens
    ?:  (has-punctuator -.tokens %')')
      [[%call [%lambda lambda] ~] +.tokens]
    =^  arg  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %')')
    [[%call [%lambda lambda] `arg] +.tokens]
  ::  Null-terminated lists  ~[1 2 3]
      %'~'
    ?>  (got-punctuator -.tokens %'[')
    =.  tokens  +.tokens
    =/  jyp=jype
      [%ring [%atom %number %.n] [[%atom %number %.n]^%$ [%link ~]^%$]^%$]^%$
    ::  retrieve first element
    =^  jock-one  tokens
      (match-inner-jock tokens)
    ::  Case ~[one]
    ?:  (has-punctuator -.tokens %']')
      ~&  [[%type jyp [jock-one [%atom [%number 0] %.n]]] +.tokens]
      :: [[%type jyp [jock-one [%atom [%number 0] %.n]]] +.tokens]
      [[jock-one [%atom [%number 0] %.n]] +.tokens]
    =/  first=?  %.y
    ::  else proceed until reaching the end
    |-  ^-  [jock (list token)]
    =^  jock-nex  tokens
      (match-inner-jock tokens)
    =/  pun  (has-punctuator -.tokens %']')
    ::  Case ~[one two]
    ?:  &(first pun)
      [[jock-one jock-nex] +.tokens]
    ::  Append null at end of list
    ?:  pun
      [[jock-nex [%atom [%number 0] %.n]] +.tokens]
    ::  Case ~[one two .. end]
    ?:  first
      =^  pairs  tokens
        $(first %.n)
      [[jock-one jock-nex pairs] tokens]
    =^  pairs  tokens
      $
    [[jock-nex pairs] tokens]
  ==
::
++  match-axis
  |=  =tokens
  ^-  [[%axis @] (list token)]
  ?>  (got-punctuator -.tokens %'&')
  =.  tokens  +.tokens
  =/  num=@  (got-jatom-number tokens)
  [[%axis num] +.tokens]
::
++  match-start-name
  |=  =tokens
  ^-  [jock (list token)]
  ?~  tokens  ~|("expect expression starting with name. token: ~" !!)
  ::  - %name (';' is is the next token)
  ::  - %edit ('=' is the next token)
  ::  - %call ('(' is the next token)
  ::  - %compare ('==' or '<' or '>' or '!' is next)
  ?.  ?=(%name -.i.tokens)
    ~|("expect name. token: {<-.i.tokens>}" !!)
  =/  name=term
    (got-name i.tokens)
  =>  .(tokens t.tokens)
  =/  limbs=(list jlimb)  [%name name]~
  ?:  =(~ tokens)
    [[%limb limbs] tokens]
  ?:  ?=(^ (get-name -.tokens))
    [[%limb limbs] tokens]
  |-
  ?:  =(~ tokens)
    [[%limb limbs] tokens]
  ?^  nom=(get-name -.tokens)
    $(tokens +.tokens, limbs [[%name u.nom] limbs])
  ?:  (has-punctuator -.tokens %'.')
    $(tokens +.tokens)
  ?:  (has-punctuator -.tokens %'=')
    ?:  (has-punctuator -.+.tokens %'=')
      =^  b  tokens
        (match-inner-jock +.+.tokens)
      [[%compare [%limb limbs] %'==' b] tokens]
    =^  val  tokens
      (match-inner-jock +.tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  jock  tokens
      (match-jock +.tokens)
    [[%edit limbs val jock] tokens]
  ?:  ?|  (has-punctuator -.tokens %'<')
          (has-punctuator -.tokens %'>')
          (has-punctuator -.tokens %'!')
      ==
    =^  comparator  tokens
      (match-comparator tokens)
    =^  inner-two  tokens
      (match-inner-jock tokens)
    [[%compare [%limb limbs] comparator inner-two] tokens]
  ?:  (has-punctuator -.tokens %'(')
    |-
    =.  tokens  +.tokens
    =^  arg  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %')')
    ::  TODO: check if we're in a compare
    [[%call [%limb limbs] `arg] +.tokens]
  [[%limb limbs] tokens]
::
++  match-keyword
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)  ~|("expect keyword. token: ~" !!)
  =^  first=token  tokens
    [-.tokens +.tokens]
  ?.  ?=(%keyword -.first)
    ~|("expect keyword. token: {<-.first>}" !!)
  ?+    +.first  !!
      %let
    =^  jype  tokens
      (match-jype tokens)
    ?>  (got-punctuator -.tokens %'=')
    =^  val  tokens
      (match-inner-jock +.tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  jock  tokens
      (match-jock +.tokens)
    [[%let jype val jock] tokens]
  ::
      %if
    =^  cond  tokens
      (match-inner-jock tokens)
    =^  then  tokens
      (match-block [tokens %'{' %'}'] match-jock)
    =^  after-if  tokens
      (match-after-if-expression tokens)
    [[%if cond then after-if] tokens]
  ::
      %assert
    =^  cond  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  then  tokens
      (match-jock +.tokens)
    [[%assert cond then] tokens]
  ::
      %with
    =^  payload=jock  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  obj-or-lambda=jock  tokens
      (match-jock +.tokens)
    :_  tokens
    ^-  jock
    ?+  -.obj-or-lambda  !!
      %object  obj-or-lambda(q `payload)
      %lambda  obj-or-lambda(payload.p `payload)
    ==
  ::
      %object
    =/  has-name  ?=(^ (get-name -.tokens))
    =/  cor-name  (fall (get-name -.tokens) %$)
    =?  tokens  has-name
      +.tokens
    ?>  (got-punctuator -.tokens %'{')
    =.  tokens  +.tokens
    =^  core  tokens
      =|  core=(map term jock)
      |-
      ?:  (has-punctuator -.tokens %'}')
        [core +.tokens]
      =/  name=term
        (got-name -.tokens)
      ?>  (got-punctuator +<.tokens %'=')
      =^  jock  tokens
        (match-inner-jock +>.tokens)
      $(core (~(put by core) name jock))
    :_  tokens
    [%object cor-name core ~]
  ::
      %compose
    =^  p  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  q  tokens
      (match-jock +.tokens)
    :_  tokens
    [%compose p q]
  ::
      %match
  :: [%match value=jock cases=(map jock jock) default=(unit jock)]
  :: [%cases value=jock cases=(map jock jock) default=(unit jock)]
    ?:  (has-keyword -.tokens %case)
      =^  value  tokens
        (match-inner-jock +.tokens)
      =^  pairs  tokens
        (match-block [tokens %'{' %'}'] match-match)
      :_  tokens
      [%cases value -.pairs +.pairs]
    ?>  (has-keyword -.tokens %type)
    =^  value  tokens
      (match-inner-jock +.tokens)
    =^  pairs  tokens
      (match-block [tokens %'{' %'}'] match-match)
    :_  tokens
    [%match value -.pairs +.pairs]
  ::
      ?(%loop %defer)
    ?>  (got-punctuator -.tokens %';')
    =^  jock  tokens
      (match-jock +.tokens)
    :_  tokens
    ?:(?=(%loop +.first) [+.first jock] [+.first jock])
  ::
      %recur
    ?.  (has-punctuator -.tokens %'(')
      [[%call [%limb [%axis 0] ~] ~] tokens]
    ?:  (has-punctuator -.+.tokens %')')
      [[%call [%limb [%axis 0] ~] ~] +.+.tokens]
    =^  arg  tokens
      (match-inner-jock +.tokens)
    ?>  (got-punctuator -.tokens %')')
    [[%call [%limb [%axis %0] ~] `arg] +.tokens]
  ::
      %this
    [[%limb [%axis 1] ~] tokens]
  ::
      %eval
    =^  p  tokens
      (match-inner-jock tokens)
    =^  q  tokens
      (match-jock tokens)
    :_  tokens
    [%eval p q]
  ::
      %crash
    [[%crash ~] tokens]
  ==
::
++  match-jype
  |=  =tokens
  ^-  [jype (list token)]
  ?:  =(~ tokens)
    ~|("expect jype. token: ~" !!)
  =/  has-name  ?=(^ (get-name -.tokens))
  =/  nom  (fall (get-name -.tokens) %$)
  =?  tokens  has-name
    +.tokens
  ?:  (has-punctuator -.tokens %'*')
    [[%none ~]^nom +.tokens]
  ?:  (has-punctuator -.tokens %'@')
    [[%atom %number %.n]^nom +.tokens]
  ?:  (has-punctuator -.tokens %'?')
    [[%atom %loobean %.n]^nom +.tokens]
  ?:  &(has-name (has-punctuator -.tokens %':'))
    =^  jype  tokens
      (match-jype +.tokens)
    [jype(name nom) tokens]
  ?:  (has-punctuator -.tokens %'[')
    =^  r=(pair jype jype)  tokens
      %+  match-block  [tokens %'[' %']']
      |=  =^tokens
      =^  jype-one  tokens  (match-jype tokens)
      =^  jype-two  tokens  (match-jype tokens)
      ::  TODO: support implicit right-association
      [[jype-one jype-two] tokens]
    [[p.r q.r]^nom tokens]
  =^  jype-leaf  tokens
    (match-jype-leaf tokens)
  [jype-leaf^nom tokens]
::
++  match-jype-leaf
  |=  =tokens
  ^-  [jype-leaf (list token)]
  ?:  =(~ tokens)  ~|("expect jype-leaf. token: ~" !!)
  ?^  nom=(get-name -.tokens)
    [[%limb name+u.nom ~] +.tokens]
  ?:  (has-punctuator -.tokens %'&')
    =^  axis-lit  tokens
      (match-axis tokens)
    [[%limb axis-lit ~] tokens]
  ?:  (has-punctuator -.tokens %'*')
    [[%none ~] +.tokens]
  ?:  (has-punctuator -.tokens %'@')
    [[%atom %number %.n] +.tokens]
  ?:  (has-punctuator -.tokens %'?')
    [[%atom %loobean %.n] +.tokens]
  ?:  (has-punctuator -.tokens %'(')
    =^  lambda-argument  tokens
      (match-lambda-argument tokens)
    [[%core %&^lambda-argument ~] tokens]
  [[%none ~] tokens]
::
++  match-lambda
  |=  =tokens
  ^-  [lambda (list token)]
  ?:  =(~ tokens)  ~|("expect lambda. token: ~" !!)
  =^  lambda-argument  tokens
    (match-lambda-argument tokens)
  =^  body  tokens
    (match-block [tokens %'{' %'}'] match-jock)
  [[lambda-argument body ~] tokens]
::
++  match-lambda-argument
  |=  =tokens
  ^-  [lambda-argument (list token)]
  ?:  =(~ tokens)  ~|("expect lambda-argument. token: ~" !!)
  %+  match-block  [tokens %'(' %')']
  |=  =^tokens
  ^-  [lambda-argument (list token)]
  =^  inp  tokens
    (match-jype tokens)
  ?>  (got-punctuator -.tokens %'-')
  ?>  (got-punctuator -.+.tokens %'>')
  =^  out  tokens
    (match-jype +.+.tokens)
  [[`inp out] tokens]
::
++  match-comparator
  |=  =tokens
  ^-  [comparator (list token)]
  =>  |%
      ++  mini  ?(%'<' %'>' %'=' %'!')
      ++  comp  (perk %'<' %'>' %'=' %'!' ~)
      --
  ?~  tokens  ~|("expect comparator. token: ~" !!)
  ?.  ?=(%punctuator -.i.tokens)
    ~|("expect punctuator. token: {<-.i.tokens>}" !!)
  =/  cm1=(unit mini)
    (rust (trip +.i.tokens) (full comp))
  ?~  cm1
    ~|("match-comparator failed: {<i.tokens>}" !!)
  ?~  t.tokens
    [;;(comparator u.cm1) t.tokens]
  ?.  ?=(%punctuator -.i.t.tokens)
    [;;(comparator u.cm1) t.tokens]
  =/  cm2=(unit mini)
    (rust (trip +.i.t.tokens) (full comp))
  ?~  cm2
    [;;(comparator u.cm1) t.tokens]
  =/  final  (cat 3 u.cm1 u.cm2)
  [;;(comparator final) t.t.tokens]
::
++  match-after-if-expression
  |=  =tokens
  ^-  (pair after-if-expression (list token))
  ?~  tokens
    ~|("expect after-if. token: ~" !!)
  ?.  ?=(%keyword -.-.tokens)
    ~|("expect keyword. token: {<-.i.tokens>}" !!)
  ?.  =(%else +.-.tokens)
    ~|("expect %else. token: {<+.-.tokens>}" !!)
  =>  .(tokens `(list token)`+.tokens)
  ?:  =(~ tokens)
    ~|("expect more. tokens: ~" !!)
  ?:  (has-punctuator -.tokens %'{')
    =^  else  tokens
      (match-block [tokens %'{' %'}'] match-jock)
    [[%else else] tokens]
  ?.  (has-keyword -.tokens %if)
    ~|("expect %if. token: {<+.-.tokens>}" !!)
  (match-else-if +.tokens)
::
++  match-else-if
  |=  =tokens
  ^-  [else-if-expression (list token)]
  =^  cond  tokens
    (match-inner-jock tokens)
  =^  then  tokens
    (match-block [tokens %'{' %'}'] match-jock)
  =^  after-if  tokens
    (match-after-if-expression tokens)
  [[%else-if cond then after-if] tokens]
::
++  match-literal
  |=  =tokens
  ^-  [[%atom jatom] (list token)]
  ?~  tokens  ~|("expect literal. token: ~" !!)
  ?.  ?=(%literal -.-.tokens)
    ~|("expect literal. token: {<-.-.tokens>}" !!)
  [[%atom +.-.tokens] +.tokens]
::
:: ++  match-symbol
::   |=  =tokens
::   ^-  [[%symbol jatom] (list token)]
::   ?~  tokens  ~|("expect symbol. token: ~" !!)
::   ?.  ?=(%symbol -.-.tokens)
::     ~|("expect symbol. token: {<-.-.tokens>}" !!)
::   [[%symbol +.-.tokens] +.tokens]
::
++  match-name
  |=  =tokens
  ^-  [[%limb (list jlimb)] (list token)]
  ?~  tokens  ~|("expect name. token: ~" !!)
  ?.  ?=(%name -.-.tokens)
    ~|("expect name. token: {<-.-.tokens>}" !!)
  [[%limb [%name +.-.tokens]~] +.tokens]
::
++  match-block
  |*  [[=tokens start=punctuator end=punctuator] gate=$-(tokens [* tokens])]
  ?>  (got-punctuator -.tokens start)
  =^  output  tokens
    (gate +.tokens)
  ?>  (got-punctuator -.tokens end)
  [output +.tokens]
::
++  match-match
  |=  =tokens
  ^-  [[(map jock jock) (unit jock)] (list token)]
  ?:  =(~ tokens)  ~|("expect map. token: ~" !!)
  =|  fall=(unit jock)
  =^  cf=[(map jock jock) (unit jock)]  tokens
    =|  duo=(list (pair jock jock))
    |-  ^-  [[(map jock jock) (unit jock)] (list token)]
    ?:  (has-punctuator -.tokens %'}')
      [[(malt duo) fall] tokens]
    :: default case, must be last
    ?:  (has-punctuator -.tokens %'_')
      ?>  (got-punctuator -.+.tokens %'-')
      ?>  (got-punctuator -.+.+.tokens %'>')
      =^  jock  tokens  `[jock (list token)]`(match-jock `(list token)`+.+.+.tokens)
      ?>  (got-punctuator -.tokens %';')
      =.  tokens  +.tokens
      ?>  (has-punctuator -.tokens %'}')  :: no trailing tokens in case block
      =.  fall  `jock
      [[(malt duo) fall] tokens]
    :: regular case
    =^  jock-1  tokens  (match-jock tokens)
    ?>  (got-punctuator -.tokens %'-')
    ?>  (got-punctuator -.+.tokens %'>')
    =^  jock-2  tokens  (match-jock +.+.tokens)
    ?>  (got-punctuator -.tokens %';')
    =.  tokens  +.tokens
    $(duo [[jock-1 jock-2] duo])
  =/  cases  -.cf
  =/  fall  +.cf
  [[cases fall] tokens]
::
++  got-jatom-number
  |=  =tokens
  ^-  @
  ?~  tokens  ~|("expect literal. token: ~" !!)
  ?.  ?=(%literal -.i.tokens)
    ~|("expect literal or symbol. token: {<-.i.tokens>}" !!)
  =/  p=jatom  +.i.tokens
  ?.  ?=(%number -.-.p)
    ~|("expect number or symbol. token: {<-.p>}" !!)
  +.-.p
::
++  got-name
  |=  =token
  ^-  term
  ?.  ?=(%name -.token)
    ~|("expect name. token: {<-.token>}" !!)
  +.token
::
++  get-name
  |=  =token
  ^-  (unit term)
  ?.  ?=(%name -.token)  ~
  [~ +.token]
::
++  got-punctuator
  |=  [=token punc=punctuator]
  ^-  ?
  ?.  ?=(%punctuator -.token)
    ~|("expect punctuator. token: {<-.token>}" !!)
  ?.  =(+.token punc)
    ~|("expect punctuator {<+.token>} to be {<punc>}" !!)
  %.y
::
++  has-punctuator
  |=  [=token punc=punctuator]
  ^-  ?
  ?.  ?=(%punctuator -.token)  %.n
  =(+.token punc)
::
++  has-keyword
  |=  [=token key=keyword]
  ^-  ?
  ?.  ?=(%keyword -.token)  %.n
  =(+.token key)
--
::
::  3: compile jock -> nock
::
|%
+$  nock
  $+  nock
  $^  [p=nock q=nock]                           ::  autocons
  $%  [%1 p=*]                                  ::  constant
      [%2 p=nock q=nock]                        ::  compose
      [%3 p=nock]                               ::  cell test
      [%4 p=nock]                               ::  increment
      [%5 p=nock q=nock]                        ::  equality test
      [%6 p=nock q=nock r=nock]                 ::  if, then, else
      [%7 p=nock q=nock]                        ::  serial compose
      [%8 p=nock q=nock]                        ::  push onto jypect
      [%9 p=@ q=nock]                           ::  select arm and fire
      [%10 p=[p=@ q=nock] q=nock]               ::  edit
      [%11 p=@ q=nock]                          ::  static hint
      [%0 p=@]                                  ::  axis select
  ==
::
++  untyped-j  [%none ~]^%$
++  lam-j
  |=  [arg=lambda-argument payload=(unit jype)]
  ^-  jype
  [%core [%& arg] payload]^%$
::
++  jwing
  $@  @
  [arm-axis=@ core-axis=@]
::
++  jt
  |_  t=jype
  ++  get-limb
    |=  lis=(list jlimb)
    ^-  (pair jype (list jwing))
    |^
    =/  res=(list jwing)  ~
    =/  ret=jwing  1
    ?:  =(~ lis)  !!
    |-
    ?~  lis
      :-  t
      ?:  =(ret 1)
        ?~  res  ret^~
        (flop res)
      ?~  res  ret^~
      !!
    =/  axi=(unit jwing)
      ?:  ?=(%name -.i.lis)
        (axis-at-name +.i.lis)
      `+.i.lis
    ?~  axi  !!
    ?^  u.axi
      ?~  new-t=(type-at-axis (peg +.u.axi -.u.axi))
        ~|  no-type-at-axis+[axi t]
        !!
      $(lis t.lis, t u.new-t, res [u.axi res])
    ?~  new-t=(type-at-axis u.axi)
      !!
    ?^  ret
      ::  TODO: in order to support additional limbs
      ::  after a core resolution, we require the return type
      ::  to be a (list jwing)
      !!
    =.  ret  (peg ret u.axi)
    ?>  (lth ret (bex 63))
    $(lis t.lis, t u.new-t)
    ::
    ++  type-at-axis
      |=  axi=@
      ^-  (unit jype)
      ?:  =(axi 1)
        `t
      =/  axi-lis  (flop (snip (rip 0 axi)))
      ~|  type-at-axis+axi-lis
      |-   ^-  (unit jype)
      ?~  axi-lis  `t(name %$)
      ?@  -<.t
        ?:  =(~ t.axi-lis)  `t
        ?.  ?=(%core -.p.t)
          ~|  t
          !!
        $(t (~(call-core jt untyped-j) p.t))
      ?:  =(0 i.axi-lis)
        $(axi-lis t.axi-lis, t p.t)
      $(axi-lis t.axi-lis, t q.t)
    ::
    ++  axis-at-name
      |=  nom=term
      =/  axi=jwing  [0 1]
      |-  ^-  (unit jwing)
      ?:  =(name.t nom)
        ?:  =(-.axi 0)
          `+.axi
        `axi
      ?@  -<.t
        ?.  ?=(%core -.p.t)
          ~
        ?:  ?=(%& -.p.p.t)
          $(t (~(call-core jt untyped-j) p.t))
        ?.  =(-.axi 0)  ~
        =/  bat  $(t (~(call-core jt untyped-j) p.t(q ~)), -.axi 1)
        ?~  bat
          ?~  q.p.t
            ~
          $(t u.q.p.t, +.axi +((mul +.axi 2)))
        ?~  q.p.t
          bat
        `[(peg 2 -.u.bat) +.axi]
      ?:  !=(name.t %$)  ~
      =/  l
        ?:  =(-.axi 0)
          $(t p.t, +.axi (mul +.axi 2))
        $(t p.t, -.axi (mul -.axi 2))
      ?~  l
        =/  r
          ?:  =(-.axi 0)
            $(t q.t, +.axi +((mul +.axi 2)))
          $(t q.t, -.axi +((mul -.axi 2)))
        r
      l
    --
  ::
  ++  find-buc
    |.  ^-  (unit [jype @])
    =/  axi  1
    |-  ^-  (unit [jype @])
    ?@  -<.t
      ?.  ?=(%core -.p.t)
        ~
      ?.  ?=(%& -.p.p.t)
        ~
      `[t axi]
    =/  l  $(t p.t, axi (mul axi 2))
    ~|  [%l l]
    ?~  l
      =/  r  $(t q.t, axi +((mul axi 2)))
      ~|  [%r r]
      r
    l
  ::
  ++  call-core
    |=  [%core p=core-body q=(unit jype)]
    ^-  jype
    ?:  ?=(%& -.p)
      ~|  %call-lambda
      =/  body-type
        ::  TODO: need to put the return type here, with all names stripped
        untyped-j
      ?~  inp.p.p
        ?~  q
          body-type
        [body-type u.q]^%$
      ?~  q
        [body-type u.inp.p.p]^%$
      [body-type [u.inp.p.p u.q]^%$]^%$
    ~|  %call-object
    =/  cor-lis=(list [name=term val=jype])  ~(tap by p.p)
    ?>  ?=(^ cor-lis)
    =/  ret-jyp=jype  val.i.cor-lis(name name.i.cor-lis)
    =>  .(cor-lis `(list [name=term val=jype])`+.cor-lis)
    |-
    ?~  cor-lis
      ?~  q
        ret-jyp
      [ret-jyp u.q]^%$
    =.  name.val.i.cor-lis  name.i.cor-lis
    %_  $
      cor-lis  t.cor-lis
      ret-jyp  (~(cons jt val.i.cor-lis) ret-jyp)
    ==
  ::
  ++  cons
    |=  q=jype
    ^-  jype
    [t q]^%$
  ::
  ++  unify
    |=  v=jype
    ^-  (unit jype)
    ?^  -<.t
      ?@  -<.v
        ?:  =(%none -.p.v)
          `t
        ~
      =+  [p q]=[(~(unify jt p.t) p.v) (~(unify jt q.t) q.v)]
      ?:  ?|(?=(~ p) ?=(~ q))
        ~
      `[[u.p u.q] name.t]
    ?^  -<.v
      ?:  =(%none -.p.t)
        `v(name name.t)
      ~
    :-  ~
    :_  name.t
    ?:  =(%none -.p.t)
      p.v
    ?:  =(%none -.p.v)
      p.t
    ?>  =(-.p.t -.p.v)
    p.t
  --
::
++  cj
  |_  jyp=jype
  ::
  ++  mint
    |=  j=jock
    ^-  [nock jype]
    ?-    -.j
        ^
      ~|  %pair-p
      =+  [p p-jyp]=$(j p.j)
      ~|  %pair-q
      =+  [q q-jyp]=$(j q.j)
      [[p q] (~(cons jt p-jyp) q-jyp)]
    ::
        %let
      ~|  %let-value
      =+  [val val-jyp]=$(j val.j)
      =.  jyp
        =/  inferred-type
          (~(unify jt type.j) val-jyp)
        ?~  inferred-type
          ~|  '%let: value type does not nest in declared type'
          ~|  [val+val-jyp typ+type.j]
          !!
        (~(cons jt u.inferred-type) jyp)
      ~|  %let-next
      =+  [nex nex-jyp]=$(j next.j)
      [[%8 val nex] nex-jyp]
    ::
        %edit
      =/  [typ=jype axi=@]
        =/  res  (~(get-limb jt jyp) limb.j)
        ?>  ?=(^ q.res)
        ?>  ?=(@ i.q.res)
        [p.res i.q.res]
      ~|  %edit-value
      =+  [val val-jyp]=$(j val.j)
      ~|  %edit-next
      ?>  ?=(^ (~(unify jt typ) val-jyp))
      =+  [nex nex-jyp]=$(j next.j)
      [[%7 [%10 [axi val] %0 1] nex] nex-jyp]
    ::
        %increment
      ~|  %increment
      =^  val  jyp  $(j val.j)
      [[%4 val] jyp]
    ::
        %cell-check
      ~|  %cell-check
      =^  val  jyp  $(j val.j)
      [[%3 val] [%atom %loobean %.n]^%$]
    ::
        %compose
      ~|  %compose-p
      =^  p  jyp
        $(j p.j)
      ~|  %compose-q
      =+  [q q-jyp]=$(j q.j)
      [[%7 p q] q-jyp]
    ::
        %object
      ~|  %object
      =/  pay=(unit (pair nock jype))
        ?~  q.j
          ::  TODO: should I put `jyp here?
          ~
        `$(j u.q.j)
      =/  exe-jyp=jype
        ::  TODO: should we default to `jyp?
        [%core %|^(~(run by p.j) |=(* untyped-j)) ?~(pay ~ `q.u.pay)]^%$
      =/  lis=(list [name=term val=jock])  ~(tap by p.j)
      ?>  ?=(^ lis)
      =+  [cor-nok one-jyp]=$(j val.i.lis, jyp exe-jyp)
      =.  name.one-jyp  name.i.lis
      =|  cor-jyp=(map term jype)
      =.  cor-jyp  (~(put by cor-jyp) name.i.lis one-jyp)
      =>  .(lis `(list [name=term val=jock])`+.lis)
      |-
      ?~  lis
        ?~  pay
          :-  [%1 cor-nok]
          [%core %|^cor-jyp ~]^%$
        :-  [[%1 cor-nok] p.u.pay]
        [%core %|^cor-jyp `q.u.pay]^%$
      =+  [mor-nok mor-jyp]=^$(j val.i.lis, jyp exe-jyp)
      %_    $
        lis      t.lis
        cor-nok  [mor-nok cor-nok]
        cor-jyp  (~(put by cor-jyp) name.i.lis mor-jyp)
      ==
    ::
        %eval
      ~|  %eval-p
      =+  [p p-jyp]=$(j p.j)
      ~|  %eval-q
      =+  [q q-jyp]=$(j q.j)
      [[%2 p q] untyped-j]
    ::
        %loop
      ~|  %loop-next
      =.  jyp  (lam-j [~ untyped-j] `jyp)
      =+  [nex nex-jyp]=$(j next.j)
      :_  jyp
      [%8 [%1 nex] %9 2 %0 1]
    ::
        %defer
      ~|  %defer-next
      =.  jyp  (lam-j [~ untyped-j] `jyp)
      =+  [nex nex-jyp]=$(j next.j)
      :_  jyp
      [[%1 nex] %0 1]
    ::
        %if
      =+  [cond cond-jyp]=$(j cond.j)
      =+  [then then-jyp]=$(j then.j)
      =+  [aftr aftr-jyp]=(mint-after-if after.j)
      [[%6 cond then aftr] [%fork then-jyp aftr-jyp]^%$]
    ::
        %assert
      =+  [cond cond-jyp]=$(j cond.j)
      =+  [then then-jyp]=$(j then.j)
      [[%6 cond then [%0 0]] then-jyp]
    ::
        %match
      =+  [val val-jyp]=$(j value.j)
      =/  cases=(list (pair jock jock))  ~(tap by cases.j)
      ?:  =(~ cases)  ~|("expect more. cases: ~" !!)
      :_  jyp
      ^-  nock
      :+  %8
        [%1 val]
      =/  cell=nock
        ?~  default.j  [%0 0]
        =+  [def def-jyp]=$(j u.default.j)
        [%7 [%0 3] [%1 def]]
      |-
      ?~  cases  cell
      =+  [jip jip-jyp]=^$(j -.-.cases)
      =+  [jok jok-jyp]=^$(j +.-.cases)
      %=  $
        cell  :^    %6
                  ^-  nock
                  (hunt-type jip-jyp)
                ^-  nock
                [%7 [%0 3] %1 `nock`jok]
              cell
        cases  +.cases
      ==
    ::
        %cases
      =+  [val val-jyp]=$(j value.j)
      =/  cases=(list (pair jock jock))  ~(tap by cases.j)
      ?:  =(~ cases)  ~|("expect more. cases: ~" !!)
      :_  jyp
      ^-  nock
      :+  %8
        [%1 val]
      =/  cell=nock
        ?~  default.j  [%0 0]
        =+  [def def-jyp]=$(j u.default.j)
        [%7 [%0 3] [%1 def]]
      |-
      ?~  cases  cell
      =+  [jok jok-jyp]=^$(j +.-.cases)
      %=  $
        cell  :^    %6
                  ^-  nock
                  (hunt-value -.-.cases)
                ^-  nock
                [%7 [%0 3] %1 `nock`jok]
              cell
        cases  +.cases
      ==
    ::
        %call
      ?+    -.func.j  !!
          %limb
        =/  old-jyp  jyp
        ~|  %call-limb
        =/  limbs=(list jlimb)  p.func.j
        ?>  ?=(^ limbs)
        =/  [typ=jype ljw=(list jwing)]
          ?.  &(?=(%axis -.i.limbs) =(+.i.limbs 0))
            (~(get-limb jt jyp) p.func.j)
          ::  special case: we're looking for $
          =/  ret  (~(find-buc jt jyp))
          ?~  ret
            ~|  "couldn't find $"
            ~|  jyp
            !!
          [-.u.ret [2 +.u.ret]^~]
        |-
        ?^  -<.typ
          ~|  typ
          ~|  limbs
          !!
        ?.  ?=(%core -.p.typ)
          !!
        :_  ?:  ?=(%& -.p.p.typ)
              out.p.p.p.typ
            ::  TODO: find arm output in core
            untyped-j
        ?~  arg.j
          (resolve-wing ljw)
        :+  %8
          (resolve-wing ljw)
        =+  [arg arg-jyp]=^$(j u.arg.j, jyp old-jyp)
        [%9 2 %10 [6 [%7 [%0 3] arg]] %0 2]
      ::
          %lambda
        ~|  %call-lambda
        =+  [lam lam-jyp]=$(j func.j)
        :_  out.arg.p.func.j
        :+  %7
          lam
        ?~  arg.j
          [%9 2 %0 1]
        =+  [arg arg-jyp]=$(j u.arg.j)
        [%9 2 %10 [6 [%7 [%0 3] arg]] %0 1]
      ==
    ::
        %compare
      :_  [%atom %loobean %.n]^%$
      ?-    comp.j
          %'=='
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%5 a b]
      ::
          %'!='
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%6 [%5 a b] [%1 1] %1 0]
      ::
      ::  TODO: figure out jets and then fix this.
          %'>'
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%11 %gth [%0 0]]
      ::
          %'<'
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%11 %lth [%0 0]]
      ::
          %'<='
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%11 %lte [%0 0]]
      ::
          %'>='
        =+  [a a-jyp]=$(j a.j)
        =+  [b b-jyp]=$(j b.j)
        [%11 %gte [%0 0]]
      ==
    ::
        %limb
      ~|  %limb
      =/  res=(pair jype (list jwing))
        (~(get-limb jt jyp) p.j)
      [(resolve-wing q.res) p.res]
    ::
        %lambda
      ~|  %enter-lambda
      ?>  ?=(^ inp.arg.p.j)
      =/  pay=(unit (pair nock jype))
        ?~  payload.p.j  ~
        `$(j u.payload.p.j)
      =/  input-default  (type-to-default u.inp.arg.p.j)
      ~|  %enter-lambda-body
      ::  TODO: wtf?
      =/  lam-jyp  (lam-j arg.p.j ?~(pay `jyp `q.u.pay))
      ::=/  lam-jyp  (lam-j arg.p.j `jyp)
      =+  [body body-jyp]=$(j body.p.j, jyp lam-jyp)
      ?~  pay
        :_  (lam-j arg.p.j `jyp)
        [%8 input-default [%1 body] [%0 1]]
      :_  (lam-j arg.p.j `q.u.pay)
      [%8 input-default [%1 body] p.u.pay]
    ::
        %type
      ~|  %type
      [[%0 0] jyp]
    ::
        %atom
      ~|  [%atom +.-.+.j]
      :-  [%1 +.-.+.j]
      [^-(jype-leaf [%atom -.-.+.j +.+.j]) %$]
    ::
        %crash
      ~|  %crash
      [[%0 0] jyp]
    ==
  ::
  ++  mint-after-if
    |=  j=after-if-expression
    ^-  [nock jype]
    ?-    -.j
      %else  (mint then.j)
    ::
        %else-if
      =+  [cond cond-jyp]=(mint cond.j)
      =+  [then then-jyp]=(mint then.j)
      =+  [aftr aftr-jyp]=$(j after.j)
      [[%6 cond then aftr] [%fork then-jyp aftr-jyp]^%$]
    ==
  ::
  ++  resolve-wing
    |=  ljw=(list jwing)
    ^-  nock
    ?>  ?=(^ ljw)
    =/  last=nock
      ?@  i.ljw
        [%0 i.ljw]
      [%9 arm-axis.i.ljw %0 core-axis.i.ljw]
    =>  .(ljw `(list jwing)`t.ljw)
    |-
    ?~  ljw  last
    =/  val=nock
      =+  ?@  i.ljw
            [%0 i.ljw]
          [%9 arm-axis.i.ljw %0 core-axis.i.ljw]
      ?@  i.ljw
        ?:  =(i.ljw %1)
          last
        [%7 last -]
      [%8 last -]
    ?~  t.ljw  val
    $(ljw t.ljw, last val)
  ::
  ++  type-to-default
    |=  j=jype
    ^-  nock
    ?^  -.-.j    [$(j p.j) $(j q.j)]
    ?-    -.p.j
    ::
        %atom      [%1 0]
    ::
        %core
      ?:  ?=(%| -.p.p.j)
        [%1 0]
      ?~  inp.p.p.p.j
        [%0 0]
      [[%1 $(j u.inp.p.p.p.j)] [%0 0]]
    ::
        %limb
      $(j p:(~(get-limb jt jyp) p.p.j))
    ::
        %fork      $(j p.p.j)
    ::
        %none      [%1 0]
    ::
        :: %ring      $(j `base-jype-leaf`p.p.j)
        %ring      $(j q.p.j)  :: TODO seems like we should be able to get to base case but it's blocked on some nest-fail type issue
    ::
        %link      [%0 0]
    ==
  ::
  :: +hunt-type: make a $nock to test whether jock nests in jype
  :: We check only four cases:  %none and %symbol to
  :: bottom out, and %fork and nothing (cell) to continue.
  :: TODO: provide atom type and aura nesting for convenience
  ++  hunt-type
    =|  axis=_2
    |=  =jype
    ^-  nock
    ::  cell case
    ?^  -.-.jype
      :: cell case
      ^-  nock
      :^    %6
          [%3 %0 axis]
        ^-  nock
        :^    %6
            `nock`[$(axis (mul 2 axis), jype `^jype`-.-.jype)]
          `nock`[$(axis +((mul 2 axis)), jype `^jype`-.+.jype)]
        [%1 1]
      [%1 1]
    ::  atom case
    ?+    -.-.jype
      ::  default case:  %atom, %core, %limb
        ~|((crip "hunt: can't match {<`@tas`-.-.jype>}") !!)
      ::
        %atom
      ?>  +.+.-.jype
      [%5 [%1 q.p.jype] %0 axis]
      ::
        %fork
      ~|('hunt: can\'t match fork' !!)
      ::
        %none
      ~|('hunt: can\'t match untyped' !!)
    ==
  ::
  :: +hunt-value: make a $nock to test whether jock matches value
  :: We check only atom cases for now (and cells like paths)
  ++  hunt-value
    =|  axis=_2
    |=  =jock
    ^-  nock
    ::  cell case
    ?^  -.jock
      :: cell case
      ^-  nock
      :^    %6
          [%3 %0 axis]
        ^-  nock
        :^    %6
            `nock`[$(axis (mul 2 axis), jock `^jock`-.jock)]
          `nock`[$(axis +((mul 2 axis)), jock `^jock`+.jock)]
        [%1 1]
      [%1 1]
    ::  atom case
    ?+    -.jock
      ::  default case:  %core, %limb
        ~|((crip "hunt: can't match {<`@tas`-.-.jock>}") !!)
      ::
        %atom
      [%5 [%1 `@`+.p.jock] %0 axis]
    ==
  --
--
