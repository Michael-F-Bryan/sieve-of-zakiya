\ ANS Forth code for 1024-bit block Secure Hash Algorithms
\ SHA-384, SHA-512, SHA-512/256, and SHA-512/224
\ FIPS 180-4 specs at: http://csrc.nist.gov/publications/PubsFIPS.html
\ Code accommodates Big and Little Endian, byte addressable CPUs.
\
\ ------------ This implementation is for 64-bit systems ------------
\
\ DEPENDENCIES: CORE EXT WORDSET ; COMMON USAGE: ?DO CELL-
\ Use of this code is free subject to acknowledgment of copyright.
\ Copyright (c) 2012-2013 Jabari Zakiya - jzakiya@mail.com  2013-1-15
\ Rev 2013-1-25: Removed use of word DIGIT in ChooseHash and simplied
\                Added performance timing test for iForth
\
\ To find/show the hash of a string or counted message do:
\ Example: S" some message string" SHAbuffer Hash.
\ To find the hash of a file use:  SHAfile

0 [IF] ======= SHA-384||512||512/256||512/224 ALGORITHM ============

    All values are 64-bits -- this implementation assumes 64-bit cpu

    Ch(x, y, z) = (x and y) xor (not x and z)
    Maj(x, y, z)= (x and y) xor (x and z) xor (y and z)

    SIGMA0 (x) = ROTR 28(x) xor ROTR 34(x) xor ROTR 39(x)
    SIGMA1 (x) = ROTR 14(x) xor ROTR 18(x) xor ROTR 41(x)
    sig0 (x)   = ROTR  1(x) xor ROTR  8(x) xor SHR 7(x)
    sig1 (x)   = ROTR 19(x) xor ROTR 61(x) xor SHR 6(x)

Each 1024-bit message block, M(1), …, M(N), is processed as follows:

For i=1 to N:
{
   1. Prepare the message schedule, {W(t)}:

              | M(t)                                               0 <= t <= 15
      W(t) = -|
              | sig1(W(t-2)) + W(t-7) + sig0(W(t-15)) + W(t-16)   16 <= t <= 79

   2. Initialize a, b, c, d, e, f, g, h, with the (i-1)st hash value:

      a = H0(i-1)  b = H1(i-1)  c = H2(i-1)  d = H3(i-1)
      e = H4(i-1)  f = H5(i-1)  g = H6(i-1)  h = H7(i-1)

   3. For t=0 to 79:
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
     SHA-512/224 224-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N):32

     SHA-512/256 256-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N)

     SHA-384 384-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N)|H4(N)|H5(N)

     SHA-512 512-bit message digest of the message, M, is:

     H0(N)|H1(N)|H2(N)|H3(N)|H4(N)|H5(N)|H6(N)|H7(N)     [THEN]

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

\ ====================    Utility Words    ====================

 [UNDEFINED] ]L [IF] : ]L  ] POSTPONE LITERAL ; IMMEDIATE  [THEN]

 [UNDEFINED] CELL- [IF] : CELL- ( x - n ) [ 1 CELLS ]L - ; [THEN]

 [UNDEFINED] U>D [IF] : U>D ( n - n 0 )  0 ; [THEN]

\ =========== Choose SHA-384||512||512/256||512/224 ===========

  2 VALUE SHA?

: ChooseHash
  CR  CR  ." Selection Menu: "
  CR ." For SHA-384 enter     1: " CR ." For SHA-512 enter     2: "
  CR ." For SHA-512/256 enter 3: " CR ." For SHA-512/224 enter 4: "
  BEGIN  CR ." Enter selection: " KEY   ( - c ) \ Get input digit char
    DUP [char] 1 [char] 5 WITHIN        ( c ? ) \ Check if digit 1..4
    IF  [char] 0 - TO SHA? FALSE ELSE DROP TRUE THEN
  WHILE ." Invalid input, try again." CR REPEAT \ Repeat if not valid digit
  CASE SHA?
    1 OF ." SHA-384 selected"     CR ENDOF
    2 OF ." SHA-512 selected"     CR ENDOF
    3 OF ." SHA-512/256 selected" CR ENDOF
    4 OF ." SHA-512/224 selected" CR ENDOF
  ENDCASE
;
  ChooseHash

\ ========= Start SHA-384||512||512/256||512/224 Code =========
  DECIMAL
  64 CONSTANT CELLSIZE          \ CPU bitsize

  2VARIABLE  SHAlen             \ Holds byte length of message <= 2^125 bytes
  CREATE SHAval  8 CELLS ALLOT  \ Holds hash after each block
  CREATE SHAsh  88 CELLS ALLOT  \ Fully extended hash array
  CREATE W      16 CELLS ALLOT  \ Holds message block
  1 W !                         \ For compile time endian testing

  HEX

CREATE  Ki  \ SHA-384||512||512/256||512/224 round constants array
428a2f98d728ae22 , 7137449123ef65cd , b5c0fbcfec4d3b2f , e9b5dba58189dbbc ,
3956c25bf348b538 , 59f111f1b605d019 , 923f82a4af194f9b , ab1c5ed5da6d8118 ,
d807aa98a3030242 , 12835b0145706fbe , 243185be4ee4b28c , 550c7dc3d5ffb4e2 ,
72be5d74f27b896f , 80deb1fe3b1696b1 , 9bdc06a725c71235 , c19bf174cf692694 ,
e49b69c19ef14ad2 , efbe4786384f25e3 , 0fc19dc68b8cd5b5 , 240ca1cc77ac9c65 ,
2de92c6f592b0275 , 4a7484aa6ea6e483 , 5cb0a9dcbd41fbd4 , 76f988da831153b5 ,
983e5152ee66dfab , a831c66d2db43210 , b00327c898fb213f , bf597fc7beef0ee4 ,
c6e00bf33da88fc2 , d5a79147930aa725 , 06ca6351e003826f , 142929670a0e6e70 ,
27b70a8546d22ffc , 2e1b21385c26c926 , 4d2c6dfc5ac42aed , 53380d139d95b3df ,
650a73548baf63de , 766a0abb3c77b2a8 , 81c2c92e47edaee6 , 92722c851482353b ,
a2bfe8a14cf10364 , a81a664bbc423001 , c24b8b70d0f89791 , c76c51a30654be30 ,
d192e819d6ef5218 , d69906245565a910 , f40e35855771202a , 106aa07032bbd1b8 ,
19a4c116b8d2d0c8 , 1e376c085141ab53 , 2748774cdf8eeb99 , 34b0bcb5e19b48a8 ,
391c0cb3c5c95a63 , 4ed8aa4ae3418acb , 5b9cca4f7763e373 , 682e6ff3d6b2b8a3 ,
748f82ee5defb2fc , 78a5636f43172f60 , 84c87814a1f0ab72 , 8cc702081a6439ec ,
90befffa23631e28 , a4506cebde82bde9 , bef9a3f7b2c67915 , c67178f2e372532b ,
ca273eceea26619c , d186b8c721c0c207 , eada7dd6cde0eb1e , f57d4f7fee6ed178 ,
06f067aa72176fba , 0a637dc5a2c898a6 , 113f9804bef90dae , 1b710b35131c471b ,
28db77f523047d84 , 32caab7b40c72493 , 3c9ebe0a15c9bebc , 431d67c49c100d4c ,
4cc5d4becb3e42b6 , 597f299cfc657e2a , 5fcb6fab3ad6faec , 6c44198c4a475817 ,

  DECIMAL

  0 VALUE H[H]  \ Pointer to addr of hash value H for each round

MACRO H[G]  " H[H]  [ 1 CELLS ]L  +"  \ Return G adr
MACRO H[F]  " H[H]  [ 2 CELLS ]L  +"  \ Return F adr
MACRO H[E]  " H[H]  [ 3 CELLS ]L  +"  \ Return E adr
MACRO H[D]  " H[H]  [ 4 CELLS ]L  +"  \ Return D adr
MACRO H[C]  " H[H]  [ 5 CELLS ]L  +"  \ Return C adr
MACRO H[B]  " H[H]  [ 6 CELLS ]L  +"  \ Return B adr
MACRO H[A]  " H[H]  [ 7 CELLS ]L  +"  \ Return A adr

SHA? 1 = [IF]
: SHAinit ( -)     \ Load initial SHA-384 values H0 - H7
  [ HEX ] cbbb9d5dc1059ed8 ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          629a292a367cd507 ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          9159015a3070dd17 ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          152fecd8f70e5939 ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          67332667ffc00b31 ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          8eb44a8768581511 ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          db0c2e0d64f98fa7 ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          47b5481dbefa4fa4 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;
: H#    6 ; \ Used in SHAstring to print out 6 64-bit hash values
: BYT#  0 ; \ Used in SHAstring to subtract number of bytes from displaying
: SHA-xxx ." SHA-384" ;
[THEN]

SHA? 2 = [IF]
: SHAinit ( -)     \ Load initial SHA-512 values H0 - H7
  [ HEX ] 6a09e667f3bcc908 ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          bb67ae8584caa73b ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          3c6ef372fe94f82b ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          a54ff53a5f1d36f1 ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          510e527fade682d1 ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          9b05688c2b3e6c1f ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          1f83d9abfb41bd6b ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          5be0cd19137e2179 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

: H#    8 ; \ Used in SHAstring to print out 8 64-bit hash values
: BYT#  0 ; \ Used in SHAstring to subtract number of bytes from displaying
: SHA-xxx ." SHA-512" ;
[THEN]

SHA? 3 = [IF]
: SHAinit ( -)     \ Load initial SHA-512/256 hash values H0 - H7
  [ HEX ] 22312194fc2bf72c ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          9f555fa3c84c64c2 ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          2393b86b6f53b151 ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          963877195940eabd ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          96283ee2a88effe3 ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          be5e1e2553863992 ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          2b0199fc2c85b8aa ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          0eb72ddc81c52ca2 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

: H#    4 ; \ Used in SHAstring to print out 4 64-bit hash values
: BYT#  0 ; \ Used in SHAstring to subtract number of bytes from displaying
: SHA-xxx ." SHA-512/256" ;
[THEN]

SHA? 4 = [IF]
: SHAinit ( -)     \ Load initial SHA-512/224 hash values H0 - H7
  [ HEX ] 8c3d37c819544da2 ( H0) DUP [ SHAval 7 CELLS + ]L ! [ SHAsh 7 CELLS + ]L !
          73e1996689dcd4d6 ( H1) DUP [ SHAval 6 CELLS + ]L ! [ SHAsh 6 CELLS + ]L !
          1dfab7ae32ff9c82 ( H2) DUP [ SHAval 5 CELLS + ]L ! [ SHAsh 5 CELLS + ]L !
          679dd514582f9fcf ( H3) DUP [ SHAval 4 CELLS + ]L ! [ SHAsh 4 CELLS + ]L !
          0f6d2b697bd44da8 ( H4) DUP [ SHAval 3 CELLS + ]L ! [ SHAsh 3 CELLS + ]L !
          77e36f7304c48942 ( H5) DUP [ SHAval 2 CELLS + ]L ! [ SHAsh 2 CELLS + ]L !
          3f9d85a86a1d36c8 ( H6) DUP [ SHAval 1 CELLS + ]L ! [ SHAsh 1 CELLS + ]L !
          1112e6ad91d692a1 ( H7) DUP   SHAval ! SHAsh !      [ DECIMAL ]
  SHAsh TO H[H]    \ Init pointer to last hash value H7=h
;

: H#    4 ; \ Used in SHAstring to print out 4 64-bit hash values
: BYT#  8 ; \ Used in SHAstring to subtract number of bytes from displaying
: SHA-xxx ." SHA-512/224" ;
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
       R@  14 ror  R@  18 ror  XOR  R>  41 ror  XOR ( SIGMA1[E]) +  H[H] @  +
;

\ ( - n )  T2 = Maj(a,b,c) + SIGMA0(a)
: T2  H[B] 2@ ( A B) >R DUP >R  28 ror  r@ 34 ror xor  r@ 39 ror xor ( - SIGMA0[a]  R:B A)
      H[C] @  DUP  R@ AND ( A^C)  R> R@ AND ( A^B) XOR  SWAP R> AND ( B^C) XOR ( Maj) +
;

\ ( x - n )  n = ROR7(X)   XOR  ROR18(X)  XOR  RSH3(X)
: sig0  ( x - n )  DUP >R   1 ROR  R@   8 ROR  XOR  R>  7 RSHIFT  XOR  ;

\ ( x - n )  n = ROR17(X)  XOR  ROR19(X)  XOR  RSH10(X)
: sig1  ( x - n )  DUP >R  19 ROR  R@  61 ROR  XOR  R>  6 RSHIFT  XOR  ;

[ELSE]

MACRO ror\  " DUP [ CELLSIZE \ TUCK - ]L LSHIFT SWAP LITERAL RSHIFT OR "

\ ( - n )  T1x = Ch(e,f,g) + SIGMA1(e) + h
: T1x  H[F] 2@  OVER  DUP >R  AND  SWAP  INVERT  H[G] @  AND  XOR  ( -- Ch  R:E)
       R@  ror\ 14  R@  ror\ 18  XOR  R>  ror\ 41  XOR ( SIGMA1[E]) + H[H] @  +
;

\ ( - n )  T2 = Maj(a,b,c) + SIGMA0(a)
: T2  H[B] 2@ >R DUP >R ( A) ror\ 28  R@  ror\ 34 xor  R@  ror\ 39 xor ( - SIGMA0[a]  R:B A)
      H[C] @  DUP  R@ AND ( A^C)  R> R@ AND ( A^B) XOR  SWAP R> AND ( B^C) XOR ( Maj) +
;

\ ( x - n )  n = ROR7(X)   XOR  ROR18(X)  XOR  RSH3(X)
: sig0  ( x - n)   DUP >R  ror\ 1   R@  ror\ 8   XOR  R>  7 RSHIFT  XOR  ;

\ ( x - n )  n = ROR17(X)  XOR  ROR19(X)  XOR  RSH10(X)
: sig1  ( x - n )  DUP >R  ror\ 19  R@  ror\ 61  XOR  R>  6 RSHIFT  XOR  ;

[THEN]

\ Put two copies of original Wi on stack, keep its address
MACRO Wi@  " DUP  @  TUCK"  ( [Wi] - wi [Wi] wi)

\ Create 2 copies of new Wi' from Wi on stack  ( ..Wi -..Wi' Wi')
MACRO Wi   " 15 PICK  15 PICK  sig0  +  7 PICK  +  2 PICK  sig1  +  DUP "

\ Drop 80 Wi cells from stack ( W0..W79 - )
[DEFINED] NDROP  [IF]
MACRO WiDROP " 80 NDROP "  \ VFX, et al
[ELSE] 
MACRO WiDROP " 5 0 DO 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP 2DROP LOOP "
[THEN]

\ Add round constant Ki (to T1x to make T1) for each round
MACRO Ki+     " I @ + "
MACRO subrnd  " T1x +  Ki+  ( T1)  DUP  H[D]  +!  T2  +  H[G] TO H[H]  H[A] ! "

MACRO I+    " [ 1 CELLS ]L "
MACRO Ki16  " [ Ki 16 CELLS + ]L "
MACRO Ki80  " [ Ki 80 CELLS + ]L "

: SHAxxx  ( Wadr - )  \ Compute SHA-xxx hash of 1024-bit message block
  Ki16   Ki DO  Wi@  subrnd  CELL+ I+ +LOOP  DROP    \ ( W0..W15) original block
  Ki80 Ki16 DO  Wi   subrnd        I+ +LOOP  WiDROP  \ ( - )
  UpDateHash
;

: setlen  ( -- )  \ Store bit count into last two cells
  SHAlen 2@  D2* D2* D2* ( bytes->bits) [ W 112 CHARS + ]L ! [ W 120 CHARS + ]L !
;

: bytes>< ( m -- w )  \ Reverse cell bytes: 1234567890abcdef <-> efcdab9078563412
  [ HEX ]  DUP >R  38 LSHIFT     R@ FF00     AND 28 LSHIFT OR
  R@ FF0000    AND 18 LSHIFT OR  R@ FF000000 AND  8 LSHIFT OR
  R@ 38 RSHIFT      FF AND OR    R@ 28 RSHIFT     FF00 AND OR
  R@ 18 RSHIFT  FF0000 AND OR    R>  8 RSHIFT FF000000 AND OR [ DECIMAL ]
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

\ Do all 128 byte blocks leaving remainder block
: hashfullblocks ( adr1 ud -- adr2 count )
  SWAP  DUP >R  7 RSHIFT               ( adr1 hi lo* ) \ Store lo on return, lo*=lo/128
  OVER [ CELLSIZE 7 - ]L LSHIFT OR >R  ( adr1 hi     ) \ Return is now: :R lo lo'
  ( hi) 7 RSHIFT 0 ?DO                 ( adr1        ) \ Do if hi'= hi/128 > 0
    0 0 DO DUP endian16 SHAxxx 128 + LOOP ( adr'     ) \ Hash for 2^cellsize full blocks
  LOOP                                    ( adr'     ) \ Hash for hi'*2^cellsize full blocks
  R> 0 ?DO DUP endian16 SHAxxx 128 + LOOP ( adr'     ) \ Hash for lo' count full 128 byte blocks
  R> ( lo) 127 AND                     ( adr2 cnt    ) \ Leave address and count for partial block
;

: hashfinal ( addr count -- )  \ Hash partial and/or last block
  DUP >R  W  SWAP  CMOVE                \ Move bytes into block W array
  W  R@ +  128  OVER  C!   ( adr     )  \ Put 80h after last message byte
  CHAR+  111 R@ -          ( adr #   )  \ Compute tentative 0 byte FILL count
  R> 111 >                 ( adr # ? )  \ Is partial block byte count > 111 ?
  IF  16 + 0  FILL         ( --      )  \ If yes, FILL rest of block w/zeroes
      W  endian16  SHAxxx  ( --      )  \ Endian adjust block if required, then hash
      W  112               ( adr 112 )  \ Now setup last block containing bit count
  THEN                     ( adr #   )
  0 FILL  setlen  W  endian14  SHAxxx   \ Zero FILL last block, set message bit count
;                               ( -- )  \ Endian adjust, except bit count, then hash

\ Compute SHA-xxx from a counted buffer of text
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
: celldigits ( a1 -- )  DUP 7 + DO I C@ bytedigits  -1 +LOOP ;
  [ELSE]    \ Big Endian
: celldigits ( a1 -- )  DUP 8 + SWAP DO I C@ bytedigits LOOP ;
  [THEN]

: SHAstring ( -- adr count )  \ Return counted SHA-xxx string array
  intdigits  [ SHAval 7 CELLS + ]L
  H# 0 DO  DUP  celldigits  CELL-  LOOP  DROP  PAD  COUNT  BYT# -
;

\ Display SHA-xxx hash value in hex
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
  D2* D2* D2* ( bytes->bits) [ W 112 CHARS + ]L ! [ W 120 CHARS + ]L !
;

: getpartial ( cnt  -- W'  cnt2 ?)
  W  2DUP  SWAP  DUP >R  bytes@          ( cnt1 adr1  )
  + 128 OVER C! CHAR+ 111 R@ - R> 111 >  ( adr2 cnt2 ?)
;

MACRO block@  " W  128  bytes@ "

: SHAfile ( -- )
  BEGIN  InputFileName  ( ior)                  \ Enter filename
  WHILE  TryAgain? IF  EXIT  THEN               \ Not valid, try (not) again
  REPEAT SHAinit                                \ Valid file, init transform
  rfileid @  FILE-SIZE  DROP  ( ud )            \ Get bytesize of input file
  0 0  D-                                       \ Adjust to hash subset of file
  CR ." Bytesize: " 2DUP  D.                    \ Display hash size to screen
  2DUP  2>R                                     \ ( lo  hi ) Save file byte cnt on RETURN
  OVER  7 RSHIFT OVER                           \ ( lo  hi lo* hi )
  [ CELLSIZE 7 - ]L LSHIFT OR  SWAP  7 RSHIFT   \ ( lo  lo' hi') lo' hi' now full block count
  0 ?DO 0 0 DO block@  W endian16 SHAxxx LOOP LOOP  \ Hash hi*2^cellsize full blocks
  0 ?DO block@  W endian16 SHAxxx LOOP              \ Hash lo count full 128 byte blocks
  ( lo) 127 AND ( rembytes) getpartial ( adr cnt ?) \ Read remaining bytes
  IF 16 + 0 FILL  W endian16 SHAxxx  W 112 THEN \ Do if rembytes > 111
  0 FILL  2R> storelen  W endian14  SHAxxx      \ Do last block
  CR  SHA-xxx ."  : "  SHAstring  TYPE  CR      \ Show SHA-xxx hash for file
  rfileid @  CLOSE-FILE  DROP                   \ Close the input file
;

\ ========  SHA-384||512||512/256||512/224 Test Suite  ========
  DECIMAL

\ Load W array with data on stack
: WLoad ( d0..d15 -- )  [ W 15 CELLS + ]L  ( d0..d15 W[15] )
  16 0 DO  TUCK  !  CELL-  LOOP  DROP
;

\ -------------------------------------------------------------
\ EXAMPLE 1: from FIPS PUB 180-4
\ Message: ASCII string 'abc'
\ Hash = ddaf35a1 93617aba cc417349 ae204131 12e6fa4e 89a97ea2 0a9eeee6 4b55d39a
\        2192992a 274fc1a8 36ba3c23 a3feebbd 454d4423 643ce80e 2a9ac94F a54ca49f
\ Hash = cb00753f 45a35e8b b5a03d69 9ac65007 272c32ab 0eded163
\        1a8b605a 43ff5bed 8086072b a1e7cc23 58Baeca1 34c825a7
\ Hash = 53048e26 81941ef9 9B2e29b7 6b4c7dab e4c2d0c6 34fc6d46 e0e2f131 07e7af23
\ Hash = 4634270f 707b6a54 daae7530 460842e2 0e37ed26 5ceee9a4 3e8924aa

\ Compute and display hash for ASCII string 'abc'
: EX1  S" abc"  SHAbuffer  HASH.  ;

\ -------------------------------------------------------------
\ EXAMPLE 2: from FIPS PUB 180-4
\ Message:"abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
\ Hash = 8e959B75 dae313da 8cf4f728 14fc143f 8f7779c6 eb9f7fa1 7299aead b6889018
\        501d289e 4900f7e4 331b99de c4b5433a c7d329ee b6dd2654 5e96e55b 874be909
\ Hash = 09330c33 f71147e8 3d192fc7 82cd1b47 53111b17 3b3b05d2
\        2fa08086 e3b0f712 fcc7c71a 557e2db9 66c3e9fa 91746039
\ Hash = 3928e184 fb8690f8 40da3988 121d31be 65cb9D3e f83ee614 6feac861 e19b563a
\ Hash = 23fec5bb 94d60b23 30819264 0b0c4533 35d66473 4fe40e72 68674af9

: EX2a S" abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" ;
: EX2  EX2a  SHAbuffer  HASH.  ;

\ -------------------------------------------------------------
\ EXAMPLE 3:
\ Message: 2 million copies of 'a' (61h), (16 million bits)
\ Hash =

\ Load block of all 'a's (61h), must hash 15,625 times
: EX3a  W  128  [CHAR] a  FILL  ;

\ Last message block: 1st bit a '1', bit-count = 16 million
: EX3b  [ HEX ] 8000000000000000 0 0 0 0 0 0 0 0 0 0 0 0 0
        [ DECIMAL ] 0 16000000 WLoad
;
\ Do hash for message of 2 million copies of ASCII 'a' (61h)
: EX3  SHAinit  EX3a  15625 0 DO W SHAxxx LOOP  EX3b  W SHAxxx HASH. ;

\ -------------------------------------------------------------
\ EXAMPLE 4:
\ Message: 400,000 SPACES 'BL' (20h), (3,200,000 bits)
\ Hash =

\ Load block of all "BL' (20h), hash 156 full blocks + 16 bytes
: EX4a  W  128  BL  FILL  ;

\ Last message block: 1st bit a '1', bit-count = 3,200,000
: EX4b  [ HEX ] 8000000000000000 0 0 0 0 0 0 0 0 0 0 0 0 0
        [ DECIMAL ] 0 3200000 WLoad
;

\ Do hash for message of 400,000 SPACES 'BL' (20h)
: EX4  SHAinit  EX4a  3125 0 DO  W SHAxxx  LOOP  EX4b  W SHAxxx HASH. ;

\ -------------------------------------------------------------
\ Message: blank string ''
\ Hash =

: SHATest ( -- )
  CR  SHA-xxx ."  test suite:"
  S" "  SHAbuffer  HASH.  S" "  QuoteString
  EX1  S" abc"  QuoteString
  EX2  EX2a     QuoteString
  EX3  S" 2 million copies of ASCII 'a' (61h)" TYPE
  EX4  S" 400,000 copies of ASCII BL (20h)" TYPE  CR
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
\ ==========  Win32Forth specific timing test words  ==========

: TIMER-START  ( - ms )  MS@ ;

: TIMER-END    ( ms - )  MS@  SWAP - U>D  msecs ;

[THEN]

[DEFINED] .SIGNON [IF]
\ ============  iForth specific timing test words  ============

: TIMER-START  ( - ms )  ?ms ;

: TIMER-END    ( ms - )  ?ms  SWAP - U>D  msecs ;

[THEN]

[DEFINED] SWIFTFORTH-TOOLBAR [IF]
\ ==========  SwiftForth specific timing test words  ==========

: TIMER-START  ( - dtime)  ucounter ;

: TIMER-END    ( dtime -)  (utimer)  usecs ;

[THEN]

[DEFINED] InFoTable [IF]
\ ============  Gforth specific timing test words  ============

: TIMER-START  ( - dtime)  utime ;

: TIMER-END    ( dtime -)  utime  2SWAP  D-  usecs ;

[THEN]

[DEFINED] TIMER-START [IF]
\ ================  Selected Performance tests ================

  DECIMAL 100 VALUE N#

: [EX1]  S" abc"  SHAbuffer  ;
: [EX2]  EX2a     SHAbuffer  ;
: [EX3]  SHAinit  EX3a  15625 0 DO W SHAxxx LOOP EX3b W SHAxxx ;

: test1  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX1 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX1]  LOOP  TIMER-END
;

: test2  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX2 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX2]  LOOP  TIMER-END
;

: test3  [ DECIMAL ]
  cr  SHA-xxx ."  test for EX2 for " N# . ." loops is "
  TIMER-START  N# 0 DO  [EX3]  LOOP  TIMER-END
;
[THEN]