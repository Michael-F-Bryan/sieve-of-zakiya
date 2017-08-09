\ ANS Forth implementation of Secure Hash Algorithm SHA-1
\ FIPS 180-4 spec at: http://csrc.nist.gov/publications/PubsFIPS.html
\ Also HMAC for SHA-1 as specified in FIPS PUB 198-1
\ Code accommodates Big and Little Endian, byte addressable CPUs.
\
\ ------------ This implementation is for 32-bit systems ------------
\
\ DEPENDENCIES: CORE EXT WORDSET ; COMMON USAGE: ?DO CELL-
\ Use of this code is free subject to acknowledgment of copyright.
\ Copyright (c) 2001-2013 Jabari Zakiya - jzakiya@mail.com  2013/1/15
\
\ To find/show the hash of a string or counted message do:
\ Example: S" some message string" SHAbuffer Hash.
\ To find the hash of a file use:  SHAfile

0 [IF] ===================== SHA-1 ALGORITHM =======================

    All values are 32-bits -- this implementation assumes 32-bit cpu

                      ft (x, y, z) = :
    Ch(x, y, z) = (x and y) xor (not x and z)               0 <= t <= 19
    Parity(x, y, z) = x xor y xor z                        20 <= t <= 39
    Maj(x, y, z) = (x and y) xor (x and z) xor (y and z)   40 <= t <= 59
    Parity(x, y, z) = x xor y xor z                        60 <= t <= 79

Each message block, M(1), …, M(N), is processed as follows:

For i=1 to N:
{
   1. Prepare the message schedule, {W(t)}:

              | M(t)                                                0 <= t <= 15
      W(t) = -|
              | ROTL_1(W(t-3) xor W(t-8) xor W(t-14) xor W(t-16))  16 <= t <= 79

   2. Initialize  a, b, c, d, e  with the (i-1)st hash value:

      a = H0(i-1)  b = H1(i-1)  c = H2(i-1)  d = H3(i-1)  e = H4(i-1)

   3. For t=0 to 79:
    {
      T = ROTL_5(a) + ft(b,c,d) + e + Kt + Wt
      e = d
      d = c
      c = ROTL_30(b)
      b = a
      a = T
    }
   4. Compute the ith intermediate hash value H(i):
     H0(i) = a + H0(i-1)
     H1(i) = b + H1(i-1)
     H2(i) = c + H2(i-1)
     H3(i) = d + H3(i-1)
     H4(i) = e + H4(i-1)
}
     160-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2{N)|H3(N)|H4{N)                       [THEN]

\ =============================================================
\ MACRO wordset from Wil Baden's Tool Belt series in
\ Forth Dimensions (FD) Vol. 19, No. 2, July/August 1997
\ Original code has been modified to make more efficient
\ MACRO allows insertion of parameters following the macro
\ "\" represents place where parameter is inserted
\ Example:  MACRO  ??  " IF  \  THEN "
\ : FOO .. ?? EXIT .... ;  ?? compiles to -- IF EXIT THEN

\ PLACE and STRING for system if needed
\ : PLACE  ( caddr n addr -)  2DUP  C!  CHAR+  SWAP  CHARS  MOVE ;
: SSTRING ( char "ccc" -) WORD COUNT HERE OVER 1+ CHARS ALLOT PLACE ;

\ Versions of /STRING and ANEW if system doesn't have them
\ : /STRING ( a n k - a+k n-k) ( OVER MIN) TUCK - >R CHARS + R> ;
\ : ANEW  >IN @ BL WORD FIND IF EXECUTE ELSE DROP THEN >IN ! MARKER ;

: split-at-char  ( a  n  char  -  a  k  a+k  n-k)
  >R  2DUP  BEGIN  DUP  WHILE  OVER  C@  R@  -
            WHILE  1 /STRING  REPEAT  THEN
            R> DROP  TUCK  2>R  -  2R>
;

: DOES>MACRO  \ Compile the macro, including external parameters
  DOES> COUNT  BEGIN [CHAR]  \ split-at-char  2>R  EVALUATE  R@
               WHILE BL WORD COUNT EVALUATE 2R>  1 /STRING REPEAT
               R> DROP   R> DROP
;

\ Macro creation word which allows parameter insertion
: MACRO  CREATE  IMMEDIATE  CHAR  SSTRING  DOES>MACRO  ;

\ ====================    Utility Words    =====================

 [UNDEFINED] ]L [IF] : ]L  ] POSTPONE LITERAL ; IMMEDIATE  [THEN]

 [UNDEFINED] CELL- [IF] : CELL- ( x - n ) [ 1 CELLS ]L - ; [THEN]

 [UNDEFINED] U>D [IF] : U>D ( n - n 0 )  0 ; [THEN]

\ =====================  Start SHA-1 Code ======================
  DECIMAL
  32 CONSTANT CELLSIZE          \ CPU bitsize

  2VARIABLE  SHAlen             \ Holds byte length of message <= 2^61 bytes
  CREATE SHAval  5 CELLS ALLOT  \ Holds hash after each block
  CREATE SHAsh  85 CELLS ALLOT  \ Fully extended hash array
  CREATE W      16 CELLS ALLOT  \ Holds message block
  1 W !                         \ For endian testing

  HEX
       5a827999  CONSTANT  K1   \ Constant for rounds  0 - 19
       6ed9eba1  CONSTANT  K2   \ Constant for rounds 20 - 39
       8f1bbcdc  CONSTANT  K3   \ Constant for rounds 40 - 59
       ca62c1d6  CONSTANT  K4   \ Constant for rounds 60 - 79

  DECIMAL

  0 VALUE H[E]  \ Pointer to addr of hash value E for each round

MACRO H[D] " H[E]  [ 1 CELLS ]L  +"  \ Return D adr
MACRO H[C] " H[E]  [ 2 CELLS ]L  +"  \ Return C adr
MACRO H[B] " H[E]  [ 3 CELLS ]L  +"  \ Return B adr
MACRO H[A] " H[E]  [ 4 CELLS ]L  +"  \ Return A adr

: SHAinit ( -)     \ Load initial hash values H0 - H4
  [ HEX ] 67452301 ( H0)  DUP  [ SHAsh 4 CELLS + ]L ! [ SHAval 4 CELLS + ]L !
          efcdab89 ( H1)  DUP  [ SHAsh 3 CELLS + ]L ! [ SHAval 3 CELLS + ]L !
          98badcfe ( H2)  DUP  [ SHAsh 2 CELLS + ]L ! [ SHAval 2 CELLS + ]L !
          10325476 ( H3)  DUP  [ SHAsh 1 CELLS + ]L ! [ SHAval 1 CELLS + ]L !
          c3d2e1f0 ( H4)  DUP    SHAsh !  SHAval !    [ DECIMAL ] 
  SHAsh TO H[E]    \ Init pointer to last hash value H5=e
;

: UpDateHash ( -)  \ Update values: SHAsh(i) = SHAval(i) = SHAval(i-1) + H(i-1)
  H[E] DUP @ [ SHAval 0 CELLS + ]L TUCK +! @ [ SHAsh 0 CELLS + ]L ! CELL+
       DUP @ [ SHAval 1 CELLS + ]L TUCK +! @ [ SHAsh 1 CELLS + ]L ! CELL+
       DUP @ [ SHAval 2 CELLS + ]L TUCK +! @ [ SHAsh 2 CELLS + ]L ! CELL+
       DUP @ [ SHAval 3 CELLS + ]L TUCK +! @ [ SHAsh 3 CELLS + ]L ! CELL+
           @ [ SHAval 4 CELLS + ]L TUCK +! @ [ SHAsh 4 CELLS + ]L !
  SHAsh TO H[E]    \ Init pointer to last hash value H5=e
;

\ Put two copies of original Wi on stack, keep its address
MACRO Wi@ " DUP  @  TUCK"  ( [Wi] - wi [Wi] wi)

\ Create 2 copies of new Wi' from Wi on stack  ( ..Wi -..Wi' Wi')
MACRO Wi  " 15 PICK  14 PICK  XOR  8 PICK  XOR  3 PICK  XOR "

\ Drop 80 Wi cells from stack ( W0..W79 - )
[DEFINED] NDROP  [IF]
MACRO WiDROP " 80 NDROP "  \ VFX, et al
[ELSE] 
MACRO WiDROP " 5 0 DO 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP LOOP "
[THEN]

\ ( - n )  n = B XOR C XOR D
MACRO F2  " H[C] 2@  XOR  H[D] @  XOR "

\ ( - n )  n = (B AND C) XOR (~B AND D)
MACRO F1  " H[C] 2@  OVER  AND  SWAP  INVERT  H[D]  @  AND  XOR "

\ ( - n )  n = (B AND C) XOR (B AND D) XOR (C AND D)
MACRO F3  " H[D]  DUP >R  CELL+ 2@  OVER AND SWAP  R@ @ AND XOR  R> 2@ AND XOR "

[DEFINED] rol
[IF]  MACRO rol_1  "  1 rol "
      MACRO rol_5  "  5 rol "
      MACRO rol_30 " 30 rol "
[ELSE]
      MACRO rol_   " DUP >R [ CELLSIZE \ TUCK - ]L RSHIFT R> LITERAL LSHIFT OR "
      MACRO rol_1  " rol_ 1 "
      MACRO rol_5  " rol_ 5 "
      MACRO rol_30 " rol_ 30 "
[THEN]

: HashAdjust ( T -)  \ Adjust hash array for next round
  H[B]  DUP  @  rol_30  SWAP  !  \ T     ;B = S(B,30) = rol(B,30)
  H[D]  DUP  TO  H[E]            \ T [E] ;H[E] points to former H[D]
  [ 4 CELLS ]L  +  ( H[A]) !     \ --    ;store T into new A
;

MACRO subrnd1  " Wi@              H[A] @  rol_5  +  H[E] @  + "
MACRO subrnd2  " Wi   rol_1  DUP  H[A] @  rol_5  +  H[E] @  + "

: rnds1  ( [W0] -  W0..W19) \ Do hash algorithm for rounds  0 - 19
  16 0 DO  subrnd1  K1  +  F1  +  ( T)  \ ..Wi [Wi] Wi+S(A,5)+E+K1+F1
           HashAdjust                   \ . Wi [Wi]
           CELL+                        \ ..Wi [Wi]'
  LOOP     DROP                         \ W0..W15   ;original block
   4 0 DO  subrnd2  K1  +  F1  +  ( T)  \ ..Wi Wi+S(A,5)+E+K1+F1
           HashAdjust                   \ ..Wi
  LOOP                                  \ ..W19
;

: rnds2  ( ..W19 - ..W39)   \ Do hash algorithm for rounds 20 - 39
  20 0 DO  subrnd2  K2  +  F2  +  ( T)  \ ..Wi Wi+S(A,5)+E+K2+F2
           HashAdjust                   \ ..Wi
  LOOP                                  \ ..W39
;

: rnds3  ( ..W39 - ..W59)   \ Do hash algorithm for rounds 40 - 59
  20 0 DO  subrnd2  K3  +  F3  +  ( T)  \ ..Wi Wi+S(A,5)+E+K3+F3
           HashAdjust                   \ ..Wi
  LOOP                                  \ ..W59
;

: rnds4  ( ..W59 - ..W79)   \ Do hash algorithm for rounds 60 - 79
  20 0 DO  subrnd2  K4  +  F2  +  ( T)  \ ..Wi Wi+S(A,5)+E+K4+F2
           HashAdjust                   \ ..Wi
  LOOP                                  \ ..W79
;

: SHA1  ( adr -)  \ Compute 160-bit SHA-1 hash of 512-bit message block
  rnds1  rnds2  rnds3  rnds4  WiDROP    \ Do SHA-1, create H[A]-H[E]
  UpDateHash                            \ Compute|update hash values
;

: setlen  ( -- )  \ Store bit count into last two cells
  SHAlen 2@  D2* D2* D2* ( bytes->bits) [ W 56 CHARS + ]L ! [ W 60 CHARS + ]L !
;

: bytes>< ( m -- w )  \ Reverse cell bytes: 12345678 <-> 78563412
  [ HEX ]  DUP >R  18 LSHIFT  R@  FF00 AND  8 LSHIFT  OR
  R@  FF0000 AND  8 RSHIFT  OR  R>  18 RSHIFT  OR  [ DECIMAL ]
;

: cellsreverse  ( adr n -- )  \ Reverse bytes of n cells in array
  0 DO  DUP  @  bytes><  OVER !  CELL+  LOOP  DROP
;

W C@ [IF]  \ if Little Endian, e.g. Intel
        MACRO endian5  "  DUP   5  cellsreverse "  ( adr -- adr )
        MACRO endian14 "  DUP  14  cellsreverse "  ( adr -- adr )
        MACRO endian16 "  DUP  16  cellsreverse "  ( adr -- adr )
[ELSE]     \ if Big Endian, e.g. PowerPC
        MACRO endian5  "  "  ( adr -- adr )  \ Do nothing
        MACRO endian14 "  "  ( adr -- adr )  \ Do nothing
        MACRO endian16 "  "  ( adr -- adr )  \ Do nothing
[THEN]

\ Do all 64 byte blocks leaving remainder block
: hashfullblocks ( adr1 ud -- adr2 count )
  SWAP  DUP >R  6 RSHIFT               ( adr1 hi lo* ) \ Store lo on return, lo*=lo/64
  OVER [ CELLSIZE 6 - ]L LSHIFT OR >R  ( adr1 hi     ) \ Return is now: :R lo lo'
  ( hi) 6 RSHIFT 0 ?DO                 ( adr1        ) \ Do if hi'= hi/64 > 0
    0 0 DO DUP endian16 SHA1 64 + LOOP ( adr'        ) \ Hash for 2^cellsize full blocks
  LOOP                                 ( adr'        ) \ Hash for hi'*2^cellsize full blocks
  R> 0 ?DO DUP endian16 SHA1 64 + LOOP ( adr'        ) \ Hash for lo' count full 64 byte blocks
  R> ( lo) 63 AND                      ( adr2 cnt    ) \ Leave address and count for partial block
;

: hashfinal ( addr count -- )  \ Hash partial and/or last block
  DUP >R  W  SWAP  CMOVE                \ Move bytes into block W array
  W  R@ +  128  OVER  C!   ( adr     )  \ Put 80h after last message byte
  CHAR+  55 R@ -           ( adr #   )  \ Compute tentative 0 byte FILL count
  R> 55 >                  ( adr # ? )  \ Is partial block byte count > 55 ?
  IF  8 + 0  FILL          ( --      )  \ If yes, FILL rest of block w/zeroes
      W  endian16  SHA1    ( --      )  \ Endian adjust block if required, then hash
      W  56                ( adr 56  )  \ Now setup last block containing bit count
  THEN                     ( adr #   )
  0 FILL  setlen  W  endian14  SHA1     \ Zero FILL last block, set message bit count
;

\ Compute SHA-1 from a counted buffer of text
: (SHAbuffer) ( addr ud - ) SHAinit  2DUP  SHAlen 2! hashfullblocks hashfinal ;
: SHAbuffer   ( addr n -- ) U>D  (SHAbuffer) ;

\ =====================  HMAC SHA-1 Code =====================

 HEX  36363636 CONSTANT ipad   5C5C5C5C CONSTANT opad  DECIMAL
 CREATE mackey  64 CHARS  ALLOT
 CREATE iarray  64 CHARS  ALLOT
 CREATE oarray  64 CHARS  ALLOT

: hash>mackey  ( - )  \ Store hash values in mackey array
  mackey  [ SHAval 4 CELLS + ]L
  5 0 DO  DUP >R  @  OVER  !  CELL+  R>  CELL-  LOOP  2DROP
  mackey  endian5  DROP  \ Make sure key stored in Big Endian order
;

: keyxor ( #pad  kadr  iadr - )
  16 0 DO  >R  2DUP  @  XOR  R@  !  CELL+  R>  CELL+  LOOP
  2DROP  DROP
;

: setkeys ( keyadr bytecnt - )  \ Process HMAC key, set arrays
  mackey  64  0  FILL                    \ Set key array to all '0'
  DUP  64 > IF    SHAbuffer hash>mackey  \ Hash key; store in mackey
            ELSE  mackey  SWAP  CMOVE    \ Put key vals in key array
            THEN
  ipad  mackey  iarray  keyxor           \ iarray = mackey XOR ipad
  opad  mackey  oarray  keyxor           \ oarray = mackey XOR opad
;

MACRO [SHA1-MAC]  " SHAinit  endian16  SHA1  hashfullblocks  hashfinal"

: SHA1-MAC  ( addr count - )  \ Perform HMAC on input data
  DUP 64 + U>D SHAlen 2! U>D iarray [SHA1-MAC] \ Inner hash
  hash>mackey  mackey 20 U>D  84 U>D SHAlen 2! \ ( mackey  20 0)
  oarray  [SHA1-MAC]                           \ Outer hash
;

: HMAC-SHA1  ( datadr n1  keyadr n2 - )  setkeys  SHA1-MAC ;

\ ===============  Hash string display wordset  ===============
  DECIMAL

\ Array of digits 0123456789abcdef
: digit$  ( -- adr )  S" 0123456789abcdef"  DROP  ;

: intdigits ( -- )  0 PAD  ! ;
: savedigit ( n -- )  PAD  C@  1+  DUP  PAD  C!  PAD  +  C!  ;
: bytedigits ( n1 -- )
  DUP 4 RSHIFT digit$ + C@ savedigit 15 AND digit$ + C@ savedigit
;

  W C@ [IF] \ Little Endian
: celldigits ( a1 -- )  DUP 3 + DO I C@ bytedigits  -1 +LOOP ;
  [ELSE]    \ Big Endian
: celldigits ( a1 -- )  DUP 4 + SWAP DO I C@ bytedigits LOOP ;
  [THEN]

: SHAstring ( -- adr count )  \ Return counted SHA-1 string array
  intdigits  [ SHAval 4 CELLS + ]L
  5 0 DO  DUP  celldigits  CELL-  LOOP  DROP  PAD  COUNT
;

\ Display SHA-1 hash value in hex ( A B C D E )
: HASH. CR  SHAstring  TYPE  SPACE  ;

: QuoteString ( adr cnt --)  [CHAR] " EMIT  TYPE  [CHAR] " EMIT ;

\ ====================  File hash wordset  ====================
  VARIABLE  rfileid     \ Holds fileid number of input file

: InputFileName  ( -- ior)
  CR  CR  ." Filename: "  PAD  DUP  80  ACCEPT ( adr #)
  R/O  OPEN-FILE  SWAP  rfileid !  ( ior)
;

: TryAgain?  ( -- ?)
  CR  CR ." Invalid iput file, try again? (Y/N)"
  KEY  DUP  EMIT  DUP [CHAR] N =  SWAP [CHAR] n = OR
;

\ Read n bytes from input file, store at addr array
: bytes@  ( adr n - )  rfileid @  READ-FILE  2DROP ;

: storelen  ( lo hi - )  \ Store count into last two cells
  D2*  D2*  D2*  [ W 56 CHARS + ]L !  [ W 60 CHARS + ]L !
;

\ Read partial block bytes from input file, pad with 80
: getpartial ( cnt  -- W'  cnt2 ?)
  W  2DUP  SWAP  DUP >R  bytes@        ( cnt1 adr1  )
  + 128 OVER C! CHAR+ 55 R@ - R> 55 >  ( adr2 cnt2 ?)
;

MACRO block@  " W  64  bytes@ "

: SHAfile ( -- )
  BEGIN  InputFileName  ( ior)                  \ Enter filename
  WHILE  TryAgain? IF  EXIT  THEN               \ Not valid, try (not) again
  REPEAT SHAinit                                \ Valid file, init transform
  rfileid @  FILE-SIZE  DROP  ( ud )            \ Get bytesize of input file
  0 0  D-                                       \ Adjust to hash subset of file
  CR ." Bytesize: " 2DUP  D.                    \ Display hash size to screen
  2DUP  2>R                                     \ ( lo  hi ) Save file byte cnt on RETURN
  OVER  6 RSHIFT OVER                           \ ( lo  hi lo* hi )
  [ CELLSIZE 6 - ]L LSHIFT OR  SWAP  6 RSHIFT   \ ( lo  lo' hi') lo' hi' now full block count
  0 ?DO 0 0 DO block@ W endian16 SHA1 LOOP LOOP \ Hash hi*2^cellsize full blocks
  0 ?DO block@  W endian16 SHA1 LOOP            \ Hash lo count full 64 byte blocks
  ( lo) 63 AND ( rembytes) getpartial ( adr cnt ?)  \ Read remaining bytes
  IF 8 + 0 FILL  W endian16  SHA1  W 56 THEN    \ Do if rembytes > 55
  0 FILL  2R> storelen  W endian14  SHA1        \ Do last block
  CR  ." SHA1 : "  SHAstring  TYPE  CR          \ Show SHA-1 hash for file
  rfileid @  CLOSE-FILE  DROP                   \ Close the input file
;

\ ====================  SHA-1 Test Suite  =====================
  DECIMAL

\ Load W array with data on stack
: WLoad ( d0..d15 -- )  [ W 15 CELLS + ]L
  16 0 DO  TUCK  !  CELL-  LOOP  DROP
;

\ -------------------------------------------------------------
\ EXAMPLE 1: from FIPS PUB 180-1
\ Message: ASCII string 'abc'
\ Hash = A9993E36  4706816A  BA3E2571  7850C26C  9CD0D89D

\ Compute and display hash for ASCII string 'abc'
: EX1  S" abc"  SHAbuffer  HASH.  ;

\ -------------------------------------------------------------
\ EXAMPLE 2: from FIPS PUB 180-1
\ Message:'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'
\ Hash = 84983E44  1C3BD26E  BAAE4AA1  F95129E5  E54670F1

: EX2a  S" abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" ;
: EX2  EX2a  SHAbuffer  HASH.  ;

\ -------------------------------------------------------------
\ EXAMPLE 3: from FIPS PUB 180-1
\ Message: 1 million copies of 'a' (61h), (8 million bits)
\ Hash = 34AA973C  D4C4DAA4  F61EEB2B  DBAD2731  6534016F

\ Load block of all 'a's (61h), must hash 15,625 times
: EX3a  W  64  [CHAR] a  FILL  ;

\ Last message block: 1st bit a '1', bit-count = 8 million
: EX3b  [ HEX ] 80000000 0 0 0 0 0 0 0 0 0 0 0 0 0
        [ DECIMAL ] 0 8000000 WLoad
;
\ Do hash for message of 1 million copies of ASCII 'a' (61h)
: EX3  SHAinit  EX3a  15625 0 DO W SHA1 LOOP  EX3b  W SHA1 HASH. ;

\ -------------------------------------------------------------
\ Message: 10,000 SPACES 'BL' (20h), (80,000 bits)
\ Hash = 37C7DDC3  EFEC3BDC  4ED4CD05  12447278  DFF38E2E

\ Load block of all "BL' (20h), hash 156 full blocks + 16 bytes
: EX4a  W  64  BL  FILL  ;

\ Last message block: 16 SPACES, bit-count = 80,000
: EX4b  [ HEX ] 20202020 20202020 20202020 20202020 80000000
                0 0 0 0 0 0 0 0 0 0 [ DECIMAL ] 80000 WLoad
;
\ Do hash for message of 10,000 SPACES 'BL' (20h)
: EX4  SHAinit  EX4a  156 0 DO  W SHA1  LOOP  EX4b  W SHA1 HASH. ;

\ -------------------------------------------------------------
\ Message: blank string ''
\ Hash =  DA39A3EE  5E6B4B0D  3255BFEF  95601890  AFD80709

: SHATest ( -- )
  CR ." SHA-1 FIPS PUB 180-1 test suite + others:"
  S" "  SHAbuffer  HASH.  S" "  QuoteString
  EX1  S" abc"  QuoteString
  EX2  EX2a     QuoteString
  EX3  S" 1 million copies of ASCII 'a' (61h)" TYPE
  EX4  S" 10,000 copies of ASCII BL (20h)" TYPE  CR
;

\ ==================  HMAC-SHA1 Test Suite  ===================
  DECIMAL

  CREATE  testkey  100 CHARS  ALLOT
  CREATE  macdata   80 CHARS  ALLOT

: incr! 0 DO  2DUP C! SWAP 1+  SWAP  CHAR+  LOOP  2DROP ;
: .hmac-sha1 ( - ) hmac-sha1  SHAstring  TYPE  CR ;

: T1  ( - ) \ IETF RFC 2202 test case 1
  CR ." IETF RFC 2202 Test Case 1 for HMAC-SHA1"
  CR ." Key  = 20 bytes of hex value 0b"
  CR ." Data = ASCII phrase 'Hi There'"
  CR ." Expected hash is: b617318655057264e28bc0b6fb378c8ef146be00"
  CR ." Computed hash is: "
  testkey 20 11 FILL  S" Hi There"  testkey 20  .hmac-sha1
;

: T2  ( - ) \ IETF RFC 2202 test case 2
  CR ." IETF RFC 2202 Test Case 2 for HMAC-SHA1"
  CR ." Key  = ASCII phrase 'Jefe'"
  CR ." Data = ASCII phrase 'what do ya want for nothing?'"
  CR ." Expected hash is: effcdf6ae5eb2fa2d27416d5f184df9c259a7c79"
  CR ." Computed hash is: "
  S" what do ya want for nothing?"  S" Jefe"  .hmac-sha1
;

: T3  ( - ) \ IETF RFC 2202 test case 3
  CR ." IETF RFC 2202 Test Case 3 for HMAC-SHA1"
  CR ." Key  = 20 bytes of hex value aa"
  CR ." Data = 50 bytes of hex value dd"
  CR ." Expected hash is: 125d7342b9ac11cd91a39af48aa17b4f63f175d3"
  CR ." Computed hash is: "
  [ HEX ] testkey 014 0aa FILL   macdata 032 0dd FILL  [ DECIMAL ]
  macdata 50  testkey 20  .hmac-sha1
;

: T4  ( - ) \ IETF RFC 2202 test case 4
  CR ." IETF RFC 2202 Test Case 4 for HMAC-SHA1"
  CR ." Key  = 0102030405060708090a0b0c0d0e0f10111213141516171819"
  CR ." Data = 50 bytes of hex value cd"
  CR ." Expected hash is: 4c9007f4026250c6bc8414f9bf50c86c2d7235da"
  CR ." Computed hash is: "
  01 testkey 25 incr!  [ HEX ] macdata 032 0cd FILL  [ DECIMAL ]
  macdata 50  testkey 25  .hmac-sha1
;

: T5  ( - ) \ IETF RFC 2202 test case 5
  CR ." IETF RFC 2202 Test Case 5 for HMAC-SHA1"
  CR ." Key  = 20 bytes of hex value 0c"
  CR ." Data = ASCII phrase 'Test With Truncation'"
  CR ." Expected hash is: 4c1a03424b55e07fe7f27be1d58bb9324a9a5a04"
  CR ." Computed hash is: "
  testkey 20 12 FILL  S" Test With Truncation"  testkey 20  .hmac-sha1
;

: T6  ( - ) \ IETF RFC 2202 test case 6
  CR ." IETF RFC 2202 Test Case 6 for HMAC-SHA1"
  CR ." Key  = 80 bytes of hex value aa"
  CR ." Data = ASCII phrase 'Test Using Larger Than Block-Size Key - Hash Key First'"
  CR ." Expected hash is: aa4ae5e15272d00e95705637ce8a3b55ed402112"
  CR ." Computed hash is: "
  [ HEX ] testkey 050 0aa FILL  [ DECIMAL ]
  S" Test Using Larger Than Block-Size Key - Hash Key First"
  testkey 80  .hmac-sha1
;

: T7  ( - ) \ IETF RFC 2202 test case 7
  CR ." IETF RFC 2202 Test Case 7 for HMAC-SHA1"
  CR ." Key  = 80 bytes of hex value aa"
  CR ." Data = ASCII phrase 'Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data'"
  CR ." Expected hash is: e8e99d0f45237d786d6bbaa7965c7808bbff1a91"
  CR ." Computed hash is: "
  [ HEX ] testkey 050 0aa FILL  [ DECIMAL ]
  S" Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"
  testkey 80  .hmac-sha1
;

: T8  ( - ) \ NIST FIPS 198 test case A.1
  CR ." NIST FIPS 198 test case A.1 for HMAC-SHA1"
  CR ." Key  = 64 bytes iterated from 00010203...3c3d3e3f"
  CR ." Data = ASCII phrase 'Sample #1'"
  CR ." Expected hash is: 4f4ca3d5d68ba7cc0a1208c9c61e9c5da0403c0a"
  CR ." Computed hash is: "
  00 testkey 64 incr!  S" Sample #1"  testkey 64  .hmac-sha1
;

: T9  ( - ) \ NIST FIPS 198 test case A.2
  CR ." NIST FIPS 198 test case A.2 for HMAC-SHA1"
  CR ." Key  = 20 bytes 303132333435363738393a3b3c3d3e3f40414243"
  CR ." Data = ASCII phrase 'Sample #2'"
  CR ." Expected hash is: 0922d3405faa3d194f82a45830737d5cc6c75d24"
  CR ." Computed hash is: "
  [ HEX ]  30 testkey  14  incr!  [ DECIMAL ]
  S" Sample #2"  testkey 20  .hmac-sha1
;

: T10 ( - ) \ NIST FIPS 198 test case A.3
  CR ." NIST FIPS 198 test case A.3 for HMAC-SHA1"
  CR ." Key  = 100 bytes iterated from 50515253...b0b1b2b3"
  CR ." Data = ASCII phrase 'Sample #3'"
  CR ." Expected hash is: bcf41eab8bb2d802f3d05caf7cb092ecf8d1a3aa"
  CR ." Computed hash is: "
  [ HEX ]  50 testkey  64  incr!  [ DECIMAL ]
  S" Sample #3"  testkey 100  .hmac-sha1
;

: T11 ( - ) \ NIST FIPS 198 test case A.4
  CR ." NIST FIPS 198 test case A.4 for HMAC-SHA1"
  CR ." Key  = 49 bytes iterated from 70717273...9d9e9fa0"
  CR ." Data = ASCII phrase 'Sample #4'"
  CR ." Expected hash is: 9ea886efe268dbecce420c7524df32e0751a2a26"
  CR ." Computed hash is: "
  [ HEX ]  70 testkey  31  incr!  [ DECIMAL ]
  S" Sample #4"  testkey 49  .hmac-sha1
;

: HMAC-TESTS ( - )  CR  T1  T2  T3  T4  T5  T6  T7  T8  T9  T10  T11 ;

\ ====== Performance Test Code for various Forth systems ======
\ ==== Provide appropriate code here for systems not shown ====

\ Convert millisecond double count to  y.xxx    secs output
: msecs ( ud-ms -- ) <#  # # #       [char] . HOLD #S #> TYPE ."  secs" ;

\ Convert microsecond double count to  y.xxxxxx secs output
: usecs ( ud-us -- ) <#  # # # # # # [char] . HOLD #S #> TYPE ."  secs" ;

[DEFINED] VFXFORTH [IF]
\ ===========  VFX Forth specific timing test words ===========

  [UNDEFINED] GetTickCount
  [IF] extern: DWORD PASCAL GetTickCount( void ) [THEN]

: TIMER-START  ( - ms )  GetTickCount ;

: TIMER-END    ( ms - )  GetTickCount  SWAP - U>D  msecs ;

[THEN]

[DEFINED] WIN32FORTH-MENU-BAR [IF]
\ ===========  Win32Forth specific timing test words ==========

: TIMER-START  ( - ms )  MS@ ;

: TIMER-END    ( ms - )  MS@  SWAP - U>D  msecs ;

[THEN]

[DEFINED] SWIFTFORTH-TOOLBAR [IF]
\ ===========  SwiftForth specific timing test words ==========

: TIMER-START  ( - dtime)  ucounter ;

: TIMER-END    ( dtime -)  (utimer)  usecs ;

[THEN]

[DEFINED] InFoTable [IF]
\ =============  Gforth specific timing test words ============

: TIMER-START  ( - dtime)  utime ;

: TIMER-END    ( dtime -)  utime  2SWAP  D-  usecs ;

[THEN]

[DEFINED] TIMER-START [IF]
\ ================  Selected Performance tests ================

  DECIMAL 10000 VALUE N#

: [EX1]  S" abc"  SHAbuffer  ;
: [EX2]  EX2a     SHAbuffer  ;
: [EX3]  SHAinit  EX3a  15625 0 DO W SHA1 LOOP EX3b W SHA1 ;

: EX5a  S" abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqwxyz1234567890" ;
: [EX5] EX5a  SHAbuffer  ;
: EX5   [EX5] Hash.  ;

: test1  [ DECIMAL ]
  cr ." SHA-1 test for EX1 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX1]  LOOP  TIMER-END
;

: test2  [ DECIMAL ]
  cr ." SHA-1 test for EX2 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX2]  LOOP  TIMER-END
;

: test3  [ DECIMAL ]
  cr ." SHA-1 test for EX3 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX3]  LOOP  TIMER-END
;

: test5  [ DECIMAL ]
  cr ." SHA-1 test for EX5 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX5]  LOOP  TIMER-END
;

  CREATE testspace 10000 ALLOT  testspace 10000 BL FILL
  1000 TO N#

: speed-test
  cr ." SHA test: buffer of 10,000 spaces done " N# . ." times is "
  TIMER-START N# 0 DO  testspace  10000  SHAbuffer  LOOP  TIMER-END
  cr ." Hash is: " SHAstring TYPE  cr
;
[THEN]