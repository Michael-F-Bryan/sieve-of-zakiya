\ ANS Forth code for Secure Hash Algorithms SHA-256 and SHA-224
\ FIPS 180-4 specs at: http://csrc.nist.gov/publications/PubsFIPS.html
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

0 [IF] ================ SHA-256||224 ALGORITHM =====================

    All values are 32-bits -- this implementation assumes 32-bit cpu

    Ch(x, y, z) = (x and y) xor (not x and z)
    Maj(x, y, z)= (x and y) xor (x and z) xor (y and z)

    SIGMA0 (x) = ROTR  2(x) xor ROTR 13(x) xor ROTR 22(x)
    SIGMA1 (x) = ROTR  6(x) xor ROTR 11(x) xor ROTR 25(x)
    sig0 (x)   = ROTR  7(x) xor ROTR 18(x) xor SHR  3(x)
    sig1 (x)   = ROTR 17(x) xor ROTR 19(x) xor SHR 10(x)

Each 512-bit message block, M(1), …, M(N), is processed as follows:

For i=1 to N:
{
   1. Prepare the message schedule, {W(t)}:

              | M(t)                                               0 <= t <= 15
      W(t) = -|
              | sig1(W(t-2)) + W(t-7) + sig0(W(t-15)) + W(t-16)   16 <= t <= 63

   2. Initialize a, b, c, d, e, f, g, h, with the (i-1)st hash value:

      a = H0(i-1)  b = H1(i-1)  c = H2(i-1)  d = H3(i-1)
      e = H4(i-1)  f = H5(i-1)  g = H6(i-1)  h = H7(i-1)

   3. For t=0 to 63:
    {
      T1 = h + SIGMA1(e) + Ch(e,f,g) + K(t) + W(t)
      T2 = SIGMA0(a) + Maj(a,b,c)
      h = g
      g = f
      f = e
      e = d + T1
      d = c
      c = b
      b = a
      a = T1 + T2
    }
   4. Compute the ith intermediate hash value H(i):
     H0(i) = a + H0(i-1)
     H1(i) = b + H1(i-1)
     H2(i) = c + H2(i-1)
     H3(i) = d + H3(i-1)
     H4(i) = e + H4(i-1)
     H5(i) = f + H5(i-1)
     H6(i) = g + H6(i-1)
     H7(i) = h + H7(i-1)
}
     SHA-256 256-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N)|H4(N)|H5(N)|H6(N)|H7(N)

     SHA-224 224-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N)|H4(N)|H5(N)|H6(N)           [THEN]

\ ======================= MACRO Wordset =======================
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

\ ==================== Choose SHA-256||224 =====================

  TRUE VALUE SHA?

: ChooseHash
  CR  CR  ." Select SHA-256 or SHA-224."
  CR      ." For SHA-224 hit Y|y, for SHA-256 hit any other key: "  
  KEY DUP [char] Y = SWAP [char] y = OR INVERT TO SHA? 
  CR SHA? IF ." SHA-256 selected" ELSE ." SHA-224 selected" THEN CR
;

  ChooseHash

\ =================  Start SHA-256||224 Code  =================
  DECIMAL
  32 CONSTANT CELLSIZE          \ CPU bitsize

  2VARIABLE  SHAlen             \ Holds byte length of message <= 2^61 bytes
  CREATE SHAval  8 CELLS ALLOT  \ Holds hash after each block
  CREATE SHAsh  72 CELLS ALLOT  \ Fully extended hash array
  CREATE W      16 CELLS ALLOT  \ Holds message block
  1 W !                         \ For compile time endian testing

  HEX
CREATE  Ki  \ SHA-256||224 round constants array
428a2f98 , 71374491 , b5c0fbcf , e9b5dba5 , 3956c25b , 59f111f1 , 923f82a4 , ab1c5ed5 ,
d807aa98 , 12835b01 , 243185be , 550c7dc3 , 72be5d74 , 80deb1fe , 9bdc06a7 , c19bf174 ,
e49b69c1 , efbe4786 , 0fc19dc6 , 240ca1cc , 2de92c6f , 4a7484aa , 5cb0a9dc , 76f988da ,
983e5152 , a831c66d , b00327c8 , bf597fc7 , c6e00bf3 , d5a79147 , 06ca6351 , 14292967 ,
27b70a85 , 2e1b2138 , 4d2c6dfc , 53380d13 , 650a7354 , 766a0abb , 81c2c92e , 92722c85 ,
a2bfe8a1 , a81a664b , c24b8b70 , c76c51a3 , d192e819 , d6990624 , f40e3585 , 106aa070 ,
19a4c116 , 1e376c08 , 2748774c , 34b0bcb5 , 391c0cb3 , 4ed8aa4a , 5b9cca4f , 682e6ff3 ,
748f82ee , 78a5636f , 84c87814 , 8cc70208 , 90befffa , a4506ceb , bef9a3f7 , c67178f2 ,

  DECIMAL

  0 VALUE H[H]  \ Pointer to addr of hash value H for each round

MACRO H[G]  " H[H]  [ 1 CELLS ]L  +"  \ Return G adr
MACRO H[F]  " H[H]  [ 2 CELLS ]L  +"  \ Return F adr
MACRO H[E]  " H[H]  [ 3 CELLS ]L  +"  \ Return E adr
MACRO H[D]  " H[H]  [ 4 CELLS ]L  +"  \ Return D adr
MACRO H[C]  " H[H]  [ 5 CELLS ]L  +"  \ Return C adr
MACRO H[B]  " H[H]  [ 6 CELLS ]L  +"  \ Return B adr
MACRO H[A]  " H[H]  [ 7 CELLS ]L  +"  \ Return A adr

SHA? [IF] \ For SHA-256
: SHAinit ( -)     \ Load initial SHA-256 hash values H0 - H7
  [ HEX ] 6a09e667 ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          bb67ae85 ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          3c6ef372 ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          a54ff53a ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          510e527f ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          9b05688c ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          1f83d9ab ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          5be0cd19 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

: H#  8 ;  \ Used in SHAstring to print out 8 32-bit hash values
: SHA-xxx ." SHA-256" ;

[ELSE]    \ For SHA-224
: SHAinit ( -)     \ Load initial SHA-224 hash values H0 - H7
  [ HEX ] c1059ed8 ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          367cd507 ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          3070dd17 ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          f70e5939 ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          ffc00b31 ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          68581511 ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          64f98fa7 ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          befa4fa4 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

: H#  7 ;  \ Used in SHAstring to print out 7 32-bit hash values
: SHA-xxx ." SHA-224" ;
[THEN]

: UpDateHash ( -)  \ Update values: SHAsh(i) = SHAval(i) = SHAval(i-1) + H(i-1)
  H[H] DUP @ [ SHAval 0 CELLS + ]L TUCK +! @ [ SHAsh 0 CELLS + ]L ! CELL+
       DUP @ [ SHAval 1 CELLS + ]L TUCK +! @ [ SHAsh 1 CELLS + ]L ! CELL+
       DUP @ [ SHAval 2 CELLS + ]L TUCK +! @ [ SHAsh 2 CELLS + ]L ! CELL+
       DUP @ [ SHAval 3 CELLS + ]L TUCK +! @ [ SHAsh 3 CELLS + ]L ! CELL+
       DUP @ [ SHAval 4 CELLS + ]L TUCK +! @ [ SHAsh 4 CELLS + ]L ! CELL+
       DUP @ [ SHAval 5 CELLS + ]L TUCK +! @ [ SHAsh 5 CELLS + ]L ! CELL+
       DUP @ [ SHAval 6 CELLS + ]L TUCK +! @ [ SHAsh 6 CELLS + ]L ! CELL+
           @ [ SHAval 7 CELLS + ]L TUCK +! @ [ SHAsh 7 CELLS + ]L !
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

[DEFINED] ROR [IF]

\ ( - n )  T1x = Ch(e,f,g) + SIGMA1(e) + h
: T1x  H[F] 2@  OVER  DUP >R  AND  SWAP  INVERT  H[G] @  AND  XOR  ( -- Ch  R:E)
       R@  6 ror  R@  11 ror  XOR  R>  25 ror  XOR ( SIGMA1[E]) +  H[H] @  +
;

\ ( - n )  T2 = Maj(a,b,c) + SIGMA0(a)
: T2  H[B] 2@ ( A B) >R DUP >R  2 ror  r@ 13 ror xor  r@ 22 ror xor ( - SIGMA0[a]  R:B A)
      H[C] @  DUP  R@ AND ( A^C)  R> R@ AND ( A^B) XOR  SWAP R> AND ( B^C) XOR ( Maj) +
;

\ ( x - n )  n = ROR7(X)   XOR  ROR18(X)  XOR  RSH3(X)
: sig0  ( x - n )  DUP >R   7 ROR  R@  18 ROR  XOR  R>  3 RSHIFT  XOR  ;

\ ( x - n )  n = ROR17(X)  XOR  ROR19(X)  XOR  RSH10(X)
: sig1  ( x - n )  DUP >R  17 ROR  R@  19 ROR  XOR  R> 10 RSHIFT  XOR  ;

[ELSE]

MACRO ror\  " DUP [ CELLSIZE \ TUCK - ]L LSHIFT SWAP LITERAL RSHIFT OR "

\ ( - n )  T1x = Ch(e,f,g) + SIGMA1(e) + h
: T1x  H[F] 2@  OVER  DUP >R  AND  SWAP  INVERT  H[G] @  AND  XOR  ( -- Ch  R:E)
       R@  ror\ 6  R@  ror\ 11  XOR  R>  ror\ 25  XOR ( SIGMA1[E]) +  H[H] @  +
;

\ ( - n )  T2 = Maj(a,b,c) + SIGMA0(a)
: T2  H[B] 2@ >R DUP >R ( A) ror\ 2  R@  ror\ 13 xor  R@  ror\ 22 xor ( - SIGMA0[a]  R:B A)
      H[C] @  DUP  R@ AND ( A^C)  R> R@ AND ( A^B) XOR  SWAP R> AND ( B^C) XOR ( Maj) +
;

\ ( x - n )  n = ROR7(X)   XOR  ROR18(X)  XOR  RSH3(X)
: sig0  ( x - n)   DUP >R  ror\  7  R@  ror\ 18  XOR  R>   3 RSHIFT  XOR  ;

\ ( x - n )  n = ROR17(X)  XOR  ROR19(X)  XOR  RSH10(X)
: sig1  ( x - n )  DUP >R  ror\ 17  R@  ror\ 19  XOR  R>  10 RSHIFT  XOR  ;

[THEN]

\ Put two copies of original Wi on stack, keep its address
MACRO Wi@  " DUP  @  TUCK"  ( [Wi] - wi [Wi] wi)

\ Create 2 copies of new Wi' from Wi on stack  ( ..Wi -..Wi' Wi')
MACRO Wi   " 15 PICK  15 PICK  sig0  +  7 PICK  +  2 PICK  sig1  +  DUP "

\ Drop 64 Wi cells from stack ( W0..W63 - )
[DEFINED] NDROP  [IF]
MACRO WiDROP " 64 NDROP "  \ VFX, et al
[ELSE] 
MACRO WiDROP " 4 0 DO 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP LOOP "
[THEN]

\ Add round constant Ki (to T1x to make T1) for each round
MACRO Ki+     " I @ + "
MACRO subrnd  " T1x +  Ki+  ( T1)  DUP  H[D]  +!  T2  +  H[G] TO H[H]  H[A] ! "

MACRO I+    " [ 1 CELLS ]L "
MACRO Ki16  " [ Ki 16 CELLS + ]L "
MACRO Ki64  " [ Ki 64 CELLS + ]L "

: SHA2xx  ( Wadr - )  \ Compute SHA-256||224 hash of 512-bit message block
  Ki16   Ki DO  Wi@  subrnd  CELL+ I+ +LOOP  DROP    \ ( W0..W15) original block
  Ki64 Ki16 DO  Wi   subrnd        I+ +LOOP  WiDROP  \ ( - )
  UpDateHash
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
      MACRO endian16 "  DUP  16  cellsreverse "  ( adr -- adr )
      MACRO endian14 "  DUP  14  cellsreverse "  ( adr -- adr )
[ELSE]     \ if Big Endian, e.g. PowerPC
      MACRO endian16 "  "  ( adr -- adr )  \ Do nothing
      MACRO endian14 "  "  ( adr -- adr )  \ Do nothing
[THEN]

\ Do all 64 byte blocks leaving remainder block
: hashfullblocks ( adr1 ud -- adr2 count )
  SWAP  DUP >R  6 RSHIFT               ( adr1 hi lo* ) \ Store lo on return, lo*=lo/64
  OVER [ CELLSIZE 6 - ]L LSHIFT OR >R  ( adr1 hi     ) \ Return is now: :R lo lo'
  ( hi) 6 RSHIFT 0 ?DO                 ( adr1        ) \ Do if hi'= hi/64 > 0
    0 0 DO DUP endian16 SHA2xx 64 + LOOP ( adr'      ) \ Hash for 2^cellsize full blocks
  LOOP                                   ( adr'      ) \ Hash for hi'*2^cellsize full blocks
  R> 0 ?DO DUP endian16 SHA2xx 64 + LOOP ( adr'      ) \ Hash for lo' count full 64 byte blocks
  R> ( lo) 63 AND                      ( adr2 cnt    ) \ Leave address and count for partial block
;

: hashfinal ( addr count -- )  \ Hash partial and/or last block
  DUP >R  W  SWAP  CMOVE                \ Move bytes into block W array
  W  R@ +  128  OVER  C!   ( adr     )  \ Put 80h after last message byte
  CHAR+  55 R@ -           ( adr #   )  \ Compute tentative 0 byte FILL count
  R> 55 >                  ( adr # ? )  \ Is partial block byte count > 55 ?
  IF  8 + 0  FILL          ( --      )  \ If yes, FILL rest of block w/zeroes
      W  endian16  SHA2xx  ( --      )  \ Endian adjust block if required, then hash
      W  56                ( adr 56  )  \ Now setup last block containing bit count
  THEN                     ( adr #   )
  0 FILL  setlen  W  endian14  SHA2xx   \ Zero FILL last block, set message bit count
;                               ( -- )  \ Endian adjust, except bit count, then hash

\ Compute SHA-256||224 from a counted buffer of text
: (SHAbuffer) ( addr ud - ) SHAinit  2DUP  SHAlen 2! hashfullblocks hashfinal ;
: SHAbuffer   ( addr n -- ) U>D  (SHAbuffer) ;

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

: SHAstring ( -- adr count )  \ Return counted SHA-2xx string array
  intdigits  [ SHAval 7 CELLS + ]L
  H# 0 DO  DUP  celldigits  CELL-  LOOP  DROP  PAD  COUNT
;

\ Display SHA-256||224 hash value in hex
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

: storelen  ( lo hi - )  \ Store bit count into last two cells
  D2* D2* D2* ( bytes->bits) [ W 56 CHARS + ]L ! [ W 60 CHARS + ]L !
;

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
  0 ?DO 0 0 DO block@  W endian16 SHA2xx LOOP LOOP  \ Hash hi*2^cellsize full blocks
  0 ?DO block@  W endian16 SHA2xx LOOP              \ Hash lo count full 64 byte blocks
  ( lo) 63 AND ( rembytes) getpartial ( adr cnt ?)  \ Read remaining bytes
  IF 8 + 0 FILL  W endian16  SHA2xx  W 56 THEN  \ Do if rembytes > 55
  0 FILL  2R> storelen  W endian14  SHA2xx      \ Do last block
  CR  SHA-xxx ."  : "  SHAstring  TYPE  CR      \ Show SHA-256||224 hash for file
  rfileid @  CLOSE-FILE  DROP                   \ Close the input file
;

\ ==================  SHA-256||224 Test Suite  ===================
  DECIMAL

\ Load W array with data on stack
: WLoad ( d0..d15 -- )  [ W 15 CELLS + ]L  ( d0..d15 W[15] )
  16 0 DO  TUCK  !  CELL-  LOOP  DROP
;

\ -------------------------------------------------------------
\ EXAMPLE 1: from FIPS PUB 180-4
\ Message: ASCII string 'abc'
\ Hash = ba7816bf 8f01cfea 414140de 5dae2223 b00361a3 96177a9c b410ff61 f20015ad
\ Hash = 75388b16 512776cc 5dba5da1 fd890150 b0c6455c b4f58b19 52522525

\ Compute and display hash for ASCII string 'abc'
: EX1  S" abc"  SHAbuffer  HASH. ;

\ -------------------------------------------------------------
\ EXAMPLE 2: from FIPS PUB 180-4
\ Message:'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'
\ Hash = 248d6a61 d20638b8 e5c02693 0c3e6039 a33ce459 64ff2167 f6ecedd4 19db06c1
\ Hash = 75388b16 512776cc 5dba5da1 fd890150 b0c6455c b4f58b19 52522525

: EX2a  S" abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" ;
: EX2  EX2a  SHAbuffer  HASH.  ;

\ -------------------------------------------------------------
\ EXAMPLE 3:
\ Message: 1 million copies of 'a' (61h), (8 million bits)
\ Hash = cdc76e5c 9914fb92 81a1c7e2 84d73e67 f1809a48 a497200e 046d39cc c7112cd0
\ Hash = 20794655 980c91d8 bbb4c1ea 97618a4b f03f4258 1948b2ee 4ee7ad67

\ Load block of all 'a's (61h), must hash 15,625 times
: EX3a  W  64  [CHAR] a  FILL  ;

\ Last message block: 1st bit a '1', bit-count = 8 million
: EX3b  [ HEX ] 80000000 0 0 0 0 0 0 0 0 0 0 0 0 0
        [ DECIMAL ] 0 8000000 WLoad
;
\ Do hash for message of 1 million copies of ASCII 'a' (61h)
: EX3  SHAinit  EX3a  15625 0 DO W SHA2xx LOOP  EX3b  W SHA2xx HASH. ;

\ -------------------------------------------------------------
\ EXAMPLE 4:
\ Message: 10,000 SPACES 'BL' (20h), (80,000 bits)
\ Hash = 7c99bc05 0d0856d0 5a0d84b5 44718f5f 2764cf6e fc939d70 42086f27 19fe8ec2
\ Hash = d68d2880 5c942e40 1d191d88 e989bf3d 00bec307 0872604c 1379e847

\ Load block of all "BL' (20h), hash 156 full blocks + 16 bytes
: EX4a  W  64  BL  FILL  ;

\ Last message block: 16 SPACES, bit-count = 80,000
: EX4b  [ HEX ] 20202020 20202020 20202020 20202020 80000000
                0 0 0 0 0 0 0 0 0 [ DECIMAL ] 0 80000 WLoad
;

\ Do hash for message of 10,000 SPACES 'BL' (20h)
: EX4  SHAinit  EX4a  156 0 DO  W SHA2xx  LOOP  EX4b  W SHA2xx HASH. ;

\ -------------------------------------------------------------
\ Message: blank string ''
\ Hash = e3b0c442 98fc1c14 9afbf4c8 996fb924 27ae41e4 649b934c a495991b 7852b855
\ Hash = d14a028c 2a3a2bc9 476102bb 288234c4 15a2b01f 828ea62a c5b3e42f

: SHATest ( -- )
  CR  SHA-xxx ."  test suite:"
  S" "  SHAbuffer  HASH.  S" "  QuoteString
  EX1  S" abc"  QuoteString
  EX2  EX2a     QuoteString
  EX3  S" 1 million copies of ASCII 'a' (61h)" TYPE
  EX4  S" 10,000 copies of ASCII BL (20h)" TYPE  CR
;

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

  DECIMAL 100 VALUE N#

: [EX1]  S" abc"  SHAbuffer  ;
: [EX2]  EX2a     SHAbuffer  ;
: [EX3]  SHAinit  EX3a  15625 0 DO W SHA2xx LOOP EX3b W SHA2xx ;

: test1  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX1 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX1]  LOOP  TIMER-END
;

: test2  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX2 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX2]  LOOP  TIMER-END
;

: test3  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX3 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX3]  LOOP  TIMER-END
;
[THEN]