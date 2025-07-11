::
::  The core structure of /lib/jock is rather complicated, and since we need
::  to refer to cores by their relative addresses sometimes, it behooves us to
::  enumerate them here.
::
::    +>        entrypoint door, immediately below
::    +>+>      mint core, at end
::    +>+>+     jeam door, in middle
::    +>+>+>+   parse core, next
::
::  We automatically supply a copy of Hoon into the namespace as an FFI because
::  so many built-in tools like arithmetic depend on it.
=<  |_  libs=(map term cord)
    ++  tokenize
      |=  txt=@
      ^-  tokens
      (rash txt parse-tokens)
    ::
    ++  jeam
      |=  txt=@
      ^-  jock
      =+  [jok tokens]=(~(match-jock +>+>+ libs) (rash txt parse-tokens))
      ?.  ?=(~ tokens)
        ~|  'jeam: must parse to a single jock'
        ~|  remaining+tokens
        !!
      jok
    ::
    ++  mint
      |=  txt=@
      ^-  *
      =/  jok  (jeam (cat 3 'import hoon;\0a' txt))
      =+  [nok jyp]=(~(mint cj:~(. +> libs) [%atom %string %.n]^%$) jok)
      nok
    ::
    ++  jypist
      |=  txt=@
      ^-  jype
      =/  jok  (jeam (cat 3 'import hoon;\0a' txt))
      =+  [nok jyp]=(~(mint cj:~(. +> libs) [%atom %string %.n]^%$) jok)
      jyp
    --
=>
::
::  1: tokenizer
::
::  The tokenizer is a simple machine that reads a string of text and
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
      %class
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
      %switch
      %eval
      %with
      %this
      %import
      %as
      %print
  ==
::
+$  jpunc
  $+  jpunc
  $?  %'.'  %';'  %','  %':'  %'&'  %'$'
      %'@'  %'?'  %'!'  %'(('
      %'('  %')'  %'{'  %'}'  %'['  %']'
      %'='  %'<'  %'>'  %'#'
      %'+'  %'-'  %'*'  %'/'  %'%'  %'_'
  ==
::
+$  jatom
  $+  jatom
  $~  [[%loobean p=%.n] q=%.n]
  $:  $%  [%string p=cord]
          [%number p=@ud]
          [%hexadecimal p=@ux]
          [%loobean p=?]
      ==
      q=?(%.y %.n)                  ::  constant flag
  ==
::
+$  token
  $+  token
  $%  [%keyword keyword]
      [%punctuator jpunc]
      [%literal jatom]
      [%name cord]
      [%type cord]
  ==
::
+$  tokens  (list token)
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
  ++  string             (stag %string (cook crip (ifix [soq soq] (star ;~(less soq prn)))))
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
  ::  This only happens if there is a name or type immediately preceding '(',
  ::  e.g. foo(bar)  ->  'foo' '((' 'bar' ')'
  ++  tagged-name        (stag %name name)                :: [%name term]
  ++  name               snek                             :: term with _
  ++  snek               %+  cook
                           |=(a=tape (rap 3 ^-((list @) a)))
                         ;~(plug low (star ;~(pose nud low cab)))
  ::
  ++  tagged-type        (stag %type type)                :: [%type 'Cord']
  ++  type               aul                              :: Cord
  ++  aul                %+  cook                         :: Ulll
                             |=(a=tape (rap 3 ^-((list @) a)))
                         ;~(plug hig (star low))
  ::
  ++  tagged-keyword     (stag %keyword keyword)
  ++  keyword
    %-  perk
    :~  %let  %func  %lambda  %class
        %if  %else  %crash  %assert
        %object  %compose  %loop  %defer
        %recur  %match  %switch  %eval  %with  %this
        %import  %as  %print
    ==
  ::
  ++  tagged-punctuator  %+  cook
                           |=  =token
                           ^-  ^token
                           ?.  &(fun =([%punctuator %'('] token))
                             token
                          ::  =.  fun  %.n
                           [%punctuator `jpunc`%'((']
                         (stag %punctuator punctuator)
  ++  punctuator
    %-  perk
    :~  %'.'  %';'  %','  %':'  %'&'  %'$'
        %'@'  %'?'  %'!'  :: XXX exclude %'((' which is a pseudo-punctuator
        %'('  %')'  %'{'  %'}'  %'['  %']'
        %'='  %'<'  %'>'  %'#'
        %'+'  %'-'  %'*'  %'/'  %'%'  %'_'
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
        (knee *(list token) |.(~+(;~(plug tagged-keyword ;~(pfix gav tokens(fun %.n))))))
        (knee *(list token) |.(~+(;~(plug tagged-symbol ;~(pfix gav tokens(fun %.n))))))
        (knee *(list token) |.(~+(;~(plug tagged-literal ;~(pfix gav tokens(fun %.n))))))
        (knee *(list token) |.(~+(;~(plug tagged-name ;~(pfix gav tokens(fun %.y))))))
        (knee *(list token) |.(~+(;~(plug tagged-punctuator ;~(pfix gav tokens(fun %.n))))))
        (knee *(list token) |.(~+(;~(plug tagged-type ;~(pfix gav tokens(fun %.y))))))
        (easy ~)
    ==
  ::
  --
::
++  parse-tokens
  |=  =nail
  ^-  (like (list token))
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
|_  libs=(map term cord)
+|  %ast
::
+$  jock
  $+  jock
  $^  [p=jock q=jock]
  $%  [%let type=jype val=jock next=jock]
      [%func type=jype body=jock next=jock]
      [%class state=jype arms=(map term jock)]
      [%method type=jype body=jock]
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
      [%compare comp=comparator a=jock b=jock]
      [%operator op=operator a=jock b=(unit jock)]
      [%lambda p=lambda]
      [%limb p=(list jlimb)]
      [%atom p=jatom]
      [%list type=jype-leaf val=(list jock)]
      [%set type=jype-leaf val=(set jock)]
      [%import name=jype next=jock]
      [%print body=?([%jock jock]) next=jock]
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
::
++  comparator-set
  ^~
  ^-  (set term)
  %-  silt
  ^-  (list comparator)
  ~[%'<' %'>' %'!=' %'==' %'<=' %'>=']
::
+$  operator
  $+  operator
  $?  %'+'
      %'-'
      %'*'
      %'/'
      %'%'
      %'**'
  ==
::
++  operator-set
  ^~
  ^-  (set term)
  %-  silt
  ^-  (list operator)
  ~[%'+' %'-' %'*' %'/' %'%' %'**']
::  Jype type base types
+$  jype
  $+  jype
  $:  $^([p=jype q=jype] p=jype-leaf)
      name=cord
  ==
::  Jype bottomed-out types
+$  jype-leaf
  $%  ::  %atom is a basic numeric type with constant flag (%.y = constant)
      [%atom p=jatom-type q=?(%.y %.n)]
      ::  %core is a callable function with arguments and returns
      [%core p=core-body q=(unit jype)]  :: q is context supplied to core
      ::  %limb is a reference to a limb in the current core
      [%limb p=(list jlimb)]
      ::  %fork is a branch point (as in an if-else)
      [%fork p=jype q=jype]
      ::  %list
      [%list type=jype]
      ::  %set
      [%set type=jype]
      ::  %hoon is a vase for the supplied subject (presumably hoon or tiny)
      :: [%hoon p=vase]
      [%hoon p=truncated-vase]
      ::  %state is a container for class state
      [%state p=jype]
      ::  %none is a null type (as for undetermined variable labels)
      [%none p=(unit term)]
  ==
::
+$  truncated-vase
  $+  truncated-vase
  $:  p=type
      q=noun
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
  $:  ::  Argument type (sample and return)
      arg=lambda-argument
      ::  Executable body (battery)
      body=jock
      ::  Supplied context, if applicable
      context=(unit jock)
  ==
::  Lambda input argument pair
+$  lambda-argument
  $+  lambda-argument
  $:  ::  sample type, if any
      inp=(unit jype)
      ::  return type
      out=jype
  ==
::  Arm lookups
+$  jlimb
  $%  ::  Arm or leg name
      [%name p=term]
      ::  Numeric axis
      [%axis p=@]
      ::  Type reference
      [%type p=cord]
  ==
::
++  match-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)
    ~|("expect jock. token: ~" !!)
  =^  lock  tokens
    ?-    -<.tokens
        %literal     (match-literal tokens)
        %name        (match-start-name tokens)
        %keyword     (match-keyword tokens)
        %punctuator  (match-start-punctuator tokens)
        %type        (match-start-name tokens)
    ==
  ?:  =(~ tokens)  [lock tokens]
  =^  oc=(unit term)  tokens
    (any-operator tokens)
  ?~  oc  [lock tokens]
  ::  Handle mapping externally.
  ?:  &(=(%'-' u.oc) =(%'>' ->.tokens))
    ::  Re-attach map operator.
    [lock [[%punctuator %'-'] tokens]]
  ::  - compare ('==','<','<=','>','>=','!=' is the next token)
  ?:  (~(has in comparator-set) u.oc)
    =^  rock  tokens
      (match-inner-jock tokens)
    [[%compare ;;(comparator u.oc) lock rock] tokens]
  ::  - arithmetic ('+' or '-' or '*' or '/' or '%' or '**' is next)
  ?:  (~(has in operator-set) u.oc)
    =^  rock  tokens
      (match-inner-jock tokens)
    :_  tokens
    ;;  jock
    [%operator u.oc lock `rock]
  ::  no infix operator
  [lock tokens]
::
++  match-inner-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)  ~|("expect inner-jock. token: ~" !!)
  ?:  ?|  (has-keyword -.tokens %object)
          (has-keyword -.tokens %class)
          (has-keyword -.tokens %with)
          (has-keyword -.tokens %this)
          (has-keyword -.tokens %crash)
      ==
    (match-jock tokens)
  =>  .(tokens `(list token)`tokens)  :: TMI
  =^  lock  tokens
    ?+    -<.tokens  !!
        %literal     (match-literal tokens)
        %name        (match-start-name tokens)
        %punctuator  (match-start-punctuator tokens)
        %type        (match-start-name tokens)
    ==
  ?~  tokens  [lock tokens]
  ::  - compare ('==','<','<=','>','>=','!=' is the next token)
  ?:  ?|  &((has-punctuator -.tokens %'=') (has-punctuator +<.tokens %'='))
          (has-punctuator -.tokens %'<')
          &((has-punctuator -.tokens %'<') (has-punctuator +<.tokens %'='))
          (has-punctuator -.tokens %'>')
          &((has-punctuator -.tokens %'>') (has-punctuator +<.tokens %'='))
          &((has-punctuator -.tokens %'!') (has-punctuator +<.tokens %'='))
      ==
    =>  .(tokens `(list token)`tokens)  :: TMI
    =^  comp  tokens
      (match-comparator tokens)
    =^  rock  tokens
      (match-inner-jock tokens)
    [[%compare comp lock rock] tokens]
  ::  - arithmetic ('+' or '-' or '*' or '/' or '%' or '**' is next)
  ?:  ?|  (has-punctuator -.tokens %'+')
          (has-punctuator -.tokens %'-')
          (has-punctuator -.tokens %'*')
          (has-punctuator -.tokens %'/')
          (has-punctuator -.tokens %'%')
          :: &((has-punctuator -.tokens %'*') (has-punctuator +<.tokens %'*')) :: subcase of '*'
      ==
    =>  .(tokens `(list token)`tokens)  :: TMI
    =^  op  tokens
      (match-operator tokens)
    =^  rock  tokens
      (match-inner-jock tokens)
    [[%operator op lock `rock] tokens]
  ::  no infix operator
  [lock tokens]
::
++  match-pair-inner-jock
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)  ~|("expect jock. token: ~" !!)
  ?:  (has-punctuator -.tokens %'(')
    =>  .(tokens `(list token)`+.tokens)  :: TMI
    =^  jock-one  tokens
      (match-inner-jock tokens)
    ?:  (has-punctuator -.tokens %')')
      [jock-one +.tokens]
    =/  first=?  %.y
    |-  ^-  [jock (list token)]
    =^  jock-nex  tokens
      (match-inner-jock tokens)
    =/  pun  (has-punctuator -.tokens %')')
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
  ?+  -<.tokens  !!
    %literal     (match-literal tokens)
    %name        (match-start-name tokens)
    %punctuator  (match-start-punctuator tokens)
    %type        (match-start-name tokens)
  ==
::  match jocks with no terminating jock (i.e. func bodies)
++  match-jock-body
  |=  [=tokens end=jpunc]
  ^-  [jock (list token)]
  ?:  =(~ tokens)
    ~|("expect jock. token: ~" !!)
  ?:  (has-punctuator -.tokens end)  !!
  =^  jock  tokens
    ?-    -<.tokens
        %literal
      ::  TODO: check if we're in a compare
      (match-literal tokens)
    ::
      %name        (match-start-name tokens)
      %keyword     (match-keyword tokens)
      %punctuator  (match-start-punctuator tokens)
      %type        (match-start-name tokens)
    ==
  [jock tokens]
::
++  match-trait
  |=  =tokens
  ^-  [jype (list token)]
  ?:  =(~ tokens)  ~|("expect trait. token: ~" !!)
  =^  type  tokens
    (match-jype tokens)
  =^  inp=jype  tokens
    (match-block [tokens %'((' %')'] match-jype)
  ?>  (got-punctuator -.tokens %'-')
  ?>  (got-punctuator +<.tokens %'>')
  =.  tokens  +>.tokens
  =^  out=jype  tokens
    (match-jype tokens)
  ?>  (got-punctuator -.tokens %';')
  :_  +.tokens
  :-  `jype-leaf`[%core [%& [`inp out]] ~]
  name.type
::
++  match-start-punctuator
  |=  =tokens
  ^-  [jock (list token)]
  ?:  =(~ tokens)  ~|("expect jock. token: ~" !!)
  =/  first=token  -.tokens
  ?.  ?=(%punctuator -.first)
    ~|("expect start-punctuator. token: {<-.first>}" !!)
  =.  tokens  +.tokens
  ?+    +.first  ~|("expect start-punctuator. token: {<+.first>}" !!)
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
  ::  $ = recur
      %'$'
    ?.  (has-punctuator -.tokens %'(')
      [[%call [%limb [%axis 0] ~] ~] tokens]
    ?:  (has-punctuator -.tokens %')')
      [[%call [%limb [%axis 0] ~] ~] +>.tokens]
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
    ?.  (has-punctuator -.tokens %'(')  ::  XXX not '(' because of parser
      [[%limb axis-lit ~] tokens]
    =^  arg  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)  ::  XXX not '('
    [[%call [%limb axis-lit ~] `arg] tokens]
  ::  Set  {1 2 3}
      %'{'
    ::  {one
    =^  jock-one  tokens
      (match-inner-jock tokens)
    =/  acc=(set jock)
      (sy jock-one ~)
    |-  ^-  [jock (list token)]
    ?:  (has-punctuator -.tokens %'}')
      ::  ...}
      :_  +.tokens  :: strip '}'
      ^-  jock
      :+  %set
        [%none ~]
      acc
    ::  {...}
    =^  jock-nex  tokens
      (match-inner-jock tokens)
    $(acc (~(put in acc) jock-nex))
  ::  Tuple
      %'('
    (match-pair-inner-jock [[%punctuator %'('] tokens])
  ::  Call
      %'(('
    =^  lambda  tokens
      (match-lambda [[%punctuator %'(('] +.tokens])
    ?:  =(~ tokens)
      [[%lambda lambda] tokens]
    ?.  (has-punctuator -.tokens %'((')
      [[%lambda lambda] tokens]
    =.  tokens  +.tokens
    ?:  (has-punctuator -.tokens %')')
      :: no argument
      [[%call [%lambda lambda] ~] +.tokens]
    =^  arg  tokens
      :: match arbitrary number of arguments
      (match-pair-inner-jock [[%punctuator %'('] tokens])
    ?>  (got-punctuator -.tokens %')')
    [[%call [%lambda lambda] `arg] +.tokens]
  ::  Null-terminated list  [1 2 3]
      %'['
    ::  [one
    =^  jock-one  tokens
      (match-inner-jock tokens)
    =/  acc=(list jock)
      [jock-one ~]
    |-  ^-  [jock (list token)]
    ?:  (has-punctuator -.tokens %']')
      ::  ...]
      :_  +.tokens
      ^-  jock
      :+  %list
        [%none ~]
      (snoc acc [%atom p=[%number 0] q=%.n])
    ::  [...]
    =^  jock-nex  tokens
      (match-inner-jock tokens)
    $(acc (snoc acc jock-nex))
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
  ?:  =(~ tokens)  ~|("expect expression starting with name. token: ~" !!)
  :: ?.  ?=(%name -<.tokens)  :: XXX commented out for typing issues
  ::   ~|("expect name. token: {<-<.tokens>}" !!)
  ::  How a name is parsed depends on the next symbol.
  =/  has-name  ?=(%name -<.tokens)
  =/  name=cord
    ~|  "expect name. token: {<-<.tokens>}"
    ?:  has-name  ;;(cord ->.tokens)
    ?>  =(%type -<.tokens)
    (got-name -.tokens)
  =.  tokens  +.tokens
  =/  limbs=(list jlimb)  ~[(make-jlimb name)]
  ::  - %name (there is no next token, which is the end of the jock)
  ?:  =(~ tokens)
    [[%limb limbs] tokens]
    :: [[%limb limbs] tokens]
  ::  - %name (';' is the next token, which is consumed outside)
  ?:  (has-punctuator -.tokens %';')
    [[%limb limbs] tokens]
  |-
  ::  - %name (there is a wing with multiple entries)
  ?:  (has-punctuator -.tokens %'.')
    =^  limbs  tokens
      =/  acc=(list jlimb)  ~
      |-
      ?.  (has-punctuator -.tokens %'.')
        [(flop acc) tokens]
      ?^  nom=(get-name +<.tokens)
        %=  $
          tokens  +>.tokens
          acc     [(make-jlimb u.nom) acc]
        ==
      ~|("expect name in wing. token: {<+<.tokens>}" !!)
    $(limbs `(list jlimb)`[(make-jlimb name) limbs], tokens tokens)
  ::  - %edit ('=' is the next token)
  ::  - compare ('==' is the next token)
  ?:  (has-punctuator -.tokens %'=')
    ::  - compare ('==' is the next token), in which case punt back
    ?:  (has-punctuator +<.tokens %'=')
      [[%limb limbs] tokens]
    =^  val  tokens
      (match-inner-jock +.tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  jock  tokens
      (match-jock +.tokens)
    [[%edit limbs val jock] tokens]
  ::  - %call ('((' is the next token)
  ?:  |((has-punctuator -.tokens %'((') (has-punctuator -.tokens %'('))
    ?:  (has-punctuator +<.tokens %')')
      ::  no argument
      =^  arg  tokens
        [~ +>.tokens]
      [[%call [%limb limbs] ~] tokens]
    =?  tokens  ?=(%'((' ->.tokens)  [[%punctuator %'('] +.tokens]
    =^  arg  tokens
      (match-pair-inner-jock tokens)
    [[%call [%limb limbs] `arg] tokens]
  [[%limb limbs] tokens]
::
++  make-jlimb
  |=  name=cord
  ^-  jlimb
  ?:  !(is-type name)
    [%name name]
  [%type name]
::
::  Metatype is a container type like List or Set
++  match-metatype
  |=  =tokens
  ^-  [jype (list token)]
  ?:  =(~ tokens)  ~|("expect expression starting with type. token: ~" !!)
  ?:  !=(%type -<.tokens)
    ~|("expect type. token: {<-.tokens>}" !!)
  =/  type=cord
    ?:  =([%type 'List'] -.tokens)  %list
    ?:  =([%type 'Set'] -.tokens)   %set
    :: ?:  =([%type 'Map'] -.tokens)   %map
    ?>  ?=([%type cord] -.tokens)
    ->.tokens
  =/  nom  (get-name -.tokens)
  ?~  nom  ~|("expect name. token: {<-.tokens>}" !!)
  ::  Short-circuit on built-in primitive types
  ?:  =('Atom' u.nom)    [[%atom %number %.n]^u.nom +.tokens]
  ?:  =('Uint' u.nom)    [[%atom %number %.n]^u.nom +.tokens]
  ?:  =('Uhex' u.nom)    [[%atom %hexadecimal %.n]^u.nom +.tokens]
  ?:  =('String' u.nom)  [[%atom %string %.n]^u.nom +.tokens]
  ?:  =('Loob' u.nom)    [[%atom %loobean %.n]^u.nom +.tokens]
  ::
  =.  tokens  +.tokens
  ?.  =([%punctuator %'(('] -.tokens)
    ::  XXX fix when finishing type TODO
    [`jype`[`jype-leaf`[%limb ~[[%type type]]] type] tokens]
  ::  match type state
  =^  jyp  tokens
    =^  r=(pair jype (unit jype))  tokens
      =^  jyp-one  tokens  (match-jype +.tokens)
      ?:  (has-punctuator -.tokens %')')
        ::  short-circuit if single element in cell
        [[jyp-one ~] tokens]
      =^  jyp-two  tokens  (match-jype tokens)
      ::  TODO: support implicit right-association  (what's a good test case?)
      [[jyp-one `jyp-two] tokens]
    [?~(q.r `jype`p.r `jype`[[p.r u.q.r] %$]) tokens]
  ?>  (got-punctuator -.tokens %')')
  ?:  ?=(%list type)  [[;;(jype-leaf [type jyp]) u.nom] +.tokens]
  ?:  ?=(%set type)  [[;;(jype-leaf [type jyp]) u.nom] +.tokens]
  [[[%state jyp] u.nom] +.tokens]
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
      (match-jock +.tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  next  tokens
      (match-jock +.tokens)
    :_  tokens
    [%let jype val next]
  ::
  ::  func inc(n:@) -> @ { +(n) };
  ::  [%func name=jype body=jock next=jock]
      %func
    =^  type  tokens
      (match-jype tokens)
    =^  inp  tokens
      (match-block [tokens %'((' %')'] match-jype)
    ?>  (got-punctuator -.tokens %'-')
    ?>  (got-punctuator +<.tokens %'>')
    =.  tokens  +>.tokens
    =^  out  tokens
      (match-jype tokens)
    =^  body  tokens
      (match-block [tokens %'{' %'}'] (curr match-jock-body %'}'))
    ?>  (got-punctuator -.tokens %';')
    =^  next  tokens
      (match-jock +.tokens)
    =.  type
      :-  [%core [%& [`inp out]] ~]
      name.type
    =.  body
      :-  %lambda
      [[`inp out] body ~]
    [[%func type body next] tokens]
  ::
  ::  lambda (b:@) -> @ {+(b)}(23);
  ::  [%lambda p=lambda]
      %lambda
    =^  lambda  tokens
      (match-lambda [[%punctuator %'('] +.tokens])
    ?:  =(~ tokens)
      [[%lambda lambda] tokens]
    ?.  (has-punctuator -.tokens %'(')
      [[%lambda lambda] tokens]
    =.  tokens  +.tokens
    ?:  (has-punctuator -.tokens %')')
      [[%call [%lambda lambda] ~] +.tokens]
    =^  arg  tokens
      (match-pair-inner-jock [[%punctuator %'('] tokens])
    :: %')' consumed by +match-pair-inner-jock
    [[%call [%lambda lambda] `arg] tokens]
  ::
  ::  [%class state=jype arms=(map term jock)]
      %class
    =^  state  tokens
      (match-jype tokens)
    ::  mask out reserved types
    ?:  =([%type 'List'] name.state)  ~|('Shadowing reserved type List is not allowed.' !!)
    ?:  =([%type 'Set'] name.state)   ~|('Shadowing reserved type Set is not allowed.' !!)
    :: ?:  =([%type 'Map'] name.state)   ~|('Shadowing reserved type Map is not allowed.' !!)
    ?>  (got-punctuator -.tokens %'{')
    =|  arms=(map term jock)
    =.  tokens  +.tokens
    =^  arms  tokens
      |-
      ?:  (has-punctuator -.tokens %'}')
        [arms +.tokens]
      ::  Retrieve the name of the method.
      =^  type  tokens
        (match-jype tokens)
      ::  Gather the arguments and output type.
      =^  inp  tokens
        ?>  (got-punctuator -.tokens %'((')
        =^  r=(pair jype (unit jype))  tokens
          =^  jyp-one  tokens  (match-jype +.tokens)
          ?:  (has-punctuator -.tokens %')')
            ::  short-circuit if single element in cell
            [[jyp-one ~] tokens]
          =^  jyp-two  tokens  (match-jype tokens)
          ::  TODO: support implicit right-association  (what's a good test case?)
          [[jyp-one `jyp-two] tokens]
        [?~(q.r `jype`p.r `jype`[[p.r u.q.r] %$]) tokens]
      ?>  (got-punctuator -.tokens %')')
      =.  tokens  +.tokens
      ?>  (got-punctuator -.tokens %'-')
      ?>  (got-punctuator +<.tokens %'>')
      =.  tokens  +>.tokens
      =^  out  tokens
        (match-jype tokens)
      =.  type
        :-  [%core [%& [`inp out]] ~]
        name.type
      ::  Retrieve the body of the method.
      =^  body  tokens
        (match-block [tokens %'{' %'}'] match-jock)
      =.  body
        :-  %lambda
        [[`inp out] body ~]
      $(arms (~(put by arms) name.type [%method type body]))
    :_  tokens
    [%class state=state arms=arms]
  ::
  ::  if (a < b) { +(a) } else { +(b) }
  ::  [%if cond=jock then=jock after-if=after-if-expression]
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
    =^  context=jock  tokens
      (match-inner-jock tokens)
    ?>  (got-punctuator -.tokens %';')
    =^  obj-or-lambda=jock  tokens
      (match-jock +.tokens)
    :_  tokens
    ^-  jock
    ?+  -.obj-or-lambda  !!
      %object  obj-or-lambda(q `context)
      %lambda  obj-or-lambda(context.p `context)
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
        (match-jock +>.tokens)
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
    =^  value  tokens
      (match-inner-jock tokens)
    =^  pairs  tokens
      (match-block [tokens %'{' %'}'] match-match)
    :_  tokens
    [%match value -.pairs +.pairs]
  ::
      %switch
  :: [%cases value=jock cases=(map jock jock) default=(unit jock)]
    =^  value  tokens
      (match-inner-jock tokens)
    =^  pairs  tokens
      (match-block [tokens %'{' %'}'] match-match)
    :_  tokens
    [%cases value -.pairs +.pairs]
  ::
      ?(%loop %defer)
    ?>  (got-punctuator -.tokens %';')
    =^  jock  tokens
      (match-jock +.tokens)
    :_  tokens
    ?:(?=(%loop +.first) [+.first jock] [+.first jock])
  ::  recur = $
      %recur
    ?.  (has-punctuator -.tokens %'(')
      [[%call [%limb [%axis 0] ~] ~] tokens]
    ?:  (has-punctuator -.+.tokens %')')
      [[%call [%limb [%axis 0] ~] ~] +>.tokens]
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
      %import
    ?>  ?=(%name -<.tokens)
    =/  nom=term  ->.tokens
    =/  src=jock  [%limb ~[-.tokens]]
    =/  tokens  +.tokens
    =/  past  (rush (~(got by libs) nom) (ifix [gay gay] tall:(vang | /)))
    ?~  past  ~|("unable to parse Hoon library: {<[+<+.src]>}" !!)
    =/  p  (~(mint ut %noun) %noun u.past)
    =?  nom  (has-keyword -.tokens %as)
      ?>  =(%name +<-.tokens)
      ;;(term +<+.tokens)
    =?  tokens  (has-keyword -.tokens %as)  +>.tokens
    ?>  ~|  'expected terminator ; after import'
      (got-punctuator -.tokens %';')
    =^  q  tokens
      (match-jock +.tokens)
    :_  tokens
    [%import [[%hoon [p.p .*(0 q.p)]] nom] q]
  ::
  :: [%print body=?([%jock jock]) next=jock]
      %print
    =^  body  tokens
      (match-block [tokens %'(' %')'] match-inner-jock)
    ?>  (got-punctuator -.tokens %';')
    =^  next  tokens
      (match-jock +.tokens)
    :_  tokens
    [%print [%jock body] next]
  ::
      %crash
    [[%crash ~] tokens]
  ==
::
::  Match tokens into jype information.
::
++  match-jype
  |=  =tokens
  ^-  [jype (list token)]
  ?:  =(~ tokens)
    ~|("expect jype. token: ~" !!)
  ::  Store name and strip it from token list
  =/  has-name  ?=(^ (get-name -.tokens))
  =/  nom  (fall (get-name -.tokens) %$)
  =?  tokens  has-name  +.tokens
  ::  Type-qualified name  b:a
  ?:  &(has-name (has-punctuator -.tokens %':'))
    ?:  =(%type +<-.tokens)
      =^  jyp  tokens
        (match-metatype `(list token)`+.tokens)
      [jyp(name nom) tokens]
    =^  jyp  tokens
      (match-jype +.tokens)
    [jyp(name nom) tokens]
  ::  Tuple cell  (a b)
  ?:  (has-punctuator -.tokens %'(')
    =^  r=(pair jype (unit jype))  tokens
      %+  match-block  [tokens %'(' %')']
      |=  =^tokens
      =^  jyp-one  tokens  (match-jype tokens)
      ?:  (has-punctuator -.tokens %')')
        ::  short-circuit if single element in cell
        [[jyp-one ~] tokens]
      =^  jyp-two  tokens  (match-jype tokens)
      ::  TODO: support implicit right-association  (what's a good test case?)
      [[jyp-one `jyp-two] tokens]
    [?~(q.r `jype`p.r `jype`[[p.r u.q.r] nom]) tokens]
  ::  If this is a class or type declaration, match it.
  ?:  &(!=(%$ nom) (is-type nom))
    =^  jyp  tokens
      (match-metatype `(list token)`[[%type nom] tokens])
    [jyp tokens]
  ::  Otherwise, match the leaf into the jype and return it with name.
  =^  jyp-leaf  tokens
    (match-jype-leaf tokens)
  [[jyp-leaf nom] tokens]
::
::  Match tokens into terminal jype information.
::
++  match-jype-leaf
  |=  =tokens
  ^-  [jype-leaf (list token)]
  ?:  =(~ tokens)  ~|("expect jype-leaf. token: ~" !!)
  ::  %atom
  ::    Match on atom type  a:@
  ?:  (has-punctuator -.tokens %'@')
    ::  TODO resolve deeper on type aura
    [[%atom %number %.n] +.tokens]
  ::    Match on loobean type  a:?
  ?:  (has-punctuator -.tokens %'?')
    [[%atom %loobean %.n] +.tokens]
  ::  Match on noun type  a:*
  ?:  (has-punctuator -.tokens %'*')
    [[%none ~] +.tokens]
  ::  Match on trait placeholder type  #
  ?:  (has-punctuator -.tokens %'#')
    [[%none [~ %$]] +.tokens]
  ::  %core
  ::    Match on lambda definition  (a:@) -> @
  ?:  (has-punctuator -.tokens %'(')
    =^  lambda-argument  tokens
      (match-lambda-argument tokens)
    [[%core [%& lambda-argument] ~] tokens]
  ::  %limb (fallthrough)
  ::    Match on limb lookup.
  ?^  nom=(get-name -.tokens)
    [[%limb ~[name+u.nom]] +.tokens]
  ::    Match on axis (& axis).
  ?:  (has-punctuator -.tokens %'&')
    =^  axis-lit  tokens
      (match-axis tokens)
    [[%limb ~[axis-lit]] tokens]
  ::  %fork
  ::    No action; fall-through.  TODO check
  ::  Else untyped (as variable name).
  ::  [%none ~]
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
  ^-  [lambda-argument (list token)]
  =^  inp  tokens
    (match-block [tokens %'(' %')'] match-jype)
  ?>  (got-punctuator -.tokens %'-')
  ?>  (got-punctuator +<.tokens %'>')
  =^  out  tokens
    (match-jype +>.tokens)
  [[`inp out] tokens]
::
++  match-comparator
  |=  =tokens
  ^-  [comparator (list token)]
  =>  |%
      ++  mini  ?(%'<' %'>' %'=' %'!')
      ++  comp  (perk %'<' %'>' %'=' %'!' ~)
      --
  ?:  =(~ tokens)  ~|("expect comparator. token: ~" !!)
  ?.  ?=(%punctuator -<.tokens)
    ~|("expect punctuator. token: {<-<.tokens>}" !!)
  =/  cm1=(unit mini)
    (rust (trip ->.tokens) (full comp))
  ?~  cm1
    ~|("match-comparator failed: {<-.tokens>}" !!)
  ?:  =(~ +.tokens)
    [;;(comparator u.cm1) +.tokens]
  ?.  ?=(%punctuator +<-.tokens)
    [;;(comparator u.cm1) +.tokens]
  =/  cm2=(unit mini)
    (rust (trip +<+.tokens) (full comp))
  ?~  cm2
    [;;(comparator u.cm1) +.tokens]
  =/  final  (cat 3 u.cm1 u.cm2)
  [;;(comparator final) +>.tokens]
::
++  match-operator
  |=  =tokens
  ^-  [operator (list token)]
  =>  |%
      ++  mini  ?(%'+' %'-' %'*' %'/' %'%' %'**')
      ++  comp  (perk %'+' %'-' %'*' %'/' %'%' %'**' ~)
      --
  ?:  =(~ tokens)  ~|("expect operator. token: ~" !!)
  ?.  ?=(%punctuator -<.tokens)
    ~|("expect punctuator. token: {<-<.tokens>}" !!)
  =/  cm1=(unit mini)
    (rust (trip ->.tokens) (full comp))
  ?~  cm1
    ~|("match-operator failed: {<-.tokens>}" !!)
  ?:  =(~ +.tokens)
    [;;(operator u.cm1) +.tokens]
  ?.  ?=(%punctuator +<-.tokens)
    [;;(operator u.cm1) +.tokens]
  =/  cm2=(unit mini)
    (rust (trip +<+.tokens) (full comp))
  ?~  cm2
    [;;(operator u.cm1) +.tokens]
  =/  final  (cat 3 u.cm1 u.cm2)
  [;;(operator final) +>.tokens]
::
++  match-after-if-expression
  |=  =tokens
  ^-  (pair after-if-expression (list token))
  ?:  =(~ tokens)
    ~|("expect after-if. token: ~" !!)
  ?.  ?=(%keyword -<.tokens)
    ~|("expect keyword. token: {<-<.tokens>}" !!)
  ?.  =(%else ->.tokens)
    ~|("expect %else. token: {<->.tokens>}" !!)
  =>  .(tokens `(list token)`+.tokens)  :: TMI
  ?:  =(~ tokens)
    ~|("expect more. tokens: ~" !!)
  ?:  (has-punctuator -.tokens %'{')
    =^  else  tokens
      (match-block [tokens %'{' %'}'] match-jock)
    [[%else else] tokens]
  ?.  (has-keyword -.tokens %if)
    ~|("expect %if. token: {<->.tokens>}" !!)
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
  ?:  =(~ tokens)  ~|("expect literal. token: ~" !!)
  ?.  ?=(%literal -<.tokens)
    ~|("expect literal. token: {<-<.tokens>}" !!)
  [[%atom ->.tokens] +.tokens]
::
++  match-name
  |=  =tokens
  ^-  [[%limb (list jlimb)] (list token)]
  ?.  ?=(%name -<.tokens)
    ~|("expect name. token: {<-<.tokens>}" !!)
  [[%limb [%name -<.tokens]~] +.tokens]
::
++  match-block
  |*  [[=tokens start=jpunc end=jpunc] gate=$-(tokens [* tokens])]
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
      ::  TODO later put these as operators in regular operator handling code
      ?>  (got-punctuator +<.tokens %'-')
      ?>  (got-punctuator +>-.tokens %'>')
      =^  jock  tokens  `[jock (list token)]`(match-jock `(list token)`+>+.tokens)
      ?>  (got-punctuator -.tokens %';')
      =.  tokens  +.tokens
      ?>  (got-punctuator -.tokens %'}')  :: no trailing tokens in case block
      =.  fall  `jock
      [[(malt duo) fall] tokens]
    :: regular case
    =^  jock-1  tokens  (match-jock tokens)
    ?>  (got-punctuator -.tokens %'-')
    ?>  (got-punctuator +<.tokens %'>')
    =^  jock-2  tokens  (match-jock +>.tokens)
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
  ?:  =(~ tokens)  ~|("expect literal. token: ~" !!)
  ?.  ?=(%literal -<.tokens)
    ~|("expect literal or symbol. token: {<-<.tokens>}" !!)
  =/  p=jatom  ->.tokens
  ?.  ?=(%number -<.p)
    ~|("expect number or symbol. token: {<-.p>}" !!)
  ->.p
::
++  got-name
  |=  =token
  ^-  cord
  ?.  |(?=(%name -.token) ?=(%type -.token))
    ~|("expect name. token: {<-.token>}" !!)
  ;;(cord +.token)
::
++  get-name
  |=  =token
  ^-  (unit cord)
  ?.  |(?=(%name -.token) ?=(%type -.token))  ~
  ?:  ?=(%name -.token)  [~ +.token]
  ?>  ?=(%type -.token)  [~ +.token]
::
::  like +sane but for snake case
::  !((sane %tas) name)
++  is-type
  |=  name=cord
  ^-  ?
  =+  [inx=0 len=(met 3 name)]
  ?!
  |-  ^-  ?
  ?:  =(inx len)  &
  =+  cur=(cut 3 [inx 1] name)
  ?&  ?|  &((gte cur 'a') (lte cur 'z'))
          &(=('_' cur) !=(0 inx) !=(len inx))
          &(&((gte cur '0') (lte cur '9')) !=(0 inx))
      ==
      $(inx +(inx))
  ==
::
++  got-punctuator
  |=  [=token punc=jpunc]
  ^-  ?
  ?.  ?=(%punctuator -.token)
    ~|("expect punctuator. token: {<-.token>}" !!)
  ?.  =(+.token punc)
    ~|("expect punctuator {<+.token>} to be {<punc>}" !!)
  %.y
::
++  got-type
  |=  [=token type=cord]
  ^-  ?
  ?:  =(~ tokens)  ~|("expect type. token: ~" !!)
  ?.  ?=(%type -<.tokens)
    ~|("expect type. token: {<token>}" !!)
  ?.  =(+.token type)
    ~|("expect type {<+.token>} to be {<type>}" !!)
  %.y
::
++  has-punctuator
  |=  [=token punc=jpunc]
  ^-  ?
  ?.  ?=(%punctuator -.token)  %.n
  =(+.token punc)
::
++  has-keyword
  |=  [=token key=keyword]
  ^-  ?
  ?.  ?=(%keyword -.token)  %.n
  =(+.token key)
::
++  has-type
  |=  [=tokens type=cord]
  ^-  ?
  ?.  ?=(%type -<.tokens)  %.n
  =(+.tokens cord)
::  detect both comparators and operators
++  any-operator
  |=  =tokens
  ^-  [(unit term) (list token)]
  ::  come back with something more clever like ++match-comparator later
  ?:  &((has-punctuator -.tokens %'=') (has-punctuator +<.tokens %'='))
    [`%'==' +>.tokens]
  ?:  &((has-punctuator -.tokens %'<') (has-punctuator +<.tokens %'='))
    [`%'<=' +>.tokens]
  ?:  (has-punctuator -.tokens %'<')
    [`%'<' +.tokens]
  ?:  &((has-punctuator -.tokens %'>') (has-punctuator +<.tokens %'='))
    [`%'>=' +>.tokens]
  ?:  (has-punctuator -.tokens %'>')
    [`%'>' +.tokens]
  ?:  &((has-punctuator -.tokens %'!') (has-punctuator +<.tokens %'='))
    [`%'!=' +>.tokens]
  ?:  (has-punctuator -.tokens %'+')
    [`%'+' +.tokens]
  ?:  (has-punctuator -.tokens %'-')
    [`%'-' +.tokens]
  ?:  (has-punctuator -.tokens %'*')
    [`%'*' +.tokens]
  ?:  (has-punctuator -.tokens %'/')
    [`%'/' +.tokens]
  ?:  (has-punctuator -.tokens %'%')
    [`%'%' +.tokens]
  ?:  &((has-punctuator -.tokens %'*') (has-punctuator +<.tokens %'*'))
    [`%'**' +>.tokens]
  [~ tokens]
::
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
::  Note that %12 does not occur, so returns from Hoon libraries must be molded.
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
      :: [%11 p=@ q=nock]                          ::  static hint
      [%11 p=$@(@ [p=@ q=nock]) q=nock]         ::  hint
      [%0 p=@]                                  ::  axis select
  ==
::
++  untyped-j  [%none ~]^%$
++  lam-j
  |=  [arg=lambda-argument context=(unit jype)]
  ^-  jype
  [%core [%& arg] context]^%$
::
++  jwing
  ::  leg (Nock 0)
  $@  @
  ::  arm (Nock 9)
  [arm-axis=@ core-axis=@]
::
++  jt
  |_  jyp=jype
  ::  A jwing is a scope resolution into a particular structure.
  ::  A jlimb is thus the actual axis in the subject of the value,
  ::  or a name/type reference to it.
  ++  get-limb
    |=  lis=(list jlimb)
    ^-  (unit (each (pair jype (list jwing)) (trel jype (list jlimb) (list jwing))))
    |^
    ::  The resulting jwing.
    =/  res=(list jwing)  ~
    ::  The resulting axis, default subject.
    =/  ret=jwing  1
    ?:  =(~ lis)  ~|("no limb requested" ~)
    |-
    ?~  lis
      ::  If we've searched to the bottom, return what we have.
      :-  ~
      :+  %&
        jyp
      ::  If self, return the wing.
      ?:  =(ret 1)
        ::  If search list empty, then return self.
        ?~  res  ~[ret]
        ::  Else, return the wing.
        (flop res)
      ::  If no wing, return our self.
      ?~  res  ~[ret]
      ::  If wing and not self, disambiguate.
      ~[-.res]
    =/  axi=(unit jwing)
      ::  Resolve names and types to axes.
      ?:  |(?=(%name -<.lis) ?=(%type -<.lis) !=(%$ name.jyp))
        (axis-at-name ->.lis)
      `[->.lis]
    ?~  axi  ~|("limb not found: {<lis>} in {<jyp>}" ~)
    ::  If it exists and we need to search further, do so.
    ?^  u.axi
      ?~  new-jyp=(type-at-axis (peg +.u.axi -.u.axi))
        ~|(no-type-at-axis+[axi jyp] ~)
      $(lis t.lis, jyp u.new-jyp, res [u.axi res])
    ?~  new-jyp=(type-at-axis u.axi)
      ~|(%expect-type-at-axis ~)
    ::  If this is a Hoon library, then return now.
    ?:  =(%hoon -<.u.new-jyp)
      :-  ~
      :-  %|
      :+  u.new-jyp
        t.lis
      ?:  =(ret 1)
        ?~  res  ~[?>(?=(@ u.axi) ?^(ret !! (peg ret u.axi)))]
        (flop res)
      ?~  res  ~[?>(?=(@ u.axi) ?^(ret !! (peg ret u.axi)))]
      ~[i.res]
    ::  If we are looking for a method, we need to resolve the instance value as
    ::  well as the door and arm.  This is the case iff the type is a class name
    ::  but the limb is only a name and there are subsequent limbs to find.
    ?:  ?&  =(%name -<.lis)               :: look for a name
            ?=(%limb -<.u.new-jyp)        :: of an instance
            ?=(%type ->-<.u.new-jyp)      :: that refers to a class type
            !=(~ t.lis)                   :: that is not just a name
        ==
      =.  ret  (peg ?^(ret 1 ret) u.axi)
      :-  ~
      :+  %&
        u.new-jyp
      ?:  =(ret 1)
        ::  If search list empty, then return self.
        ?~  res  ~[ret]
        ::  Else, return the wing.
        (flop res)
      ::  If no wing, return our self.
      ?~  res  ~[ret]
      ::  If wing and not self, disambiguate.
      ~[i.res]
    ?^  ret
      ::  TODO: in order to support additional limbs
      ::  after a core resolution, we require the return type
      ::  to be a (list jwing)
      ~
    =.  ret  (peg ret u.axi)
    ?>  (lth ret (bex 63))  :: disallow axes larger than Goldilocks prime field
    $(lis t.lis, jyp u.new-jyp)
    ::
    ::  Locate the type at a given axis.
    ++  type-at-axis
      |=  axi=@
      ^-  (unit jype)
      ?:  =(axi 1)
        `jyp
      =/  axi-lis  (flop (snip (rip 0 axi)))
      ~|  type-at-axis+axi-lis
      |-   ^-  (unit jype)
      ?~  axi-lis
        `jyp(name %$)
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
    ::  Locate a name's corresponding axis.
    ++  axis-at-name
      |=  nom=term
      ^-  (unit jwing)
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
      ?:  !=(name.jyp %$)
        ~
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
  ::  Construct subject for when core is called.
  ++  call-core
    |=  [%core p=core-body q=(unit jype)]
    ^-  jype
    ?:  ?=(%& -.p)
      ~|  %call-lambda
      =/  out-type
        ::  TODO: need to put the return type here, with all names stripped
        out.p.p
      ?~  inp.p.p
        ?~  q
          [out-type untyped-j]^%$
        [out-type u.q]^%$
      ?~  q
        [out-type u.inp.p.p]^%$
      [out-type [u.inp.p.p u.q]^%$]^%$
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
    |=  ryp=jype
    ^-  (unit jype)
    ~|  "unable to unify types\0ahave: {<ryp>}\0aneed: {<jyp>}"
    ?^  -<.jyp
      ?@  -<.ryp
        ?:  =(%none -.p.ryp)
          `jyp
        ~
      =+  [p q]=[(~(unify jt p.jyp) p.ryp) (~(unify jt q.jyp) q.ryp)]
      ?:  |(?=(~ p) ?=(~ q))
        ~
      `[[u.p u.q] name.jyp]
    ?^  -<.ryp
      ?:  =(%none -.p.jyp)
        `ryp(name name.jyp)
      ~
    :-  ~
    :_  name.jyp
    ?:  =(%none -.p.jyp)
      p.ryp
    ?:  =(%none -.p.ryp)
      p.jyp
    ?:  =(%cell -.p.ryp)
      !!
    ?>  =(-.p.jyp -.p.ryp)
    p.jyp
  ::
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
        ::  let permits four correct cases:
        ::  1. let name = value;
        ::  2. let name:(@ @) = value;  (primitive type)
        ::  3. let name:type = value;
        ::  4. let name = Type(value);
        =/  inferred-type=(unit jype)
          ?:  ?=(%limb -<.type.j)
            :: case 3, let name:type = value;
            :: [p=[%limb p=~[[%type p='Foo']]] name='name']
            :: check nesting of lval and rval but pass lval
            ~|  %nesting-with-specified-lval-type
            :: =/  [lyp=jype ljw=(list jwing)]
            ::   (~(get-limb jt jyp) +.p.type.j)
            =/  lim  (~(get-limb jt jyp) +.p.type.j)
            ?~  lim  ~|('limb not found' !!)
            ?>  ?=(%& -.u.lim)
            =/  lyp=jype  p.p.u.lim
            =/  ljw=(list jwing)  q.p.u.lim
            `[[%limb ~[[%type name.val-jyp]]] name.type.j]
          ?:  (is-type name.val-jyp)
            :: case 4, let name = Type(value);
            :: [p=[%limb p=~[[%type p='Foo']]] name='name']
            :: pass rval as Type after nesting check
            ~|  %nesting-without-specified-lval-type
            ^-  (unit jype)
            `[[%limb ~[[%type name.val-jyp]]] name.type.j]
          :: cases 1 and 2, let name = value;
          :: [p=jype name='name']
          :: pass unified lval and rval
          ~|  %nesting-without-specified-lval
          (~(unify jt type.j) val-jyp)
        ?~  inferred-type
          ~|  '%let: value type does not nest in declared type'
          ~|  "have: {<val-jyp>}\0aneed: {<type.j>}"
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
        %method
      =+  [val val-jyp]=$(j body.j)
      =/  inferred-type
        (~(unify jt type.j) val-jyp)
      ?~  inferred-type
        ~|  '%func: value type does not nest in declared type'
        ~|  ['have:' val-jyp 'need:' type.j]
        !!
      [val val-jyp]
    ::
        %class
      ~|  %class
      ::  door sample
      =/  sam-nok  (type-to-default state.j)
      ::  unified context including door sample in context
      ?>  ?=(%state -<.state.j)
      ::  exe-jyp has list of untyped arms plus door state
      =/  exe-jyp=jype
        :: instead of untyped, assume correct output type in exe-jyp
        =/  context=jype
          (~(cons jt p.p.state.j) jyp)
        [[%core %|^(~(run by arms.j) |=(* untyped-j)) `context] %$]
      =/  lis=(list [name=term val=jock])  ~(tap by arms.j)
      ?>  ?=(^ lis)
      ::  core and jype of first arm
      =+  [cor-nok one-jyp]=$(j val.i.lis, jyp exe-jyp)
      =.  name.one-jyp  name.i.lis
      =/  cor-jyp=(map term jype)
        (~(put by *(map term jype)) name.i.lis one-jyp)
      =>  .(lis `(list [name=term val=jock])`+.lis)
      ::  core and jype of subsequent arms
      |-  ^-  [nock jype]
      ?~  lis
        :-  [%8 sam-nok [%1 cor-nok] [%0 1]]  :: XXX for subject
        =/  inner-jyp
          (~(cons jt state.j) [[%core %|^cor-jyp `state.j] name.state.j])
        =.  inner-jyp  inner-jyp(name name.state.j)
        (~(cons jt inner-jyp) jyp)
      =+  [mor-nok mor-jyp]=%=(^$ j val.i.lis, jyp exe-jyp)
      %_  $
        lis      t.lis
        cor-nok  [mor-nok cor-nok]
        cor-jyp  (~(put by cor-jyp) name.i.lis mor-jyp)
      ==
    ::
        %edit
      =/  [typ=jype axi=@]
        =/  res  (~(get-limb jt jyp) limb.j)
        ?~  res  ~|('limb not found' !!)
        ?>  ?=(%& -.u.res)
        ?>  ?=(^ q.p.u.res)
        ?>  ?=(@ i.q.p.u.res)
        [p.p.u.res i.q.p.u.res]
      ~|  %edit-value
      =+  [val val-jyp]=$(j val.j)
      ~|  %edit-next
      ::  assert type compatibility
      ?>  ?=(^ (~(unify jt typ) val-jyp))
      ::  expose updated value address
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
      =/  con=(unit (pair nock jype))
        ?~  q.j
          ::  TODO: should I put `jyp here?
          ~
        `$(j u.q.j)
      =/  exe-jyp=jype
        ::  TODO: should we default to `jyp?
        [%core %|^(~(run by p.j) |=(* untyped-j)) ?~(con ~ `q.u.con)]^%$
      =/  lis=(list [name=term val=jock])  ~(tap by p.j)
      ?>  ?=(^ lis)
      =+  [cor-nok one-jyp]=$(j val.i.lis, jyp exe-jyp)
      =.  name.one-jyp  name.i.lis
      =|  cor-jyp=(map term jype)
      =.  cor-jyp  (~(put by cor-jyp) name.i.lis one-jyp)
      =>  .(lis `(list [name=term val=jock])`+.lis)
      |-
      ?~  lis
        ?~  con
          :-  [%1 cor-nok]
          [%core %|^cor-jyp ~]^%$
        :-  [[%1 cor-nok] p.u.con]
        [%core %|^cor-jyp `q.u.con]^%$
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
      =+  [jip jip-jyp]=^$(j -<.cases)
      =+  [jok jok-jyp]=^$(j ->.cases)
      %=  $
        cell   :^    %6
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
      =+  [jok jok-jyp]=^$(j ->.cases)
      %=  $
        cell   :^    %6
                   ^-  nock
                   (hunt-value -<.cases)
                 ^-  nock
                 [%7 [%0 3] %1 `nock`jok]
               cell
        cases  +.cases
      ==
    ::
        %call
      ?+    -.func.j  ~|('must call a limb' !!)
          %limb
        =/  old-jyp  jyp
        ~|  %call-limb
        =/  limbs=(list jlimb)  p.func.j
        ?>  ?=(^ limbs)
        ::  At this point it's looking for a %core (either func or class).
        ::  We need to resolve several cases (in no particular order):
        ::    1. func function (single jlimb)
        ::       func(args)
        ::    2. class constructor (one jlimb) (single or multiple args)
        ::       Type(state)
        ::    3. class method (in instance) (two jlimbs, first a name)
        ::       instance.method(args)
        ::    4. lambda function (assigned to variable) (single jlimb)
        ::       lambda(args)->out{}
        ::    5. class method (from other method)
        ::       method(args)
        ::    6. library call (at least two jlimbs, the first being a library name)
        ::       library.func(args)
        ::    7. class instance leg (single jlimb, name in state)
        ::       instance.state()
        ::
        =/  [typ=jype ljl=(list jlimb) ljw=(list jwing)]
          ?.  =([%axis 0] -.limbs)
            =/  lim  (~(get-limb jt jyp) limbs)
            ?~  lim  ~|('limb not found' !!)
            ?:  ?=(%& -.u.lim)
              [p.p.u.lim ~ q.p.u.lim]
            p.u.lim
          ::  special case: we're looking for $
          =/  ret  (~(find-buc jt jyp))
          ?~  ret  ~|("couldn't find $ in {<jyp>}" !!)
          [-.u.ret ~ ~[[2 +.u.ret]]]
        ::
        ?:  !=(~ ljl)
          ::  case 6, library call
          ::    library.func(args)
          ::  Construct a gate call from the rest of the limbs.
          ::  We have to +slam the gate into the Hoon library,
          ::  thus two separate wings.
          ~|  %call-case-6
          ?>  ?=(^ limbs)
          ?~  arg.j  ~|("expect function argument" !!)
          =+  [val val-jyp]=$(j u.arg.j)
          ::  Construct the AST for the Hoon RPC using the bunt for now.
          =+  ast=(j2h ljl ~)
          ?>  ?=(%hoon -<.typ)
          =/  min  (~(mint ut -.p.p.-.typ) %noun ast)
          =/  pmin  p.min
          =/  pjyp  (type2jype pmin)
          =/  qmin
            ~|  'failed to validate Nock---perhaps a %12?'
            ;;(nock q.min)
          :_  pjyp
          ;;  nock
          :+  %8
            :^    %9
                +<+<.qmin
              %0
            -.ljw
            :: equivalent to Hoon:
            :: :+  %7
            ::   [%0 -.ljw]
            :: :^    %9
            ::     +<+<.qmin
            ::   %0
            :: 1
          =+  [arg arg-jyp]=$(j u.arg.j, jyp old-jyp)
          [%9 2 %10 [6 [%7 [%0 3] arg]] %0 2]
        ::
        ::  class constructor (case 2), multiple arguments
        ::  [%call func=[%limb p=(list jlimb)] arg=(unit jock)]
        ::    Type(state)
        ?^  -<.typ
          ~|  %call-case-2-args
          ?:  ?=(%type -<.limbs)
            ?~  arg.j  ~|("expect method argument" !!)
            =+  [val val-jyp]=$(j u.arg.j)
            ::  This is a class, so we know that the state is at the head.
            ?>  ?=(%state -<-<.typ)
            =/  inferred-type  (~(unify jt -<->.typ) val-jyp)
            ?~  inferred-type
              ~|  '%call: argument value type does not nest in method type'
              ~|  "have: {<val-jyp>}\0aneed: {<typ>}"
              !!
            =.  inferred-type  `u.inferred-type(name ->.limbs)
            :_  u.inferred-type
            :+  %8
              ::  parent of axis
              [%0 (div ;;(@ +:(resolve-wing ljw)) 2)]
            :+  %10
              [6 %7 [%0 3] val]
            [%0 2]
          ::
          ?>  ?=(%name -<.limbs)
          ?~  arg.j  ~|("expect method argument" !!)
          =+  [val val-jyp]=$(j u.arg.j)
          =/  inferred-type  (~(unify jt typ) val-jyp)
          ?~  inferred-type
            ~|  '%call: argument value type does not nest in method type'
            ~|  "have: {<val-jyp>}\0aneed: {<typ>}"
            !!
          =.  inferred-type  `u.inferred-type(name ->.limbs)
          :-  val
          u.inferred-type
        ::
        ::  class method call by constructor (case 2), single argument
        ::    [%call func=[%limb p=(list jlimb)] arg=(unit jock)]
        ::    Type(state)
        ?.  ?=(%core -.p.typ)
          ?:  ?=(%type -<.limbs)
            ~|  %call-case-2
            ::  XXX possibly unused now
            ?>  ?=(%type -<.limbs)
            ?~  arg.j  ~|("expect constructor state argument" !!)
            =+  [val val-jyp]=$(j u.arg.j)
            ::  XXX this checks to make sure state and input actually nest
            =/  inferred-type  (~(unify jt typ) val-jyp)
            ?~  inferred-type
              ~|  '%call: argument value type does not nest in method type'
              ~|  "have: {<val-jyp>}\0aneed: {<typ>}"
              !!
            =.  inferred-type  `u.inferred-type
            :-  val
            [[%limb limbs] ->.limbs]
          ?>  ?=(%name -<.limbs)
          ?>  ?=(%limb -.p.typ)
          ::  Get class definition for instance.  This is a cons of
          ::  the state and the methods (arms) as a core.
          =/  lim  (~(get-limb jt jyp) p.p.typ)
          ?~  lim  ~|('limb not found' !!)
          ?>  ?=(%& -.u.lim)
          =/  dyp=jype  p.p.u.lim
          =/  ljd=(list jwing)  q.p.u.lim
          =/  cyp  ;;(jype ->.dyp)
          ?>  ?=(%core -<.cyp)
          ?:  ?=(%& -.p.p.cyp)  ~|("class cannot be lambda" !!)
          ::  Search for the door defn in the subject jype.
          =/  gat-nom  `cord`+<+.limbs
          =/  gat-lim  (~(get-limb jt dyp) +.limbs)
          ?~  gat-lim
            ~|  %call-case-7
            ::  Getter for state variables.
            ::    instance.state()
            =/  sta  -<.dyp
            ?>  ?=(%state -<.sta)
            =/  stn  p.p.sta
            =/  ljs  (~(get-limb jt +.stn) +.limbs)
            ?~  ljs  ~|('leg not found' !!)
            :_  *jype
            :+  %7
              (resolve-wing ljw)
            :+  %7
              [%0 6]  :: door state is always at sample +6
            [%0 ;;(@ +>-.u.ljs)]
          ::
          ~|  %call-case-3
          ::  class method call in instance (case 3)
          ::    instance.method(args)
          ::  In this case, we have located the class instance
          ::  but now need the method and the argument to construct
          ::  the Nock.
          ?>  ?=(%& -.u.gat-lim)
          =/  gat-jyp=jype  p.p.u.gat-lim
          =/  ljg=(list jwing)  q.p.u.gat-lim
          =/  gat  (~(get by p.p.p.cyp) gat-nom)
          ?~  gat  ~|("gate not found: {<gat-nom>} in {<name.typ>}" !!)
          ?>  ?=(%core -<.u.gat)
          ?.  ?=(%& -.p.p.u.gat)  ~|("method cannot be lambda" !!)
          =/  dor-nom  -<+.dyp  :: class name, used to determine return type
          :: Output is a regular type.
          ^-  [nock jype]
          :_  out.p.p.p.u.gat
          ?~  arg.j
            (resolve-wing ljd)
          :+  %8
            :+  %7
                (resolve-wing ljw)
              [%9 ;;(@ -<.ljg) %0 1]
          =+  [arg arg-jyp]=$(j u.arg.j, jyp old-jyp)
          [%9 2 %10 [6 [%7 [%0 3] arg]] %0 2]
        ::
        ::  traditional function call (case 1)
        ::    func(args)
        ?:  ?=(%& -.p.p.typ)
          ~|  %call-case-1
          :_  out.p.p.p.typ
          ?:  =([%axis 0] +<.func.j)
            ::  self call (i.e., recursion)
            ?~  arg.j
              (resolve-wing ljw)
            =+  [arg arg-jyp]=$(j u.arg.j, jyp old-jyp)
            [%9 2 %10 [6 [%7 [%0 1] arg]] %0 1]
          ?~  arg.j
            :: no or default args
            (resolve-wing ljw)
          :: supplied args, mutate sample
          :+  %8
            (resolve-wing ljw)
          =+  [arg arg-jyp]=$(j u.arg.j, jyp old-jyp)
          [%9 2 %10 [6 [%7 [%0 3] arg]] %0 2]
        ::
        ::  lambda function call (case 4)
        ::    lambda(args)->out{}
        ?>  &(=(1 (lent p.func.j)) !?=(%type -<.limbs))
        ~|  %call-case-4
        :_  =/  gat  ;;([%core p=core-body q=(unit jype)] -:(~(got by p.p.p.typ) +:(snag 0 p.func.j)))
            ?>  ?=(%& -.p.gat)
            out.p.p.gat
        ?~  arg.j
          :: no or default args
          (resolve-wing ljw)
        :: supplied args, mutate sample
        :+  %8
          (resolve-wing ljw)
        =+  [arg arg-jyp]=$(j u.arg.j, jyp old-jyp)
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
      ::  Other comparators must map into Hoon itself.
          %'>'
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %gth]]] arg=`[a.j b.j]]
        -:$(j j)
      ::
          %'<'
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %lth]]] arg=`[a.j b.j]]
        -:$(j j)
      ::
          %'<='
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %lte]]] arg=`[a.j b.j]]
        -:$(j j)
      ::
          %'>='
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %gte]]] arg=`[a.j b.j]]
        -:$(j j)
      ==
    ::
        %operator
      ~|  %operator
      :_  [%atom %number %.n]^%$
      ?-    op.j
          %'+'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %add]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
          %'-'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %sub]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
          %'*'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %mul]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
          %'/'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %div]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
          %'%'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %mod]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
          %'**'
        ?~  b.j  !!
        =/  j=jock  [%call [%limb p=~[[%name %hoon] [%name %pow]]] arg=`[a.j u.b.j]]
        -:$(j j)
        ::
      ==
    ::
        %limb
      ~|  %limb
      =/  lim  (~(get-limb jt jyp) p.j)
      ?~  lim  ~|('limb not found' !!)
      ?>  ?=(%& -.u.lim)  :: +each resolution
      =/  res=(pair jype (list jwing))  p.u.lim
      [(resolve-wing q.res) p.res]
    ::
        %lambda
      ~|  %enter-lambda
      ?>  ?=(^ inp.arg.p.j)
      =/  con=(unit (pair nock jype))
        ?~  context.p.j  ~
        `$(j u.context.p.j)
      =/  input-default  (type-to-default u.inp.arg.p.j)
      ~|  %enter-lambda-body
      ::  TODO: wtf?
      =/  lam-jyp  (lam-j arg.p.j ?~(con `jyp `q.u.con))
      ::  1. Get body jype
      =+  [body body-jyp]=$(j body.p.j, jyp lam-jyp)
      ?:  (is-type name.out.arg.p.j)
        ::  instance return from method
        ?~  con
          :_  (lam-j arg.p.j `jyp)
          :+  %8
            input-default
          :-
            :-  %1
            :+  %8
              [%0 7]
            :+  %10
              [6 %7 [%0 3] body]
            [%0 2]
          [%0 1]
        :_  (lam-j arg.p.j `q.u.con)
        :+  %8
          input-default
        :-
          :-  %1
          :+  %8
            [%0 7]
          :+  %10
            [6 %7 [%0 3] body]
          [%0 2]
        p.u.con
      ::  normal return
      ?~  con
        :_  (lam-j arg.p.j `jyp)
        [%8 input-default [%1 body] %0 1]  ::  XXX for subject
      :_  (lam-j arg.p.j `q.u.con)
      [%8 input-default [%1 body] p.u.con]
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
      ?~  vals
        ?:  =(%1 -<.nok)
          ;;(nock (list-to-tuple (flop nok)))
        ;;(nock [%1 (list-to-tuple (flop nok))])
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
        [%10 [- [%0 (mul 2 -)]] %0 1]
      --
    ::
        %set
      ~|  %set
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
      ~|  [%atom +<+.j]
      :-  [%1 +<+.j]
      [^-(jype-leaf [%atom +<-.j +>.j]) %$]
    ::
        %import
      ~|  %import
      ?>  ?=(%hoon -<.name.j)  :: right now only hoon.hoon
      =.  jyp  (~(cons jt name.j) jyp)
      ~|  %import-next
      =+  [nex nex-jyp]=$(j next.j)
      :_  nex-jyp
      :+  %8
        [%1 q.p.p.name.j]
      nex
    ::
        %print
      ~|  %print
      =+  [val val-jyp]=$(j +.body.j)
      =+  [nex nex-jyp]=$(j next.j)
      :_  nex-jyp
      :+  %11
        [%slog [%1 0] %1 (pprint val val-jyp)]
      nex
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
    ?^  -<.j    [$(j p.j) $(j q.j)]
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
      =/  lim  (~(get-limb jt jyp) p.p.j)
      ?~  lim  ~|('limb not found' !!)
      ?>  ?=(%& -.u.lim)  :: if you want from a library then resolve it yourself
      $(j p.p.u.lim)
    ::
        %fork      $(j p.p.j)
    ::
        %list      [%1 0]
    ::
        %set       [%1 0]
    ::
        %hoon      [%1 0]
    ::
        %state     $(j p.p.j)
    ::
        %none      [%1 0]
    ==
  ::
  ::  Convert a Jock function call to a Hoon gate call.
  ++  j2h
    |=  [wing=(list jlimb) arg=(unit jock)]
    ::  XXX formally this is a potential mismatch from the imported Hoon, be careful!
    ^-  hoon
    =/  p
      =|  out=hoon
      |-  ^-  hoon
      ?~  wing
        out
      ?:  =(*hoon out)
        ::  overwrite bunt with first value
        $(out [%wing ~[->.wing]], wing +.wing)
      $(out [%wing (snoc ;;(^wing +.out) ->.wing)], wing +.wing)  :: XXX not as efficient but easy
    =/  q
      |-  ^-  (list hoon)
      ?~  arg  ~
      =/  arg  u.arg
      ?^  -.arg
        (weld $(arg `-.arg) $(arg `+.arg))
      ?+    -.arg  ~|("j2h: expect valid function argument" !!)
          %atom
        ::  Atoms trivially map to Hoon atoms.
        ::  [%atom p=jatom]
        ::    [[%string p=term] q=?], etc.
        ^-  (list hoon)
        :_  ~
        ;;  hoon
        :+  ?:(q.p.arg %rock %sand)
          ?-  -<.p.arg
            %string       %ta
            %number       %ud
            %hexadecimal  %ux
            %loobean      %f
          ==
        p.p.arg
      ::
          %limb
        ::  Limbs must be resolved to a basic value.
        ::  [%limb p=(list jlimb)]
        ~|  %limb
        ~
      ::
          %list
        ::  Lists are composed of a series of values, which we unpack.
        ::  [%list type=jype-leaf val=(list jock)]
        ~|  %list
        :_  ~
        :-  %clsg
        %-  snip  :: spurious ~ from Jock representation
        %+  turn
          val.arg
        |=  item=jock
        ^-  hoon
        -:^$(arg `item)
      ::
          %set
        ::  Sets are a tree of values, which must be in the same order as Hoon.
        ::  [%set type=jype-leaf val=(set jock)]
        ~|  %set
        !!
      ==
    [%cncl p q]
  ::
  ::  Convert a Hoon type to a Jock jype.
  ++  type2jype
    |=  t=type
    ^-  jype
    :: +$  type  $+  type
    ::           $~  %noun                                     ::
    ::           $@  $?  %noun                                 ::  any nouns
    ::                   %void                                 ::  no noun
    ::               ==                                        ::
    ::           $%  [%atom p=term q=(unit @)]                 ::  atom / constant
    ::               [%cell p=type q=type]                     ::  ordered pair
    ::               [%core p=type q=coil]                     ::  object
    ::               [%face p=$@(term tune) q=type]            ::  namespace
    ::               [%fork p=(set type)]                      ::  union
    ::               [%hint p=(pair type note) q=type]         ::  annotation
    ::               [%hold p=type q=hoon]                     ::  lazy evaluation
    ::           ==                                            ::
    ?+    -.t
        ::  We cannot convert %core, %face, %fork, %hint, %void.
        ~|("cannot convert type {<t>} to valid jype" !!)
      ::
        %atom
      :_  %$
      ^-  jype-leaf
      :+  %atom
        ?+  p.t  ~|("cannot convert atom type {<p.t>} to jatom" !!)
          %ud   %number
          %ux   %hexadecimal
          %t    %string
          %ta   %string
          %tas  %string
          %f    %loobean
        ==
      =(~ q.t)
    ::
        %cell
      :_  %$
      ^-  jype-leaf
      :: [%list [type.p.t %$]]
      *jype-leaf
    ::
        %hold
      ::  %hold can mean a lot of things, but presumably means a container.
      :_  %$
      *jype-leaf
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
    ?^  -<.jype
      :: cell case
      ^-  nock
      :^    %6
          [%3 %0 axis]
        ^-  nock
        :^    %6
            `nock`[$(axis (mul 2 axis), jype `^jype`-<.jype)]
          `nock`[$(axis +((mul 2 axis)), jype `^jype`+<.jype)]
        [%1 1]
      [%1 1]
    ::  atom case
    ?+    -.-.jype
      ::  default case:  %atom, %core, %limb
        ~|((crip "hunt: can't match {<`@tas`-<.jype>}") !!)
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
        ~|((crip "hunt: can't match {<`@tas`-<.jock>}") !!)
      ::
        %atom
      [%5 [%1 `@`+.p.jock] %0 axis]
    ==
  --
  ::
  ::  Prettyprinter
  ++  pprint
    |=  [=nock =jype]
    ^-  tank
    :: ?^  -<.j    [$(j p.j) $(j q.j)]
    ?+    -<.jype
        :-  %leaf
        "print: {<[-.jype]>} {<`*`nock>}"
    ::
        %atom
      %-  crip
      ?-    ->-.jype
        %loobean
      "{<;;(? +.nock)>}"
      ::
        %number
      "{<;;(@ud +.nock)>}"
      ::
        %hexadecimal
      "{<;;(@ux +.nock)>}"
      ::
        %string
      "{<;;(@t +.nock)>}"
      ::
      ==
    ::
    ==
--
