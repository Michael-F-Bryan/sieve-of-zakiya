0 [IF]  AES  Code Tutotorial

ANS FORTH code to implement the Advanced Encryption Standard (AES).

The National Institute of Standards and Technology (NIST) announced
on October 2, 2000 that Rijndael, created by Joan Daemen and Vincent 
Rijmen, was selected as the AES algorithm to replace the old (since 1976)
Data Encryption Standard (DES). The formal AES specification is codified 
in NIST (Federal Information Processing Standard) FIPS-197, url below:

http://csrc.nist.gov/publications/fips/fips197/fips-197.pdf

AES (Rijndael) is a block cipher which takes a 128-bit input block
and produces a ciphered 128-bit output block.  The AES standard defines
3 key sizes of 128, 192, or 256 bits, though Rijndael accommodates more.

This is a "fast" implementation of the algorithm, which employs large
precomputed table values to eliminate repetitive processing. Specifically,
galois field multiplications and row and column shift operations are
combined into and accommodated by the arrays emix and dmix.

Rijndael allows for two possible architectural structures.  The normal
architecture processes the input key to create expanded key segments
that can be used for both the encipher and decipher structures. For
this case, the decipher architecture performs the inverted operations
of the encipher algorithm using the expanded keys, in reverse order.

An alternative architecture allows deciphering to be done with the
same structure for enciphering, but then requiring the decipher key
to be modified, which takes longer to process.

This code accommodates both structures. The VALUE "ARCHITECTURE" is
used to determine the compilation architecture.  A '0' (FALSE) will
compile the standard (inverted ciphers) structure, while a non-zero
value compiles the identical ciphers structure using a modified key.

The difference between the architectures is speed.  If fast decipher
key processing is most important, the inverted architecture is faster,
with the decipher strucuture being slower. This is reversed for the 
identical ciphers structure. Faster block deciphering is normally
more important than key processing (which occurs only once per message),
so setting ARCHITECTURE to '1/TRUE' is probably best for most scenarios.

The word SPEED-TEST can be used to show the architectural differences
in speed for your system. First load this source file with the value
ARCHITECTURE set to '0'/1', then run 'speedtest', then clear that
version's compiled code from dictionary with word 'AESCODE', and load
source file with ARCHITECTURE flipped, and run 'speedtest' again.

> include /<path-source-file>/aes.f  \ ARCHITECTURE set to '0/1'
> speedtest                          \ run speedtest for architecture
> aescode                            \ remove previous compiled code
> include /<path-source-file>/aes.f  \ ARCHITECTURE set to '1/0'
> speedtest                          \ speedtest for new architecture

Change N# ( x to N#) after file loaded to change speedtest loop count.
 
The word AESTEST provides known value tests. Output should be below.

> AESTEST

For 128-bit key:   000102030405060708090a0b0c0d0e0f
Plaintext input:   00112233445566778899aabbccddeeff
Known  ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a
Computed ciphtext: 69c4e0d86a7b0430d8cdb78070b4c55a
Computed original: 00112233445566778899aabbccddeeff

For 192-bit key:   000102030405060708090a0b0c0d0e0f1011121314151617
Plaintext input:   00112233445566778899aabbccddeeff
Known  ciphertext: dda97ca4864cdfe06eaf70a0ec0d7191
Computed ciphtext: dda97ca4864cdfe06eaf70a0ec0d7191
Computed original: 00112233445566778899aabbccddeeff

For 256-bit key:   000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
Plaintext input:   00112233445566778899aabbccddeeff
Known  ciphertext: 8ea2b7ca516745bfeafc49904b496089
Computed ciphtext: 8ea2b7ca516745bfeafc49904b496089
Computed original: 00112233445566778899aabbccddeeff

Finally, the word AESFILE will [en/de]cipher a file in ECB mode.
To verify that a deciphered file is the same as the original file,
take their cryptographic hashes (using MD5, SHA-1, SHA-256, etc),
which should be the same.

The utility word FILESIZE is used to display the byte size of any file.

This AES.F source file, as well as various NIST cryptographic hashes
(SHA-1, SHA-224, SHA-256, SHA-384, etc) I have created (or will) are
downloadable from the FORTH folder located at the url below.

www.4shared.com/dir/TcMrUvTB/sharing.html

[THEN]

\ Advanced Encryption Standard (AES) -- Rijndael -- in ANS FORTH.
\ Accommodates Little or Big Endian, byte addressable 32-bit CPUs.
\ Rijndael was created by Joan Daemen and Vincent Rijmen.
\ Rijndael was announced as the AES algorithm on 2000/10/2 by the
\ National Institute of Standards and Technology (NIST) - www.nist.gov
\ NIST FIPS-197: http://csrc.nist.gov/publications/fips/fips197/fips-197.pdf
\ Use of this code is free subject to acknowledgment of copyright.
\ Copyright (c) 2001 Jabari Zakiya, -- jzakiya at gmail dot com, 2001/5/26
\ Revised: 2014/10/13 

  MARKER    AEScode                     \ Set start-of-code marker
  VARIABLE  endian?   1  endian?  !     \ Is CPU BIG or LITTLE endian?

\ ==================== Macro Wordset Code =====================
\ MACRO wordset from Wil Baden's Tool Belt series in
\ Forth Dimensions (FD) Vol. 19, No. 2, July/August 1997.
\ Original code has been modified to make more efficient.
\ MACRO allows insertion of parameters following the macro.
\ "\" represents place where parameter is inserted
\ Example:  MACRO  ??  " IF  \  THEN "
\ : FOO .. ?? EXIT .... ;  ?? compiles to -- IF EXIT THEN

[UNDEFINED] PLACE [IF]
: PLACE  ( caddr n addr -)  2DUP  C!  CHAR+  SWAP  CHARS  MOVE ;
[THEN]

: SSTRING ( char "ccc" -) WORD COUNT HERE OVER 1+ CHARS ALLOT PLACE ;

[UNDEFINED] /STRING [IF]
: /STRING ( a n k - a+k n-k) ( OVER MIN) TUCK - >R CHARS + R> ;
[THEN]

[UNDEFINED] ANEW [IF]
: ANEW  >IN @ BL WORD FIND IF EXECUTE ELSE DROP THEN >IN ! MARKER ;
[THEN]

: split-at-char  ( a  n  char  -  a  k  a+k  n-k)
  >R  2DUP  BEGIN  DUP  WHILE  OVER  C@  R@  -
            WHILE  1 /STRING  REPEAT  THEN
            R> DROP  TUCK  2>R  -  2R>
;

: DOES>MACRO  \ Compile the macro, including trailing parameters.
  DOES> COUNT  BEGIN [CHAR]  \ split-at-char  2>R  EVALUATE  R@
               WHILE BL WORD COUNT EVALUATE 2R>  1 /STRING REPEAT
               R> DROP   R> DROP
;

\ Macro creation word which allows trailing parameter insertion.
: MACRO  CREATE  IMMEDIATE  CHAR  SSTRING  DOES>MACRO  ;

\ ====================    Utility Words    =====================

[UNDEFINED] ]L [IF] : ]L  ] POSTPONE LITERAL ; IMMEDIATE  [THEN]

[UNDEFINED] CELL- [IF] : CELL- ( x - n ) [ 1 CELLS ]L - ; [THEN]

[UNDEFINED] U>D [IF] : U>D ( n - n 0 )  0 ; [THEN]

\ =====================  Start Rijndael Code =====================
  DECIMAL

  32     CONSTANT  CELLSIZE     \ Set cpu register size
  TRUE   CONSTANT  deciph       \ Mode value for decipher key expansion
  FALSE  CONSTANT  enciph       \ Mode value for encipher key expansion
      1  VALUE  ARCHITECTURE    \ 0 - inverted, 1 - identical cipher structures

CREATE expkey   60 CELLS  ALLOT         \ Holds expanded key data
CREATE ciphdat  16 CHARS  ALLOT         \ Holds ciphered data

ciphdat             CONSTANT  col[0]    \ 1st column of STATE matrix
ciphdat  1 CELLS +  CONSTANT  col[1]    \ 2nd column of STATE matrix
ciphdat  2 CELLS +  CONSTANT  col[2]    \ 3rd column of STATE matrix
ciphdat  3 CELLS +  CONSTANT  col[3]    \ 4th column of STATE matrix

  HEX
\ Constants for key expansion
CREATE keycons  01 ,  02 ,  04 ,  08 ,  10 ,  20 ,  40 ,  80 ,  1B ,  36 ,

CREATE sbox  \ Rijndael Sbox table, accommodates shifted byte reads
00000063 , 0000007C , 00000077 , 0000007B , 000000F2 , 0000006B , 0000006F , 000000C5 ,
00000030 , 00000001 , 00000067 , 0000002B , 000000FE , 000000D7 , 000000AB , 00000076 ,
000000CA , 00000082 , 000000C9 , 0000007D , 000000FA , 00000059 , 00000047 , 000000F0 ,
000000AD , 000000D4 , 000000A2 , 000000AF , 0000009C , 000000A4 , 00000072 , 000000C0 ,
000000B7 , 000000FD , 00000093 , 00000026 , 00000036 , 0000003F , 000000F7 , 000000CC ,
00000034 , 000000A5 , 000000E5 , 000000F1 , 00000071 , 000000D8 , 00000031 , 00000015 ,
00000004 , 000000C7 , 00000023 , 000000C3 , 00000018 , 00000096 , 00000005 , 0000009A ,
00000007 , 00000012 , 00000080 , 000000E2 , 000000EB , 00000027 , 000000B2 , 00000075 ,
00000009 , 00000083 , 0000002C , 0000001A , 0000001B , 0000006E , 0000005A , 000000A0 ,
00000052 , 0000003B , 000000D6 , 000000B3 , 00000029 , 000000E3 , 0000002F , 00000084 ,
00000053 , 000000D1 , 00000000 , 000000ED , 00000020 , 000000FC , 000000B1 , 0000005B ,
0000006A , 000000CB , 000000BE , 00000039 , 0000004A , 0000004C , 00000058 , 000000CF ,
000000D0 , 000000EF , 000000AA , 000000FB , 00000043 , 0000004D , 00000033 , 00000085 ,
00000045 , 000000F9 , 00000002 , 0000007F , 00000050 , 0000003C , 0000009F , 000000A8 ,
00000051 , 000000A3 , 00000040 , 0000008F , 00000092 , 0000009D , 00000038 , 000000F5 ,
000000BC , 000000B6 , 000000DA , 00000021 , 00000010 , 000000FF , 000000F3 , 000000D2 ,
000000CD , 0000000C , 00000013 , 000000EC , 0000005F , 00000097 , 00000044 , 00000017 ,
000000C4 , 000000A7 , 0000007E , 0000003D , 00000064 , 0000005D , 00000019 , 00000073 ,
00000060 , 00000081 , 0000004F , 000000DC , 00000022 , 0000002A , 00000090 , 00000088 ,
00000046 , 000000EE , 000000B8 , 00000014 , 000000DE , 0000005E , 0000000B , 000000DB ,
000000E0 , 00000032 , 0000003A , 0000000A , 00000049 , 00000006 , 00000024 , 0000005C ,
000000C2 , 000000D3 , 000000AC , 00000062 , 00000091 , 00000095 , 000000E4 , 00000079 ,
000000E7 , 000000C8 , 00000037 , 0000006D , 0000008D , 000000D5 , 0000004E , 000000A9 ,
0000006C , 00000056 , 000000F4 , 000000EA , 00000065 , 0000007A , 000000AE , 00000008 ,
000000BA , 00000078 , 00000025 , 0000002E , 0000001C , 000000A6 , 000000B4 , 000000C6 ,
000000E8 , 000000DD , 00000074 , 0000001F , 0000004B , 000000BD , 0000008B , 0000008A ,
00000070 , 0000003E , 000000B5 , 00000066 , 00000048 , 00000003 , 000000F6 , 0000000E ,
00000061 , 00000035 , 00000057 , 000000B9 , 00000086 , 000000C1 , 0000001D , 0000009E ,
000000E1 , 000000F8 , 00000098 , 00000011 , 00000069 , 000000D9 , 0000008E , 00000094 ,
0000009B , 0000001E , 00000087 , 000000E9 , 000000CE , 00000055 , 00000028 , 000000DF ,
0000008C , 000000A1 , 00000089 , 0000000D , 000000BF , 000000E6 , 00000042 , 00000068 ,
00000041 , 00000099 , 0000002D , 0000000F , 000000B0 , 00000054 , 000000BB , 00000016 ,

DECIMAL  768 CELLS ALLOT  HEX  \ Allot 768 cells for rest of matrix, will fill later

CREATE ibox  \ Rijndael Inverted Sbox table, acccommodates shifted bytes reads
00000052 , 00000009 , 0000006A , 000000D5 , 00000030 , 00000036 , 000000A5 , 00000038 ,
000000BF , 00000040 , 000000A3 , 0000009E , 00000081 , 000000F3 , 000000D7 , 000000FB ,
0000007C , 000000E3 , 00000039 , 00000082 , 0000009B , 0000002F , 000000FF , 00000087 ,
00000034 , 0000008E , 00000043 , 00000044 , 000000C4 , 000000DE , 000000E9 , 000000CB ,
00000054 , 0000007B , 00000094 , 00000032 , 000000A6 , 000000C2 , 00000023 , 0000003D ,
000000EE , 0000004C , 00000095 , 0000000B , 00000042 , 000000FA , 000000C3 , 0000004E ,
00000008 , 0000002E , 000000A1 , 00000066 , 00000028 , 000000D9 , 00000024 , 000000B2 ,
00000076 , 0000005B , 000000A2 , 00000049 , 0000006D , 0000008B , 000000D1 , 00000025 ,
00000072 , 000000F8 , 000000F6 , 00000064 , 00000086 , 00000068 , 00000098 , 00000016 ,
000000D4 , 000000A4 , 0000005C , 000000CC , 0000005D , 00000065 , 000000B6 , 00000092 ,
0000006C , 00000070 , 00000048 , 00000050 , 000000FD , 000000ED , 000000B9 , 000000DA ,
0000005E , 00000015 , 00000046 , 00000057 , 000000A7 , 0000008D , 0000009D , 00000084 ,
00000090 , 000000D8 , 000000AB , 00000000 , 0000008C , 000000BC , 000000D3 , 0000000A ,
000000F7 , 000000E4 , 00000058 , 00000005 , 000000B8 , 000000B3 , 00000045 , 00000006 ,
000000D0 , 0000002C , 0000001E , 0000008F , 000000CA , 0000003F , 0000000F , 00000002 ,
000000C1 , 000000AF , 000000BD , 00000003 , 00000001 , 00000013 , 0000008A , 0000006B ,
0000003A , 00000091 , 00000011 , 00000041 , 0000004F , 00000067 , 000000DC , 000000EA ,
00000097 , 000000F2 , 000000CF , 000000CE , 000000F0 , 000000B4 , 000000E6 , 00000073 ,
00000096 , 000000AC , 00000074 , 00000022 , 000000E7 , 000000AD , 00000035 , 00000085 ,
000000E2 , 000000F9 , 00000037 , 000000E8 , 0000001C , 00000075 , 000000DF , 0000006E ,
00000047 , 000000F1 , 0000001A , 00000071 , 0000001D , 00000029 , 000000C5 , 00000089 ,
0000006F , 000000B7 , 00000062 , 0000000E , 000000AA , 00000018 , 000000BE , 0000001B ,
000000FC , 00000056 , 0000003E , 0000004B , 000000C6 , 000000D2 , 00000079 , 00000020 ,
0000009A , 000000DB , 000000C0 , 000000FE , 00000078 , 000000CD , 0000005A , 000000F4 ,
0000001F , 000000DD , 000000A8 , 00000033 , 00000088 , 00000007 , 000000C7 , 00000031 ,
000000B1 , 00000012 , 00000010 , 00000059 , 00000027 , 00000080 , 000000EC , 0000005F ,
00000060 , 00000051 , 0000007F , 000000A9 , 00000019 , 000000B5 , 0000004A , 0000000D ,
0000002D , 000000E5 , 0000007A , 0000009F , 00000093 , 000000C9 , 0000009C , 000000EF ,
000000A0 , 000000E0 , 0000003B , 0000004D , 000000AE , 0000002A , 000000F5 , 000000B0 ,
000000C8 , 000000EB , 000000BB , 0000003C , 00000083 , 00000053 , 00000099 , 00000061 ,
00000017 , 0000002B , 00000004 , 0000007E , 000000BA , 00000077 , 000000D6 , 00000026 ,
000000E1 , 00000069 , 00000014 , 00000063 , 00000055 , 00000021 , 0000000C , 0000007D ,

DECIMAL  768 CELLS ALLOT  HEX  \ Allot 768 cells for rest of matrix, will fill later

CREATE emix  \ Colmix table: each Sbox[I] byte value x g(3,1,1,2)
A56363C6 , 847C7CF8 , 997777EE , 8D7B7BF6 , 0DF2F2FF , BD6B6BD6 , B16F6FDE , 54C5C591 ,
50303060 , 03010102 , A96767CE , 7D2B2B56 , 19FEFEE7 , 62D7D7B5 , E6ABAB4D , 9A7676EC ,
45CACA8F , 9D82821F , 40C9C989 , 877D7DFA , 15FAFAEF , EB5959B2 , C947478E , 0BF0F0FB ,
ECADAD41 , 67D4D4B3 , FDA2A25F , EAAFAF45 , BF9C9C23 , F7A4A453 , 967272E4 , 5BC0C09B ,
C2B7B775 , 1CFDFDE1 , AE93933D , 6A26264C , 5A36366C , 413F3F7E , 02F7F7F5 , 4FCCCC83 ,
5C343468 , F4A5A551 , 34E5E5D1 , 08F1F1F9 , 937171E2 , 73D8D8AB , 53313162 , 3F15152A ,
0C040408 , 52C7C795 , 65232346 , 5EC3C39D , 28181830 , A1969637 , 0F05050A , B59A9A2F ,
0907070E , 36121224 , 9B80801B , 3DE2E2DF , 26EBEBCD , 6927274E , CDB2B27F , 9F7575EA ,
1B090912 , 9E83831D , 742C2C58 , 2E1A1A34 , 2D1B1B36 , B26E6EDC , EE5A5AB4 , FBA0A05B ,
F65252A4 , 4D3B3B76 , 61D6D6B7 , CEB3B37D , 7B292952 , 3EE3E3DD , 712F2F5E , 97848413 ,
F55353A6 , 68D1D1B9 , 00000000 , 2CEDEDC1 , 60202040 , 1FFCFCE3 , C8B1B179 , ED5B5BB6 ,
BE6A6AD4 , 46CBCB8D , D9BEBE67 , 4B393972 , DE4A4A94 , D44C4C98 , E85858B0 , 4ACFCF85 ,
6BD0D0BB , 2AEFEFC5 , E5AAAA4F , 16FBFBED , C5434386 , D74D4D9A , 55333366 , 94858511 ,
CF45458A , 10F9F9E9 , 06020204 , 817F7FFE , F05050A0 , 443C3C78 , BA9F9F25 , E3A8A84B ,
F35151A2 , FEA3A35D , C0404080 , 8A8F8F05 , AD92923F , BC9D9D21 , 48383870 , 04F5F5F1 ,
DFBCBC63 , C1B6B677 , 75DADAAF , 63212142 , 30101020 , 1AFFFFE5 , 0EF3F3FD , 6DD2D2BF ,
4CCDCD81 , 140C0C18 , 35131326 , 2FECECC3 , E15F5FBE , A2979735 , CC444488 , 3917172E ,
57C4C493 , F2A7A755 , 827E7EFC , 473D3D7A , AC6464C8 , E75D5DBA , 2B191932 , 957373E6 ,
A06060C0 , 98818119 , D14F4F9E , 7FDCDCA3 , 66222244 , 7E2A2A54 , AB90903B , 8388880B ,
CA46468C , 29EEEEC7 , D3B8B86B , 3C141428 , 79DEDEA7 , E25E5EBC , 1D0B0B16 , 76DBDBAD ,
3BE0E0DB , 56323264 , 4E3A3A74 , 1E0A0A14 , DB494992 , 0A06060C , 6C242448 , E45C5CB8 ,
5DC2C29F , 6ED3D3BD , EFACAC43 , A66262C4 , A8919139 , A4959531 , 37E4E4D3 , 8B7979F2 ,
32E7E7D5 , 43C8C88B , 5937376E , B76D6DDA , 8C8D8D01 , 64D5D5B1 , D24E4E9C , E0A9A949 ,
B46C6CD8 , FA5656AC , 07F4F4F3 , 25EAEACF , AF6565CA , 8E7A7AF4 , E9AEAE47 , 18080810 ,
D5BABA6F , 887878F0 , 6F25254A , 722E2E5C , 241C1C38 , F1A6A657 , C7B4B473 , 51C6C697 ,
23E8E8CB , 7CDDDDA1 , 9C7474E8 , 211F1F3E , DD4B4B96 , DCBDBD61 , 868B8B0D , 858A8A0F ,
907070E0 , 423E3E7C , C4B5B571 , AA6666CC , D8484890 , 05030306 , 01F6F6F7 , 120E0E1C ,
A36161C2 , 5F35356A , F95757AE , D0B9B969 , 91868617 , 58C1C199 , 271D1D3A , B99E9E27 ,
38E1E1D9 , 13F8F8EB , B398982B , 33111122 , BB6969D2 , 70D9D9A9 , 898E8E07 , A7949433 ,
B69B9B2D , 221E1E3C , 92878715 , 20E9E9C9 , 49CECE87 , FF5555AA , 78282850 , 7ADFDFA5 ,
8F8C8C03 , F8A1A159 , 80898909 , 170D0D1A , DABFBF65 , 31E6E6D7 , C6424284 , B86868D0 ,
C3414182 , B0999929 , 772D2D5A , 110F0F1E , CBB0B07B , FC5454A8 , D6BBBB6D , 3A16162C ,

DECIMAL  768 CELLS ALLOT  HEX  \ Allot 768 cells for rest of matrix, will fill later

CREATE dmix  \ Inverse Colmix table: each Ibox[I] byte value x g(b,d,9,e)
50A7F451 , 5365417E , C3A4171A , 965E273A , CB6BAB3B , F1459D1F , AB58FAAC , 9303E34B ,
55FA3020 , F66D76AD , 9176CC88 , 254C02F5 , FCD7E54F , D7CB2AC5 , 80443526 , 8FA362B5 ,
495AB1DE , 671BBA25 , 980EEA45 , E1C0FE5D , 02752FC3 , 12F04C81 , A397468D , C6F9D36B ,
E75F8F03 , 959C9215 , EB7A6DBF , DA595295 , 2D83BED4 , D3217458 , 2969E049 , 44C8C98E ,
6A89C275 , 78798EF4 , 6B3E5899 , DD71B927 , B64FE1BE , 17AD88F0 , 66AC20C9 , B43ACE7D ,
184ADF63 , 82311AE5 , 60335197 , 457F5362 , E07764B1 , 84AE6BBB , 1CA081FE , 942B08F9 ,
58684870 , 19FD458F , 876CDE94 , B7F87B52 , 23D373AB , E2024B72 , 578F1FE3 , 2AAB5566 ,
0728EBB2 , 03C2B52F , 9A7BC586 , A50837D3 , F2872830 , B2A5BF23 , BA6A0302 , 5C8216ED ,
2B1CCF8A , 92B479A7 , F0F207F3 , A1E2694E , CDF4DA65 , D5BE0506 , 1F6234D1 , 8AFEA6C4 ,
9D532E34 , A055F3A2 , 32E18A05 , 75EBF6A4 , 39EC830B , AAEF6040 , 069F715E , 51106EBD ,
F98A213E , 3D06DD96 , AE053EDD , 46BDE64D , B58D5491 , 055DC471 , 6FD40604 , FF155060 ,
24FB9819 , 97E9BDD6 , CC434089 , 779ED967 , BD42E8B0 , 888B8907 , 385B19E7 , DBEEC879 ,
470A7CA1 , E90F427C , C91E84F8 , 00000000 , 83868009 , 48ED2B32 , AC70111E , 4E725A6C ,
FBFF0EFD , 5638850F , 1ED5AE3D , 27392D36 , 64D90F0A , 21A65C68 , D1545B9B , 3A2E3624 ,
B1670A0C , 0FE75793 , D296EEB4 , 9E919B1B , 4FC5C080 , A220DC61 , 694B775A , 161A121C ,
0ABA93E2 , E52AA0C0 , 43E0223C , 1D171B12 , 0B0D090E , ADC78BF2 , B9A8B62D , C8A91E14 ,
8519F157 , 4C0775AF , BBDD99EE , FD607FA3 , 9F2601F7 , BCF5725C , C53B6644 , 347EFB5B ,
7629438B , DCC623CB , 68FCEDB6 , 63F1E4B8 , CADC31D7 , 10856342 , 40229713 , 2011C684 ,
7D244A85 , F83DBBD2 , 1132F9AE , 6DA129C7 , 4B2F9E1D , F330B2DC , EC52860D , D0E3C177 ,
6C16B32B , 99B970A9 , FA489411 , 2264E947 , C48CFCA8 , 1A3FF0A0 , D82C7D56 , EF903322 ,
C74E4987 , C1D138D9 , FEA2CA8C , 360BD498 , CF81F5A6 , 28DE7AA5 , 268EB7DA , A4BFAD3F ,
E49D3A2C , 0D927850 , 9BCC5F6A , 62467E54 , C2138DF6 , E8B8D890 , 5EF7392E , F5AFC382 ,
BE805D9F , 7C93D069 , A92DD56F , B31225CF , 3B99ACC8 , A77D1810 , 6E639CE8 , 7BBB3BDB ,
097826CD , F418596E , 01B79AEC , A89A4F83 , 656E95E6 , 7EE6FFAA , 08CFBC21 , E6E815EF ,
D99BE7BA , CE366F4A , D4099FEA , D67CB029 , AFB2A431 , 31233F2A , 3094A5C6 , C066A235 ,
37BC4E74 , A6CA82FC , B0D090E0 , 15D8A733 , 4A9804F1 , F7DAEC41 , 0E50CD7F , 2FF69117 ,
8DD64D76 , 4DB0EF43 , 544DAACC , DF0496E4 , E3B5D19E , 1B886A4C , B81F2CC1 , 7F516546 ,
04EA5E9D , 5D358C01 , 737487FA , 2E410BFB , 5A1D67B3 , 52D2DB92 , 335610E9 , 1347D66D ,
8C61D79A , 7A0CA137 , 8E14F859 , 893C13EB , EE27A9CE , 35C961B7 , EDE51CE1 , 3CB1477A ,
59DFD29C , 3F73F255 , 79CE1418 , BF37C773 , EACDF753 , 5BAAFD5F , 146F3DDF , 86DB4478 ,
81F3AFCA , 3EC468B9 , 2C342438 , 5F40A3C2 , 72C31D16 , 0C25E2BC , 8B493C28 , 41950DFF ,
7101A839 , DEB30C08 , 9CE4B4D8 , 90C15664 , 6184CB7B , 70B632D5 , 745C6C48 , 4257B8D0 ,

DECIMAL  768 CELLS ALLOT  \ Allot 768 cells for rest of matrix, will fill later

MARKER  TABLES!  \ Set marker for code to load constant tables

MACRO rol\  " DUP >R [ CELLSIZE \ TUCK - ]L RSHIFT R> LITERAL LSHIFT OR "

: col!  ( adr -- )  \ Move shifted 1st quadrant values into upper table quadrants
  256 0 DO  DUP >R  @                         \ quad1[I] = abcd placed on stack
            rol\ 8  DUP  R@  256 CELLS  +  !  \ quad2[I] = bcda is stored
            rol\ 8  DUP  R@  512 CELLS  +  !  \ quad3[I] = cdab is stored
            rol\ 8       R@  768 CELLS  +  !  \ quad4[I] = dabc is stored
            R>  CELL+                         \ address for quad1[I+1]
  LOOP  DROP
;

ARCHITECTURE  [IF] \ Set dmix array to do identical cipher architectures

: dmix[]  ;  \ Do nothing, no dmix array processing necessary

[ELSE] \ Set dmix array to do inverted cipher architecture

  dmix   dmix 768 CELLS +   256 CELLS  CMOVE  \ Move dmix 1st quad into 4th quad

: dmix[]  ( -- )  \ Reorder then move dmix values to match table index values
  256 0 DO  sbox  I CELLS +  @       \ Retrieve byte value at sbox[I]
            CELLS                    \ Convert to array address index I'
            dmix + 768 CELLS +  @    \ Get icolmix data from dmix4[I']
            dmix  I CELLS +  !       \ Store in 1st quad at dmix[I]
  LOOP
;

[THEN]

\ Fill rest of large arrays with shifted values from the arrays 1st quadrant
sbox col!   ibox col!   emix col!   dmix[] dmix col!

TABLES!  \ FORGET this code (purge from dictionary) after storing tables

DECIMAL

: keyadd  ( kadr -- kadr)  \ Add (XOR) key segment to STATE
  DUP  DUP >R         @  col[0]  @  XOR  col[0]  !  \ col[0] ^= k[0]
  R@  [ 1 CELLS ]L +  @  col[1]  @  XOR  col[1]  !  \ col[1] ^= k[1]
  R@  [ 2 CELLS ]L +  @  col[2]  @  XOR  col[2]  !  \ col[2] ^= k[2]
  R>  [ 3 CELLS ]L +  @  col[3]  @  XOR  col[3]  !  \ col[3] ^= k[3]
;

  HEX      03FC  CONSTANT  bytemask
  DECIMAL

\ For selected byte (0-3) of cell on stack get 32-bit STATE column or table value
MACRO byte0@\   " CELLS       bytemask  AND  [ \ 256 * CELLS  \  +  ]L  +  @ "
MACRO byte1@\   " 06  RSHIFT  bytemask  AND  [ \ 256 * CELLS  \  +  ]L  +  @ "
MACRO byte2@\   " 14  RSHIFT  bytemask  AND  [ \ 256 * CELLS  \  +  ]L  +  @ "
MACRO byte3@\   " 22  RSHIFT  bytemask  AND  [ \ 256 * CELLS  \  +  ]L  +  @ "

\ Add (XOR) a KEY segment to a STATE column segment
MACRO keyaddi\  " R@  [ \  CELLS  ]L  +  @  XOR  \  ! "

\ =================== Key Expansion Wordset ===================

DECIMAL

: colsub  ( x -- y )  \ Replace cell bytes with sbox values
  DUP >R  byte0@\  0  sbox       R@  byte1@\  1  sbox  OR
  R@      byte2@\  2  sbox  OR   R>  byte3@\  3  sbox  OR
;

: rotsub  ( x -- y )  \ Replace rotated cell bytes with sbox values
  DUP >R  byte0@\  3  sbox       R@  byte1@\  0  sbox  OR
  R@      byte2@\  1  sbox  OR   R>  byte3@\  2  sbox  OR
;

\ First column key expansion ( kadr x consadr -- y kadr' )
MACRO col0\ " @ SWAP rotsub XOR SWAP DUP >R @ XOR DUP R@ [ \ CELLS ]L + ! R> CELL+ "

\ Normal key expansion ( x kadr -- y kadr' )
MACRO coli\ " DUP >R  @  XOR  DUP  R@  [ \ CELLS ]L  +  !  R>  CELL+ "

: 128keyexpand  ( kadr x cadr --  )  \ Expand 128-bit key
  10 0 DO  DUP >R  col0\ 4  coli\ 4  coli\ 4  coli\ 4
           SWAP  R>  CELL+
  LOOP  2DROP  DROP
;

: 192keyexpand  ( kadr x cadr --  )  \ Expand 192-bit key
  7 0 DO  DUP  >R  col0\ 6  coli\ 6  coli\ 6
          coli\ 6  coli\ 6  coli\ 6  SWAP  R>  CELL+
  LOOP    col0\ 6  coli\ 6  coli\ 6  coli\ 6  2DROP
;

: 256keyexpand  ( kadr x cadr --  )  \ Expand 256-bit key
  6 0 DO  DUP  >R  col0\ 8  coli\ 8  coli\ 8  coli\ 8  >R  colsub  R>
          coli\ 8  coli\ 8  coli\ 8  coli\ 8  SWAP  R>  CELL+
  LOOP    col0\ 8  coli\ 8  coli\ 8  coli\ 8  2DROP
;

  0 VALUE  rndcnt    0 VALUE  1stkey   \ Init cipher rounds parameters

\ Set up stack with correct parameters for key expansion
MACRO setup\  " DROP  expkey  DUP  [ \  CELLS ]L  +  @  keycons"

ARCHITECTURE  [IF]  \ This will perform modified key processing

\ Convert I byte array index to new I' array index by sbox(I) -> I'
MACRO s->i    " CELLS sbox  +  @  CELLS "

\ Use as kmix\ i j,  where 'i' (0-3) is the byte index of cell 'j' (0-3) of the
\ current 128-bit key segment. byte(i,j) indexes the sbox table, which produces
\ the array index value for quad 'i' of dmix, which is the icolmix value for 'i'

MACRO kmixi\  " R@ [ \ DUP  \ CELLS  + ]L + C@ s->i [ 256 * CELLS dmix + ]L + @"

: ikeycolmix  ( kadr -- )  \ Do inverse colmix on a 128-bit key segment
  >R                       \ Store beginning of key segment on RETURN
  kmixi\ 0 0  kmixi\ 1 0  XOR  kmixi\ 2 0  XOR  kmixi\ 3 0  XOR  R@  !
  kmixi\ 0 1  kmixi\ 1 1  XOR  kmixi\ 2 1  XOR  kmixi\ 3 1  XOR  R@  [ 1 CELLS ]L + !
  kmixi\ 0 2  kmixi\ 1 2  XOR  kmixi\ 2 2  XOR  kmixi\ 3 2  XOR  R@  [ 2 CELLS ]L + !
  kmixi\ 0 3  kmixi\ 1 3  XOR  kmixi\ 2 3  XOR  kmixi\ 3 3  XOR  R>  [ 3 CELLS ]L + !
;

: icolmixkey  ( -- )    \ Do inverse colmix on the fully expanded key
  expkey [ 4 CELLS ]L + \ Point to 1st expanded key segment
  rndcnt 0 DO  DUP  ikeycolmix  [ 4 CELLS ]L  +  LOOP  DROP
;

        MACRO modkey " icolmixkey"  \ Do modified key processing
[ELSE]  MACRO modkey "  " \ Do nothing for regular key processing
[THEN]

: keyexpand  ( keyadr keysize mode -- )  \ Create expanded key data
  ( mode ) >R            \ Save mode on RETURN
  ( ksize) 3 RSHIFT  >R  \ Divide keysize by 8 for bytecnt and save
  expkey  R@  CMOVE      \ Move key to expanded key array
                         \ Now do key processing according to key bytecnt
  R>  DUP  16 = IF  setup\  3  128keyexpand   9  TO  rndcnt  ELSE
      DUP  24 = IF  setup\  5  192keyexpand  11  TO  rndcnt  ELSE
      DUP  32 = IF  setup\  7  256keyexpand  13  TO  rndcnt  ELSE
                R> ( mode) DROP  1 OR Abort" Invalid Keysize "
                THEN  THEN  THEN
  R> ( mode)  IF   \ Set key pointer to last key segment to decipher
                    expkey  rndcnt  1+ [ 16 CHARS ]L *  +  TO  1stkey
                    modkey  \ Do modified key processing if necessary
              ELSE  \ Set key pointer to first key segment to encipher
                    expkey  TO  1stkey
              THEN
;

\ ================  ENDIAN Processing Wordset  ================

: bytes>< ( m -- w )  \ Reverse cell bytes: 12345678 <-> 78563412
  [ HEX ]  DUP >R  18 LSHIFT  R@  FF00 AND  8 LSHIFT  OR
  R@  FF0000 AND  8 RSHIFT  OR  R>  18 RSHIFT  OR  [ DECIMAL ]
;

: cellsreverse  ( adr n -- )  \ Reverse bytes of n cells in array
  0 DO  DUP  @  bytes><  OVER !  CELL+  LOOP  DROP
;
endian?  C@ [IF]  \ if little ENDIAN, e.g. Pentium Class (PC's)
      MACRO endianarray "  "  ( adr -- adr )  \ Do nothing
[ELSE]      \ if big ENDIAN, e.g. Power PC's (Macs)
      MACRO endianarray "  DUP  8  cellsreverse "  ( adr -- adr )
[THEN]

\ ===================== Encipher Wordset ======================

: subcol0  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[0]  @  byte0@\  0  sbox       col[1]  @  byte1@\  1  sbox  OR
  col[2]  @  byte2@\  2  sbox  OR   col[3]  @  byte3@\  3  sbox  OR
;

: subcol1  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[1]  @  byte0@\  0  sbox       col[2]  @  byte1@\  1  sbox  OR
  col[3]  @  byte2@\  2  sbox  OR   col[0]  @  byte3@\  3  sbox  OR
;

: subcol2  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[2]  @  byte0@\  0  sbox       col[3]  @  byte1@\  1  sbox  OR
  col[0]  @  byte2@\  2  sbox  OR   col[1]  @  byte3@\  3  sbox  OR
;

: subcol3  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[3]  @  byte0@\  0  sbox       col[0]  @  byte1@\  1  sbox  OR
  col[1]  @  byte2@\  2  sbox  OR   col[2]  @  byte3@\  3  sbox  OR
;

: colmix0  ( -- x )  \ Col mix substitutions of row bytes of shifted cols
  col[0]  @  byte0@\  0  emix       col[1]  @  byte1@\  1  emix  XOR
  col[2]  @  byte2@\  2  emix  XOR  col[3]  @  byte3@\  3  emix  XOR
;

: colmix1  ( -- x )  \ Col mix substitutions of row bytes of shifted cols
  col[1]  @  byte0@\  0  emix       col[2]  @  byte1@\  1  emix  XOR
  col[3]  @  byte2@\  2  emix  XOR  col[0]  @  byte3@\  3  emix  XOR
;

: colmix2  ( -- x )  \ Col mix substitutions of row bytes of shifted cols
  col[2]  @  byte0@\  0  emix       col[3]  @  byte1@\  1  emix  XOR
  col[0]  @  byte2@\  2  emix  XOR  col[1]  @  byte3@\  3  emix  XOR
;

: colmix3  ( -- x )  \ Col mix substitutions of row bytes of shifted cols
  col[3]  @  byte0@\  0  emix       col[0]  @  byte1@\  1  emix  XOR
  col[1]  @  byte2@\  2  emix  XOR  col[2]  @  byte3@\  3  emix  XOR
;

: enciphrndi  ( kadr -- kadr')  \ Encpiher round w/current expkey segment
  >R  colmix3  colmix2  colmix1  colmix0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]
  keyaddi\ 2 col[2]  keyaddi\ 3 col[3]  R>  [ 4 CELLS ]L  +  ( kadr')
;

: enciphrndn  ( kadr -- )  \ Last encipher round without colmix
  >R  subcol3  subcol2  subcol1  subcol0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]  keyaddi\ 2 col[2]
  R>  [ 3 CELLS ]L  +  @  XOR  col[3]  !
;

: AESencipher  ( -- )  \ Encipher input block with given key
  \ First Add (XOR) input block with original key
  1stkey  keyadd  [ 4 CELLS ]L  + ( kadr')
  rndcnt 0 DO  enciphrndi  LOOP  enciphrndn  \ Do full encipher
;

\ ===================== Decipher Wordset ======================

: isubcol0  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[0]  @  byte0@\  0  ibox       col[3]  @  byte1@\  1  ibox  OR
  col[2]  @  byte2@\  2  ibox  OR   col[1]  @  byte3@\  3  ibox  OR
;

: isubcol1  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[1]  @  byte0@\  0  ibox       col[0]  @  byte1@\  1  ibox  OR
  col[3]  @  byte2@\  2  ibox  OR   col[2]  @  byte3@\  3  ibox  OR
;

: isubcol2  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[2]  @  byte0@\  0  ibox       col[1]  @  byte1@\  1  ibox  OR
  col[0]  @  byte2@\  2  ibox  OR   col[3]  @  byte3@\  3  ibox  OR
;

: isubcol3  ( -- x )  \ Byte substitutions of row bytes of shifted cols
  col[3]  @  byte0@\  0  ibox       col[2]  @  byte1@\  1  ibox  OR
  col[1]  @  byte2@\  2  ibox  OR   col[0]  @  byte3@\  3  ibox  OR
;

ARCHITECTURE  [IF] \ For identical ciphers architectures

: icolmix0  ( -- x )  \ InvCol mix substitutions of row bytes of shifted cols
  col[0]  @  byte0@\  0  dmix       col[3]  @  byte1@\  1  dmix  XOR
  col[2]  @  byte2@\  2  dmix  XOR  col[1]  @  byte3@\  3  dmix  XOR
;

: icolmix1  ( -- x )  \ InvCol mix substitutions of row bytes of shifted cols
  col[1]  @  byte0@\  0  dmix       col[0]  @  byte1@\  1  dmix  XOR
  col[3]  @  byte2@\  2  dmix  XOR  col[2]  @  byte3@\  3  dmix  XOR
;

: icolmix2  ( -- x )  \ InvCol mix substitutions of row bytes of shifted cols
  col[2]  @  byte0@\  0  dmix       col[1]  @  byte1@\  1  dmix  XOR
  col[0]  @  byte2@\  2  dmix  XOR  col[3]  @  byte3@\  3  dmix  XOR
;

: icolmix3  ( -- x )  \ InvCol mix substitutions of row bytes of shifted cols
  col[3]  @  byte0@\  0  dmix       col[2]  @  byte1@\  1  dmix  XOR
  col[1]  @  byte2@\  2  dmix  XOR  col[0]  @  byte3@\  3  dmix  XOR
;

: deciphrndi  ( kadr -- kadr')  \ Decpiher round w/current expkey segment
  >R  icolmix3  icolmix2  icolmix1  icolmix0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]
  keyaddi\ 2 col[2]  keyaddi\ 3 col[3]  R>  [ 4 CELLS ]L  - ( kadr')
;

: deciphrndn  ( kadr -- )  \ First round without colmix
  >R  isubcol3  isubcol2  isubcol1  isubcol0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]  keyaddi\ 2 col[2]
  R>  [ 3 CELLS ]L  +  @  XOR  col[3]  !
;

: AESdecipher  ( -- )  \ Encipher input block with given key
  \ First Add (XOR) input block with last key segnent
  1stkey  keyadd  [ 4 CELLS ]L  - ( kadr')
  rndcnt 0 DO  deciphrndi  LOOP  deciphrndn  \ Do full decipher
;
[ELSE] \ For inverted ciphers architecture

\ ================= Inverted Decipher Wordset ==================

: icolmix0  ( -- )  \ Inverse col mix of column 0 row bytes
  col[0]  @  DUP >R  byte0@\  0  dmix   R@  byte1@\  1  dmix  XOR
  R@  byte2@\  2  dmix  XOR   R>  byte3@\  3  dmix  XOR  col[0]  !
;

: icolmix1  ( -- )  \ Inverse col mix of column 1 row bytes
  col[1]  @  DUP >R  byte0@\  0  dmix   R@  byte1@\  1  dmix  XOR
  R@  byte2@\  2  dmix  XOR   R>  byte3@\  3  dmix  XOR  col[1]  !
;

: icolmix2  ( -- )  \ Inverse col mix of column 2 row bytes
  col[2]  @  DUP >R  byte0@\  0  dmix   R@  byte1@\  1  dmix  XOR
  R@  byte2@\  2  dmix  XOR   R>  byte3@\  3  dmix  XOR  col[2]  !
;

: icolmix3  ( -- )  \ Inverse col mix of column 3 row bytes
  col[3]  @  DUP >R  byte0@\  0  dmix   R@  byte1@\  1  dmix  XOR
  R@  byte2@\  2  dmix  XOR   R>  byte3@\  3  dmix  XOR  col[3]  !
;

: deciphrnd0  ( kadr -- kadr')  \ First round without inverse colmix
  >R  isubcol3  isubcol2  isubcol1  isubcol0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]
  keyaddi\ 2 col[2]  keyaddi\ 3 col[3]  R>  [ 4 CELLS ]L  - ( kadr')
;

: deciphrndi  ( kadr -- kadr')  \ Decpiher round w/current expkey segment
  >R  icolmix3  icolmix2  icolmix1  icolmix0
      isubcol3  isubcol2  isubcol1  isubcol0  ( col3..col0 )
  keyaddi\ 0 col[0]  keyaddi\ 1 col[1]
  keyaddi\ 2 col[2]  keyaddi\ 3 col[3]  R>  [ 4 CELLS ]L  - ( kadr')
;

: AESdecipher  ( -- )  \ Decipher input block with given expanded key
  \ First Add (XOR) input block with last key segnent
  1stkey  keyadd  [ 4 CELLS ]L  - ( kadr')
  deciphrnd0  rndcnt 0 DO  deciphrndi  LOOP  DROP  \ Do full decipher
;
[THEN]

\ =====================  AES File Wordset  ====================
\ Words to read a file, encipher or decipher it, store results in another file
  DECIMAL

          0  VALUE  mode             \ Holds cipher mode: encipher or decipher
          0  VALUE  keysize          \ Cipher keysize in bits
         16  VALUE  blocksize        \ AES blocksize in bytes
          VARIABLE  aes-mode         \ Holds execution address for selected AES mode
          VARIABLE  rfileid          \ Holds fileid of input  file
          VARIABLE  wfileid          \ Holds fileid of output file
          VARIABLE  nblocks          \ Number of full 16 byte blocks in input file
          VARIABLE  npads            \ Number of times bytepad can be fully filled
          VARIABLE  rembytes         \ Number of bytes < 16 at end of input file
          VARIABLE  remblocks        \ Number of full blocks remaining to read|write
          VARIABLE  padblocks        \ Number of full blocks bytepad array can hold
          VARIABLE  padlen           \ Number of bytes of pad storage
              8192  padblocks !      \ Set number of blocks for bytepad array to hold
   padblocks @ blocksize *  padlen ! \ Set byte length of bytepad array
   CREATE bytepad  padlen @  ALLOT   \ Create bytepad array to store input file data

: read-bytes  ( n - )  \ Read n bytes from opened input file into bytepad array
  bytepad  SWAP  rfileid @  READ-FILE  2DROP  \ Read n bytes into bytepad array
;

: write-bytes  ( n - )  \ Write n bytes from bytepad array to opened output file
  bytepad  SWAP  wfileid @  WRITE-FILE  DROP  \ Write n bytes to output file
;

: InputFileName  ( -- ior)  \ Open input file as read only, store fileid
  CR  ." Input  Filename: "  PAD  DUP  80  ACCEPT ( adr #)
  R/O  OPEN-FILE  SWAP  rfileid !  ( ior)
;

: TryAgain?  ( -- ?)  \ Check for invalid input file
  CR  ." Invalid iput file, try again? (Y/N)"
  KEY  DUP  EMIT  DUP [CHAR] N =  SWAP [CHAR] n = OR
;

: OutputFileName  ( -- ior)  \ Create output file as read/write; store fileid
  CR  ." Output Filename: "  PAD  DUP  80  ACCEPT ( adr #)
  R/W  CREATE-FILE  SWAP  wfileid !  ( ior)
;

: InputAgain  ( -- )  CR ." Invalid output file, enter another filename" ;

: chars>number ( caddr -- num caddr')  \ Convert HEX byte chars to number value
  >R  0 0  R>               HEX        \ Set up counted string to convert chars
  BEGIN  DUP  C@  BL  =                \ If current char is a "space" (20h)
  WHILE  CHAR+  REPEAT                 \ Skip "space" chars until databyte
  2 >NUMBER  DROP  NIP      DECIMAL    \ Convert 2 (hex) chars to byte number
;

: Filesize  ( -- )  \ Utility word to display bytesize for entered filename
  ." of "  PAD  DUP  80  ACCEPT ( adr #)  R/W  OPEN-FILE  DROP  ( fileid)
  DUP  FILE-SIZE  DROP  ( ud)  ."  has "  D. ." bytes"  CLOSE-FILE  DROP  CR
;

: InputMode  ( -- )  \ Enter cipher mode and set aesmode
  BEGIN
  CR  ." Enter cipher mode: [E/e or D/d] "
  KEY  DUP  EMIT
  DUP [CHAR] E =  OVER  [CHAR] e = OR
  IF  enciph  TO  mode  [']  AESencipher  aes-mode !  DROP  EXIT  THEN
  DUP [CHAR] D =  SWAP  [CHAR] d = OR
  IF  deciph  TO  mode  [']  AESdecipher  aes-mode !  EXIT  THEN
  CR  ." Invalid entry, try again."
  AGAIN
;

: InputKeysize  ( -- )  \ Enter keysize
  BEGIN  DECIMAL
  CR  ." Enter Keysize: 1 (128) | 2 (192) | 3 (256): "
  KEY  DUP  EMIT
  DUP [CHAR] 1 =  IF  128  TO  keysize  DROP  EXIT  THEN
  DUP [CHAR] 2 =  IF  192  TO  keysize  DROP  EXIT  THEN
      [CHAR] 3 =  IF  256  TO  keysize        EXIT  THEN
  CR  ." Invalid entry, try again. "
  AGAIN
;

: InputKey  ( -- )  DECIMAL  \ Input cipher key
  CR  ." To enter key numerically as HEX digits type N/n: "
  CR  ." To enter as ASCII characters type any other key: "
  KEY  DUP  EMIT  DUP [CHAR] N =  SWAP  [CHAR] n = OR  DUP  ( ? ?)
  \ Determine and save  digit or char count required for input entry
  IF    keysize  4  /  ( ? #digits)  \ HEX  digit count
  ELSE  keysize  8  /  ( ? #chars )  \ ASCII char count
  THEN  >R  ( ? )      \ Save digit/char count on RETURN
  BEGIN  DECIMAL       \ Receive key data input
         CR  ." A "  keysize . ." bit key needs "
         R@ .  DUP  ( ? ? ) IF ." digits: "  ELSE ."  chars: " THEN
         R@  0 DO  [CHAR] *  EMIT LOOP             \ EMIT string of *'s
         CR ." Enter the " R@ . ." digts/chars here: "
         PAD  DUP  80  ACCEPT  R@  <  ( ? adr ? )  \ Enough digits/chars?
  WHILE   ( ? adr )  DROP  CR  ." Not enough digits/chars, enter key again;"
  REPEAT  ( ? adr )
  SWAP    ( adr ? )  \ Is input HEX digits?
  IF    expkey  R>  ( adr expadr #digits)     \ For HEX digit entry
        \ Convert HEX chars into numerical bytes and store in key array
        2/ 0 DO  >R  chars>number  SWAP  R@  C!  R>  CHAR+  LOOP  2DROP
  ELSE  ( adr)  expkey  R>  ( #chars)  CMOVE  \ Move CHARS into key array
  THEN  ( -- )
  expkey  endianarray  ( expkey)       \ Endian convert array if necessary
  ( expkey)  keysize  mode  keyexpand  \ Create expanded keys
;

: aes-blocks ( bytepadadr n - )  \ Cipher and replace n blocks from bytepad array
  0 DO  ciphdat  2DUP  blocksize  CMOVE   \ Move a block into ciphdat array
        aes-mode  @  EXECUTE    ( a1 a2)  \ [En/De]cipher the block
        OVER  blocksize  CMOVE  ( a1   )  \ Replace original block in bytepad
        blocksize  +            ( a1'  )  \ Point to next block in bytepad
  LOOP  DROP                    ( -- )    \ Do n times, clear stack when done
;

: AESfile  ( -)  \ Perform AES in given cipher mode in ECB mode
  InputMode                                     \ Input cipher mode
  InputKeysize                                  \ Input keysize in bits
  InputKey                                      \ Input key and process it
  BEGIN  InputFileName  ( ior)                  \ Enter input filename
  WHILE  TryAgain? IF  EXIT  THEN  REPEAT       \ Not valid, try (not) again
  BEGIN  OutputFileName  ( ior)                 \ Request output file name
  WHILE  InputAgain  REPEAT                     \ Not valid, try (not) again
  rfileid @  FILE-SIZE  DROP         ( ud   )   \ Get bytesize of input file
  mode                               ( ud ? )   \ If deciphering input file
  IF   1 0  D-                       ( ud'  )   \ Subtract 1 from filesize for rembyte
       1  read-bytes                 ( ud'  )   \ Get original plaintext file rembytes
       bytepad C@  rembytes !        ( ud'  )   \ Store plaintext file rembytes count
       blocksize  UM/MOD  nblocks !  ( rembs)   \ Store numblocks, rembytes should be 0
       IF   rfileid @  CLOSE-FILE  DROP         \ If input rembytes <>0 CLOSE input file
            wfileid @  CLOSE-FILE  DROP         \ CLOSE the output file
            ABORT"  Ciphertext corrupted!"      \ Write meesage, then abort
       THEN
  ELSE ( ud )                                   \ If enciphering input file
       blocksize  UM/MOD  nblocks ! rembytes !  \ Store # of fullblocks and rembytes
       rembytes 1  wfileid @  WRITE-FILE  DROP  \ Write rembytes to 1st byte of outfile
  THEN
  nblocks @  0  padblocks @  UM/MOD  ( r q )    \ Determine number of times bytepad filled
  npads !  remblocks !                          \ Set values accordingly
  npads @  ?DUP                                 \ Is number of times byteppad filled > 0 ?
  IF   0 DO  padlen @  read-bytes               \ Read padlen from infile to bytepad
             bytepad  padblocks @  aes-blocks   \ Do AES on all blocks of bytepad data
             padlen @  write-bytes              \ Write ciphered blocks to outfile
       LOOP                                     \ Do for all complete padlen segments
  THEN
  remblocks @  ?DUP                             \ Are remblocks < padlen left?
  IF   DUP  blocksize  *  TUCK                  \ Set stack ( nbytes  nblocks  nbytes)
       ( nbytes )  read-bytes                   \ Read remaining bytes in full blocks
       ( nblocks)  bytepad  SWAP  aes-blocks    \ Do AES on remaining full blocks
       ( nbytes )  write-bytes                  \ Write encipehered blocks to outfile
  THEN
  mode enciph =  rembytes @  AND  ?DUP          \ If remaining encipher stray bytes left?
  IF   ( rembytes)  read-bytes                  \ Read remaining bytes into bytepad
       bytepad  1  aes-blocks                   \ Do AES on last block with fill bytes
       blocksize  write-bytes                   \ Write last ciphered block to outfile
  THEN
  mode rembytes @  AND  ( ?)                    \ If decipher mode AND rembytes > 0
  IF   wfileid @  FILE-SIZE    DROP    ( ud )   \ Get end position of deciphered file
       blocksize  rembytes @  -  0  D- ( uD')   \ Subtract ciphertext fill bytes
       wfileid @  RESIZE-FILE  DROP             \ Make deciphered file original length
  THEN
  mode IF                                       \ End of deciphering, display
  CR  ." Original data restored in output file" \ Deciphered mode completion message
  ELSE                                          \ End of enciphering, display
  CR ." Enciphered input stored in output file" \ Enciphered mode completion message
  THEN  CR

  rfileid @  CLOSE-FILE  DROP                   \ Close the input  file
  wfileid @  CLOSE-FILE  DROP                   \ Close the output file

  expkey 60 CELLS   2DUP  -1 FILL  0 FILL       \ Scrub expkey  array
  bytepad padlen @  2DUP  -1 FILL  0 FILL       \ Scrub bytepad array
;

\ ================  AES string display wordset  ===============
  DECIMAL
\ Array of digits 0123456789abcdef
: digit$  ( -- adr )  S" 0123456789abcdef"  DROP  ;

: savedigit ( n -- )  PAD  C@  1+  DUP  PAD  C!  PAD  +  C!  ;

: bytedigits ( n1 -- )
  DUP 4 RSHIFT digit$ + C@ savedigit 15 AND digit$ + C@ savedigit
;

  endian? C@ [IF]  \ little ENDIAN
: celldigits ( a1 -- )  DUP 4 + SWAP DO I C@ bytedigits LOOP ;
  [ELSE]  \ big ENDIAN
: celldigits ( a1 -- )  DUP 3 + DO I C@ bytedigits  -1 +LOOP ;
  [THEN]

: string. ( adr cellcnt -- )  \ Display counted string array
  0 PAD  !  0 DO  DUP  celldigits  CELL+  LOOP  DROP  PAD  COUNT  TYPE
;

: adrs  ( adr n -- adr' n)  TUCK  1-  CELLS  +  SWAP  ;

\ Load arrays with test data on stack
  endian? C@ [IF]  \ little ENDIAN
: testdata! ( d1..dn adr n -) adrs 0 DO SWAP bytes>< OVER ! CELL- LOOP DROP ;
  [ELSE]  \ big ENDIAN
: testdata! ( d1..dn adr n -) adrs 0 DO TUCK ! CELL- LOOP  DROP  ;
  [THEN]

\ ====================== AES Test Suite =======================
: AEStest [ HEX ]
  00010203  04050607  08090a0b  0c0d0e0f  expkey  4 testdata!
  00112233  44556677  8899aabb  ccddeeff  ciphdat 4 testdata!  [ DECIMAL ]
  CR CR ." For 128-bit key:   " expkey  4 string.
  CR    ." Plaintext input:   " ciphdat 4 string.
  CR    ." Known  ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a"
  expkey  128  enciph  keyexpand  aesencipher
  CR  ." Computed ciphtext: " ciphdat  4  string.
  expkey  128  deciph  keyexpand  aesdecipher
  CR  ." Computed original: " ciphdat  4  string.

  [ HEX ] 00010203  04050607  08090a0b  0c0d0e0f  10111213  14151617
  expkey  6 testdata!
  00112233  44556677  8899aabb  ccddeeff  ciphdat 4 testdata!  [ DECIMAL ]
  CR CR ." For 192-bit key:   " expkey  6 string.
  CR    ." Plaintext input:   " ciphdat 4 string.
  CR    ." Known  ciphertext: dda97ca4864cdfe06eaf70a0ec0d7191"
  expkey  192  enciph  keyexpand  aesencipher
  CR  ." Computed ciphtext: " ciphdat  4  string.
  expkey  192  deciph  keyexpand  aesdecipher
  CR  ." Computed original: " ciphdat  4  string.

  [ HEX ] 00010203  04050607  08090a0b  0c0d0e0f
  10111213  14151617  18191a1b  1c1d1e1f  expkey  8 testdata!
  00112233  44556677  8899aabb  ccddeeff  ciphdat 4 testdata!  [ DECIMAL ]
  CR CR ." For 256-bit key:   " expkey  8 string.
  CR    ." Plaintext input:   " ciphdat 4 string.
  CR    ." Known  ciphertext: 8ea2b7ca516745bfeafc49904b496089"
  expkey  256  enciph  keyexpand  aesencipher
  CR  ." Computed ciphtext: " ciphdat  4  string.
  expkey  256  deciph  keyexpand  aesdecipher
  CR  ." Computed original: " ciphdat  4  string.  CR
;

\ ====== Performance Test Code for various Forth systems ======
\ ==== Provide appropriate code here for systems not shown ====

\ Convert millisecond double count to  y.xxx    secs output
: msecs ( ud-ms -- ) <#  # # #       [char] . HOLD #S #> TYPE ."  secs" ;

\ Convert microsecond double count to  y.xxxxxx secs output
: usecs ( ud-us -- ) <#  # # # # # # [char] . HOLD #S #> TYPE ."  secs" ;

[DEFINED] VFXFORTH [IF]
\ ===========  VFX Forth specific timing test words ===========

: TIMER-START  ( - ms )  Ticks ;

: TIMER-END    ( ms - )  Ticks  SWAP - U>D  msecs ;

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

  DECIMAL 1000000 VALUE N#

: CiphArch  ( - )  \ State the architecture structure
  ARCHITECTURE
  IF    CR  ." Cipher structures are the same, decipher with modified expanded keys"
  ELSE  CR  ." Decipher structure is inverted, decipher with unmodified expanded keys"
  THEN
;

: ciphtest  DECIMAL  \ Speed test for both cipher modes for all 3 key sizes
  cr ." AES 128-bit encipher test for " N# . ." loops is "
  expkey 128 enciph keyexpand  TIMER-START  N# 0 DO  AESencipher  LOOP  TIMER-END
  cr ." AES 192-bit encipher test for " N# . ." loops is "
  expkey 192 enciph keyexpand  TIMER-START  N# 0 DO  AESencipher  LOOP  TIMER-END
  cr ." AES 256-bit encipher test for " N# . ." loops is "
  expkey 256 enciph keyexpand  TIMER-START  N# 0 DO  AESencipher  LOOP  TIMER-END
  CR
  cr ." AES 128-bit decipher test for " N# . ." loops is "
  expkey 128 deciph keyexpand  TIMER-START  N# 0 DO  AESdecipher  LOOP  TIMER-END
  cr ." AES 192-bit decipher test for " N# . ." loops is "
  expkey 192 deciph keyexpand  TIMER-START  N# 0 DO  AESdecipher  LOOP  TIMER-END
  cr ." AES 256-bit decipher test for " N# . ." loops is "
  expkey 256 deciph keyexpand  TIMER-START  N# 0 DO  AESdecipher  LOOP  TIMER-END
;

: keytest  DECIMAL   \ Speed test for both cipher modes for all 3 key sizes
  cr ." AES 128-bit encipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 128 enciph keyexpand  LOOP TIMER-END
  cr ." AES 192-bit encipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 192 enciph keyexpand  LOOP TIMER-END
  cr ." AES 256-bit encipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 256 enciph keyexpand  LOOP TIMER-END
  CR
  cr ." AES 128-bit decipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 128 deciph keyexpand  LOOP TIMER-END
  cr ." AES 192-bit decipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 192 deciph keyexpand  LOOP TIMER-END
  cr ." AES 256-bit decipher keys for " N# . ." loops is "
  TIMER-START  N# 0 DO  expkey 256 deciph keyexpand  LOOP TIMER-END
;

: speed-test  CiphArch  ciphtest  CR  keytest  CR  ;
[THEN]