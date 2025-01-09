=<  |%
    ++  tokenize
      |=  txt=@
      ^-  jokens
      (rash txt parse-tokens)
    ::
    ++  jeam
      |=  txt=@
      ^-  jock
      =+  [jok jokens]=(match-jock (rash txt parse-tokens))
      ?.  ?=(~ jokens)
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
      %func
      %lambda
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
+$  jpunc
  $+  jpunc
  $?  %'.'  %';'  %','  %':'  %'&'  %'$'
      %'@'  %'?'  %'!'  %'(('
      %'('  %')'  %'{'  %'}'  %'['  %']'
      %'='  %'<'  %'>'
      %'+'  %'-'  %'*'  %'/'  %'_'
  ==
::
+$  jatom
  $+  jatom
  $~  [[%loobean p=%.n] q=%.n]
  $:  $%  [%string p=term]
          [%number p=@ud]
          [%hexadecimal p=@ux]
          [%loobean p=?]
      ==
    q=?(%.y %.n)
  ==
::
+$  joken
  $+  joken
  $%  [%keyword keyword]
      [%punctuator jpunc]
      [%literal jatom]
      [%name term]
      [%type cord]
  ==
::
+$  jokens  (list joken)
::
++  val   %+  cold  ~
          ;~  plug  fas  fas
            (star ;~(pose prn (mask [`@`0x9 ~])))
            (just `@`10)
          ==
++  var   %+  cold  ~
          ;~  plug  ;~(plug fas tar)
              (star ;~(less ;~(plug tar fas) ;~(pose prn (mask [`@`0x9 `@`0xa ~]))))
              ;~(plug tar fas)
          ==
++  gav  (cold ~ (star ;~(pose val var gah)))
++  gae  ;~(pose gav (easy ~))
::
++  tokenize
  =|  fun=?(%.y %.n)
  |%
  ++  string             (stag %string (ifix [soq soq] sym))
  ++  number             (stag %number dem:ag)
  ++  hexadecimal        (stag %hexadecimal ;~(pfix (jest %'0x') hex))
  ++  loobean
    %+  stag  %loobean
    ;~(pose (cold %.y (jest %true)) (cold %.n (jest %false)))
  ::
  ++  tagged-literal     (stag %literal (hart literal %.n))
  ++  literal            ;~(pose loobean hexadecimal number string)
  ++  tagged-symbol      (stag %literal (hart symbol %.y))
  ++  symbol             ;~(pfix cen literal)
  ::  add a suffix label
  ++  hart
    |*  [sef=rule gob=*]
    |=  tub=nail
    =+  vex=(sef tub)
    ?~  q.vex
      vex
    [p=p.vex q=[~ u=[p=[p.u.q.vex gob] q=q.u.q.vex]]]
  ::
  ::  A name can resolve either to a simple name or to a function invocation,
  ::  if it is followed by no whitespace and an open parenthesis.  In that case,
  ::  the goal is to parse a function call into the pseudo-punctuator '(('.
  ::  This only happens if there is a term immediately preceding the '(',
  ::    e.g. foo(bar)  ->  'foo' '((' 'bar' ')'
  ++  tagged-name        (stag %name name)                :: [%name term]
  ++  name               sym                              :: term
  ::
  ++  tagged-type        (stag %type type)                :: [%type 'Cord']
  ++  type               alu                              :: Cord
  ++  alu                %+  cook                         :: Ulll
                             |=(a=tape (rap 3 ^-((list @) a)))
                         ;~(plug hig (star low))
  ::
  ++  tagged-keyword     (stag %keyword keyword)
  ++  keyword
    %-  perk
    :~  %let  %func  %lambda  %if  %else  %crash  %assert
        %object  %compose  %loop  %defer
        %recur  %match  %eval  %with  %this
        %type  %case
    ==
  ::
  ++  tagged-punctuator  %+  cook
                           |=  =joken
                           ^-  ^joken
                           ?.  &(fun =([%punctuator %'('] joken))
                             joken
                          ::  =.  fun  %.n
                           [%punctuator `jpunc`%'((']
                         (stag %punctuator punctuator)
  ++  punctuator
    %-  perk
    :~  %'.'  %';'  %','  %':'  %'&'  %'$'
        %'@'  %'?'  %'!'  :: XXX exclude %'((' which is a pseudo-punctuator
        %'('  %')'  %'{'  %'}'  %'['  %']'
        %'='  %'<'  %'>'
        %'+'  %'-'  %'*'  %'/'  %'_'
    ==
  ::
  ::  The parser's precedence rules:
  ::  1.  Keywords
  ::  2.  Names, because of foo(bar) function calls
  ::  3.  Punctuators, same reason
  ::  4.  Types
  ::  5.  Symbols
  ::  6.  Literals
  :: +$  upcast  [term *]
  ++  tokens
    ;~  pose
        (knee *(list joken) |.(~+(;~(plug tagged-keyword ;~(pfix gav tokens(fun %.n))))))
        (knee *(list joken) |.(~+(;~(plug tagged-symbol ;~(pfix gav tokens(fun %.n))))))
        (knee *(list joken) |.(~+(;~(plug tagged-literal ;~(pfix gav tokens(fun %.n))))))
        (knee *(list joken) |.(~+(;~(plug tagged-name ;~(pfix gav tokens(fun %.y))))))
        (knee *(list joken) |.(~+(;~(plug tagged-punctuator ;~(pfix gav tokens(fun %.n))))))
        (knee *(list joken) |.(~+(;~(plug tagged-type ;~(pfix gav tokens(fun %.n))))))
        (easy ~)
    ==
  ::
  --
::
++  parse-tokens
  |=  =nail
  ^-  (like (list joken))
  %.  nail
  %-  full
  (ifix [gae gae] tokens:tokenize)
--
::
=>
::
::  2: jock abstract syntax tree and parser
::
::  The jock abstract syntax tree (AST) is produced from the joken list.  A jock
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
      [%func type=jype body=jock next=jock]
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
      [%atom p=jatom]
      [%list type=jype-leaf val=(list jock)]
      [%set type=jype-leaf val=(set jock)]
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
+$  jype-leaf
  $%  ::  %atom is a basic numeric type with constant flag (%.y = constant)
      [%atom p=jatom-type q=?(%.y %.n)]
      ::  %core is a callable function with arguments and returns
      [%core p=core-body q=(unit jype)]
      ::  %limb is a reference to a limb in the current core
      [%limb p=(list jlimb)]
      ::  %fork is a branch point (as in an if-else)
      [%fork p=jype q=jype]
      ::  %list
      [%list type=jype]
      ::  %set
      [%set type=jype]
      ::  %none is a null type (as for undetermined variable labels)
      [%none ~]
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
  |=  =jokens
  ^-  [jock (list joken)]
  ?:  =(~ jokens)
    ~|("expect jock. joken: ~" !!)
  =^  jock  jokens
    ?-    -<.jokens
        %literal
      ::  TODO: check if we're in a compare
      (match-literal jokens)
    ::
      %name        (match-start-name jokens)
      %keyword     (match-keyword jokens)
      %punctuator  (match-start-punctuator jokens)
      %type        !!  ::(match-metatype jokens)  :: shouldn't reach this way
    ==
  [jock jokens]
::
++  match-inner-jock
  |=  =jokens
  ^-  [jock (list joken)]
  ?~  jokens  ~|("expect inner-jock. joken: ~" !!)
  ?:  ?|  (has-keyword -.jokens %object)
          (has-keyword -.jokens %with)
          (has-keyword -.jokens %this)
          (has-keyword -.jokens %crash)
      ==
    (match-jock jokens)
  :: ?:  (has-punctuator -.jokens %'{')
  ::   =>  .(jokens `(list joken)`jokens)  :: static list typing
  ::   =^  jock  jokens
  ::     (match-jock jokens)
  ::   [jock +.jokens]
  ~&  inner-jock+[jokens]
  ?+    -.i.jokens  !!
      %literal
    ::  TODO: check if we're in a compare
    (match-literal jokens)
  ::
    %name        (match-start-name jokens)
    %punctuator  (match-start-punctuator jokens)
    %type        !!  ::(match-metatype jokens)  :: shouldn't reach this way
  ==
::
++  match-jock-args
  |=  =jokens
  ^-  [jock (list joken)]
  ?:  =(~ jokens)  ~|("expect inner-jock. joken: ~" !!)
  :: =>  .(jokens `(list joken)`jokens)  :: static list typing
  =^  jock  jokens
    (match-jock jokens)
  [jock +.jokens]
::
++  match-pair-inner-jock
  |=  =jokens
  ^-  [jock (list joken)]
  ?~  jokens  ~|("expect jock. joken: ~" !!)
  ~&  match-pair-inner-jock+[jokens]
  ?:  (has-punctuator -.jokens %'(')
    =>  .(jokens `(list joken)`+.jokens)
    =^  jock-one  jokens
      (match-inner-jock jokens)
    ~&  jock-one+jock-one
    ?:  (has-punctuator -.jokens %')')
      [jock-one +.jokens]
    =/  first=?  %.y
    |-  ^-  [jock (list joken)]
    =^  jock-nex  jokens
      (match-inner-jock jokens)
    ~&  jock-nex+[jock-nex jokens]
    =/  pun  (has-punctuator -.jokens %')')
    ?:  &(first pun)
      [[jock-one jock-nex] +.jokens]
    ?:  pun
      [jock-nex +.jokens]
    ?:  first
      =^  pairs  jokens
        $(first %.n)
      [[jock-one jock-nex pairs] jokens]
    ~&  fallthrough+jokens
    =^  pairs  jokens
      $
    [[jock-nex pairs] jokens]
  ?+  -.i.jokens  !!
    %literal     (match-literal jokens)
    %name        (match-start-name jokens)
    %punctuator  (match-start-punctuator jokens)
    %type        !!  ::(match-metatype jokens)  :: shouldn't reach this way
  ==
::
++  match-start-punctuator
  |=  =jokens
  ^-  [jock (list joken)]
  ?:  =(~ jokens)  ~|("expect jock. joken: ~" !!)
  =/  first=joken  -.jokens
  ?.  ?=(%punctuator -.first)
    ~|("expect start-punctuator. joken: {<-.first>}" !!)
  =.  jokens  +.jokens
  ?+    +.first  ~|(jokens !!)
  ::  Increment  +(0)
      %'+'
    =^  jock  jokens
      (match-block [jokens %'(' %')'] match-inner-jock)
    ::  TODO: check if we're in a compare
    [[%increment jock] jokens]
  ::
      %'?'
    =^  jock  jokens
      (match-block [jokens %'(' %')'] match-inner-jock)
    ::  TODO: check if we're in a compare
    [[%cell-check jock] jokens]
  ::
      %'$'
    ?.  (has-punctuator -.jokens %'(')
      [[%call [%limb [%axis 0] ~] ~] jokens]
    ?:  (has-punctuator -.jokens %')')
      [[%call [%limb [%axis 0] ~] ~] +.+.jokens]
    =^  arg  jokens
      (match-block [jokens %'(' %')'] match-inner-jock)
    [[%call [%limb [%axis %0] ~] `arg] jokens]
  ::  Axis address  &1
      %'&'
    ::  TODO: check if we're in a compare
    =^  axis-lit  jokens
      (match-axis [[%punctuator %'&'] jokens])
    ?:  =(~ jokens)
      [[%limb axis-lit ~] jokens]
    ?.  (has-punctuator -.jokens %'(')  ::  XXX not '(' because of parser
      [[%limb axis-lit ~] jokens]
    =^  arg  jokens
      (match-block [jokens %'(' %')'] match-inner-jock)  ::  XXX not '('
    [[%call [%limb axis-lit ~] `arg] jokens]
  ::  Set  {1 2 3}
      %'{'
    ::  {one
    =^  jock-one  jokens
      (match-inner-jock jokens)
    =/  acc=(set jock)
      (sy jock-one ~)
    |-  ^-  [jock (list joken)]
    ?:  (has-punctuator -.jokens %'}')
      ::  ...}
      :_  +.jokens  :: strip '}'
      ^-  jock
      :+  %set
        [%none ~]
      acc
    ::  {...}
    =^  jock-nex  jokens
      (match-inner-jock jokens)
    $(acc (~(put in acc) jock-nex))
  ::  Tuple
      %'('
    (match-pair-inner-jock [[%punctuator %'('] jokens])
  ::  Call
      %'(('
    =^  lambda  jokens
      (match-lambda [[%punctuator %'(('] +.jokens])
    ?:  =(~ jokens)
      [[%lambda lambda] jokens]
    ?.  (has-punctuator -.jokens %'((')
      [[%lambda lambda] jokens]
    =.  jokens  +.jokens
    ?:  (has-punctuator -.jokens %')')
      :: no argument
      [[%call [%lambda lambda] ~] +.jokens]
    =^  arg  jokens
      :: match arbitrary number of arguments
      (match-pair-inner-jock [[%punctuator %'('] jokens])
    ?>  (got-punctuator -.jokens %')')
    [[%call [%lambda lambda] `arg] +.jokens]
  ::  Null-terminated list  [1 2 3]
      %'['
    ::  [one
    =^  jock-one  jokens
      (match-inner-jock jokens)
    =/  acc=(list jock)
      [jock-one ~]
    |-  ^-  [jock (list joken)]
    ?:  (has-punctuator -.jokens %']')
      ::  ...]
      :_  +.jokens
      ^-  jock
      :+  %list
        [%none ~]
      (snoc acc [%atom p=[%number 0] q=%.n])
    ::  [...]
    =^  jock-nex  jokens
      (match-inner-jock jokens)
    $(acc (snoc acc jock-nex))
  ==
::
++  match-axis
  |=  =jokens
  ^-  [[%axis @] (list joken)]
  ?>  (got-punctuator -.jokens %'&')
  =.  jokens  +.jokens
  =/  num=@  (got-jatom-number jokens)
  [[%axis num] +.jokens]
::
++  match-start-name
  |=  =jokens
  ^-  [jock (list joken)]
  ?~  jokens  ~|("expect expression starting with name. joken: ~" !!)
  ::  - %name (';' is is the next joken)
  ::  - %edit ('=' is the next joken)
  ::  - %call ('((' is the next joken)
  ::  - %compare ('==' or '<' or '>' or '!' is next)
  ?.  ?=(%name -.i.jokens)
    ~|("expect name. joken: {<-.i.jokens>}" !!)
  =/  name=term
    (got-name i.jokens)
  =>  .(jokens t.jokens)
  =/  limbs=(list jlimb)  [%name name]~
  ?:  =(~ jokens)
    [[%limb limbs] jokens]
  ?:  ?=(^ (get-name -.jokens))
    [[%limb limbs] jokens]
  |-
  ?:  =(~ jokens)
    [[%limb limbs] jokens]
  ?^  nom=(get-name -.jokens)
    $(jokens +.jokens, limbs [[%name u.nom] limbs])
  ?:  (has-punctuator -.jokens %'.')
    $(jokens +.jokens)
  ?:  (has-punctuator -.jokens %'=')
    ?:  (has-punctuator -.+.jokens %'=')
      =^  b  jokens
        (match-inner-jock +.+.jokens)
      [[%compare [%limb limbs] %'==' b] jokens]
    =^  val  jokens
      (match-inner-jock +.jokens)
    ?>  (got-punctuator -.jokens %';')
    =^  jock  jokens
      (match-jock +.jokens)
    [[%edit limbs val jock] jokens]
  ?:  ?|  (has-punctuator -.jokens %'<')
          (has-punctuator -.jokens %'>')
          (has-punctuator -.jokens %'!')
      ==
    =^  comparator  jokens
      (match-comparator jokens)
    =^  inner-two  jokens
      (match-inner-jock jokens)
    [[%compare [%limb limbs] comparator inner-two] jokens]
  ?:  (has-punctuator -.jokens %'((')
    |-
    =.  jokens  +.jokens
    =^  arg  jokens
      (match-inner-jock jokens)
    ?>  (got-punctuator -.jokens %')')
    ::  TODO: check if we're in a compare
    [[%call [%limb limbs] `arg] +.jokens]
  [[%limb limbs] jokens]
::
++  match-metatype
  |=  =jokens
  ^-  [jype (list joken)]
  ?:  =(~ jokens)  ~|("expect expression starting with type. joken: ~" !!)
  ?:  !=(%type -<.jokens)
    ~|("expect type. joken: {<-.jokens>}" !!)
  =/  type
    ?:  =([%type 'List'] -.jokens)
      %list
    ?:  =([%type 'Set'] -.jokens)
      %set
    !!  ::  TODO generalize
  =.  jokens  +.jokens
  =^  jyp  jokens
    (match-block [jokens %'(' %')'] match-jype)
  :: ?>  (got-punctuator -.+.jokens %'(')
  :: =^  jyp  jokens
  ::   (match-jype `(list joken)`+>.jokens)
  :: ?>  (got-punctuator -.jokens %')')
  [`jype`[;;(jype-leaf [type jyp]) %$] jokens]
::
++  match-keyword
  |=  =jokens
  ^-  [jock (list joken)]
  ?:  =(~ jokens)  ~|("expect keyword. joken: ~" !!)
  =^  first=joken  jokens
    [-.jokens +.jokens]
  ?.  ?=(%keyword -.first)
    ~|("expect keyword. joken: {<-.first>}" !!)
  ?+    +.first  !!
      %let
    =^  jype  jokens
      (match-jype jokens)
    ?>  (got-punctuator -.jokens %'=')
    =^  val  jokens
      (match-jock +.jokens)
    ?>  (got-punctuator -.jokens %';')
    =^  jock  jokens
      (match-jock +.jokens)
    [[%let jype val jock] jokens]
  ::
  ::  func a(b:@) -> @ { +(b) };
  ::  [%func name=jype body=jock next=jock]
      %func
    =^  type  jokens
      (match-jype jokens)
    =^  inp  jokens
      (match-block [jokens %'((' %')'] match-jype)
    ?>  (got-punctuator -.jokens %'-')
    ?>  (got-punctuator +<.jokens %'>')
    =.  jokens  +>.jokens
    =^  out  jokens
      (match-jype jokens)
    =^  body  jokens
      (match-block [jokens %'{' %'}'] match-jock)
    ::  Fork between a lambda closure and a function definition.
    ?>  (got-punctuator -.jokens %';')
    =^  next  jokens
      (match-jock +.jokens)
    =.  type
      :-  [%core [%& [`inp out]] ~]
      name.type
    =.  body
      :-  %lambda
      [[`inp out] body ~]
    [[%func type body next] jokens]
  ::
  ::  lambda (b:@) -> @ {+(b)}(23);
  ::  [%lambda p=lambda]
      %lambda
    =^  lambda  jokens
      (match-lambda [[%punctuator %'('] +.jokens])
    ?:  =(~ jokens)
      [[%lambda lambda] jokens]
    ?.  (has-punctuator -.jokens %'(')
      [[%lambda lambda] jokens]
    =.  jokens  +.jokens
    ?:  (has-punctuator -.jokens %')')
      [[%call [%lambda lambda] ~] +.jokens]
    =^  arg  jokens
      (match-pair-inner-jock [[%punctuator %'('] jokens])
    :: %')' consumed by +match-pair-inner-jock
    [[%call [%lambda lambda] `arg] jokens]
  ::
  ::  if (a < b) { +(a) } else { +(b) }
  ::  [%if cond=jock then=jock after-if=after-if-expression]
      %if
    =^  cond  jokens
      (match-inner-jock jokens)
    =^  then  jokens
      (match-block [jokens %'{' %'}'] match-jock)
    =^  after-if  jokens
      (match-after-if-expression jokens)
    [[%if cond then after-if] jokens]
  ::
      %assert
    =^  cond  jokens
      (match-inner-jock jokens)
    ?>  (got-punctuator -.jokens %';')
    =^  then  jokens
      (match-jock +.jokens)
    [[%assert cond then] jokens]
  ::
      %with
    =^  payload=jock  jokens
      (match-inner-jock jokens)
    ?>  (got-punctuator -.jokens %';')
    =^  obj-or-lambda=jock  jokens
      (match-jock +.jokens)
    :_  jokens
    ^-  jock
    ?+  -.obj-or-lambda  !!
      %object  obj-or-lambda(q `payload)
      %lambda  obj-or-lambda(payload.p `payload)
    ==
  ::
      %object
    =/  has-name  ?=(^ (get-name -.jokens))
    =/  cor-name  (fall (get-name -.jokens) %$)
    =?  jokens  has-name
      +.jokens
    ?>  (got-punctuator -.jokens %'{')
    =.  jokens  +.jokens
    =^  core  jokens
      =|  core=(map term jock)
      |-
      ?:  (has-punctuator -.jokens %'}')
        [core +.jokens]
      =/  name=term
        (got-name -.jokens)
      ?>  (got-punctuator +<.jokens %'=')
      =^  jock  jokens
        (match-jock +>.jokens)
        :: (match-inner-jock +>.jokens)
      $(core (~(put by core) name jock))
    :_  jokens
    [%object cor-name core ~]
  ::
      %compose
    =^  p  jokens
      (match-inner-jock jokens)
    ?>  (got-punctuator -.jokens %';')
    =^  q  jokens
      (match-jock +.jokens)
    :_  jokens
    [%compose p q]
  ::
      %match
  :: [%match value=jock cases=(map jock jock) default=(unit jock)]
  :: [%cases value=jock cases=(map jock jock) default=(unit jock)]
    ?:  (has-keyword -.jokens %case)
      =^  value  jokens
        (match-inner-jock +.jokens)
      =^  pairs  jokens
        (match-block [jokens %'{' %'}'] match-match)
      :_  jokens
      [%cases value -.pairs +.pairs]
    ?>  (has-keyword -.jokens %type)
    =^  value  jokens
      (match-inner-jock +.jokens)
    =^  pairs  jokens
      (match-block [jokens %'{' %'}'] match-match)
    :_  jokens
    [%match value -.pairs +.pairs]
  ::
      ?(%loop %defer)
    ?>  (got-punctuator -.jokens %';')
    =^  jock  jokens
      (match-jock +.jokens)
    :_  jokens
    ?:(?=(%loop +.first) [+.first jock] [+.first jock])
  ::
      %recur
    ?.  (has-punctuator -.jokens %'(')
      [[%call [%limb [%axis 0] ~] ~] jokens]
    ?:  (has-punctuator -.+.jokens %')')
      [[%call [%limb [%axis 0] ~] ~] +.+.jokens]
    =^  arg  jokens
      (match-inner-jock +.jokens)
    ?>  (got-punctuator -.jokens %')')
    [[%call [%limb [%axis %0] ~] `arg] +.jokens]
  ::
      %this
    [[%limb [%axis 1] ~] jokens]
  ::
      %eval
    =^  p  jokens
      (match-inner-jock jokens)
    =^  q  jokens
      (match-jock jokens)
    :_  jokens
    [%eval p q]
  ::
      %crash
    [[%crash ~] jokens]
  ==
::
::  Match jokens into jype information.
::
++  match-jype
  |=  =jokens
  ^-  [jype (list joken)]
  ?:  =(~ jokens)
    ~|("expect jype. joken: ~" !!)
  ::  Store name and strip it from joken list
  =/  has-name  ?=(^ (get-name -.jokens))
  =/  nom  (fall (get-name -.jokens) %$)
  =?  jokens  has-name  +.jokens
  ::  Type-qualified name  b:a
  ?:  &(has-name (has-punctuator -.jokens %':'))
    ?:  =(%type -.-.+.jokens)
      =^  jyp  jokens
        (match-metatype `(list joken)`+.jokens)
      [jyp(name nom) jokens]
    =^  jyp  jokens
      (match-jype +.jokens)
    [jyp(name nom) jokens]
  ::  Tuple cell  (a b)
  ?:  (has-punctuator -.jokens %'(')
    =^  r=(pair jype (unit jype))  jokens
      %+  match-block  [jokens %'(' %')']
      |=  =^jokens
      =^  jyp-one  jokens  (match-jype jokens)
      ?:  (has-punctuator -.jokens %')')
        ::  short-circuit if single element in cell
        [[jyp-one ~] jokens]
      =^  jyp-two  jokens  (match-jype jokens)
      ::  TODO: support implicit right-association  (what's a good test case?)
      [[jyp-one `jyp-two] jokens]
    [?~(q.r `jype`p.r `jype`[[p.r u.q.r] nom]) jokens]
  ::  Otherwise, match the leaf into the jype and return it with name.
  ?:  =(%type -.-.jokens)
    =^  jyp  jokens
      (match-metatype `(list joken)`jokens)
    [jyp(name nom) jokens]
  =^  jyp-leaf  jokens
    (match-jype-leaf jokens)
  [[jyp-leaf nom] jokens]
::
::  Match jokens into terminal jype information.
::
++  match-jype-leaf
  |=  =jokens
  ^-  [jype-leaf (list joken)]
  ?:  =(~ jokens)  ~|("expect jype-leaf. joken: ~" !!)
  ::  %atom
  ::    Match on atom type  a:@
  ?:  (has-punctuator -.jokens %'@')
    ::  TODO resolve deeper on type aura
    [[%atom %number %.n] +.jokens]
  ::    Match on loobean type  a:?
  ?:  (has-punctuator -.jokens %'?')
    [[%atom %loobean %.n] +.jokens]
  ::  Match on no type  a:*
  ?:  (has-punctuator -.jokens %'*')
    [[%none ~] +.jokens]
  ::  %core
  ::    Match on lambda definition  (a:@) -> @
  ?:  (has-punctuator -.jokens %'(')
    =^  lambda-argument  jokens
      (match-lambda-argument jokens)
    [[%core [%& lambda-argument] ~] jokens]
  ::  %limb (fallthrough)
  ::    Match on limb lookup.
  ?^  nom=(get-name -.jokens)
    [[%limb ~[name+u.nom]] +.jokens]
  ::    Match on axis (& axis).
  ?:  (has-punctuator -.jokens %'&')
    =^  axis-lit  jokens
      (match-axis jokens)
    [[%limb ~[axis-lit]] jokens]
  ::  %fork
  ::    No action; fall-through.  TODO check
  ::  Else untyped (as variable name).
  ::  [%none ~]
  [[%none ~] jokens]
::
++  match-lambda
  |=  =jokens
  ^-  [lambda (list joken)]
  ?:  =(~ jokens)  ~|("expect lambda. joken: ~" !!)
  =^  lambda-argument  jokens
    (match-lambda-argument jokens)
  =^  body  jokens
    (match-block [jokens %'{' %'}'] match-jock)
  [[lambda-argument body ~] jokens]
::
++  match-lambda-argument
  |=  =jokens
  ^-  [lambda-argument (list joken)]
  ?:  =(~ jokens)  ~|("expect lambda-argument. joken: ~" !!)
  ^-  [lambda-argument (list joken)]
  =^  inp  jokens
    (match-block [jokens %'(' %')'] match-jype)
  ?>  (got-punctuator -.jokens %'-')
  ?>  (got-punctuator +<.jokens %'>')
  =^  out  jokens
    (match-jype +.+.jokens)
  [[`inp out] jokens]
::
++  match-comparator
  |=  =jokens
  ^-  [comparator (list joken)]
  =>  |%
      ++  mini  ?(%'<' %'>' %'=' %'!')
      ++  comp  (perk %'<' %'>' %'=' %'!' ~)
      --
  ?~  jokens  ~|("expect comparator. joken: ~" !!)
  ?.  ?=(%punctuator -.i.jokens)
    ~|("expect punctuator. joken: {<-.i.jokens>}" !!)
  =/  cm1=(unit mini)
    (rust (trip +.i.jokens) (full comp))
  ?~  cm1
    ~|("match-comparator failed: {<i.jokens>}" !!)
  ?~  t.jokens
    [;;(comparator u.cm1) t.jokens]
  ?.  ?=(%punctuator -.i.t.jokens)
    [;;(comparator u.cm1) t.jokens]
  =/  cm2=(unit mini)
    (rust (trip +.i.t.jokens) (full comp))
  ?~  cm2
    [;;(comparator u.cm1) t.jokens]
  =/  final  (cat 3 u.cm1 u.cm2)
  [;;(comparator final) t.t.jokens]
::
++  match-after-if-expression
  |=  =jokens
  ^-  (pair after-if-expression (list joken))
  ?~  jokens
    ~|("expect after-if. joken: ~" !!)
  ?.  ?=(%keyword -.-.jokens)
    ~|("expect keyword. joken: {<-.i.jokens>}" !!)
  ?.  =(%else +.-.jokens)
    ~|("expect %else. joken: {<+.-.jokens>}" !!)
  =>  .(jokens `(list joken)`+.jokens)
  ?:  =(~ jokens)
    ~|("expect more. jokens: ~" !!)
  ?:  (has-punctuator -.jokens %'{')
    =^  else  jokens
      (match-block [jokens %'{' %'}'] match-jock)
    [[%else else] jokens]
  ?.  (has-keyword -.jokens %if)
    ~|("expect %if. joken: {<+.-.jokens>}" !!)
  (match-else-if +.jokens)
::
++  match-else-if
  |=  =jokens
  ^-  [else-if-expression (list joken)]
  =^  cond  jokens
    (match-inner-jock jokens)
  =^  then  jokens
    (match-block [jokens %'{' %'}'] match-jock)
  =^  after-if  jokens
    (match-after-if-expression jokens)
  [[%else-if cond then after-if] jokens]
::
++  match-literal
  |=  =jokens
  ^-  [[%atom jatom] (list joken)]
  ?~  jokens  ~|("expect literal. joken: ~" !!)
  ?.  ?=(%literal -.-.jokens)
    ~|("expect literal. joken: {<-<.jokens>}" !!)
  [[%atom +.-.jokens] +.jokens]
::
++  match-name
  |=  =jokens
  ^-  [[%limb (list jlimb)] (list joken)]
  ?.  ?=(%name -.-.jokens)
    ~|("expect name. joken: {<-<.jokens>}" !!)
  [[%limb [%name +.-.jokens]~] +.jokens]
::
++  match-block
  |*  [[=jokens start=jpunc end=jpunc] gate=$-(jokens [* jokens])]
  ?>  (got-punctuator -.jokens start)
  =^  output  jokens
    (gate +.jokens)
  ?>  (got-punctuator -.jokens end)
  [output +.jokens]
::
++  match-match
  |=  =jokens
  ^-  [[(map jock jock) (unit jock)] (list joken)]
  ?:  =(~ jokens)  ~|("expect map. joken: ~" !!)
  =|  fall=(unit jock)
  =^  cf=[(map jock jock) (unit jock)]  jokens
    =|  duo=(list (pair jock jock))
    |-  ^-  [[(map jock jock) (unit jock)] (list joken)]
    ?:  (has-punctuator -.jokens %'}')
      [[(malt duo) fall] jokens]
    :: default case, must be last
    ?:  (has-punctuator -.jokens %'_')
      ?>  (got-punctuator -.+.jokens %'-')
      ?>  (got-punctuator -.+.+.jokens %'>')
      =^  jock  jokens  `[jock (list joken)]`(match-jock `(list joken)`+.+.+.jokens)
      ?>  (got-punctuator -.jokens %';')
      =.  jokens  +.jokens
      ?>  (got-punctuator -.jokens %'}')  :: no trailing jokens in case block
      =.  fall  `jock
      [[(malt duo) fall] jokens]
    :: regular case
    =^  jock-1  jokens  (match-jock jokens)
    ?>  (got-punctuator -.jokens %'-')
    ?>  (got-punctuator -.+.jokens %'>')
    =^  jock-2  jokens  (match-jock +.+.jokens)
    ?>  (got-punctuator -.jokens %';')
    =.  jokens  +.jokens
    $(duo [[jock-1 jock-2] duo])
  =/  cases  -.cf
  =/  fall  +.cf
  [[cases fall] jokens]
::
++  got-jatom-number
  |=  =jokens
  ^-  @
  ?~  jokens  ~|("expect literal. joken: ~" !!)
  ?.  ?=(%literal -.i.jokens)
    ~|("expect literal or symbol. joken: {<-.i.jokens>}" !!)
  =/  p=jatom  +.i.jokens
  ?.  ?=(%number -.-.p)
    ~|("expect number or symbol. joken: {<-.p>}" !!)
  +.-.p
::
++  got-name
  |=  =joken
  ^-  term
  ?.  ?=(%name -.joken)
    ~|("expect name. joken: {<-.joken>}" !!)
  +.joken
::
++  get-name
  |=  =joken
  ^-  (unit term)
  ?.  ?=(%name -.joken)  ~
  [~ +.joken]
::
++  got-punctuator
  |=  [=joken punc=jpunc]
  ^-  ?
  ?.  ?=(%punctuator -.joken)
    ~|("expect punctuator. joken: {<-.joken>}" !!)
  ?.  =(+.joken punc)
    ~|("expect punctuator {<+.joken>} to be {<punc>}" !!)
  %.y
::
++  has-punctuator
  |=  [=joken punc=jpunc]
  ^-  ?
  ?.  ?=(%punctuator -.joken)  %.n
  =(+.joken punc)
::
++  has-keyword
  |=  [=joken key=keyword]
  ^-  ?
  ?.  ?=(%keyword -.joken)  %.n
  =(+.joken key)
--
::
::  3: compile jock -> nock
::
::  The compilation stage accepts a jock and returns a pair of nock and jype.
::  (Note that this order is reversed from that of Hoon's +mint).  Static type
::  validation takes place as a natural consequence of resolving the jype and
::  constructing the Nock expression.  By convention, we denote the Nock rules
::  as %constants.
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
  ::  leg (Nock 0)
  $@  @
  ::  arm (Nock 9)
  [arm-axis=@ core-axis=@]
::
++  jt
  |_  jyp=jype
  ++  get-limb
    |=  lis=(list jlimb)
    ^-  (pair jype (list jwing))
    |^
    =/  res=(list jwing)  ~
    =/  ret=jwing  1
    ?:  =(~ lis)  !!
    |-
    ?~  lis
      :-  jyp
      ?:  =(ret 1)
        ?~  res  ret^~
        (flop res)
      ?~  res  ret^~
      !!
    =/  axi=(unit jwing)
      ?:  ?=(%name -.i.lis)
        (axis-at-name +.i.lis)
      `+.i.lis
    ?~  axi  ~|  'limb not found'  !!
    ?^  u.axi
      ?~  new-jyp=(type-at-axis (peg +.u.axi -.u.axi))
        ~|  no-type-at-axis+[axi jyp]
        !!
      $(lis t.lis, jyp u.new-jyp, res [u.axi res])
    ?~  new-jyp=(type-at-axis u.axi)
      !!
    ?^  ret
      ::  TODO: in order to support additional limbs
      ::  after a core resolution, we require the return type
      ::  to be a (list jwing)
      !!
    =.  ret  (peg ret u.axi)
    ?>  (lth ret (bex 63))
    $(lis t.lis, jyp u.new-jyp)
    ::
    ++  type-at-axis
      |=  axi=@
      ^-  (unit jype)
      ?:  =(axi 1)
        `jyp
      =/  axi-lis  (flop (snip (rip 0 axi)))
      ~|  type-at-axis+axi-lis
      |-   ^-  (unit jype)
      ?~  axi-lis  `jyp(name %$)
      ?@  -<.jyp
        ?:  =(~ t.axi-lis)  `jyp
        ?.  ?=(%core -.p.jyp)
          ~|  jyp
          !!
        $(jyp (~(call-core jt untyped-j) p.jyp))
      ?:  =(0 i.axi-lis)
        $(axi-lis t.axi-lis, jyp p.jyp)
      $(axi-lis t.axi-lis, jyp q.jyp)
    ::
    ++  axis-at-name
      |=  nom=term
      =/  axi=jwing  [0 1]
      |-  ^-  (unit jwing)
      ?:  =(name.jyp nom)
        ?:  =(-.axi 0)
          `+.axi
        `axi
      ?@  -<.jyp
        ?.  ?=(%core -.p.jyp)
          ~
        ?:  ?=(%& -.p.p.jyp)
          $(jyp (~(call-core jt untyped-j) p.jyp))
        ?.  =(-.axi 0)  ~
        =/  bat  $(jyp (~(call-core jt untyped-j) p.jyp(q ~)), -.axi 1)
        ?~  bat
          ?~  q.p.jyp
            ~
          $(jyp u.q.p.jyp, +.axi +((mul +.axi 2)))
        ?~  q.p.jyp
          bat
        `[(peg 2 -.u.bat) +.axi]
      ?:  !=(name.jyp %$)  ~
      =/  l
        ?:  =(-.axi 0)
          $(jyp p.jyp, +.axi (mul +.axi 2))
        $(jyp p.jyp, -.axi (mul -.axi 2))
      ?~  l
        =/  r
          ?:  =(-.axi 0)
            $(jyp q.jyp, +.axi +((mul +.axi 2)))
          $(jyp q.jyp, -.axi +((mul -.axi 2)))
        r
      l
    --
  ::
  ++  find-buc
    |.  ^-  (unit [jype @])
    =/  axi  1
    |-  ^-  (unit [jype @])
    ?@  -<.jyp
      ?.  ?=(%core -.p.jyp)
        ~
      ?.  ?=(%& -.p.p.jyp)
        ~
      `[jyp axi]
    =/  l  $(jyp p.jyp, axi (mul axi 2))
    ~|  [%l l]
    ?~  l
      =/  r  $(jyp q.jyp, axi +((mul axi 2)))
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
    [jyp q]^%$
  ::
  ++  unify
    |=  v=jype
    ^-  (unit jype)
    ~|  "unable to unify types\0ahave: {<v>}\0aneed: {<jyp>}"
    ?^  -.-.jyp
      ?@  -<.v
        ?:  =(%none -.p.v)
          `jyp
        ~
      =+  [p q]=[(~(unify jt p.jyp) p.v) (~(unify jt q.jyp) q.v)]
      ?:  |(?=(~ p) ?=(~ q))
        ~
      `[[u.p u.q] name.jyp]
    ?^  -<.v
      ?:  =(%none -.p.jyp)
        `v(name name.jyp)
      ~
    :-  ~
    :_  name.jyp
    ?:  =(%none -.p.jyp)
      p.v
    ?:  =(%none -.p.v)
      p.jyp
    ?>  =(-.p.jyp -.p.v)
    p.jyp
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
          ~|  ['have:' val-jyp 'need:' type.j]
          !!
        (~(cons jt u.inferred-type) jyp)
      ~|  %let-next
      =+  [nex nex-jyp]=$(j next.j)
      [[%8 val nex] nex-jyp]
    ::
        %func
      =+  [val val-jyp]=$(j body.j)
      =.  jyp
        =/  inferred-type
          (~(unify jt type.j) val-jyp)
        ?~  inferred-type
          ~|  '%func: value type does not nest in declared type'
          ~|  ['have:' val-jyp 'need:' type.j]
          !!
        (~(cons jt u.inferred-type) jyp)
      ~|  %func-next
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
      =+  [body body-jyp]=$(j body.p.j, jyp lam-jyp)
      ?~  pay
        :_  (lam-j arg.p.j `jyp)
        [%8 input-default [%1 body] [%0 1]]  ::  XXX autocons [0 1] for subject
      :_  (lam-j arg.p.j `q.u.pay)
      [%8 input-default [%1 body] p.u.pay]
    ::
        %list
      ~|  %list
      |^
      =/  vals=(list jock)  val.j
      ?:  =(~ vals)  ~|  'list: no value'  !!
      =+  [val val-jyp]=^$(j -.vals)
      ::  XXX right now this means the val-jyp is %none and will be overridden
      =/  inferred-type
        (~(unify jt type.j^%$) val-jyp)
      ?~  inferred-type
        ~|  '%list: value type does not nest in declared type'
        ~|  ['have:' val-jyp 'need:' type.j]
        !!
      =/  nok=(list nock)  ~[val]
      =.  vals  +.vals
      :_  [[%list u.inferred-type] %$]
      |-  ^-  nock
      ::  if the next element ends the list, then we are at the closing ~
      ?~  +.vals
        ;;(nock (list-to-tuple (flop nok)))
      ::  for each jock, validate that it nests in the container's declared type
      =+  [val val-jyp]=^^$(j -.vals)
      =/  inferred-type
        (~(unify jt type.j^%$) val-jyp)
      ?~  inferred-type
        ~|  '%list: value type does not nest in declared type'
        ~|  ['have:' val-jyp 'need:' type.j]
        !!
      %=  $
        nok   [val nok]
        vals  +.vals
      ==
      ::
      ++  list-to-tuple
        |*  a=(list)
        ?~  a  !!
        ::  address of [a_{k-1} ~] (final nontrivial tail of list)
        =+  (dec (bex (lent a)))
        .*  a
        [%10 [- [%0 (mul 2 -)]] [%0 1]]
      --
    ::
        %set
      ~|  %set
      :: |^
      =/  vals=(list jock)  ~(tap in val.j)
      ?:  =(~ vals)  ~|  'set: no value'  !!
      =+  [val val-jyp]=$(j -.vals)
      ::  XXX right now this means the val-jyp is %none and will be overridden
      =/  inferred-type
        (~(unify jt type.j^%$) val-jyp)
      ?~  inferred-type
        ~|  '%set: value type does not nest in declared type'
        ~|  ['have:' val-jyp 'need:' type.j]
        !!
      ::  At this point, we have a (set jock), not a (set *) of the values
      =/  res=(set *)  (~(put in *(set *)) val)
      =.  vals  +.vals
      :_  [[%set u.inferred-type] %$]
      |-  ^-  nock
      ?~  vals
        [%1 `*`res]
      =+  [val val-jyp]=^$(j -.vals)
      =/  inferred-type
        (~(unify jt type.j^%$) val-jyp)
      ?~  inferred-type
        ~|  '%set: value type does not nest in declared type'
        ~|  ['have:' val-jyp 'need:' type.j]
        !!
      %=  $
        res   (~(put in res) val)
        vals  +.vals
      ==
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
        %list      [%1 0]
    ::
        %set       [%1 0]
    ::
        %none      [%1 0]
    ==
  ::
  :: +hunt-type: make a $nock to test whether jock nests in jype
  :: We check only four cases:  %none and constant %atom to
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
