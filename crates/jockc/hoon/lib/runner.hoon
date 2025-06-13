/+  jock
::
|_  libs=(map term cord)
++  parse
  |=  =cord
  ^-  (list token:jock)
  ~|  %parse
  (rash cord parse-tokens:~(. jock libs))
::
++  jeam
  |=  =cord
  ^-  jock:jock
  ~|  %jeam
  =/  res=(unit jock:jock)
    %-  mole
    |.
    (jeam:~(. jock libs) cord)
  ?~  res
    *jock:jock
  u.res
::
++  mint
  |=  =cord
  ^-  nock:jock
  ~|  %mint
  =/  res=(unit *)
    %-  mole
    |.
    (mint:~(. jock libs) cord)
  ?~  res
    *nock:jock
  ;;(nock:jock u.res)
::
++  jype
  |=  =cord
  ^-  jype:jock
  ~|  %jype
  =/  res=(unit jype:jock)
    %-  mole
    |.
    (jypist:~(. jock libs) cord)
  ?~  res
    *jype:jock
  u.res
::
++  nock
  |=  =cord
  ^-  *
  ~|  %nock
  =/  res=(unit *)
    %-  mole
    |.
    .*(%0 (mint:~(. jock libs) cord))
  ?~  res
    *nock:jock
  u.res
::
++  exec
  |=  =cord
  ^-  *
  =/  nok  (mint:~(. jock libs) cord)
  .*(0 +.nok)
::
--
