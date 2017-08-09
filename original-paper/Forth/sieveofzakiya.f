\ This code performs the Sieve of Zakiya (SoZ) in Forth.
\ The SoZ uses Number Theory Sieves (NTS) which are
\ classes of number theory prime generator functions.
\ This code is a direct translation of the Ruby versions
\ in my paper, "Ultimate Prime Sieve -- Sieve of Zakiya."
\ The pdf of the paper, and this source code (with others)
\ is available to download from this site:

\ www.4shared.com/account/dir/7467736/97bd7b71/sharing

\ This code was developed and tested on gforth on Linux.
\ It also runs on Win32Forth on Windows.
\ Hardware system: Intel P4 2.8 Ghz, 1 GB
\ Jabari Zakiya, 2008/06/18,  jzakiya at mail dot com
\ Updated 2008/07/28 -- more efficient coding
\ Updated 2008/10/13 -- added primesP60, SoE, BENCHMARKS
\ Updated 2008/11/03 -- architectural & coding improvements
\                       to all generators. Renamed generators.
\ Updated 2008/11/10 -- add SoZP11
\ Updated 2008/11/25 -- comments about passing in sqrt N
\                       cosmetic code changes of nested IF..THENS
\ Updated 2008/12/20 -- change sqrt to not rely on float library
\ Updated 2010/02/06 -- incorporate elimination of n1-n480 VALUEs
\ Start: gforth -m xxxM to do big N values
\ Then:  include <path/file 

: array create  here over erase  allot  does> swap + ;

\ : sqrt ( n - n)  0 d>f fsqrt f>d drop ;
\ Replace dependency on fsqrt with universal integer sqrt
\ address-unit-bits cells constant bits/cell \ 8 cells for 8-bit byte addressable
: sqrt ( n - n) 0 0 [ 8 cells 2/ ] literal 0 do >r d2* d2* r> 
    2* 2dup 2* u> if dup >r 2* - 1- r> 1+ then loop nip nip 
;

   0 value num
   1000000001 to num       \ set number to find primes upto
   num 1- 2/ value lndx    \ max index and elements for sieve array
   lndx 1155 + array sieve \ 1155 will allow sieve for modulus <= 2310
   lndx sieve value slndx  \ end of array address

\ nprimes - show number of primes found, .primes - display prime values
: nprimes ( - n)  1 ( for prime 2) lndx sieve 0 sieve do I c@ if 1+ then loop . ;
: .primes ." 2 " lndx 0 do I sieve c@ if I 2* 3 + . then loop ;

   0 value n     0 value x     0 value x1
   0 value j2    0 value j3    0 value j4    0 value j5    0 value j6

   0 value p1    0 value p2    0 value p3    0 value p4    0 value p5    0 value p6
   0 value p7    0 value p8    0 value p9    0 value p10   0 value p11   0 value p12
   0 value p13   0 value p14   0 value p15   0 value p16   0 value p17   0 value p18
   0 value p19   0 value p20   0 value p21   0 value p22   0 value p23   0 value p24
   0 value p25   0 value p26   0 value p27   0 value p28   0 value p29   0 value p30
   0 value p31   0 value p32   0 value p33   0 value p34   0 value p35   0 value p36
   0 value p37   0 value p38   0 value p39   0 value p40   0 value p41   0 value p42
   0 value p43   0 value p44   0 value p45   0 value p46   0 value p47   0 value p48
   0 value p49   0 value p50   0 value p51   0 value p52   0 value p53   0 value p54
   0 value p55   0 value p56   0 value p57   0 value p58   0 value p59   0 value p60
   0 value p61   0 value p62   0 value p63   0 value p64   0 value p65   0 value p66
   0 value p67   0 value p68   0 value p69   0 value p70   0 value p71   0 value p72
   0 value p73   0 value p74   0 value p75   0 value p76   0 value p77   0 value p78
   0 value p79   0 value p80   0 value p81   0 value p82   0 value p83   0 value p84
   0 value p85   0 value p86   0 value p87   0 value p88   0 value p89   0 value p90
   0 value p91   0 value p92   0 value p93   0 value p94   0 value p95   0 value p96
   0 value p97   0 value p98   0 value p99   0 value p100  0 value p101  0 value p102
   0 value p103  0 value p104  0 value p105  0 value p106  0 value p107  0 value p108
   0 value p109  0 value p110  0 value p111  0 value p112  0 value p113  0 value p114
   0 value p115  0 value p116  0 value p117  0 value p118  0 value p119  0 value p120
   0 value p121  0 value p122  0 value p123  0 value p124  0 value p125  0 value p126
   0 value p127  0 value p128  0 value p129  0 value p130  0 value p131  0 value p132
   0 value p133  0 value p134  0 value p135  0 value p136  0 value p137  0 value p138
   0 value p139  0 value p140  0 value p141  0 value p142  0 value p143  0 value p144
   0 value p145  0 value p146  0 value p147  0 value p148  0 value p149  0 value p150
   0 value p151  0 value p152  0 value p153  0 value p154  0 value p155  0 value p156
   0 value p157  0 value p158  0 value p159  0 value p160  0 value p161  0 value p162
   0 value p163  0 value p164  0 value p165  0 value p166  0 value p167  0 value p168
   0 value p169  0 value p170  0 value p171  0 value p172  0 value p173  0 value p174
   0 value p175  0 value p176  0 value p177  0 value p178  0 value p179  0 value p180
   0 value p181  0 value p182  0 value p183  0 value p184  0 value p185  0 value p186
   0 value p187  0 value p188  0 value p189  0 value p190  0 value p191  0 value p192
   0 value p193  0 value p194  0 value p195  0 value p196  0 value p197  0 value p198
   0 value p199  0 value p200  0 value p201  0 value p202  0 value p203  0 value p204
   0 value p205  0 value p206  0 value p207  0 value p208  0 value p209  0 value p210
   0 value p211  0 value p212  0 value p213  0 value p214  0 value p215  0 value p216
   0 value p217  0 value p218  0 value p219  0 value p220  0 value p221  0 value p222
   0 value p223  0 value p224  0 value p225  0 value p226  0 value p227  0 value p228
   0 value p229  0 value p230  0 value p231  0 value p232  0 value p233  0 value p234
   0 value p235  0 value p236  0 value p237  0 value p238  0 value p239  0 value p240
   0 value p241  0 value p242  0 value p243  0 value p244  0 value p245  0 value p246
   0 value p247  0 value p248  0 value p249  0 value p250  0 value p251  0 value p252
   0 value p253  0 value p254  0 value p255  0 value p256  0 value p257  0 value p258
   0 value p259  0 value p260  0 value p261  0 value p262  0 value p263  0 value p264
   0 value p265  0 value p266  0 value p267  0 value p268  0 value p269  0 value p270
   0 value p271  0 value p272  0 value p273  0 value p274  0 value p275  0 value p276
   0 value p277  0 value p278  0 value p279  0 value p280  0 value p281  0 value p282
   0 value p283  0 value p284  0 value p285  0 value p286  0 value p287  0 value p288
   0 value p289  0 value p290  0 value p291  0 value p292  0 value p293  0 value p294
   0 value p295  0 value p296  0 value p297  0 value p298  0 value p299  0 value p300
   0 value p301  0 value p302  0 value p303  0 value p304  0 value p305  0 value p306
   0 value p307  0 value p308  0 value p309  0 value p310  0 value p311  0 value p312
   0 value p313  0 value p314  0 value p315  0 value p316  0 value p317  0 value p318
   0 value p319  0 value p320  0 value p321  0 value p322  0 value p323  0 value p324
   0 value p325  0 value p326  0 value p327  0 value p328  0 value p329  0 value p330
   0 value p331  0 value p332  0 value p333  0 value p334  0 value p335  0 value p336
   0 value p337  0 value p338  0 value p339  0 value p340  0 value p341  0 value p342
   0 value p343  0 value p344  0 value p345  0 value p346  0 value p347  0 value p348
   0 value p349  0 value p350  0 value p351  0 value p352  0 value p353  0 value p354
   0 value p355  0 value p356  0 value p357  0 value p358  0 value p359  0 value p360
   0 value p361  0 value p362  0 value p363  0 value p364  0 value p365  0 value p366
   0 value p367  0 value p368  0 value p369  0 value p370  0 value p371  0 value p372
   0 value p373  0 value p374  0 value p375  0 value p376  0 value p377  0 value p378
   0 value p379  0 value p380  0 value p381  0 value p382  0 value p383  0 value p384
   0 value p385  0 value p386  0 value p387  0 value p388  0 value p389  0 value p390
   0 value p391  0 value p392  0 value p393  0 value p394  0 value p395  0 value p396
   0 value p397  0 value p398  0 value p399  0 value p400  0 value p401  0 value p402
   0 value p403  0 value p404  0 value p405  0 value p406  0 value p407  0 value p408
   0 value p409  0 value p410  0 value p411  0 value p412  0 value p413  0 value p414
   0 value p415  0 value p416  0 value p417  0 value p418  0 value p419  0 value p420
   0 value p421  0 value p422  0 value p423  0 value p424  0 value p425  0 value p426
   0 value p427  0 value p428  0 value p429  0 value p430  0 value p431  0 value p432
   0 value p433  0 value p434  0 value p435  0 value p436  0 value p437  0 value p438
   0 value p439  0 value p440  0 value p441  0 value p442  0 value p443  0 value p444
   0 value p445  0 value p446  0 value p447  0 value p448  0 value p449  0 value p450
   0 value p451  0 value p452  0 value p453  0 value p454  0 value p455  0 value p456
   0 value p457  0 value p458  0 value p459  0 value p460  0 value p461  0 value p462
   0 value p463  0 value p464  0 value p465  0 value p466  0 value p467  0 value p468
   0 value p469  0 value p470  0 value p471  0 value p472  0 value p473  0 value p474
   0 value p475  0 value p476  0 value p477  0 value p478  0 value p479  0 value p480

: SoE ( N - )
   \ classical brute-force Sieve of Eratosthenes (SoE)
   \ initialize N/2 size sieve array with all true values
   \ where the sieve indices represent the odd integers: 0->3, 1->5, etc
   \ convert real integers to array indices/vals by i = (n-3)>>1
   0 sieve lndx 1+ 1 fill      \ set all sieve elements to true
   ( num) sqrt 3 - 2/ 1+ 0 do  \ ((sqrt(num)-3)/2)+1  0  do
       I sieve c@ if           \ if sieve element prime, eliminate its multiples
          \ do equivalent of (I*I).step(lndx, 2I+3) { |j| sieve[j] = false }
	  \ where (I*(I+3)*2)+3 performs I*I for the converted odd integers
          I 2* 3 + ( ndx+) slndx  I 3 + I * 2* 3 + sieve do 0 I c! dup +loop drop
       then
   loop
;

: SoZP3 ( N - )
  \ all prime candidates > 3 are of the form 6*x+1 and 6*x+5
  \ initialize sieve array with only these candidate values
  \ where byte array indices for sieve are odd integers representations
  \ convert integers to array indices/vals by  i = (n-3)>>1

   to num   -1 sieve to p1   1 sieve to p2
   begin p2 slndx < while
      3 p1 + to p1   3 p2 + to p2   1 p1 c!   1 p2 c!
   repeat
   \ now initialize sieve array with (odd) primes < 6
   1 0 sieve c!   1 1 sieve c!

   0 to n   \ n = primes count
   num sqrt 3 - 2/ 1+ 1 do
       I sieve c@ if
          \ j  i  5i  7i  6i    p1=5i,  p2=7i,  x=6i
          \ 5->1  11  16  15
          \ j = (2*i)+3; p1 = (2*j)+i; p2 = p1+j; x = p2-i
          I 2* 3 + ( j) dup 2* I + ( p1) dup to p1 + dup to p2 I - to x1
          n 2/ x1 * to x  n 1+ to n   \ x = x1*(n/rescnt)  rescnt = 2
          x p1 + sieve to p1  x p2 + sieve to p2
          begin p2 slndx < while
             0 p1 c!  0 p2 c!  x1 p1 + to p1  x1 p2 + to p2
          repeat
          p1 slndx < if 0 p1 c! then
       then
   loop
;

: SoZP5 ( N - )
  \ all prime candidates > 5 are of the form 30*x+(1,7,11,13,17,19,23,29)
  \ initialize sieve array with only these candidate values
  \ where byte array indices for sieve are odd integers representations
  \ convert integers to array indices/vals by i = (n-3)>>1

   to num
   -1 sieve to p1  2 sieve to p2  4  sieve to p3  5  sieve to p4
    7 sieve to p5  8 sieve to p6  10 sieve to p7  13 sieve to p8
   begin p8 slndx < while
      15 p1 + to p1   15 p2 + to p2   15 p3 + to p3  15 p4 + to p4
      15 p5 + to p5   15 p6 + to p6   15 p7 + to p7  15 p8 + to p8
      1 p1 c!  1 p2 c!  1 p3 c!  1 p4 c!  1 p5 c!  1 p6 c!  1 p7 c!  1 p8 c!
   repeat
   \ now initialize sieve array with (odd) primes < 30
   1 0 sieve c!  1 1 sieve c!  1 2  sieve c!  1 4  sieve c!  1 5 sieve c!
   1 7 sieve c!  1 8 sieve c!  1 10 sieve c!  1 13 sieve c!

   0 to n   \ n = primes count
   num sqrt 3 - 2/ 1+ 2 do
       I sieve c@ if
          \ p1=7*i, p2=11*i, p3=13*i --- p6=23*i, p7=29*i, p8=31*i, x=30*i
          \ j  i  7i  11i   13i   17i   19i   23i   29i   31i   30i
          \ 7->2  23   37    44    58    65    79   100   107   105
	  \ j=(2*i)+3; j2=2*j; p1 = j2+j+i; p2 = p1+j2; p3 = p2+j; p4=p3+j2
	  \ p5 = p4+j;  p6 = p5+j2;  p7 = p6+j2+j; p8 = p7+j;  x = p8-i
          I 2* 3 + ( j) I over dup 2* dup >r + + ( p1) dup to p1 r@  + ( p2)
          dup to p2 over + ( p3) dup to p3 r@ + ( p4) dup to p4 over + ( p5)
          dup to p5 r@ + ( p6) dup to p6 over + r> + ( p7) dup to p7 + ( p8)
          dup to p8 I - ( x1) to x1
          n 3 rshift x1 * to x  n 1+ to n   \ x = x1*(n/rescnt)  rescnt = 8
          x p1 + sieve to p1  x p2 + sieve to p2  x p3 + sieve to p3  x p4 + sieve to p4
          x p5 + sieve to p5  x p6 + sieve to p6  x p7 + sieve to p7  x p8 + sieve to p8
	  begin p8 slndx < while
             0 p1 c!  0 p2 c!  0 p3 c!  0 p4 c!  0 p5 c!  0 p6 c!  0 p7 c!  0 p8 c!
             x1 p1 + to p1  x1 p2 + to p2  x1 p3 + to p3  x1 p4 + to p4
             x1 p5 + to p5  x1 p6 + to p6  x1 p7 + to p7  x1 p8 + to p8
          repeat
          p1 slndx < if 0 p1 c!   p2 slndx < if 0 p2 c!   p3 slndx < if 0 p3 c!
          p4 slndx < if 0 p4 c!   p5 slndx < if 0 p5 c!   p6 slndx < if 0 p6 c!
          p7 slndx < if 0 p7 c!   then then then then then then then
       then
   loop
;

: SoZP60 ( N - )
  \ all prime candidates > 5 are of the form 60*x+(1,7,11,13,17,19,23,29,31,37
  \ 41,43,47,49,53,59)
  \ initialize sieve array with only these candidate values
  \ where byte array indices for sieve are odd integers representations
  \ convert integers to array indices/vals by i = (n-3)>>1

   to num
   -1 sieve to p1    2 sieve to p2    4 sieve to p3    5 sieve to p4
    7 sieve to p5    8 sieve to p6   10 sieve to p7   13 sieve to p8
   14 sieve to p9   17 sieve to p10  19 sieve to p11  20 sieve to p12
   22 sieve to p13  23 sieve to p14  25 sieve to p15  28 sieve to p16
   begin p16 slndx < while
      30 p1  + to p1   30 p2  + to p2   30 p3  + to p3   30 p4  + to p4
      30 p5  + to p5   30 p6  + to p6   30 p7  + to p7   30 p8  + to p8
      30 p9  + to p9   30 p10 + to p10  30 p11 + to p11  30 p12 + to p12
      30 p13 + to p13  30 p14 + to p14  30 p15 + to p15  30 p16 + to p16
      1 p1 c!  1 p2  c!  1 p3  c!  1 p4  c!  1 p5  c!  1 p6  c!  1 p7  c!  1 p8  c!
      1 p9 c!  1 p10 c!  1 p11 c!  1 p12 c!  1 p13 c!  1 p14 c!  1 p15 c!  1 p16 c!
   repeat
   \ now initialize sieve array with (odd) primes < 30
   1 0 sieve c!  1 1 sieve c!  1 2  sieve c! 1 4  sieve c! 1 5  sieve c!
   1 7 sieve c!  1 8 sieve c!  1 10 sieve c! 1 13 sieve c! 1 14 sieve c!
   1 17 sieve c! 1 19 sieve c! 1 20 sieve c! 1 22 sieve c! 1 25 sieve c! 1 28 sieve c!

   0 to n   \ n = primes count
   num sqrt 3 - 2/ 1+ 2 do
       I sieve c@ if
          \ p1=7*i, p2=11*i, p3=13*i --- p14=53*i, p15=59*i, p16=61*i, x=60*i
          \ j  i  7i 11i 13i 17i 19i 23i  29i  31i 37i 41i 43i 47i 49i 53i 59i 61i 60i
          \ 7->2  23  37  44  58  65  79  100  107 128 142 149 163 170 184 205 212 210
	  \ j = (2*i)+3; j2 = 2*j;  p1 = j2+j+i;  p2 = p1+j2;  p3 = p2+j;    p4 = p3+j2
	  \ p5 = p4+j;  p6 = p5+j2; p7 = p6+j2+j; p8 = p7+j;   p9 = p8+j2+j; p10 = p9+j2
	  \ p11 = p10+j; p12 = p11+j2; p13 = p12+j; p14 = p13+j2; p15 = p14+j2+j
	  \ p16 = p15+j; k = p16-i
          I 2* 3 + ( j) I over dup 2* dup >r + + ( p1) dup to p1 r@  + ( p2)
          dup to p2 over + ( p3) dup to p3 r@ + ( p4) dup to p4 over + ( p5)
          dup to p5 r@ + ( p6) dup to p6 over + r@ + ( p7)  dup to p7  over + ( p8)
          dup to p8 over + r@ + ( p9) dup to p9 r@ + ( p10) dup to p10 over + ( p11)
	  dup to p11 r@ + ( p12) dup to p12 over + ( p13) dup to p13 r@ + ( p14)
	  dup to p14 over + r> + ( p15) dup to p15 + ( p16) dup to p16 I - ( x1) to x1
          n 4 rshift x1 * to x  n 1+ to n   \ x = x1*(n/rescnt)  rescnt = 16
          x p1  + sieve to p1   x p2  + sieve to p2   x p3  + sieve to p3   x p4  + sieve to p4
          x p5  + sieve to p5   x p6  + sieve to p6   x p7  + sieve to p7   x p8  + sieve to p8
          x p9  + sieve to p9   x p10 + sieve to p10  x p11 + sieve to p11  x p12 + sieve to p12
          x p13 + sieve to p13  x p14 + sieve to p14  x p15 + sieve to p15  x p16 + sieve to p16
	  begin p16 slndx < while
             0 p1 c!  0 p2  c!  0 p3  c!  0 p4  c!  0 p5  c!  0 p6  c!  0 p7  c!  0 p8  c!
             0 p9 c!  0 p10 c!  0 p11 c!  0 p12 c!  0 p13 c!  0 p14 c!  0 p15 c!  0 p16 c!
             x1 p1  + to p1   x1 p2  + to p2   x1 p3  + to p3   x1 p4  + to p4
             x1 p5  + to p5   x1 p6  + to p6   x1 p7  + to p7   x1 p8  + to p8
             x1 p9  + to p9   x1 p10 + to p10  x1 p11 + to p11  x1 p12 + to p12
             x1 p13 + to p13  x1 p14 + to p14  x1 p15 + to p15  x1 p16 + to p16
          repeat
          p1  slndx < if 0 p1  c!   p2  slndx < if 0 p2  c!   p3  slndx < if 0 p3  c!
          p4  slndx < if 0 p4  c!   p5  slndx < if 0 p5  c!   p6  slndx < if 0 p6  c!
          p7  slndx < if 0 p7  c!   p8  slndx < if 0 p8  c!   p9  slndx < if 0 p9  c!
          p10 slndx < if 0 p10 c!   p11 slndx < if 0 p11 c!   p12 slndx < if 0 p12 c!
          p13 slndx < if 0 p13 c!   p14 slndx < if 0 p14 c!   p15 slndx < if 0 p15 c!
          then then then then then then then then then then then then then then then
       then
   loop
;

: SoZP7 ( N - )
  \ all prime candidates > 7 are of form  210*x+(1,11,13,17,19,23,29,31,37
  \ 41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,121,127,131
  \ 137,139,143,149,151,157,163,167,169173,179,181,187,191,193,197,199,209)
  \ initialize sieve array with only these candidate values
  \ where byte array indices for sieve are odd integers representations
  \ convert integers to array indices/vals by i = (n-3)>>1

   to num
   -1 sieve to p1    4 sieve to p2    5 sieve to  p3    7  sieve to p4
    8 sieve to p5   10 sieve to p6   13 sieve to  p7   14  sieve to p8
   17 sieve to p9   19 sieve to p10  20 sieve to  p11  22  sieve to p12
   25 sieve to p13  28 sieve to p14  29 sieve to  p15  32  sieve to p16
   34 sieve to p17  35 sieve to p18  38 sieve to  p19  40  sieve to p20 
   43 sieve to p21  47 sieve to p22  49 sieve to  p23  50  sieve to p24
   52 sieve to p25  53 sieve to p26  55 sieve to  p27  62  sieve to p28
   64 sieve to p29  67 sieve to p30  68 sieve to  p31  73  sieve to p32
   74 sieve to p33  77 sieve to p34  80 sieve to  p35  82  sieve to p36
   85 sieve to p37  88 sieve to p38  89 sieve to  p39  94  sieve to p40
   95 sieve to p41  97 sieve to p42  98 sieve to  p43  59  sieve to p44
   70 sieve to p45  83 sieve to p46  92 sieve to  p47  103 sieve to p48
   begin p48 slndx < while
      105 p1  + to p1   105 p2  + to p2   105 p3  + to p3   105 p4  + to p4
      105 p5  + to p5   105 p6  + to p6   105 p7  + to p7   105 p8  + to p8
      105 p9  + to p9   105 p10 + to p10  105 p11 + to p11  105 p12 + to p12
      105 p13 + to p13  105 p14 + to p14  105 p15 + to p15  105 p16 + to p16
      105 p17 + to p17  105 p18 + to p18  105 p19 + to p19  105 p20 + to p20
      105 p21 + to p21  105 p22 + to p22  105 p23 + to p23  105 p24 + to p24
      105 p25 + to p25  105 p26 + to p26  105 p27 + to p27  105 p28 + to p28
      105 p29 + to p29  105 p30 + to p30  105 p31 + to p31  105 p32 + to p32
      105 p33 + to p33  105 p34 + to p34  105 p35 + to p35  105 p36 + to p36
      105 p37 + to p37  105 p38 + to p38  105 p39 + to p39  105 p40 + to p40
      105 p41 + to p41  105 p42 + to p42  105 p43 + to p43  105 p44 + to p44
      105 p45 + to p45  105 p46 + to p46  105 p47 + to p47  105 p48 + to p48
      1 p1  c!  1 p2  c!  1 p3  c!  1 p4  c!  1 p5  c!  1 p6  c!  1 p7  c!  1 p8  c!
      1 p9  c!  1 p10 c!  1 p11 c!  1 p12 c!  1 p13 c!  1 p14 c!  1 p15 c!  1 p16 c!
      1 p17 c!  1 p18 c!  1 p19 c!  1 p20 c!  1 p21 c!  1 p22 c!  1 p23 c!  1 p24 c! 
      1 p25 c!  1 p26 c!  1 p27 c!  1 p28 c!  1 p29 c!  1 p30 c!  1 p31 c!  1 p32 c! 
      1 p33 c!  1 p34 c!  1 p35 c!  1 p36 c!  1 p37 c!  1 p38 c!  1 p39 c!  1 p40 c!
      1 p41 c!  1 p42 c!  1 p43 c!  1 p44 c!  1 p45 c!  1 p46 c!  1 p47 c!  1 p48 c!
   repeat
   \ now initialize sieve array with (odd) primes < 210
   1 0  sieve c!  1 1  sieve c!  1 2  sieve c!  1 4  sieve c!  1 5  sieve c!
   1 7  sieve c!  1 8  sieve c!  1 10 sieve c!  1 13 sieve c!  1 14 sieve c!
   1 17 sieve c!  1 19 sieve c!  1 20 sieve c!  1 22 sieve c!  1 25 sieve c!
   1 28 sieve c!  1 29 sieve c!  1 32 sieve c!  1 34 sieve c!  1 35 sieve c!
   1 38 sieve c!  1 40 sieve c!  1 43 sieve c!  1 47 sieve c!  1 49 sieve c!
   1 50 sieve c!  1 52 sieve c!  1 53 sieve c!  1 55 sieve c!  1 62 sieve c!
   1 64 sieve c!  1 67 sieve c!  1 68 sieve c!  1 73 sieve c!  1 74 sieve c!
   1 77 sieve c!  1 80 sieve c!  1 82 sieve c!  1 85 sieve c!  1 88 sieve c!
   1 89 sieve c!  1 94 sieve c!  1 95 sieve c!  1 97 sieve c!  1 98 sieve c!

   0 to n   \ n = primes count
   num sqrt 3 - 2/ 1+ 4 do
       I sieve c@ if
          \ p1=11*i, p2=13*i, p3=17*i -- p46=199*i, p47=209*i, p48=211*i,  x=210*i
          \  j  i 11i 13i 17i 19i 23i 29i 31i 37i..193i 197i 199i 209i 211i 210i
          \ 11->4  59  70  92 103 125 191 202 128  1060 1082 1093 1148 1159 1155
          \ j=(2*i)+3; j2=2*j; j3=j2+j; j4=2*j2; j5=j4+j
          \ p1=j5+i; p2=p1+j; p3=p2+j2; p4=p3+j; p5=p4+j2; p6=p5+j3; p7=p6+j; p8=p7+j3
          \ p9=p8+j2; p10=p9+j; p11=p10+j2; p12=p11+j3; p13=p12+j3; p14=p13+j;p15=p14+j3
          \ p16=p15+j2; p17=p16+j;  p18=p17+j3; p19=p18+j2; p20=p19+j3; p21=p20+j4
          \ p22=p21+j2; p23=p22+j;  p24=p23+j2; p25=p24+j;  p26=p25+j2; p27=p26+j4
          \ p28=p27+j3; p29=p28+j2; p30=p29+j3; p31=p30+j;  p32=p31+j2; p33=p32+j3
          \ p34=p33+j;  p35=p34+j3; p36=p35+j3; p37=p36+j2; p38=p37+j;  p39=p38+j2
          \ p40=p39+j3; p41=p40+j;  p42=p41+j3; p43=p42+j2; p44=p43+j;  p45=p44+j2
          \ p46=p45+j;  p47=p46+j5; p48=p47+j;  x = p48-i
          I 2* 3 + ( j) dup 2* ( j2) dup to j2 over + ( j3) dup to j3  j2 + ( j5)
          I over ( j5) >r + ( p1)  dup to p1 over  + ( p2)  dup to p2  j2 + ( p3)
	  dup to p3  over + ( p4)  dup to p4  j2   + ( p5)  dup to p5  j3 + ( p6)
	  dup to p6  over + ( p7)  dup to p7  j3   + ( p8)  dup to p8  j2 + ( p9)
	  dup to p9  over + ( p10) dup to p10 j2   + ( p11) dup to p11 j3 + ( p12)
	  dup to p12 j3   + ( p13) dup to p13 over + ( p14) dup to p14 j3 + ( p15)
	  dup to p15 j2   + ( p16) dup to p16 over + ( p17) dup to p17 j3 + ( p18)
	  dup to p18 j2   + ( p19) dup to p19 j3   + ( p20) dup to p20 j2 2* + ( p21)
	  dup to p21 j2   + ( p22) dup to p22 over + ( p23) dup to p23 j2 + ( p24)
	  dup to p24 over + ( p25) dup to p25 j2   + ( p26) dup to p26 j2 2* + ( p27)
	  dup to p27 j3   + ( p28) dup to p28 j2   + ( p29) dup to p29 j3 + ( p30)
	  dup to p30 over + ( p31) dup to p31 j2   + ( p32) dup to p32 j3 + ( p33)
	  dup to p33 over + ( p34) dup to p34 j3   + ( p35) dup to p35 j3 + ( p36)
	  dup to p36 j2   + ( p37) dup to p37 over + ( p38) dup to p38 j2 + ( p39)
	  dup to p39 j3   + ( p40) dup to p40 over + ( p41) dup to p41 j3 + ( p42)
	  dup to p42 j2   + ( p43) dup to p43 over + ( p44) dup to p44 j2 + ( p45)
	  dup to p45 over + ( p46) dup to p46 r>   + ( p47) dup to p47    + ( p48)
	  dup to p48 I - to x1
          n 48 / x1 * to x  n 1+ to n        \ x = x1*(n/rescnt)  rescnt = 48
          x p1  + sieve to p1   x p2  + sieve to p2   x p3  + sieve to p3   x p4  + sieve to p4
          x p5  + sieve to p5   x p6  + sieve to p6   x p7  + sieve to p7   x p8  + sieve to p8
          x p9  + sieve to p9   x p10 + sieve to p10  x p11 + sieve to p11  x p12 + sieve to p12
          x p13 + sieve to p13  x p14 + sieve to p14  x p15 + sieve to p15  x p16 + sieve to p16
          x p17 + sieve to p17  x p18 + sieve to p18  x p19 + sieve to p19  x p20 + sieve to p20
          x p21 + sieve to p21  x p22 + sieve to p22  x p23 + sieve to p23  x p24 + sieve to p24
          x p25 + sieve to p25  x p26 + sieve to p26  x p27 + sieve to p27  x p28 + sieve to p28
          x p29 + sieve to p29  x p30 + sieve to p30  x p31 + sieve to p31  x p32 + sieve to p32
          x p33 + sieve to p33  x p34 + sieve to p34  x p35 + sieve to p35  x p36 + sieve to p36
          x p37 + sieve to p37  x p38 + sieve to p38  x p39 + sieve to p39  x p40 + sieve to p40
          x p41 + sieve to p41  x p42 + sieve to p42  x p43 + sieve to p43  x p44 + sieve to p44
          x p45 + sieve to p45  x p46 + sieve to p46  x p47 + sieve to p47  x p48 + sieve to p48
          begin p48 slndx < while
             0 p1  c!  0 p2  c!  0 p3  c!  0 p4  c!  0 p5  c!  0 p6  c!  0 p7  c!  0 p8  c!
             0 p9  c!  0 p10 c!  0 p11 c!  0 p12 c!  0 p13 c!  0 p14 c!  0 p15 c!  0 p16 c! 
             0 p17 c!  0 p18 c!  0 p19 c!  0 p20 c!  0 p21 c!  0 p22 c!  0 p23 c!  0 p24 c!
             0 p25 c!  0 p26 c!  0 p27 c!  0 p28 c!  0 p29 c!  0 p30 c!  0 p31 c!  0 p32 c!
             0 p33 c!  0 p34 c!  0 p35 c!  0 p36 c!  0 p37 c!  0 p38 c!  0 p39 c!  0 p40 c!
             0 p41 c!  0 p42 c!  0 p43 c!  0 p44 c!  0 p45 c!  0 p46 c!  0 p47 c!  0 p48 c!
             x1 p1  + to p1   x1 p2  + to p2   x1 p3  + to p3   x1 p4  + to p4
             x1 p5  + to p5   x1 p6  + to p6   x1 p7  + to p7   x1 p8  + to p8
             x1 p9  + to p9   x1 p10 + to p10  x1 p11 + to p11  x1 p12 + to p12
             x1 p13 + to p13  x1 p14 + to p14  x1 p15 + to p15  x1 p16 + to p16
             x1 p17 + to p17  x1 p18 + to p18  x1 p19 + to p19  x1 p20 + to p20
             x1 p21 + to p21  x1 p22 + to p22  x1 p23 + to p23  x1 p24 + to p24
             x1 p25 + to p25  x1 p26 + to p26  x1 p27 + to p27  x1 p28 + to p28
             x1 p29 + to p29  x1 p30 + to p30  x1 p31 + to p31  x1 p32 + to p32
             x1 p33 + to p33  x1 p34 + to p34  x1 p35 + to p35  x1 p36 + to p36
             x1 p37 + to p37  x1 p38 + to p38  x1 p39 + to p39  x1 p40 + to p40
             x1 p41 + to p41  x1 p42 + to p42  x1 p43 + to p43  x1 p44 + to p44
             x1 p45 + to p45  x1 p46 + to p46  x1 p47 + to p47  x1 p48 + to p48
          repeat
          p1  slndx < if 0 p1  c!   p2  slndx < if 0 p2  c!   p3  slndx < if 0 p3  c!
          p4  slndx < if 0 p4  c!   p5  slndx < if 0 p5  c!   p6  slndx < if 0 p6  c!
          p7  slndx < if 0 p7  c!   p8  slndx < if 0 p8  c!   p9  slndx < if 0 p9  c!
          p10 slndx < if 0 p10 c!   p11 slndx < if 0 p11 c!   p12 slndx < if 0 p12 c!
          p13 slndx < if 0 p13 c!   p14 slndx < if 0 p14 c!   p15 slndx < if 0 p15 c!
          p16 slndx < if 0 p16 c!   p17 slndx < if 0 p17 c!   p18 slndx < if 0 p18 c!
          p19 slndx < if 0 p19 c!   p20 slndx < if 0 p20 c!   p21 slndx < if 0 p21 c!
          p22 slndx < if 0 p22 c!   p23 slndx < if 0 p23 c!   p24 slndx < if 0 p24 c!
          p25 slndx < if 0 p25 c!   p26 slndx < if 0 p26 c!   p27 slndx < if 0 p27 c!
          p28 slndx < if 0 p28 c!   p29 slndx < if 0 p29 c!   p30 slndx < if 0 p30 c!
          p31 slndx < if 0 p31 c!   p32 slndx < if 0 p32 c!   p33 slndx < if 0 p33 c!
          p34 slndx < if 0 p34 c!   p35 slndx < if 0 p35 c!   p36 slndx < if 0 p36 c!
          p37 slndx < if 0 p37 c!   p38 slndx < if 0 p38 c!   p39 slndx < if 0 p39 c!
          p40 slndx < if 0 p40 c!   p41 slndx < if 0 p41 c!   p42 slndx < if 0 p42 c!
          p43 slndx < if 0 p43 c!   p44 slndx < if 0 p44 c!   p45 slndx < if 0 p45 c!
          p46 slndx < if 0 p46 c!   p47 slndx < if 0 p47 c!   then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
       then
   loop
;

: SoZP11 ( N - )
  \ all prime candidates > 11 are of form 2310*x+(1,13,17,19,23,29,31,37,41
  \ 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
  \ 127, 131, 137, 139, 149, 151, 157, 163, 167, 169, 173, 179, 181, 191, 193,
  \ 197, 199, 211, 221, 223, 227, 229, 233, 239, 241, 247, 251, 257, 263, 269,
  \ 271, 277, 281, 283, 289, 293, 299, 307, 311, 313, 317, 323, 331, 337, 347,
  \ 349, 353, 359, 361, 367, 373, 377, 379, 383, 389, 391, 397, 401, 403, 409,
  \ 419, 421, 431, 433, 437, 439, 443, 449, 457, 461, 463, 467, 479, 481, 487,
  \ 491, 493, 499, 503, 509, 521, 523, 527, 529, 533, 541, 547, 551, 557, 559,
  \ 563, 569, 571, 577, 587, 589, 593, 599, 601, 607, 611, 613, 617, 619, 629,
  \ 631, 641, 643, 647, 653, 659, 661, 667, 673, 677, 683, 689, 691, 697, 701,
  \ 703, 709, 713, 719, 727, 731, 733, 739, 743, 751, 757, 761, 767, 769, 773,
  \ 779, 787, 793, 797, 799, 809, 811, 817, 821, 823, 827, 829, 839, 841, 851,
  \ 853, 857, 859, 863, 871, 877, 881, 883, 887, 893, 899, 901, 907, 911, 919,
  \ 923, 929, 937, 941, 943, 947, 949, 953, 961, 967, 971, 977, 983, 989, 991,
  \ 997, 1003, 1007, 1009, 1013, 1019, 1021, 1027, 1031, 1033, 1037, 1039, 1049,
  \ 1051,1061, 1063, 1069, 1073, 1079, 1081, 1087, 1091, 1093, 1097, 1103, 1109,
  \ 1117,1121, 1123, 1129, 1139, 1147, 1151, 1153, 1157, 1159, 1163, 1171, 1181,
  \ 1187,1189, 1193, 1201, 1207, 1213, 1217, 1219, 1223, 1229, 1231, 1237, 1241,
  \ 1247,1249, 1259, 1261, 1271, 1273, 1277, 1279, 1283, 1289, 1291, 1297, 1301,
  \ 1303,1307, 1313, 1319, 1321, 1327, 1333, 1339, 1343, 1349, 1357, 1361, 1363,
  \ 1367,1369, 1373, 1381, 1387, 1391, 1399, 1403, 1409, 1411, 1417, 1423, 1427,
  \ 1429,1433, 1439, 1447, 1451, 1453, 1457, 1459, 1469, 1471, 1481, 1483, 1487,
  \ 1489,1493, 1499, 1501, 1511, 1513, 1517, 1523, 1531, 1537, 1541, 1543, 1549,
  \ 1553,1559, 1567, 1571, 1577, 1579, 1583, 1591, 1597, 1601, 1607, 1609, 1613,
  \ 1619,1621, 1627, 1633, 1637, 1643, 1649, 1651, 1657, 1663, 1667, 1669, 1679,
  \ 1681,1691, 1693, 1697, 1699, 1703, 1709, 1711, 1717, 1721, 1723, 1733, 1739,
  \ 1741,1747, 1751, 1753, 1759, 1763, 1769, 1777, 1781, 1783, 1787, 1789, 1801,
  \ 1807,1811, 1817, 1819, 1823, 1829, 1831, 1843, 1847, 1849, 1853, 1861, 1867,
  \ 1871,1873, 1877, 1879, 1889, 1891, 1901, 1907, 1909, 1913, 1919, 1921, 1927,
  \ 1931,1933, 1937, 1943, 1949, 1951, 1957, 1961, 1963, 1973, 1979, 1987, 1993,
  \ 1997,1999, 2003, 2011, 2017, 2021, 2027, 2029, 2033, 2039, 2041, 2047, 2053,
  \ 2059,2063, 2069, 2071, 2077, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2117,
  \ 2119,2129, 2131, 2137, 2141, 2143, 2147, 2153, 2159, 2161, 2171, 2173, 2179,
  \ 2183,2197, 2201, 2203, 2207, 2209, 2213, 2221, 2227, 2231, 2237, 2239, 2243,
  \ 2249,2251,2257,2263,2267,2269,2273,2279, 2281, 2287, 2291, 2293, 2297, 2309)
  \ initialize sieve array with only these candidate values
  \ where byte array indices for sieve are odd integers representations
  \ convert integers to array indices/vals by i = (n-3)>>1

   to num
   -1   sieve to p1     5   sieve to p2     7   sieve to p3     8   sieve to p4
   10   sieve to p5    13   sieve to p6    14   sieve to p7    17   sieve to p8
   19   sieve to p9    20   sieve to p10   22   sieve to p11   25   sieve to p12
   28   sieve to p13   29   sieve to p14   32   sieve to p15   34   sieve to p16
   35   sieve to p17   38   sieve to p18   40   sieve to p19   43   sieve to p20
   47   sieve to p21   49   sieve to p22   50   sieve to p23   52   sieve to p24
   53   sieve to p25   55   sieve to p26   62   sieve to p27   64   sieve to p28
   67   sieve to p29   68   sieve to p30   73   sieve to p31   74   sieve to p32
   77   sieve to p33   80   sieve to p34   82   sieve to p35   83   sieve to p36
   85   sieve to p37   88   sieve to p38   89   sieve to p39   94   sieve to p40
   95   sieve to p41   97   sieve to p42   98   sieve to p43   104  sieve to p44
   109  sieve to p45   110  sieve to p46   112  sieve to p47   113  sieve to p48
   115  sieve to p49   118  sieve to p50   119  sieve to p51   122  sieve to p52
   124  sieve to p53   127  sieve to p54   130  sieve to p55   133  sieve to p56
   134  sieve to p57   137  sieve to p58   139  sieve to p59   140  sieve to p60
   143  sieve to p61   145  sieve to p62   148  sieve to p63   152  sieve to p64
   154  sieve to p65   155  sieve to p66   157  sieve to p67   160  sieve to p68
   164  sieve to p69   167  sieve to p70   172  sieve to p71   173  sieve to p72
   175  sieve to p73   178  sieve to p74   179  sieve to p75   182  sieve to p76
   185  sieve to p77   187  sieve to p78   188  sieve to p79   190  sieve to p80
   193  sieve to p81   194  sieve to p82   197  sieve to p83   199  sieve to p84
   200  sieve to p85   203  sieve to p86   208  sieve to p87   209  sieve to p88
   214  sieve to p89   215  sieve to p90   217  sieve to p91   218  sieve to p92
   220  sieve to p93   223  sieve to p94   227  sieve to p95   229  sieve to p96
   230  sieve to p97   232  sieve to p98   238  sieve to p99   239  sieve to p100
   242  sieve to p101  244  sieve to p102  245  sieve to p103  248  sieve to p104
   250  sieve to p105  253  sieve to p106  259  sieve to p107  260  sieve to p108
   262  sieve to p109  263  sieve to p110  265  sieve to p111  269  sieve to p112
   272  sieve to p113  274  sieve to p114  277  sieve to p115  278  sieve to p116
   280  sieve to p117  283  sieve to p118  284  sieve to p119  287  sieve to p120
   292  sieve to p121  293  sieve to p122  295  sieve to p123  298  sieve to p124
   299  sieve to p125  302  sieve to p126  304  sieve to p127  305  sieve to p128
   307  sieve to p129  308  sieve to p130  313  sieve to p131  314  sieve to p132
   319  sieve to p133  320  sieve to p134  322  sieve to p135  325  sieve to p136
   328  sieve to p137  329  sieve to p138  332  sieve to p139  335  sieve to p140
   337  sieve to p141  340  sieve to p142  343  sieve to p143  344  sieve to p144
   347  sieve to p145  349  sieve to p146  350  sieve to p147  353  sieve to p148
   355  sieve to p149  358  sieve to p150  362  sieve to p151  364  sieve to p152
   365  sieve to p153  368  sieve to p154  370  sieve to p155  374  sieve to p156
   377  sieve to p157  379  sieve to p158  382  sieve to p159  383  sieve to p160
   385  sieve to p161  388  sieve to p162  392  sieve to p163  395  sieve to p164
   397  sieve to p165  398  sieve to p166  403  sieve to p167  404  sieve to p168
   407  sieve to p169  409  sieve to p170  410  sieve to p171  412  sieve to p172
   413  sieve to p173  418  sieve to p174  419  sieve to p175  424  sieve to p176
   425  sieve to p177  427  sieve to p178  428  sieve to p179  430  sieve to p180
   434  sieve to p181  437  sieve to p182  439  sieve to p183  440  sieve to p184
   442  sieve to p185  445  sieve to p186  448  sieve to p187  449  sieve to p188
   452  sieve to p189  454  sieve to p190  458  sieve to p191  460  sieve to p192
   463  sieve to p193  467  sieve to p194  469  sieve to p195  470  sieve to p196
   472  sieve to p197  473  sieve to p198  475  sieve to p199  479  sieve to p200
   482  sieve to p201  484  sieve to p202  487  sieve to p203  490  sieve to p204
   493  sieve to p205  494  sieve to p206  497  sieve to p207  500  sieve to p208
   502  sieve to p209  503  sieve to p210  505  sieve to p211  508  sieve to p212
   509  sieve to p213  512  sieve to p214  514  sieve to p215  515  sieve to p216
   517  sieve to p217  518  sieve to p218  523  sieve to p219  524  sieve to p220
   529  sieve to p221  530  sieve to p222  533  sieve to p223  535  sieve to p224
   538  sieve to p225  539  sieve to p226  542  sieve to p227  544  sieve to p228
   545  sieve to p229  547  sieve to p230  550  sieve to p231  553  sieve to p232
   557  sieve to p233  559  sieve to p234  560  sieve to p235  563  sieve to p236
   568  sieve to p237  572  sieve to p238  574  sieve to p239  575  sieve to p240
   577  sieve to p241  578  sieve to p242  580  sieve to p243  584  sieve to p244
   589  sieve to p245  592  sieve to p246  593  sieve to p247  595  sieve to p248
   599  sieve to p249  602  sieve to p250  605  sieve to p251  607  sieve to p252
   608  sieve to p253  610  sieve to p254  613  sieve to p255  614  sieve to p256
   617  sieve to p257  619  sieve to p258  622  sieve to p259  623  sieve to p260
   628  sieve to p261  629  sieve to p262  634  sieve to p263  635  sieve to p264
   637  sieve to p265  638  sieve to p266  640  sieve to p267  643  sieve to p268
   644  sieve to p269  647  sieve to p270  649  sieve to p271  650  sieve to p272
   652  sieve to p273  655  sieve to p274  658  sieve to p275  659  sieve to p276
   662  sieve to p277  665  sieve to p278  668  sieve to p279  670  sieve to p280
   673  sieve to p281  677  sieve to p282  679  sieve to p283  680  sieve to p284
   682  sieve to p285  683  sieve to p286  685  sieve to p287  689  sieve to p288
   692  sieve to p289  694  sieve to p290  698  sieve to p291  700  sieve to p292
   703  sieve to p293  704  sieve to p294  707  sieve to p295  710  sieve to p296
   712  sieve to p297  713  sieve to p298  715  sieve to p299  718  sieve to p300
   722  sieve to p301  724  sieve to p302  725  sieve to p303  727  sieve to p304
   728  sieve to p305  733  sieve to p306  734  sieve to p307  739  sieve to p308
   740  sieve to p309  742  sieve to p310  743  sieve to p311  745  sieve to p312
   748  sieve to p313  749  sieve to p314  754  sieve to p315  755  sieve to p316
   757  sieve to p317  760  sieve to p318  764  sieve to p319  767  sieve to p320
   769  sieve to p321  770  sieve to p322  773  sieve to p323  775  sieve to p324
   778  sieve to p325  782  sieve to p326  784  sieve to p327  787  sieve to p328
   788  sieve to p329  790  sieve to p330  794  sieve to p331  797  sieve to p332
   799  sieve to p333  802  sieve to p334  803  sieve to p335  805  sieve to p336
   808  sieve to p337  809  sieve to p338  812  sieve to p339  815  sieve to p340
   817  sieve to p341  820  sieve to p342  823  sieve to p343  824  sieve to p344
   827  sieve to p345  830  sieve to p346  832  sieve to p347  833  sieve to p348
   838  sieve to p349  839  sieve to p350  844  sieve to p351  845  sieve to p352
   847  sieve to p353  848  sieve to p354  850  sieve to p355  853  sieve to p356
   854  sieve to p357  857  sieve to p358  859  sieve to p359  860  sieve to p360
   865  sieve to p361  868  sieve to p362  869  sieve to p363  872  sieve to p364
   874  sieve to p365  875  sieve to p366  878  sieve to p367  880  sieve to p368
   883  sieve to p369  887  sieve to p370  889  sieve to p371  890  sieve to p372
   892  sieve to p373  893  sieve to p374  899  sieve to p375  902  sieve to p376
   904  sieve to p377  907  sieve to p378  908  sieve to p379  910  sieve to p380
   913  sieve to p381  914  sieve to p382  920  sieve to p383  922  sieve to p384
   923  sieve to p385  925  sieve to p386  929  sieve to p387  932  sieve to p388
   934  sieve to p389  935  sieve to p390  937  sieve to p391  938  sieve to p392
   943  sieve to p393  944  sieve to p394  949  sieve to p395  952  sieve to p396
   953  sieve to p397  955  sieve to p398  958  sieve to p399  959  sieve to p400
   962  sieve to p401  964  sieve to p402  965  sieve to p403  967  sieve to p404
   970  sieve to p405  973  sieve to p406  974  sieve to p407  977  sieve to p408
   979  sieve to p409  980  sieve to p410  985  sieve to p411  988  sieve to p412
   992  sieve to p413  995  sieve to p414  997  sieve to p415  998  sieve to p416
   1000 sieve to p417  1004 sieve to p418  1007 sieve to p419  1009 sieve to p420
   1012 sieve to p421  1013 sieve to p422  1015 sieve to p423  1018 sieve to p424
   1019 sieve to p425  1022 sieve to p426  1025 sieve to p427  1028 sieve to p428
   1030 sieve to p429  1033 sieve to p430  1034 sieve to p431  1037 sieve to p432
   1039 sieve to p433  1040 sieve to p434  1042 sieve to p435  1043 sieve to p436
   1048 sieve to p437  1054 sieve to p438  1055 sieve to p439  1057 sieve to p440
   1058 sieve to p441  1063 sieve to p442  1064 sieve to p443  1067 sieve to p444
   1069 sieve to p445  1070 sieve to p446  1072 sieve to p447  1075 sieve to p448
   1078 sieve to p449  1079 sieve to p450  1084 sieve to p451  1085 sieve to p452
   1088 sieve to p453  1090 sieve to p454  1097 sieve to p455  1099 sieve to p456
   1100 sieve to p457  1102 sieve to p458  1103 sieve to p459  1105 sieve to p460
   1109 sieve to p461  1112 sieve to p462  1114 sieve to p463  1117 sieve to p464
   1118 sieve to p465  1120 sieve to p466  1123 sieve to p467  1124 sieve to p468
   1127 sieve to p469  1130 sieve to p470  1132 sieve to p471  1133 sieve to p472
   1135 sieve to p473  1138 sieve to p474  1139 sieve to p475  1142 sieve to p476
   1144 sieve to p477  1145 sieve to p478  1147 sieve to p479  1153 sieve to p480
   begin p480 slndx < while
      1155 p1   + to p1    1155 p2   + to p2    1155 p3   + to p3    1155 p4   + to p4
      1155 p5   + to p5    1155 p6   + to p6    1155 p7   + to p7    1155 p8   + to p8
      1155 p9   + to p9    1155 p10  + to p10   1155 p11  + to p11   1155 p12  + to p12
      1155 p13  + to p13   1155 p14  + to p14   1155 p15  + to p15   1155 p16  + to p16
      1155 p17  + to p17   1155 p18  + to p18   1155 p19  + to p19   1155 p20  + to p20
      1155 p21  + to p21   1155 p22  + to p22   1155 p23  + to p23   1155 p24  + to p24
      1155 p25  + to p25   1155 p26  + to p26   1155 p27  + to p27   1155 p28  + to p28
      1155 p29  + to p29   1155 p30  + to p30   1155 p31  + to p31   1155 p32  + to p32
      1155 p33  + to p33   1155 p34  + to p34   1155 p35  + to p35   1155 p36  + to p36
      1155 p37  + to p37   1155 p38  + to p38   1155 p39  + to p39   1155 p40  + to p40
      1155 p41  + to p41   1155 p42  + to p42   1155 p43  + to p43   1155 p44  + to p44
      1155 p45  + to p45   1155 p46  + to p46   1155 p47  + to p47   1155 p48  + to p48
      1155 p49  + to p49   1155 p50  + to p50   1155 p51  + to p51   1155 p52  + to p52
      1155 p53  + to p53   1155 p54  + to p54   1155 p55  + to p55   1155 p56  + to p56
      1155 p57  + to p57   1155 p58  + to p58   1155 p59  + to p59   1155 p60  + to p60
      1155 p61  + to p61   1155 p62  + to p62   1155 p63  + to p63   1155 p64  + to p64
      1155 p65  + to p65   1155 p66  + to p66   1155 p67  + to p67   1155 p68  + to p68
      1155 p69  + to p69   1155 p70  + to p70   1155 p71  + to p71   1155 p72  + to p72
      1155 p73  + to p73   1155 p74  + to p74   1155 p75  + to p75   1155 p76  + to p76
      1155 p77  + to p77   1155 p78  + to p78   1155 p79  + to p79   1155 p80  + to p80
      1155 p81  + to p81   1155 p82  + to p82   1155 p83  + to p83   1155 p84  + to p84
      1155 p85  + to p85   1155 p86  + to p86   1155 p87  + to p87   1155 p88  + to p88
      1155 p89  + to p89   1155 p90  + to p90   1155 p91  + to p91   1155 p92  + to p92
      1155 p93  + to p93   1155 p94  + to p94   1155 p95  + to p95   1155 p96  + to p96
      1155 p97  + to p97   1155 p98  + to p98   1155 p99  + to p99   1155 p100 + to p100
      1155 p101 + to p101  1155 p102 + to p102  1155 p103 + to p103  1155 p104 + to p104
      1155 p105 + to p105  1155 p106 + to p106  1155 p107 + to p107  1155 p108 + to p108
      1155 p109 + to p109  1155 p110 + to p110  1155 p111 + to p111  1155 p112 + to p112
      1155 p113 + to p113  1155 p114 + to p114  1155 p115 + to p115  1155 p116 + to p116
      1155 p117 + to p117  1155 p118 + to p118  1155 p119 + to p119  1155 p120 + to p120
      1155 p121 + to p121  1155 p122 + to p122  1155 p123 + to p123  1155 p124 + to p124
      1155 p125 + to p125  1155 p126 + to p126  1155 p127 + to p127  1155 p128 + to p128
      1155 p129 + to p129  1155 p130 + to p130  1155 p131 + to p131  1155 p132 + to p132
      1155 p133 + to p133  1155 p134 + to p134  1155 p135 + to p135  1155 p136 + to p136
      1155 p137 + to p137  1155 p138 + to p138  1155 p139 + to p139  1155 p140 + to p140
      1155 p141 + to p141  1155 p142 + to p142  1155 p143 + to p143  1155 p144 + to p144
      1155 p145 + to p145  1155 p146 + to p146  1155 p147 + to p147  1155 p148 + to p148
      1155 p149 + to p149  1155 p150 + to p150  1155 p151 + to p151  1155 p152 + to p152
      1155 p153 + to p153  1155 p154 + to p154  1155 p155 + to p155  1155 p156 + to p156
      1155 p157 + to p157  1155 p158 + to p158  1155 p159 + to p159  1155 p160 + to p160
      1155 p161 + to p161  1155 p162 + to p162  1155 p163 + to p163  1155 p164 + to p164
      1155 p165 + to p165  1155 p166 + to p166  1155 p167 + to p167  1155 p168 + to p168
      1155 p169 + to p169  1155 p170 + to p170  1155 p171 + to p171  1155 p172 + to p172
      1155 p173 + to p173  1155 p174 + to p174  1155 p175 + to p175  1155 p176 + to p176
      1155 p177 + to p177  1155 p178 + to p178  1155 p179 + to p179  1155 p180 + to p180
      1155 p181 + to p181  1155 p182 + to p182  1155 p183 + to p183  1155 p184 + to p184
      1155 p185 + to p185  1155 p186 + to p186  1155 p187 + to p187  1155 p188 + to p188
      1155 p189 + to p189  1155 p190 + to p190  1155 p191 + to p191  1155 p192 + to p192
      1155 p193 + to p193  1155 p194 + to p194  1155 p195 + to p195  1155 p196 + to p196
      1155 p197 + to p197  1155 p198 + to p198  1155 p199 + to p199  1155 p200 + to p200
      1155 p201 + to p201  1155 p202 + to p202  1155 p203 + to p203  1155 p204 + to p204
      1155 p205 + to p205  1155 p206 + to p206  1155 p207 + to p207  1155 p208 + to p208
      1155 p209 + to p209  1155 p210 + to p210  1155 p211 + to p211  1155 p212 + to p212
      1155 p213 + to p213  1155 p214 + to p214  1155 p215 + to p215  1155 p216 + to p216
      1155 p217 + to p217  1155 p218 + to p218  1155 p219 + to p219  1155 p220 + to p220
      1155 p221 + to p221  1155 p222 + to p222  1155 p223 + to p223  1155 p224 + to p224
      1155 p225 + to p225  1155 p226 + to p226  1155 p227 + to p227  1155 p228 + to p228
      1155 p229 + to p229  1155 p230 + to p230  1155 p231 + to p231  1155 p232 + to p232
      1155 p233 + to p233  1155 p234 + to p234  1155 p235 + to p235  1155 p236 + to p236
      1155 p237 + to p237  1155 p238 + to p238  1155 p239 + to p239  1155 p240 + to p240
      1155 p241 + to p241  1155 p242 + to p242  1155 p243 + to p243  1155 p244 + to p244
      1155 p245 + to p245  1155 p246 + to p246  1155 p247 + to p247  1155 p248 + to p248
      1155 p249 + to p249  1155 p250 + to p250  1155 p251 + to p251  1155 p252 + to p252
      1155 p253 + to p253  1155 p254 + to p254  1155 p255 + to p255  1155 p256 + to p256
      1155 p257 + to p257  1155 p258 + to p258  1155 p259 + to p259  1155 p260 + to p260
      1155 p261 + to p261  1155 p262 + to p262  1155 p263 + to p263  1155 p264 + to p264
      1155 p265 + to p265  1155 p266 + to p266  1155 p267 + to p267  1155 p268 + to p268
      1155 p269 + to p269  1155 p270 + to p270  1155 p271 + to p271  1155 p272 + to p272
      1155 p273 + to p273  1155 p274 + to p274  1155 p275 + to p275  1155 p276 + to p276
      1155 p277 + to p277  1155 p278 + to p278  1155 p279 + to p279  1155 p280 + to p280
      1155 p281 + to p281  1155 p282 + to p282  1155 p283 + to p283  1155 p284 + to p284
      1155 p285 + to p285  1155 p286 + to p286  1155 p287 + to p287  1155 p288 + to p288
      1155 p289 + to p289  1155 p290 + to p290  1155 p291 + to p291  1155 p292 + to p292
      1155 p293 + to p293  1155 p294 + to p294  1155 p295 + to p295  1155 p296 + to p296
      1155 p297 + to p297  1155 p298 + to p298  1155 p299 + to p299  1155 p300 + to p300
      1155 p301 + to p301  1155 p302 + to p302  1155 p303 + to p303  1155 p304 + to p304
      1155 p305 + to p305  1155 p306 + to p306  1155 p307 + to p307  1155 p308 + to p308
      1155 p309 + to p309  1155 p310 + to p310  1155 p311 + to p311  1155 p312 + to p312
      1155 p313 + to p313  1155 p314 + to p314  1155 p315 + to p315  1155 p316 + to p316
      1155 p317 + to p317  1155 p318 + to p318  1155 p319 + to p319  1155 p320 + to p320
      1155 p321 + to p321  1155 p322 + to p322  1155 p323 + to p323  1155 p324 + to p324
      1155 p325 + to p325  1155 p326 + to p326  1155 p327 + to p327  1155 p328 + to p328
      1155 p329 + to p329  1155 p330 + to p330  1155 p331 + to p331  1155 p332 + to p332
      1155 p333 + to p333  1155 p334 + to p334  1155 p335 + to p335  1155 p336 + to p336
      1155 p337 + to p337  1155 p338 + to p338  1155 p339 + to p339  1155 p340 + to p340
      1155 p341 + to p341  1155 p342 + to p342  1155 p343 + to p343  1155 p344 + to p344
      1155 p345 + to p345  1155 p346 + to p346  1155 p347 + to p347  1155 p348 + to p348
      1155 p349 + to p349  1155 p350 + to p350  1155 p351 + to p351  1155 p352 + to p352
      1155 p353 + to p353  1155 p354 + to p354  1155 p355 + to p355  1155 p356 + to p356
      1155 p357 + to p357  1155 p358 + to p358  1155 p359 + to p359  1155 p360 + to p360
      1155 p361 + to p361  1155 p362 + to p362  1155 p363 + to p363  1155 p364 + to p364
      1155 p365 + to p365  1155 p366 + to p366  1155 p367 + to p367  1155 p368 + to p368
      1155 p369 + to p369  1155 p370 + to p370  1155 p371 + to p371  1155 p372 + to p372
      1155 p373 + to p373  1155 p374 + to p374  1155 p375 + to p375  1155 p376 + to p376
      1155 p377 + to p377  1155 p378 + to p378  1155 p379 + to p379  1155 p380 + to p380
      1155 p381 + to p381  1155 p382 + to p382  1155 p383 + to p383  1155 p384 + to p384
      1155 p385 + to p385  1155 p386 + to p386  1155 p387 + to p387  1155 p388 + to p388
      1155 p389 + to p389  1155 p390 + to p390  1155 p391 + to p391  1155 p392 + to p392
      1155 p393 + to p393  1155 p394 + to p394  1155 p395 + to p395  1155 p396 + to p396
      1155 p397 + to p397  1155 p398 + to p398  1155 p399 + to p399  1155 p400 + to p400
      1155 p401 + to p401  1155 p402 + to p402  1155 p403 + to p403  1155 p404 + to p404
      1155 p405 + to p405  1155 p406 + to p406  1155 p407 + to p407  1155 p408 + to p408
      1155 p409 + to p409  1155 p410 + to p410  1155 p411 + to p411  1155 p412 + to p412
      1155 p413 + to p413  1155 p414 + to p414  1155 p415 + to p415  1155 p416 + to p416
      1155 p417 + to p417  1155 p418 + to p418  1155 p419 + to p419  1155 p420 + to p420
      1155 p421 + to p421  1155 p422 + to p422  1155 p423 + to p423  1155 p424 + to p424
      1155 p425 + to p425  1155 p426 + to p426  1155 p427 + to p427  1155 p428 + to p428
      1155 p429 + to p429  1155 p430 + to p430  1155 p431 + to p431  1155 p432 + to p432
      1155 p433 + to p433  1155 p434 + to p434  1155 p435 + to p435  1155 p436 + to p436
      1155 p437 + to p437  1155 p438 + to p438  1155 p439 + to p439  1155 p440 + to p440
      1155 p441 + to p441  1155 p442 + to p442  1155 p443 + to p443  1155 p444 + to p444
      1155 p445 + to p445  1155 p446 + to p446  1155 p447 + to p447  1155 p448 + to p448
      1155 p449 + to p449  1155 p450 + to p450  1155 p451 + to p451  1155 p452 + to p452
      1155 p453 + to p453  1155 p454 + to p454  1155 p455 + to p455  1155 p456 + to p456
      1155 p457 + to p457  1155 p458 + to p458  1155 p459 + to p459  1155 p460 + to p460
      1155 p461 + to p461  1155 p462 + to p462  1155 p463 + to p463  1155 p464 + to p464
      1155 p465 + to p465  1155 p466 + to p466  1155 p467 + to p467  1155 p468 + to p468
      1155 p469 + to p469  1155 p470 + to p470  1155 p471 + to p471  1155 p472 + to p472
      1155 p473 + to p473  1155 p474 + to p474  1155 p475 + to p475  1155 p476 + to p476
      1155 p477 + to p477  1155 p478 + to p478  1155 p479 + to p479  1155 p480 + to p480
      1 p1   c! 1 p2   c! 1 p3   c! 1 p4   c! 1 p5   c! 1 p6   c! 1 p7   c! 1 p8   c!
      1 p9   c! 1 p10  c! 1 p11  c! 1 p12  c! 1 p13  c! 1 p14  c! 1 p15  c! 1 p16  c!
      1 p17  c! 1 p18  c! 1 p19  c! 1 p20  c! 1 p21  c! 1 p22  c! 1 p23  c! 1 p24  c!
      1 p25  c! 1 p26  c! 1 p27  c! 1 p28  c! 1 p29  c! 1 p30  c! 1 p31  c! 1 p32  c!
      1 p33  c! 1 p34  c! 1 p35  c! 1 p36  c! 1 p37  c! 1 p38  c! 1 p39  c! 1 p40  c!
      1 p41  c! 1 p42  c! 1 p43  c! 1 p44  c! 1 p45  c! 1 p46  c! 1 p47  c! 1 p48  c!
      1 p49  c! 1 p50  c! 1 p51  c! 1 p52  c! 1 p53  c! 1 p54  c! 1 p55  c! 1 p56  c!
      1 p57  c! 1 p58  c! 1 p59  c! 1 p60  c! 1 p61  c! 1 p62  c! 1 p63  c! 1 p64  c!
      1 p65  c! 1 p66  c! 1 p67  c! 1 p68  c! 1 p69  c! 1 p70  c! 1 p71  c! 1 p72  c!
      1 p73  c! 1 p74  c! 1 p75  c! 1 p76  c! 1 p77  c! 1 p78  c! 1 p79  c! 1 p80  c!
      1 p81  c! 1 p82  c! 1 p83  c! 1 p84  c! 1 p85  c! 1 p86  c! 1 p87  c! 1 p88  c!
      1 p89  c! 1 p90  c! 1 p91  c! 1 p92  c! 1 p93  c! 1 p94  c! 1 p95  c! 1 p96  c!
      1 p97  c! 1 p98  c! 1 p99  c! 1 p100 c! 1 p101 c! 1 p102 c! 1 p103 c! 1 p104 c!
      1 p105 c! 1 p106 c! 1 p107 c! 1 p108 c! 1 p109 c! 1 p110 c! 1 p111 c! 1 p112 c!
      1 p113 c! 1 p114 c! 1 p115 c! 1 p116 c! 1 p117 c! 1 p118 c! 1 p119 c! 1 p120 c!
      1 p121 c! 1 p122 c! 1 p123 c! 1 p124 c! 1 p125 c! 1 p126 c! 1 p127 c! 1 p128 c!
      1 p129 c! 1 p130 c! 1 p131 c! 1 p132 c! 1 p133 c! 1 p134 c! 1 p135 c! 1 p136 c!
      1 p137 c! 1 p138 c! 1 p139 c! 1 p140 c! 1 p141 c! 1 p142 c! 1 p143 c! 1 p144 c!
      1 p145 c! 1 p146 c! 1 p147 c! 1 p148 c! 1 p149 c! 1 p150 c! 1 p151 c! 1 p152 c!
      1 p153 c! 1 p154 c! 1 p155 c! 1 p156 c! 1 p157 c! 1 p158 c! 1 p159 c! 1 p160 c!
      1 p161 c! 1 p162 c! 1 p163 c! 1 p164 c! 1 p165 c! 1 p166 c! 1 p167 c! 1 p168 c!
      1 p169 c! 1 p170 c! 1 p171 c! 1 p172 c! 1 p173 c! 1 p174 c! 1 p175 c! 1 p176 c!
      1 p177 c! 1 p178 c! 1 p179 c! 1 p180 c! 1 p181 c! 1 p182 c! 1 p183 c! 1 p184 c!
      1 p185 c! 1 p186 c! 1 p187 c! 1 p188 c! 1 p189 c! 1 p190 c! 1 p191 c! 1 p192 c!
      1 p193 c! 1 p194 c! 1 p195 c! 1 p196 c! 1 p197 c! 1 p198 c! 1 p199 c! 1 p200 c!
      1 p201 c! 1 p202 c! 1 p203 c! 1 p204 c! 1 p205 c! 1 p206 c! 1 p207 c! 1 p208 c!
      1 p209 c! 1 p210 c! 1 p211 c! 1 p212 c! 1 p213 c! 1 p214 c! 1 p215 c! 1 p216 c!
      1 p217 c! 1 p218 c! 1 p219 c! 1 p220 c! 1 p221 c! 1 p222 c! 1 p223 c! 1 p224 c!
      1 p225 c! 1 p226 c! 1 p227 c! 1 p228 c! 1 p229 c! 1 p230 c! 1 p231 c! 1 p232 c!
      1 p233 c! 1 p234 c! 1 p235 c! 1 p236 c! 1 p237 c! 1 p238 c! 1 p239 c! 1 p240 c!
      1 p241 c! 1 p242 c! 1 p243 c! 1 p244 c! 1 p245 c! 1 p246 c! 1 p247 c! 1 p248 c!
      1 p249 c! 1 p250 c! 1 p251 c! 1 p252 c! 1 p253 c! 1 p254 c! 1 p255 c! 1 p256 c!
      1 p257 c! 1 p258 c! 1 p259 c! 1 p260 c! 1 p261 c! 1 p262 c! 1 p263 c! 1 p264 c!
      1 p265 c! 1 p266 c! 1 p267 c! 1 p268 c! 1 p269 c! 1 p270 c! 1 p271 c! 1 p272 c!
      1 p273 c! 1 p274 c! 1 p275 c! 1 p276 c! 1 p277 c! 1 p278 c! 1 p279 c! 1 p280 c!
      1 p281 c! 1 p282 c! 1 p283 c! 1 p284 c! 1 p285 c! 1 p286 c! 1 p287 c! 1 p288 c!
      1 p289 c! 1 p290 c! 1 p291 c! 1 p292 c! 1 p293 c! 1 p294 c! 1 p295 c! 1 p296 c!
      1 p297 c! 1 p298 c! 1 p299 c! 1 p300 c! 1 p301 c! 1 p302 c! 1 p303 c! 1 p304 c!
      1 p305 c! 1 p306 c! 1 p307 c! 1 p308 c! 1 p309 c! 1 p310 c! 1 p311 c! 1 p312 c!
      1 p313 c! 1 p314 c! 1 p315 c! 1 p316 c! 1 p317 c! 1 p318 c! 1 p319 c! 1 p320 c!
      1 p321 c! 1 p322 c! 1 p323 c! 1 p324 c! 1 p325 c! 1 p326 c! 1 p327 c! 1 p328 c!
      1 p329 c! 1 p330 c! 1 p331 c! 1 p332 c! 1 p333 c! 1 p334 c! 1 p335 c! 1 p336 c!
      1 p337 c! 1 p338 c! 1 p339 c! 1 p340 c! 1 p341 c! 1 p342 c! 1 p343 c! 1 p344 c!
      1 p345 c! 1 p346 c! 1 p347 c! 1 p348 c! 1 p349 c! 1 p350 c! 1 p351 c! 1 p352 c!
      1 p353 c! 1 p354 c! 1 p355 c! 1 p356 c! 1 p357 c! 1 p358 c! 1 p359 c! 1 p360 c!
      1 p361 c! 1 p362 c! 1 p363 c! 1 p364 c! 1 p365 c! 1 p366 c! 1 p367 c! 1 p368 c!
      1 p369 c! 1 p370 c! 1 p371 c! 1 p372 c! 1 p373 c! 1 p374 c! 1 p375 c! 1 p376 c!
      1 p377 c! 1 p378 c! 1 p379 c! 1 p380 c! 1 p381 c! 1 p382 c! 1 p383 c! 1 p384 c!
      1 p385 c! 1 p386 c! 1 p387 c! 1 p388 c! 1 p389 c! 1 p390 c! 1 p391 c! 1 p392 c!
      1 p393 c! 1 p394 c! 1 p395 c! 1 p396 c! 1 p397 c! 1 p398 c! 1 p399 c! 1 p400 c!
      1 p401 c! 1 p402 c! 1 p403 c! 1 p404 c! 1 p405 c! 1 p406 c! 1 p407 c! 1 p408 c!
      1 p409 c! 1 p410 c! 1 p411 c! 1 p412 c! 1 p413 c! 1 p414 c! 1 p415 c! 1 p416 c!
      1 p417 c! 1 p418 c! 1 p419 c! 1 p420 c! 1 p421 c! 1 p422 c! 1 p423 c! 1 p424 c!
      1 p425 c! 1 p426 c! 1 p427 c! 1 p428 c! 1 p429 c! 1 p430 c! 1 p431 c! 1 p432 c!
      1 p433 c! 1 p434 c! 1 p435 c! 1 p436 c! 1 p437 c! 1 p438 c! 1 p439 c! 1 p440 c!
      1 p441 c! 1 p442 c! 1 p443 c! 1 p444 c! 1 p445 c! 1 p446 c! 1 p447 c! 1 p448 c!
      1 p449 c! 1 p450 c! 1 p451 c! 1 p452 c! 1 p453 c! 1 p454 c! 1 p455 c! 1 p456 c!
      1 p457 c! 1 p458 c! 1 p459 c! 1 p460 c! 1 p461 c! 1 p462 c! 1 p463 c! 1 p464 c!
      1 p465 c! 1 p466 c! 1 p467 c! 1 p468 c! 1 p469 c! 1 p470 c! 1 p471 c! 1 p472 c!
      1 p473 c! 1 p474 c! 1 p475 c! 1 p476 c! 1 p477 c! 1 p478 c! 1 p479 c! 1 p480 c!
   repeat
   \ now initialize sieve array with (odd) primes < 2310
   1 0    sieve c!  1 1    sieve c!  1 2    sieve c!  1 4    sieve c!  1 5    sieve c!
   1 7    sieve c!  1 8    sieve c!  1 10   sieve c!  1 13   sieve c!  1 14   sieve c!
   1 17   sieve c!  1 19   sieve c!  1 20   sieve c!  1 22   sieve c!  1 25   sieve c!
   1 28   sieve c!  1 29   sieve c!  1 32   sieve c!  1 34   sieve c!  1 35   sieve c!
   1 38   sieve c!  1 40   sieve c!  1 43   sieve c!  1 47   sieve c!  1 49   sieve c!
   1 50   sieve c!  1 52   sieve c!  1 53   sieve c!  1 55   sieve c!  1 62   sieve c!
   1 64   sieve c!  1 67   sieve c!  1 68   sieve c!  1 73   sieve c!  1 74   sieve c!
   1 77   sieve c!  1 80   sieve c!  1 82   sieve c!  1 85   sieve c!  1 88   sieve c!
   1 89   sieve c!  1 94   sieve c!  1 95   sieve c!  1 97   sieve c!  1 98   sieve c!
   1 104  sieve c!  1 110  sieve c!  1 112  sieve c!  1 113  sieve c!  1 115  sieve c!
   1 118  sieve c!  1 119  sieve c!  1 124  sieve c!  1 127  sieve c!  1 130  sieve c!
   1 133  sieve c!  1 134  sieve c!  1 137  sieve c!  1 139  sieve c!  1 140  sieve c!
   1 145  sieve c!  1 152  sieve c!  1 154  sieve c!  1 155  sieve c!  1 157  sieve c!
   1 164  sieve c!  1 167  sieve c!  1 172  sieve c!  1 173  sieve c!  1 175  sieve c!
   1 178  sieve c!  1 182  sieve c!  1 185  sieve c!  1 188  sieve c!  1 190  sieve c!
   1 193  sieve c!  1 197  sieve c!  1 199  sieve c!  1 203  sieve c!  1 208  sieve c!
   1 209  sieve c!  1 214  sieve c!  1 215  sieve c!  1 218  sieve c!  1 220  sieve c!
   1 223  sieve c!  1 227  sieve c!  1 229  sieve c!  1 230  sieve c!  1 232  sieve c!
   1 238  sieve c!  1 242  sieve c!  1 244  sieve c!  1 248  sieve c!  1 250  sieve c!
   1 253  sieve c!  1 259  sieve c!  1 260  sieve c!  1 269  sieve c!  1 272  sieve c!
   1 277  sieve c!  1 280  sieve c!  1 283  sieve c!  1 284  sieve c!  1 287  sieve c!
   1 292  sieve c!  1 295  sieve c!  1 298  sieve c!  1 299  sieve c!  1 302  sieve c!
   1 305  sieve c!  1 307  sieve c!  1 308  sieve c!  1 314  sieve c!  1 319  sieve c!
   1 320  sieve c!  1 322  sieve c!  1 325  sieve c!  1 328  sieve c!  1 329  sieve c!
   1 335  sieve c!  1 337  sieve c!  1 340  sieve c!  1 344  sieve c!  1 349  sieve c!
   1 353  sieve c!  1 358  sieve c!  1 362  sieve c!  1 365  sieve c!  1 368  sieve c!
   1 370  sieve c!  1 374  sieve c!  1 377  sieve c!  1 379  sieve c!  1 383  sieve c!
   1 385  sieve c!  1 392  sieve c!  1 397  sieve c!  1 403  sieve c!  1 404  sieve c!
   1 409  sieve c!  1 410  sieve c!  1 412  sieve c!  1 413  sieve c!  1 418  sieve c!
   1 425  sieve c!  1 427  sieve c!  1 428  sieve c!  1 430  sieve c!  1 437  sieve c!
   1 439  sieve c!  1 440  sieve c!  1 442  sieve c!  1 452  sieve c!  1 454  sieve c!
   1 458  sieve c!  1 463  sieve c!  1 467  sieve c!  1 469  sieve c!  1 472  sieve c!
   1 475  sieve c!  1 482  sieve c!  1 484  sieve c!  1 487  sieve c!  1 490  sieve c!
   1 494  sieve c!  1 497  sieve c!  1 503  sieve c!  1 505  sieve c!  1 508  sieve c!
   1 509  sieve c!  1 514  sieve c!  1 515  sieve c!  1 518  sieve c!  1 523  sieve c!
   1 524  sieve c!  1 529  sieve c!  1 530  sieve c!  1 533  sieve c!  1 542  sieve c!
   1 544  sieve c!  1 545  sieve c!  1 547  sieve c!  1 550  sieve c!  1 553  sieve c!
   1 557  sieve c!  1 560  sieve c!  1 563  sieve c!  1 574  sieve c!  1 575  sieve c!
   1 580  sieve c!  1 584  sieve c!  1 589  sieve c!  1 592  sieve c!  1 595  sieve c!
   1 599  sieve c!  1 605  sieve c!  1 607  sieve c!  1 610  sieve c!  1 613  sieve c!
   1 614  sieve c!  1 617  sieve c!  1 623  sieve c!  1 628  sieve c!  1 637  sieve c!
   1 638  sieve c!  1 640  sieve c!  1 643  sieve c!  1 644  sieve c!  1 647  sieve c!
   1 649  sieve c!  1 650  sieve c!  1 652  sieve c!  1 658  sieve c!  1 659  sieve c!
   1 662  sieve c!  1 679  sieve c!  1 682  sieve c!  1 685  sieve c!  1 689  sieve c!
   1 698  sieve c!  1 703  sieve c!  1 710  sieve c!  1 712  sieve c!  1 713  sieve c!
   1 715  sieve c!  1 718  sieve c!  1 722  sieve c!  1 724  sieve c!  1 725  sieve c!
   1 728  sieve c!  1 734  sieve c!  1 739  sieve c!  1 740  sieve c!  1 742  sieve c!
   1 743  sieve c!  1 745  sieve c!  1 748  sieve c!  1 754  sieve c!  1 760  sieve c!
   1 764  sieve c!  1 770  sieve c!  1 773  sieve c!  1 775  sieve c!  1 778  sieve c!
   1 782  sieve c!  1 784  sieve c!  1 788  sieve c!  1 790  sieve c!  1 797  sieve c!
   1 799  sieve c!  1 802  sieve c!  1 803  sieve c!  1 805  sieve c!  1 808  sieve c!
   1 809  sieve c!  1 812  sieve c!  1 817  sieve c!  1 827  sieve c!  1 830  sieve c!
   1 832  sieve c!  1 833  sieve c!  1 845  sieve c!  1 847  sieve c!  1 848  sieve c!
   1 853  sieve c!  1 859  sieve c!  1 860  sieve c!  1 865  sieve c!  1 869  sieve c!
   1 872  sieve c!  1 875  sieve c!  1 878  sieve c!  1 887  sieve c!  1 890  sieve c!
   1 892  sieve c!  1 893  sieve c!  1 899  sieve c!  1 904  sieve c!  1 910  sieve c!
   1 914  sieve c!  1 922  sieve c!  1 929  sieve c!  1 932  sieve c!  1 934  sieve c!
   1 935  sieve c!  1 937  sieve c!  1 938  sieve c!  1 943  sieve c!  1 949  sieve c!
   1 952  sieve c!  1 955  sieve c!  1 964  sieve c!  1 965  sieve c!  1 973  sieve c!
   1 974  sieve c!  1 985  sieve c!  1 988  sieve c!  1 992  sieve c!  1 995  sieve c!
   1 997  sieve c!  1 998  sieve c!  1 1000 sieve c!  1 1004 sieve c!  1 1007 sieve c!
   1 1012 sieve c!  1 1013 sieve c!  1 1018 sieve c!  1 1025 sieve c!  1 1030 sieve c!
   1 1033 sieve c!  1 1039 sieve c!  1 1040 sieve c!  1 1042 sieve c!  1 1043 sieve c!
   1 1048 sieve c!  1 1054 sieve c!  1 1055 sieve c!  1 1063 sieve c!  1 1064 sieve c!
   1 1067 sieve c!  1 1069 sieve c!  1 1070 sieve c!  1 1075 sieve c!  1 1079 sieve c!
   1 1088 sieve c!  1 1100 sieve c!  1 1102 sieve c!  1 1105 sieve c!  1 1109 sieve c!
   1 1117 sieve c!  1 1118 sieve c!  1 1120 sieve c!  1 1124 sieve c!  1 1132 sieve c!
   1 1133 sieve c!  1 1135 sieve c!  1 1139 sieve c!  1 1142 sieve c!  1 1145 sieve c!
   1 1147 sieve c!  1 1153 sieve c!

   0 to n   \ n = primes count
   num sqrt 3 - 2/ 1+ 5 do
       I sieve c@ if
          \ p1=13*i, p2=17*i, p3=19*i -- p478=2297*i,p479=2309*i,p480=2311*i,k=2310*i
          \  j  i 13i 17i 19i 23i 29i 31i 37i..2291i 2293i 2297i 2309i 2311i 2310i
          \ 13->5  83 109 122 148 187 200 239  14890 14903 14929 15007 15020 15015
	  \ j=(i<<1)+3; j2=j<<1; j3=j2+j; j4=j2<<1; j5=j4+j; j6=j4+j2; j7=j4+j3
	  \ p1=j6+i; p2=p1+j2; p3=p2+j; p4=p3+j2; p5=p4+j3; p6=p5+j; p7=p6+j3; p8=p7+j2
	  \ p9=p8+j; p10=p9+j2; p11=p10+j3; p12=p11+j3; p13=p12+j; p14=p13+j3; p15=p14+j2
	  \ p16=p15+j;  p17=p16+j3; p18=p17+j2; p19=p18+j3; p20=p19+j4; p21=p20+j2
	  \ p22=p21+j;  p23=p22+j2; p24=p23+j;  p25=p24+j2; p26=p25+j7; p27=p26+j2
	  \ p28=p27+j3; p29=p28+j;  p30=p29+j5; p31=p30+j;  p32=p31+j3; p33=p32+j3
	  \ p34=p33+j2; p35=p34+j;  p36=p35+j2; p37=p36+j3; p38=p37+j;  p39=p38+j5
	  \ p40=p39+j;  p41=p40+j2; p42=p41+j;  p43=p42+j6; p44=p43+j5; p45=p44+j
	  \ p46=p45+j2; p47=p46+j;  p48=p47+j2; p49=p48+j3; p50=p49+j;  p51=p50+j3	
	  \ p52=p51+j2; p53=p52+j3; p54=p53+j3; p55=p54+j3; p56=p55+j;  p57=p56+j3
	  \ p58=p57+j2; p59=p58+j;  p60=p59+j3; p61=p60+j2; p62=p61+j3; p63=p62+j4
	  \ p64=p63+j2; p65=p64+j;  p66=p65+j2; p67=p66+j3; p68=p67+j4; p69=p68+j3	
	  \ p70=p69+j5; p71=p70+j;  p72=p71+j2; p73=p72+j3; p74=p73+j;  p75=p74+j3
	  \ p76=p75+j3; p77=p76+j2; p78=p77+j;  p79=p78+j2; p80=p79+j3; p81=p80+j
	  \ p82=p81+j3; p83=p82+j2; p84=p83+j;  p85=p84+j3; p86=p85+j5; p87=p86+j
	  \ p88=p87+j5; p89=p88+j;  p90=p89+j2; p91=p90+j;  p92=p91+j2; p93=p92+j3
	  \ p94=p93+j4; p95=p94+j2; p96=p95+j;  p97=p96+j2; p98=p97+j6; p99=p98+j
	  \ p100=p99+j3; p101=p100+j2;p102=p101+j;  p103=p102+j3; p104=p103+j2; p105=p104+j3
	  \ p106=p105+j6;p107=p106+j; p108=p107+j2; p109=p108+j;  p110=p109+j2; p111=p110+j4
	  \ p112=p111+j3;p113=p112+j2;p114=p113+j3; p115=p114+j;  p116=p115+j2; p117=p116+j3
	  \ p118=p117+j; p119=p118+j3;p120=p119+j5; p121=p120+j;  p122=p121+j2; p123=p122+j3
	  \ p124=p123+j; p125=p124+j3;p126=p125+j2; p127=p126+j;  p128=p127+j2; p129=p128+j
	  \ p130=p129+j5;p131=p130+j; p132=p131+j5; p133=p132+j;  p134=p133+j2; p135=p134+j3
	  \ p136=p135+j3;p137=p136+j; p138=p137+j3; p139=p138+j3; p140=p139+j2; p141=p140+j3
	  \ p142=p141+j3;p143=p142+j; p144=p143+j3; p145=p144+j2; p146=p145+j;  p147=p146+j3
	  \ p148=p147+j2;p149=p148+j3;p150=p149+j4; p151=p150+j2; p152=p151+j;  p153=p152+j3
	  \ p154=p153+j2;p155=p154+j4;p156=p155+j3; p157=p156+j2; p158=p157+j3; p159=p158+j	
	  \ p160=p159+j2;p161=p160+j3;p162=p161+j4; p163=p162+j3; p164=p163+j2; p165=p164+j
	  \ p166=p165+j5;p167=p166+j; p168=p167+j3; p169=p168+j2; p170=p169+j;  p171=p170+j2
	  \ p172=p171+j; p173=p172+j5;p174=p173+j;  p175=p174+j5; p176=p175+j;  p177=p176+j2
	  \ p178=p177+j; p179=p178+j2;p180=p179+j4; p181=p180+j3; p182=p181+j2; p183=p182+j
	  \ p184=p183+j2;p185=p184+j3;p186=p185+j3; p187=p186+j;  p188=p187+j3; p189=p188+j2
	  \ p190=p189+j4;p191=p190+j2;p192=p191+j3; p193=p192+j4; p194=p193+j2; p195=p194+j
	  \ p196=p195+j2;p197=p196+j; p198=p197+j2; p199=p198+j4; p200=p199+j3; p201=p200+j2
	  \ p202=p201+j3;p203=p202+j3;p204=p203+j3; p205=p204+j;  p206=p205+j3; p207=p206+j3
	  \ p208=p207+j2;p209=p208+j; p210=p209+j2; p211=p210+j3; p212=p211+j;  p213=p212+j3
	  \ p214=p213+j2;p215=p214+j; p216=p215+j2; p217=p216+j;  p218=p217+j5; p219=p218+j
	  \ p220=p219+j5;p221=p220+j; p222=p221+j3; p223=p222+j2; p224=p223+j3; p225=p224+j
	  \ p226=p225+j3;p227=p226+j2;p228=p227+j;  p229=p228+j2; p230=p229+j3; p231=p230+j3
	  \ p232=p231+j4;p233=p232+j2;p234=p233+j;  p235=p234+j3; p236=p235+j5; p237=p236+j4
	  \ p238=p237+j2;p239=p238+j; p240=p239+j2; p241=p240+j;  p242=p241+j2; p243=p242+j4
	  \ p244=p243+j5;p245=p244+j3;p246=p245+j;  p247=p246+j2; p248=p247+j4; p249=p248+j3
	  \ p250=p249+j3;p251=p250+j2;p252=p251+j;  p253=p252+j2; p254=p253+j3; p255=p254+j
	  \ p256=p255+j3;p257=p256+j2;p258=p257+j3; p259=p258+j;  p260=p259+j5; p261=p260+j
	  \ p262=p261+j5;p263=p262+j; p264=p263+j2; p265=p264+j;  p266=p265+j2; p267=p266+j3
	  \ p268=p267+j; p269=p268+j3;p270=p269+j2; p271=p270+j;  p272=p271+j2; p273=p272+j3
	  \ p274=p273+j3;p275=p274+j; p276=p275+j3; p277=p276+j3; p278=p277+j3; p279=p278+j2
	  \ p280=p279+j3;p281=p280+j4;p282=p281+j2; p283=p282+j;  p284=p283+j2; p285=p284+j
	  \ p286=p285+j2;p287=p286+j4;p288=p287+j3; p289=p288+j2; p290=p289+j4; p291=p290+j2
	  \ p292=p291+j3;p293=p292+j; p294=p293+j3; p295=p294+j3; p296=p295+j2; p297=p296+j
	  \ p298=p297+j2;p299=p298+j3;p300=p299+j4; p301=p300+j2; p302=p301+j;  p303=p302+j2
	  \ p304=p303+j; p305=p304+j5;p306=p305+j;  p307=p306+j5; p308=p307+j;  p309=p308+j2
	  \ p310=p309+j; p311=p310+j2;p312=p311+j3; p313=p312+j;  p314=p313+j5; p315=p314+j
 	  \ p316=p315+j2;p317=p316+j3;p318=p317+j4; p319=p318+j3; p320=p319+j2; p321=p320+j
	  \ p322=p321+j3;p323=p322+j2;p324=p323+j3; p325=p324+j4; p326=p325+j2; p327=p326+j3
	  \ p328=p327+j; p329=p328+j2;p330=p329+j4; p331=p330+j3; p332=p331+j2; p333=p332+j3
	  \ p334=p333+j; p335=p334+j2;p336=p335+j3; p337=p336+j;  p338=p337+j3; p339=p338+j3
	  \ p340=p339+j2;p341=p340+j3;p342=p341+j3; p343=p342+j;  p344=p343+j3; p345=p344+j3
	  \ p346=p345+j2;p347=p346+j; p348=p347+j5; p349=p348+j;  p350=p349+j5; p351=p350+j
	  \ p352=p351+j2;p353=p352+j; p354=p353+j2; p355=p354+j3; p356=p355+j;  p357=p356+j3
	  \ p358=p357+j2;p359=p358+j; p360=p359+j5; p361=p360+j3; p362=p361+j;  p363=p362+j3
	  \ p364=p363+j2;p365=p364+j; p366=p365+j3; p367=p366+j2; p368=p367+j3; p369=p368+j4
	  \ p370=p369+j2;p371=p370+j; p372=p371+j2; p373=p372+j;  p374=p373+j6; p375=p374+j3
 	  \ p376=p375+j2;p377=p376+j3;p378=p377+j;  p379=p378+j2; p380=p379+j3; p381=p380+j
	  \ p382=p381+j6;p383=p382+j2;p384=p383+j;  p385=p384+j2; p386=p385+j4; p387=p386+j3
	  \ p388=p387+j2;p389=p388+j; p390=p389+j2; p391=p390+j;  p392=p391+j5; p393=p392+j
	  \ p394=p393+j5;p395=p394+j3;p396=p395+j;  p397=p396+j2; p398=p397+j3; p399=p398+j
	  \ p400=p399+j3;p401=p400+j2;p402=p401+j;  p403=p402+j2; p404=p403+j3; p405=p404+j3
	  \ p406=p405+j; p407=p406+j3;p408=p407+j2; p409=p408+j;  p410=p409+j5; p411=p410+j3
	  \ p412=p411+j4;p413=p412+j3;p414=p413+j2; p415=p414+j;  p416=p415+j2; p417=p416+j4
	  \ p418=p417+j3;p419=p418+j2;p420=p419+j3; p421=p420+j;  p422=p421+j2; p423=p422+j3
	  \ p424=p423+j; p425=p424+j3;p426=p425+j3; p427=p426+j3; p428=p427+j2; p429=p428+j3
	  \ p430=p429+j; p431=p430+j3;p432=p431+j2; p433=p432+j;  p434=p433+j2; p435=p434+j
	  \ p436=p435+j5;p437=p436+j6;p438=p437+j;  p439=p438+j2; p440=p439+j ; p441=p440+j5
	  \ p442=p441+j; p443=p442+j3;p444=p443+j2; p445=p444+j;  p446=p445+j2; p447=p446+j3	
	  \ p448=p447+j3;p449=p448+j; p450=p449+j5; p451=p450+j;  p452=p451+j3; p453=p452+j2
	  \ p454=p453+j7;p455=p454+j2;p456=p455+j;  p457=p456+j2; p458=p457+j;  p459=p458+j2
	  \ p460=p459+j4;p461=p460+j3;p462=p461+j2; p463=p462+j3; p464=p463+j;  p465=p464+j2
	  \ p466=p465+j3;p467=p466+j; p468=p467+j3; p469=p468+j3; p470=p469+j2; p471=p470+j
	  \ p472=p471+j2;p473=p472+j3;p474=p473+j;  p475=p474+j3; p476=p475+j2; p477=p476+j
	  \ p478=p477+j2;p479=p478+j6;p480=p479+j;  k = p480-i
          I dup 2* 3 + ( j) dup 2* ( j2) dup to j2 over + ( j3) dup to j3  over + ( j4)
          dup to j4  over + ( j5)    dup to j5 over + ( j6) dup to j6  over + ( j7) >r
          swap j6 + ( p1) dup to p1 j2 + ( p2) dup to p2 over + ( p3) dup to p3 j2 + ( p4)
	  dup to p4   j3   + ( p5)   dup to p5   over + ( p6)   dup to p6   j3   + ( p7)
	  dup to p7   j2   + ( p8)   dup to p8   over + ( p9)   dup to p9   j2   + ( p10)
	  dup to p10  j3   + ( p11)  dup to p11  j3   + ( p12)  dup to p12  over + ( p13)
          dup to p13  j3   + ( p14)  dup to p14  j2   + ( p15)  dup to p15  over + ( p16)
          dup to p16  j3   + ( p17)  dup to p17  j2   + ( p18)  dup to p18  j3   + ( p19)
          dup to p19  j4   + ( p20)  dup to p20  j2   + ( p21)  dup to p21  over + ( p22)
          dup to p22  j2   + ( p23)  dup to p23  over + ( p24)  dup to p24  j2   + ( p25)
          dup to p25  r@   + ( p26)  dup to p26  j2   + ( p27)  dup to p27  j3   + ( p28)
          dup to p28  over + ( p29)  dup to p29  j5   + ( p30)  dup to p30  over + ( p31)
          dup to p31  j3   + ( p32)  dup to p32  j3   + ( p33)  dup to p33  j2   + ( p34)
          dup to p34  over + ( p35)  dup to p35  j2   + ( p36)  dup to p36  j3   + ( p37)
          dup to p37  over + ( p38)  dup to p38  j5   + ( p39)  dup to p39  over + ( p40)
          dup to p40  j2   + ( p41)  dup to p41  over + ( p42)  dup to p42  j6   + ( p43)
          dup to p43  j5   + ( p44)  dup to p44  over + ( p45)  dup to p45  j2   + ( p46)
          dup to p46  over + ( p47)  dup to p47  j2   + ( p48)  dup to p48  j3   + ( p49)
          dup to p49  over + ( p50)  dup to p50  j3   + ( p51)  dup to p51  j2   + ( p52)
          dup to p52  j3   + ( p53)  dup to p53  j3   + ( p54)  dup to p54  j3   + ( p55)
          dup to p55  over + ( p56)  dup to p56  j3   + ( p57)  dup to p57  j2   + ( p58)
          dup to p58  over + ( p59)  dup to p59  j3   + ( p60)  dup to p60  j2   + ( p61)
          dup to p61  j3   + ( p62)  dup to p62  j4   + ( p63)  dup to p63  j2   + ( p64)
          dup to p64  over + ( p65)  dup to p65  j2   + ( p66)  dup to p66  j3   + ( p67)
          dup to p67  j4   + ( p68)  dup to p68  j3   + ( p69)  dup to p69  j5   + ( p70)
          dup to p70  over + ( p71)  dup to p71  j2   + ( p72)  dup to p72  j3   + ( p73)
          dup to p73  over + ( p74)  dup to p74  j3   + ( p75)  dup to p75  j3   + ( p76)
          dup to p76  j2   + ( p77)  dup to p77  over + ( p78)  dup to p78  j2   + ( p79)
          dup to p79  j3   + ( p80)  dup to p80  over + ( p81)  dup to p81  j3   + ( p82)
          dup to p82  j2   + ( p83)  dup to p83  over + ( p84)  dup to p84  j3   + ( p85)
          dup to p85  j5   + ( p86)  dup to p86  over + ( p87)  dup to p87  j5   + ( p88)
          dup to p88  over + ( p89)  dup to p89  j2   + ( p90)  dup to p90  over + ( p91)
          dup to p91  j2   + ( p92)  dup to p92  j3   + ( p93)  dup to p93  j4   + ( p94)
          dup to p94  j2   + ( p95)  dup to p95  over + ( p96)  dup to p96  j2   + ( p97)
          dup to p97  j6   + ( p98)  dup to p98  over + ( p99)  dup to p99  j3   + ( p100)
          dup to p100 j2   + ( p101) dup to p101 over + ( p102) dup to p102 j3   + ( p103)
          dup to p103 j2   + ( p104) dup to p104 j3   + ( p105) dup to p105 j6   + ( p106)
          dup to p106 over + ( p107) dup to p107 j2   + ( p108) dup to p108 over + ( p109)
          dup to p109 j2   + ( p110) dup to p110 j4   + ( p111) dup to p111 j3   + ( p112)
          dup to p112 j2   + ( p113) dup to p113 j3   + ( p114) dup to p114 over + ( p115)
          dup to p115 j2   + ( p116) dup to p116 j3   + ( p117) dup to p117 over + ( p118)
          dup to p118 j3   + ( p119) dup to p119 j5   + ( p120) dup to p120 over + ( p121)
          dup to p121 j2   + ( p122) dup to p122 j3   + ( p123) dup to p123 over + ( p124)
          dup to p124 j3   + ( p125) dup to p125 j2   + ( p126) dup to p126 over + ( p127)
          dup to p127 j2   + ( p128) dup to p128 over + ( p129) dup to p129 j5   + ( p130)
          dup to p130 over + ( p131) dup to p131 j5   + ( p132) dup to p132 over + ( p133)
          dup to p133 j2   + ( p134) dup to p134 j3   + ( p135) dup to p135 j3   + ( p136)
          dup to p136 over + ( p137) dup to p137 j3   + ( p138) dup to p138 j3   + ( p139)
          dup to p139 j2   + ( p140) dup to p140 j3   + ( p141) dup to p141 j3   + ( p142)
          dup to p142 over + ( p143) dup to p143 j3   + ( p144) dup to p144 j2   + ( p145)
          dup to p145 over + ( p146) dup to p146 j3   + ( p147) dup to p147 j2   + ( p148)
          dup to p148 j3   + ( p149) dup to p149 j4   + ( p150) dup to p150 j2   + ( p151)
          dup to p151 over + ( p152) dup to p152 j3   + ( p153) dup to p153 j2   + ( p154)
          dup to p154 j4   + ( p155) dup to p155 j3   + ( p156) dup to p156 j2   + ( p157)
          dup to p157 j3   + ( p158) dup to p158 over + ( p159) dup to p159 j2   + ( p160)
          dup to p160 j3   + ( p161) dup to p161 j4   + ( p162) dup to p162 j3   + ( p163)
          dup to p163 j2   + ( p164) dup to p164 over + ( p165) dup to p165 j5   + ( p166)
          dup to p166 over + ( p167) dup to p167 j3   + ( p168) dup to p168 j2   + ( p169)
          dup to p169 over + ( p170) dup to p170 j2   + ( p171) dup to p171 over + ( p172)
          dup to p172 j5   + ( p173) dup to p173 over + ( p174) dup to p174 j5   + ( p175)
          dup to p175 over + ( p176) dup to p176 j2   + ( p177) dup to p177 over + ( p178)
          dup to p178 j2   + ( p179) dup to p179 j4   + ( p180) dup to p180 j3   + ( p181)
          dup to p181 j2   + ( p182) dup to p182 over + ( p183) dup to p183 j2   + ( p184)
          dup to p184 j3   + ( p185) dup to p185 j3   + ( p186) dup to p186 over + ( p187)
          dup to p187 j3   + ( p188) dup to p188 j2   + ( p189) dup to p189 j4   + ( p190)
          dup to p190 j2   + ( p191) dup to p191 j3   + ( p192) dup to p192 j4   + ( p193)
          dup to p193 j2   + ( p194) dup to p194 over + ( p195) dup to p195 j2   + ( p196)
          dup to p196 over + ( p197) dup to p197 j2   + ( p198) dup to p198 j4   + ( p199)
          dup to p199 j3   + ( p200) dup to p200 j2   + ( p201) dup to p201 j3   + ( p202)
          dup to p202 j3   + ( p203) dup to p203 j3   + ( p204) dup to p204 over + ( p205)
          dup to p205 j3   + ( p206) dup to p206 j3   + ( p207) dup to p207 j2   + ( p208)
          dup to p208 over + ( p209) dup to p209 j2   + ( p210) dup to p210 j3   + ( p211)
          dup to p211 over + ( p212) dup to p212 j3   + ( p213) dup to p213 j2   + ( p214)
          dup to p214 over + ( p215) dup to p215 j2   + ( p216) dup to p216 over + ( p217)
          dup to p217 j5   + ( p218) dup to p218 over + ( p219) dup to p219 j5   + ( p220)
          dup to p220 over + ( p221) dup to p221 j3   + ( p222) dup to p222 j2   + ( p223)
          dup to p223 j3   + ( p224) dup to p224 over + ( p225) dup to p225 j3   + ( p226)
          dup to p226 j2   + ( p227) dup to p227 over + ( p228) dup to p228 j2   + ( p229)
          dup to p229 j3   + ( p230) dup to p230 j3   + ( p231) dup to p231 j4   + ( p232)
          dup to p232 j2   + ( p233) dup to p233 over + ( p234) dup to p234 j3   + ( p235)
          dup to p235 j5   + ( p236) dup to p236 j4   + ( p237) dup to p237 j2   + ( p238)
          dup to p238 over + ( p239) dup to p239 j2   + ( p240) dup to p240 over + ( p241)
          dup to p241 j2   + ( p242) dup to p242 j4   + ( p243) dup to p243 j5   + ( p244)
          dup to p244 j3   + ( p245) dup to p245 over + ( p246) dup to p246 j2   + ( p247)
          dup to p247 j4   + ( p248) dup to p248 j3   + ( p249) dup to p249 j3   + ( p250)
          dup to p250 j2   + ( p251) dup to p251 over + ( p252) dup to p252 j2   + ( p253)
          dup to p253 j3   + ( p254) dup to p254 over + ( p255) dup to p255 j3   + ( p256)
          dup to p256 j2   + ( p257) dup to p257 j3   + ( p258) dup to p258 over + ( p259)
          dup to p259 j5   + ( p260) dup to p260 over + ( p261) dup to p261 j5   + ( p262)
          dup to p262 over + ( p263) dup to p263 j2   + ( p264) dup to p264 over + ( p265)
          dup to p265 j2   + ( p266) dup to p266 j3   + ( p267) dup to p267 over + ( p268)
          dup to p268 j3   + ( p269) dup to p269 j2   + ( p270) dup to p270 over + ( p271)
          dup to p271 j2   + ( p272) dup to p272 j3   + ( p273) dup to p273 j3   + ( p274)
          dup to p274 over + ( p275) dup to p275 j3   + ( p276) dup to p276 j3   + ( p277)
          dup to p277 j3   + ( p278) dup to p278 j2   + ( p279) dup to p279 j3   + ( p280)
          dup to p280 j4   + ( p281) dup to p281 j2   + ( p282) dup to p282 over + ( p283)
          dup to p283 j2   + ( p284) dup to p284 over + ( p285) dup to p285 j2   + ( p286)
          dup to p286 j4   + ( p287) dup to p287 j3   + ( p288) dup to p288 j2   + ( p289)
          dup to p289 j4   + ( p290) dup to p290 j2   + ( p291) dup to p291 j3   + ( p292)
          dup to p292 over + ( p293) dup to p293 j3   + ( p294) dup to p294 j3   + ( p295)
          dup to p295 j2   + ( p296) dup to p296 over + ( p297) dup to p297 j2   + ( p298)
          dup to p298 j3   + ( p299) dup to p299 j4   + ( p300) dup to p300 j2   + ( p301)
          dup to p301 over + ( p302) dup to p302 j2   + ( p303) dup to p303 over + ( p304)
          dup to p304 j5   + ( p305) dup to p305 over + ( p306) dup to p306 j5   + ( p307)
          dup to p307 over + ( p308) dup to p308 j2   + ( p309) dup to p309 over + ( p310)
          dup to p310 j2   + ( p311) dup to p311 j3   + ( p312) dup to p312 over + ( p313)
          dup to p313 j5   + ( p314) dup to p314 over + ( p315) dup to p315 j2   + ( p316)
          dup to p316 j3   + ( p317) dup to p317 j4   + ( p318) dup to p318 j3   + ( p319)
          dup to p319 j2   + ( p320) dup to p320 over + ( p321) dup to p321 j3   + ( p322)
          dup to p322 j2   + ( p323) dup to p323 j3   + ( p324) dup to p324 j4   + ( p325)
          dup to p325 j2   + ( p326) dup to p326 j3   + ( p327) dup to p327 over + ( p328)
          dup to p328 j2   + ( p329) dup to p329 j4   + ( p330) dup to p330 j3   + ( p331)
          dup to p331 j2   + ( p332) dup to p332 j3   + ( p333) dup to p333 over + ( p334)
          dup to p334 j2   + ( p335) dup to p335 j3   + ( p336) dup to p336 over + ( p337)
          dup to p337 j3   + ( p338) dup to p338 j3   + ( p339) dup to p339 j2   + ( p340)
          dup to p340 j3   + ( p341) dup to p341 j3   + ( p342) dup to p342 over + ( p343)
          dup to p343 j3   + ( p344) dup to p344 j3   + ( p345) dup to p345 j2   + ( p346)
          dup to p346 over + ( p347) dup to p347 j5   + ( p348) dup to p348 over + ( p349)
          dup to p349 j5   + ( p350) dup to p350 over + ( p351) dup to p351 j2   + ( p352)
          dup to p352 over + ( p353) dup to p353 j2   + ( p354) dup to p354 j3   + ( p355)
          dup to p355 over + ( p356) dup to p356 j3   + ( p357) dup to p357 j2   + ( p358)
          dup to p358 over + ( p359) dup to p359 j5   + ( p360) dup to p360 j3   + ( p361)
          dup to p361 over + ( p362) dup to p362 j3   + ( p363) dup to p363 j2   + ( p364)
          dup to p364 over + ( p365) dup to p365 j3   + ( p366) dup to p366 j2   + ( p367)
          dup to p367 j3   + ( p368) dup to p368 j4   + ( p369) dup to p369 j2   + ( p370)
          dup to p370 over + ( p371) dup to p371 j2   + ( p372) dup to p372 over + ( p373)
          dup to p373 j6   + ( p374) dup to p374 j3   + ( p375) dup to p375 j2   + ( p376)
          dup to p376 j3   + ( p377) dup to p377 over + ( p378) dup to p378 j2   + ( p379)
          dup to p379 j3   + ( p380) dup to p380 over + ( p381) dup to p381 j6   + ( p382)
          dup to p382 j2   + ( p383) dup to p383 over + ( p384) dup to p384 j2   + ( p385)
          dup to p385 j4   + ( p386) dup to p386 j3   + ( p387) dup to p387 j2   + ( p388)
          dup to p388 over + ( p389) dup to p389 j2   + ( p390) dup to p390 over + ( p391)
          dup to p391 j5   + ( p392) dup to p392 over + ( p393) dup to p393 j5   + ( p394)
          dup to p394 j3   + ( p395) dup to p395 over + ( p396) dup to p396 j2   + ( p397)
          dup to p397 j3   + ( p398) dup to p398 over + ( p399) dup to p399 j3   + ( p400)
          dup to p400 j2   + ( p401) dup to p401 over + ( p402) dup to p402 j2   + ( p403)
          dup to p403 j3   + ( p404) dup to p404 j3   + ( p405) dup to p405 over + ( p406)
          dup to p406 j3   + ( p407) dup to p407 j2   + ( p408) dup to p408 over + ( p409)
          dup to p409 j5   + ( p410) dup to p410 j3   + ( p411) dup to p411 j4   + ( p412)
          dup to p412 j3   + ( p413) dup to p413 j2   + ( p414) dup to p414 over + ( p415)
          dup to p415 j2   + ( p416) dup to p416 j4   + ( p417) dup to p417 j3   + ( p418)
          dup to p418 j2   + ( p419) dup to p419 j3   + ( p420) dup to p420 over + ( p421)
          dup to p421 j2   + ( p422) dup to p422 j3   + ( p423) dup to p423 over + ( p424)
          dup to p424 j3   + ( p425) dup to p425 j3   + ( p426) dup to p426 j3   + ( p427)
          dup to p427 j2   + ( p428) dup to p428 j3   + ( p429) dup to p429 over + ( p430)
          dup to p430 j3   + ( p431) dup to p431 j2   + ( p432) dup to p432 over + ( p433)
          dup to p433 j2   + ( p434) dup to p434 over + ( p435) dup to p435 j5   + ( p436)
          dup to p436 j6   + ( p437) dup to p437 over + ( p438) dup to p438 j2   + ( p439)
          dup to p439 over + ( p440) dup to p440 j5   + ( p441) dup to p441 over + ( p442)
          dup to p442 j3   + ( p443) dup to p443 j2   + ( p444) dup to p444 over + ( p445)
          dup to p445 j2   + ( p446) dup to p446 j3   + ( p447) dup to p447 j3   + ( p448)
          dup to p448 over + ( p449) dup to p449 j5   + ( p450) dup to p450 over + ( p451)
          dup to p451 j3   + ( p452) dup to p452 j2   + ( p453) dup to p453 r>   + ( p454)
          dup to p454 j2   + ( p455) dup to p455 over + ( p456) dup to p456 j2   + ( p457)
          dup to p457 over + ( p458) dup to p458 j2   + ( p459) dup to p459 j4   + ( p460)
          dup to p460 j3   + ( p461) dup to p461 j2   + ( p462) dup to p462 j3   + ( p463)
          dup to p463 over + ( p464) dup to p464 j2   + ( p465) dup to p465 j3   + ( p466)
          dup to p466 over + ( p467) dup to p467 j3   + ( p468) dup to p468 j3   + ( p469)
          dup to p469 j2   + ( p470) dup to p470 over + ( p471) dup to p471 j2   + ( p472)
          dup to p472 j3   + ( p473) dup to p473 over + ( p474) dup to p474 j3   + ( p475)
          dup to p475 j2   + ( p476) dup to p476 over + ( p477) dup to p477 j2   + ( p478)
          dup to p478 j6   + ( p479) dup to p479      + ( p480) dup to p480 I - to x1
          n 480 / x1 * to x  n 1+ to n          \ x = x1*(n/rescnt)  rescnt = 480
          x p1   + sieve to p1    x p2   + sieve to p2    x p3   + sieve to p3    x p4   + sieve to p4
          x p5   + sieve to p5    x p6   + sieve to p6    x p7   + sieve to p7    x p8   + sieve to p8
          x p9   + sieve to p9    x p10  + sieve to p10   x p11  + sieve to p11   x p12  + sieve to p12
          x p13  + sieve to p13   x p14  + sieve to p14   x p15  + sieve to p15   x p16  + sieve to p16
          x p17  + sieve to p17   x p18  + sieve to p18   x p19  + sieve to p19   x p20  + sieve to p20
          x p21  + sieve to p21   x p22  + sieve to p22   x p23  + sieve to p23   x p24  + sieve to p24
          x p25  + sieve to p25   x p26  + sieve to p26   x p27  + sieve to p27   x p28  + sieve to p28
          x p29  + sieve to p29   x p30  + sieve to p30   x p31  + sieve to p31   x p32  + sieve to p32
          x p33  + sieve to p33   x p34  + sieve to p34   x p35  + sieve to p35   x p36  + sieve to p36
          x p37  + sieve to p37   x p38  + sieve to p38   x p39  + sieve to p39   x p40  + sieve to p40
          x p41  + sieve to p41   x p42  + sieve to p42   x p43  + sieve to p43   x p44  + sieve to p44
          x p45  + sieve to p45   x p46  + sieve to p46   x p47  + sieve to p47   x p48  + sieve to p48
          x p49  + sieve to p49   x p50  + sieve to p50   x p51  + sieve to p51   x p52  + sieve to p52
          x p53  + sieve to p53   x p54  + sieve to p54   x p55  + sieve to p55   x p56  + sieve to p56
          x p57  + sieve to p57   x p58  + sieve to p58   x p59  + sieve to p59   x p60  + sieve to p60
          x p61  + sieve to p61   x p62  + sieve to p62   x p63  + sieve to p63   x p64  + sieve to p64
          x p65  + sieve to p65   x p66  + sieve to p66   x p67  + sieve to p67   x p68  + sieve to p68
          x p69  + sieve to p69   x p70  + sieve to p70   x p71  + sieve to p71   x p72  + sieve to p72
          x p73  + sieve to p73   x p74  + sieve to p74   x p75  + sieve to p75   x p76  + sieve to p76
          x p77  + sieve to p77   x p78  + sieve to p78   x p79  + sieve to p79   x p80  + sieve to p80
          x p81  + sieve to p81   x p82  + sieve to p82   x p83  + sieve to p83   x p84  + sieve to p84
          x p85  + sieve to p85   x p86  + sieve to p86   x p87  + sieve to p87   x p88  + sieve to p88
          x p89  + sieve to p89   x p90  + sieve to p90   x p91  + sieve to p91   x p92  + sieve to p92
          x p93  + sieve to p93   x p94  + sieve to p94   x p95  + sieve to p95   x p96  + sieve to p96
          x p97  + sieve to p97   x p98  + sieve to p98   x p99  + sieve to p99   x p100 + sieve to p100
          x p101 + sieve to p101  x p102 + sieve to p102  x p103 + sieve to p103  x p104 + sieve to p104
          x p105 + sieve to p105  x p106 + sieve to p106  x p107 + sieve to p107  x p108 + sieve to p108
          x p109 + sieve to p109  x p110 + sieve to p110  x p111 + sieve to p111  x p112 + sieve to p112
          x p113 + sieve to p113  x p114 + sieve to p114  x p115 + sieve to p115  x p116 + sieve to p116
          x p117 + sieve to p117  x p118 + sieve to p118  x p119 + sieve to p119  x p120 + sieve to p120
          x p121 + sieve to p121  x p122 + sieve to p122  x p123 + sieve to p123  x p124 + sieve to p124
          x p125 + sieve to p125  x p126 + sieve to p126  x p127 + sieve to p127  x p128 + sieve to p128
          x p129 + sieve to p129  x p130 + sieve to p130  x p131 + sieve to p131  x p132 + sieve to p132
          x p133 + sieve to p133  x p134 + sieve to p134  x p135 + sieve to p135  x p136 + sieve to p136
          x p137 + sieve to p137  x p138 + sieve to p138  x p139 + sieve to p139  x p140 + sieve to p140
          x p141 + sieve to p141  x p142 + sieve to p142  x p143 + sieve to p143  x p144 + sieve to p144
          x p145 + sieve to p145  x p146 + sieve to p146  x p147 + sieve to p147  x p148 + sieve to p148
          x p149 + sieve to p149  x p150 + sieve to p150  x p151 + sieve to p151  x p152 + sieve to p152
          x p153 + sieve to p153  x p154 + sieve to p154  x p155 + sieve to p155  x p156 + sieve to p156
          x p157 + sieve to p157  x p158 + sieve to p158  x p159 + sieve to p159  x p160 + sieve to p160
          x p161 + sieve to p161  x p162 + sieve to p162  x p163 + sieve to p163  x p164 + sieve to p164
          x p165 + sieve to p165  x p166 + sieve to p166  x p167 + sieve to p167  x p168 + sieve to p168
          x p169 + sieve to p169  x p170 + sieve to p170  x p171 + sieve to p171  x p172 + sieve to p172
          x p173 + sieve to p173  x p174 + sieve to p174  x p175 + sieve to p175  x p176 + sieve to p176
          x p177 + sieve to p177  x p178 + sieve to p178  x p179 + sieve to p179  x p180 + sieve to p180
          x p181 + sieve to p181  x p182 + sieve to p182  x p183 + sieve to p183  x p184 + sieve to p184
          x p185 + sieve to p185  x p186 + sieve to p186  x p187 + sieve to p187  x p188 + sieve to p188
          x p189 + sieve to p189  x p190 + sieve to p190  x p191 + sieve to p191  x p192 + sieve to p192
          x p193 + sieve to p193  x p194 + sieve to p194  x p195 + sieve to p195  x p196 + sieve to p196
          x p197 + sieve to p197  x p198 + sieve to p198  x p199 + sieve to p199  x p200 + sieve to p200
          x p201 + sieve to p201  x p202 + sieve to p202  x p203 + sieve to p203  x p204 + sieve to p204
          x p205 + sieve to p205  x p206 + sieve to p206  x p207 + sieve to p207  x p208 + sieve to p208
          x p209 + sieve to p209  x p210 + sieve to p210  x p211 + sieve to p211  x p212 + sieve to p212
          x p213 + sieve to p213  x p214 + sieve to p214  x p215 + sieve to p215  x p216 + sieve to p216
          x p217 + sieve to p217  x p218 + sieve to p218  x p219 + sieve to p219  x p220 + sieve to p220
          x p221 + sieve to p221  x p222 + sieve to p222  x p223 + sieve to p223  x p224 + sieve to p224
          x p225 + sieve to p225  x p226 + sieve to p226  x p227 + sieve to p227  x p228 + sieve to p228
          x p229 + sieve to p229  x p230 + sieve to p230  x p231 + sieve to p231  x p232 + sieve to p232
          x p233 + sieve to p233  x p234 + sieve to p234  x p235 + sieve to p235  x p236 + sieve to p236
          x p237 + sieve to p237  x p238 + sieve to p238  x p239 + sieve to p239  x p240 + sieve to p240
          x p241 + sieve to p241  x p242 + sieve to p242  x p243 + sieve to p243  x p244 + sieve to p244
          x p245 + sieve to p245  x p246 + sieve to p246  x p247 + sieve to p247  x p248 + sieve to p248
          x p249 + sieve to p249  x p250 + sieve to p250  x p251 + sieve to p251  x p252 + sieve to p252
          x p253 + sieve to p253  x p254 + sieve to p254  x p255 + sieve to p255  x p256 + sieve to p256
          x p257 + sieve to p257  x p258 + sieve to p258  x p259 + sieve to p259  x p260 + sieve to p260
          x p261 + sieve to p261  x p262 + sieve to p262  x p263 + sieve to p263  x p264 + sieve to p264
          x p265 + sieve to p265  x p266 + sieve to p266  x p267 + sieve to p267  x p268 + sieve to p268
          x p269 + sieve to p269  x p270 + sieve to p270  x p271 + sieve to p271  x p272 + sieve to p272
          x p273 + sieve to p273  x p274 + sieve to p274  x p275 + sieve to p275  x p276 + sieve to p276
          x p277 + sieve to p277  x p278 + sieve to p278  x p279 + sieve to p279  x p280 + sieve to p280
          x p281 + sieve to p281  x p282 + sieve to p282  x p283 + sieve to p283  x p284 + sieve to p284
          x p285 + sieve to p285  x p286 + sieve to p286  x p287 + sieve to p287  x p288 + sieve to p288
          x p289 + sieve to p289  x p290 + sieve to p290  x p291 + sieve to p291  x p292 + sieve to p292
          x p293 + sieve to p293  x p294 + sieve to p294  x p295 + sieve to p295  x p296 + sieve to p296
          x p297 + sieve to p297  x p298 + sieve to p298  x p299 + sieve to p299  x p300 + sieve to p300
          x p301 + sieve to p301  x p302 + sieve to p302  x p303 + sieve to p303  x p304 + sieve to p304
          x p305 + sieve to p305  x p306 + sieve to p306  x p307 + sieve to p307  x p308 + sieve to p308
          x p309 + sieve to p309  x p310 + sieve to p310  x p311 + sieve to p311  x p312 + sieve to p312
          x p313 + sieve to p313  x p314 + sieve to p314  x p315 + sieve to p315  x p316 + sieve to p316
          x p317 + sieve to p317  x p318 + sieve to p318  x p319 + sieve to p319  x p320 + sieve to p320
          x p321 + sieve to p321  x p322 + sieve to p322  x p323 + sieve to p323  x p324 + sieve to p324
          x p325 + sieve to p325  x p326 + sieve to p326  x p327 + sieve to p327  x p328 + sieve to p328
          x p329 + sieve to p329  x p330 + sieve to p330  x p331 + sieve to p331  x p332 + sieve to p332
          x p333 + sieve to p333  x p334 + sieve to p334  x p335 + sieve to p335  x p336 + sieve to p336
          x p337 + sieve to p337  x p338 + sieve to p338  x p339 + sieve to p339  x p340 + sieve to p340
          x p341 + sieve to p341  x p342 + sieve to p342  x p343 + sieve to p343  x p344 + sieve to p344
          x p345 + sieve to p345  x p346 + sieve to p346  x p347 + sieve to p347  x p348 + sieve to p348
          x p349 + sieve to p349  x p350 + sieve to p350  x p351 + sieve to p351  x p352 + sieve to p352
          x p353 + sieve to p353  x p354 + sieve to p354  x p355 + sieve to p355  x p356 + sieve to p356
          x p357 + sieve to p357  x p358 + sieve to p358  x p359 + sieve to p359  x p360 + sieve to p360
          x p361 + sieve to p361  x p362 + sieve to p362  x p363 + sieve to p363  x p364 + sieve to p364
          x p365 + sieve to p365  x p366 + sieve to p366  x p367 + sieve to p367  x p368 + sieve to p368
          x p369 + sieve to p369  x p370 + sieve to p370  x p371 + sieve to p371  x p372 + sieve to p372
          x p373 + sieve to p373  x p374 + sieve to p374  x p375 + sieve to p375  x p376 + sieve to p376
          x p377 + sieve to p377  x p378 + sieve to p378  x p379 + sieve to p379  x p380 + sieve to p380
          x p381 + sieve to p381  x p382 + sieve to p382  x p383 + sieve to p383  x p384 + sieve to p384
          x p385 + sieve to p385  x p386 + sieve to p386  x p387 + sieve to p387  x p388 + sieve to p388
          x p389 + sieve to p389  x p390 + sieve to p390  x p391 + sieve to p391  x p392 + sieve to p392
          x p393 + sieve to p393  x p394 + sieve to p394  x p395 + sieve to p395  x p396 + sieve to p396
          x p397 + sieve to p397  x p398 + sieve to p398  x p399 + sieve to p399  x p400 + sieve to p400
          x p401 + sieve to p401  x p402 + sieve to p402  x p403 + sieve to p403  x p404 + sieve to p404
          x p405 + sieve to p405  x p406 + sieve to p406  x p407 + sieve to p407  x p408 + sieve to p408
          x p409 + sieve to p409  x p410 + sieve to p410  x p411 + sieve to p411  x p412 + sieve to p412
          x p413 + sieve to p413  x p414 + sieve to p414  x p415 + sieve to p415  x p416 + sieve to p416
          x p417 + sieve to p417  x p418 + sieve to p418  x p419 + sieve to p419  x p420 + sieve to p420
          x p421 + sieve to p421  x p422 + sieve to p422  x p423 + sieve to p423  x p424 + sieve to p424
          x p425 + sieve to p425  x p426 + sieve to p426  x p427 + sieve to p427  x p428 + sieve to p428
          x p429 + sieve to p429  x p430 + sieve to p430  x p431 + sieve to p431  x p432 + sieve to p432
          x p433 + sieve to p433  x p434 + sieve to p434  x p435 + sieve to p435  x p436 + sieve to p436
          x p437 + sieve to p437  x p438 + sieve to p438  x p439 + sieve to p439  x p440 + sieve to p440
          x p441 + sieve to p441  x p442 + sieve to p442  x p443 + sieve to p443  x p444 + sieve to p444
          x p445 + sieve to p445  x p446 + sieve to p446  x p447 + sieve to p447  x p448 + sieve to p448
          x p449 + sieve to p449  x p450 + sieve to p450  x p451 + sieve to p451  x p452 + sieve to p452
          x p453 + sieve to p453  x p454 + sieve to p454  x p455 + sieve to p455  x p456 + sieve to p456
          x p457 + sieve to p457  x p458 + sieve to p458  x p459 + sieve to p459  x p460 + sieve to p460
          x p461 + sieve to p461  x p462 + sieve to p462  x p463 + sieve to p463  x p464 + sieve to p464
          x p465 + sieve to p465  x p466 + sieve to p466  x p467 + sieve to p467  x p468 + sieve to p468
          x p469 + sieve to p469  x p470 + sieve to p470  x p471 + sieve to p471  x p472 + sieve to p472
          x p473 + sieve to p473  x p474 + sieve to p474  x p475 + sieve to p475  x p476 + sieve to p476
          x p477 + sieve to p477  x p478 + sieve to p478  x p479 + sieve to p479  x p480 + sieve to p480
          begin p480 slndx < while
             0 p1   c!  0 p2   c!  0 p3   c!  0 p4   c!  0 p5   c!  0 p6   c!  0 p7   c!  0 p8   c!
             0 p9   c!  0 p10  c!  0 p11  c!  0 p12  c!  0 p13  c!  0 p14  c!  0 p15  c!  0 p16  c! 
             0 p17  c!  0 p18  c!  0 p19  c!  0 p20  c!  0 p21  c!  0 p22  c!  0 p23  c!  0 p24  c!
             0 p25  c!  0 p26  c!  0 p27  c!  0 p28  c!  0 p29  c!  0 p30  c!  0 p31  c!  0 p32  c!
             0 p33  c!  0 p34  c!  0 p35  c!  0 p36  c!  0 p37  c!  0 p38  c!  0 p39  c!  0 p40  c!
             0 p41  c!  0 p42  c!  0 p43  c!  0 p44  c!  0 p45  c!  0 p46  c!  0 p47  c!  0 p48  c!
             0 p49  c!  0 p50  c!  0 p51  c!  0 p52  c!  0 p53  c!  0 p54  c!  0 p55  c!  0 p56  c!
             0 p57  c!  0 p58  c!  0 p59  c!  0 p60  c!  0 p61  c!  0 p62  c!  0 p63  c!  0 p64  c!
             0 p65  c!  0 p66  c!  0 p67  c!  0 p68  c!  0 p69  c!  0 p70  c!  0 p71  c!  0 p72  c!
             0 p73  c!  0 p74  c!  0 p75  c!  0 p76  c!  0 p77  c!  0 p78  c!  0 p79  c!  0 p80  c!
             0 p81  c!  0 p82  c!  0 p83  c!  0 p84  c!  0 p85  c!  0 p86  c!  0 p87  c!  0 p88  c!
             0 p89  c!  0 p90  c!  0 p91  c!  0 p92  c!  0 p93  c!  0 p94  c!  0 p95  c!  0 p96  c!
             0 p97  c!  0 p98  c!  0 p99  c!  0 p100 c!  0 p101 c!  0 p102 c!  0 p103 c!  0 p104 c!
             0 p105 c!  0 p106 c!  0 p107 c!  0 p108 c!  0 p109 c!  0 p110 c!  0 p111 c!  0 p112 c!
             0 p113 c!  0 p114 c!  0 p115 c!  0 p116 c!  0 p117 c!  0 p118 c!  0 p119 c!  0 p120 c!
             0 p121 c!  0 p122 c!  0 p123 c!  0 p124 c!  0 p125 c!  0 p126 c!  0 p127 c!  0 p128 c!
             0 p129 c!  0 p130 c!  0 p131 c!  0 p132 c!  0 p133 c!  0 p134 c!  0 p135 c!  0 p136 c!
             0 p137 c!  0 p138 c!  0 p139 c!  0 p140 c!  0 p141 c!  0 p142 c!  0 p143 c!  0 p144 c!
             0 p145 c!  0 p146 c!  0 p147 c!  0 p148 c!  0 p149 c!  0 p150 c!  0 p151 c!  0 p152 c!
             0 p153 c!  0 p154 c!  0 p155 c!  0 p156 c!  0 p157 c!  0 p158 c!  0 p159 c!  0 p160 c!
             0 p161 c!  0 p162 c!  0 p163 c!  0 p164 c!  0 p165 c!  0 p166 c!  0 p167 c!  0 p168 c!
             0 p169 c!  0 p170 c!  0 p171 c!  0 p172 c!  0 p173 c!  0 p174 c!  0 p175 c!  0 p176 c!
             0 p177 c!  0 p178 c!  0 p179 c!  0 p180 c!  0 p181 c!  0 p182 c!  0 p183 c!  0 p184 c!
             0 p185 c!  0 p186 c!  0 p187 c!  0 p188 c!  0 p189 c!  0 p190 c!  0 p191 c!  0 p192 c!
             0 p193 c!  0 p194 c!  0 p195 c!  0 p196 c!  0 p197 c!  0 p198 c!  0 p199 c!  0 p200 c!
             0 p201 c!  0 p202 c!  0 p203 c!  0 p204 c!  0 p205 c!  0 p206 c!  0 p207 c!  0 p208 c!
             0 p209 c!  0 p210 c!  0 p211 c!  0 p212 c!  0 p213 c!  0 p214 c!  0 p215 c!  0 p216 c!
             0 p217 c!  0 p218 c!  0 p219 c!  0 p220 c!  0 p221 c!  0 p222 c!  0 p223 c!  0 p224 c!
             0 p225 c!  0 p226 c!  0 p227 c!  0 p228 c!  0 p229 c!  0 p230 c!  0 p231 c!  0 p232 c!
             0 p233 c!  0 p234 c!  0 p235 c!  0 p236 c!  0 p237 c!  0 p238 c!  0 p239 c!  0 p240 c!
             0 p241 c!  0 p242 c!  0 p243 c!  0 p244 c!  0 p245 c!  0 p246 c!  0 p247 c!  0 p248 c!
             0 p249 c!  0 p250 c!  0 p251 c!  0 p252 c!  0 p253 c!  0 p254 c!  0 p255 c!  0 p256 c!
             0 p257 c!  0 p258 c!  0 p259 c!  0 p260 c!  0 p261 c!  0 p262 c!  0 p263 c!  0 p264 c!
             0 p265 c!  0 p266 c!  0 p267 c!  0 p268 c!  0 p269 c!  0 p270 c!  0 p271 c!  0 p272 c!
             0 p273 c!  0 p274 c!  0 p275 c!  0 p276 c!  0 p277 c!  0 p278 c!  0 p279 c!  0 p280 c!
             0 p281 c!  0 p282 c!  0 p283 c!  0 p284 c!  0 p285 c!  0 p286 c!  0 p287 c!  0 p288 c!
             0 p289 c!  0 p290 c!  0 p291 c!  0 p292 c!  0 p293 c!  0 p294 c!  0 p295 c!  0 p296 c!
             0 p297 c!  0 p298 c!  0 p299 c!  0 p300 c!  0 p301 c!  0 p302 c!  0 p303 c!  0 p304 c!
             0 p305 c!  0 p306 c!  0 p307 c!  0 p308 c!  0 p309 c!  0 p310 c!  0 p311 c!  0 p312 c!
             0 p313 c!  0 p314 c!  0 p315 c!  0 p316 c!  0 p317 c!  0 p318 c!  0 p319 c!  0 p320 c!
             0 p321 c!  0 p322 c!  0 p323 c!  0 p324 c!  0 p325 c!  0 p326 c!  0 p327 c!  0 p328 c!
             0 p329 c!  0 p330 c!  0 p331 c!  0 p332 c!  0 p333 c!  0 p334 c!  0 p335 c!  0 p336 c!
             0 p337 c!  0 p338 c!  0 p339 c!  0 p340 c!  0 p341 c!  0 p342 c!  0 p343 c!  0 p344 c!
             0 p345 c!  0 p346 c!  0 p347 c!  0 p348 c!  0 p349 c!  0 p350 c!  0 p351 c!  0 p352 c!
             0 p353 c!  0 p354 c!  0 p355 c!  0 p356 c!  0 p357 c!  0 p358 c!  0 p359 c!  0 p360 c!
             0 p361 c!  0 p362 c!  0 p363 c!  0 p364 c!  0 p365 c!  0 p366 c!  0 p367 c!  0 p368 c!
             0 p369 c!  0 p370 c!  0 p371 c!  0 p372 c!  0 p373 c!  0 p374 c!  0 p375 c!  0 p376 c!
             0 p377 c!  0 p378 c!  0 p379 c!  0 p380 c!  0 p381 c!  0 p382 c!  0 p383 c!  0 p384 c!
             0 p385 c!  0 p386 c!  0 p387 c!  0 p388 c!  0 p389 c!  0 p390 c!  0 p391 c!  0 p392 c!
             0 p393 c!  0 p394 c!  0 p395 c!  0 p396 c!  0 p397 c!  0 p398 c!  0 p399 c!  0 p400 c!
             0 p401 c!  0 p402 c!  0 p403 c!  0 p404 c!  0 p405 c!  0 p406 c!  0 p407 c!  0 p408 c!
             0 p409 c!  0 p410 c!  0 p411 c!  0 p412 c!  0 p413 c!  0 p414 c!  0 p415 c!  0 p416 c!
             0 p417 c!  0 p418 c!  0 p419 c!  0 p420 c!  0 p421 c!  0 p422 c!  0 p423 c!  0 p424 c!
             0 p425 c!  0 p426 c!  0 p427 c!  0 p428 c!  0 p429 c!  0 p430 c!  0 p431 c!  0 p432 c!
             0 p433 c!  0 p434 c!  0 p435 c!  0 p436 c!  0 p437 c!  0 p438 c!  0 p439 c!  0 p440 c!
             0 p441 c!  0 p442 c!  0 p443 c!  0 p444 c!  0 p445 c!  0 p446 c!  0 p447 c!  0 p448 c!
             0 p449 c!  0 p450 c!  0 p451 c!  0 p452 c!  0 p453 c!  0 p454 c!  0 p455 c!  0 p456 c!
             0 p457 c!  0 p458 c!  0 p459 c!  0 p460 c!  0 p461 c!  0 p462 c!  0 p463 c!  0 p464 c!
             0 p465 c!  0 p466 c!  0 p467 c!  0 p468 c!  0 p469 c!  0 p470 c!  0 p471 c!  0 p472 c!
             0 p473 c!  0 p474 c!  0 p475 c!  0 p476 c!  0 p477 c!  0 p478 c!  0 p479 c!  0 p480 c!
             x1 p1   + to p1    x1 p2   + to p2    x1 p3   + to p3    x1 p4   + to p4
             x1 p5   + to p5    x1 p6   + to p6    x1 p7   + to p7    x1 p8   + to p8
             x1 p9   + to p9    x1 p10  + to p10   x1 p11  + to p11   x1 p12  + to p12
             x1 p13  + to p13   x1 p14  + to p14   x1 p15  + to p15   x1 p16  + to p16
             x1 p17  + to p17   x1 p18  + to p18   x1 p19  + to p19   x1 p20  + to p20
             x1 p21  + to p21   x1 p22  + to p22   x1 p23  + to p23   x1 p24  + to p24
             x1 p25  + to p25   x1 p26  + to p26   x1 p27  + to p27   x1 p28  + to p28
             x1 p29  + to p29   x1 p30  + to p30   x1 p31  + to p31   x1 p32  + to p32
             x1 p33  + to p33   x1 p34  + to p34   x1 p35  + to p35   x1 p36  + to p36
             x1 p37  + to p37   x1 p38  + to p38   x1 p39  + to p39   x1 p40  + to p40
             x1 p41  + to p41   x1 p42  + to p42   x1 p43  + to p43   x1 p44  + to p44
             x1 p45  + to p45   x1 p46  + to p46   x1 p47  + to p47   x1 p48  + to p48
             x1 p49  + to p49   x1 p50  + to p50   x1 p51  + to p51   x1 p52  + to p52
             x1 p53  + to p53   x1 p54  + to p54   x1 p55  + to p55   x1 p56  + to p56
             x1 p57  + to p57   x1 p58  + to p58   x1 p59  + to p59   x1 p60  + to p60
             x1 p61  + to p61   x1 p62  + to p62   x1 p63  + to p63   x1 p64  + to p64
             x1 p65  + to p65   x1 p66  + to p66   x1 p67  + to p67   x1 p68  + to p68
             x1 p69  + to p69   x1 p70  + to p70   x1 p71  + to p71   x1 p72  + to p72
             x1 p73  + to p73   x1 p74  + to p74   x1 p75  + to p75   x1 p76  + to p76
             x1 p77  + to p77   x1 p78  + to p78   x1 p79  + to p79   x1 p80  + to p80
             x1 p81  + to p81   x1 p82  + to p82   x1 p83  + to p83   x1 p84  + to p84
             x1 p85  + to p85   x1 p86  + to p86   x1 p87  + to p87   x1 p88  + to p88
             x1 p89  + to p89   x1 p90  + to p90   x1 p91  + to p91   x1 p92  + to p92
             x1 p93  + to p93   x1 p94  + to p94   x1 p95  + to p95   x1 p96  + to p96
             x1 p97  + to p97   x1 p98  + to p98   x1 p99  + to p99   x1 p100 + to p100
             x1 p101 + to p101  x1 p102 + to p102  x1 p103 + to p103  x1 p104 + to p104
             x1 p105 + to p105  x1 p106 + to p106  x1 p107 + to p107  x1 p108 + to p108
             x1 p109 + to p109  x1 p110 + to p110  x1 p111 + to p111  x1 p112 + to p112
             x1 p113 + to p113  x1 p114 + to p114  x1 p115 + to p115  x1 p116 + to p116
             x1 p117 + to p117  x1 p118 + to p118  x1 p119 + to p119  x1 p120 + to p120
             x1 p121 + to p121  x1 p122 + to p122  x1 p123 + to p123  x1 p124 + to p124
             x1 p125 + to p125  x1 p126 + to p126  x1 p127 + to p127  x1 p128 + to p128
             x1 p129 + to p129  x1 p130 + to p130  x1 p131 + to p131  x1 p132 + to p132
             x1 p133 + to p133  x1 p134 + to p134  x1 p135 + to p135  x1 p136 + to p136
             x1 p137 + to p137  x1 p138 + to p138  x1 p139 + to p139  x1 p140 + to p140
             x1 p141 + to p141  x1 p142 + to p142  x1 p143 + to p143  x1 p144 + to p144
             x1 p145 + to p145  x1 p146 + to p146  x1 p147 + to p147  x1 p148 + to p148
             x1 p149 + to p149  x1 p150 + to p150  x1 p151 + to p151  x1 p152 + to p152
             x1 p153 + to p153  x1 p154 + to p154  x1 p155 + to p155  x1 p156 + to p156
             x1 p157 + to p157  x1 p158 + to p158  x1 p159 + to p159  x1 p160 + to p160
             x1 p161 + to p161  x1 p162 + to p162  x1 p163 + to p163  x1 p164 + to p164
             x1 p165 + to p165  x1 p166 + to p166  x1 p167 + to p167  x1 p168 + to p168
             x1 p169 + to p169  x1 p170 + to p170  x1 p171 + to p171  x1 p172 + to p172
             x1 p173 + to p173  x1 p174 + to p174  x1 p175 + to p175  x1 p176 + to p176
             x1 p177 + to p177  x1 p178 + to p178  x1 p179 + to p179  x1 p180 + to p180
             x1 p181 + to p181  x1 p182 + to p182  x1 p183 + to p183  x1 p184 + to p184
             x1 p185 + to p185  x1 p186 + to p186  x1 p187 + to p187  x1 p188 + to p188
             x1 p189 + to p189  x1 p190 + to p190  x1 p191 + to p191  x1 p192 + to p192
             x1 p193 + to p193  x1 p194 + to p194  x1 p195 + to p195  x1 p196 + to p196
             x1 p197 + to p197  x1 p198 + to p198  x1 p199 + to p199  x1 p200 + to p200
             x1 p201 + to p201  x1 p202 + to p202  x1 p203 + to p203  x1 p204 + to p204
             x1 p205 + to p205  x1 p206 + to p206  x1 p207 + to p207  x1 p208 + to p208
             x1 p209 + to p209  x1 p210 + to p210  x1 p211 + to p211  x1 p212 + to p212
             x1 p213 + to p213  x1 p214 + to p214  x1 p215 + to p215  x1 p216 + to p216
             x1 p217 + to p217  x1 p218 + to p218  x1 p219 + to p219  x1 p220 + to p220
             x1 p221 + to p221  x1 p222 + to p222  x1 p223 + to p223  x1 p224 + to p224
             x1 p225 + to p225  x1 p226 + to p226  x1 p227 + to p227  x1 p228 + to p228
             x1 p229 + to p229  x1 p230 + to p230  x1 p231 + to p231  x1 p232 + to p232
             x1 p233 + to p233  x1 p234 + to p234  x1 p235 + to p235  x1 p236 + to p236
             x1 p237 + to p237  x1 p238 + to p238  x1 p239 + to p239  x1 p240 + to p240
             x1 p241 + to p241  x1 p242 + to p242  x1 p243 + to p243  x1 p244 + to p244
             x1 p245 + to p245  x1 p246 + to p246  x1 p247 + to p247  x1 p248 + to p248
             x1 p249 + to p249  x1 p250 + to p250  x1 p251 + to p251  x1 p252 + to p252
             x1 p253 + to p253  x1 p254 + to p254  x1 p255 + to p255  x1 p256 + to p256
             x1 p257 + to p257  x1 p258 + to p258  x1 p259 + to p259  x1 p260 + to p260
             x1 p261 + to p261  x1 p262 + to p262  x1 p263 + to p263  x1 p264 + to p264
             x1 p265 + to p265  x1 p266 + to p266  x1 p267 + to p267  x1 p268 + to p268
             x1 p269 + to p269  x1 p270 + to p270  x1 p271 + to p271  x1 p272 + to p272
             x1 p273 + to p273  x1 p274 + to p274  x1 p275 + to p275  x1 p276 + to p276
             x1 p277 + to p277  x1 p278 + to p278  x1 p279 + to p279  x1 p280 + to p280
             x1 p281 + to p281  x1 p282 + to p282  x1 p283 + to p283  x1 p284 + to p284
             x1 p285 + to p285  x1 p286 + to p286  x1 p287 + to p287  x1 p288 + to p288
             x1 p289 + to p289  x1 p290 + to p290  x1 p291 + to p291  x1 p292 + to p292
             x1 p293 + to p293  x1 p294 + to p294  x1 p295 + to p295  x1 p296 + to p296
             x1 p297 + to p297  x1 p298 + to p298  x1 p299 + to p299  x1 p300 + to p300
             x1 p301 + to p301  x1 p302 + to p302  x1 p303 + to p303  x1 p304 + to p304
             x1 p305 + to p305  x1 p306 + to p306  x1 p307 + to p307  x1 p308 + to p308
             x1 p309 + to p309  x1 p310 + to p310  x1 p311 + to p311  x1 p312 + to p312
             x1 p313 + to p313  x1 p314 + to p314  x1 p315 + to p315  x1 p316 + to p316
             x1 p317 + to p317  x1 p318 + to p318  x1 p319 + to p319  x1 p320 + to p320
             x1 p321 + to p321  x1 p322 + to p322  x1 p323 + to p323  x1 p324 + to p324
             x1 p325 + to p325  x1 p326 + to p326  x1 p327 + to p327  x1 p328 + to p328
             x1 p329 + to p329  x1 p330 + to p330  x1 p331 + to p331  x1 p332 + to p332
             x1 p333 + to p333  x1 p334 + to p334  x1 p335 + to p335  x1 p336 + to p336
             x1 p337 + to p337  x1 p338 + to p338  x1 p339 + to p339  x1 p340 + to p340
             x1 p341 + to p341  x1 p342 + to p342  x1 p343 + to p343  x1 p344 + to p344
             x1 p345 + to p345  x1 p346 + to p346  x1 p347 + to p347  x1 p348 + to p348
             x1 p349 + to p349  x1 p350 + to p350  x1 p351 + to p351  x1 p352 + to p352
             x1 p353 + to p353  x1 p354 + to p354  x1 p355 + to p355  x1 p356 + to p356
             x1 p357 + to p357  x1 p358 + to p358  x1 p359 + to p359  x1 p360 + to p360
             x1 p361 + to p361  x1 p362 + to p362  x1 p363 + to p363  x1 p364 + to p364
             x1 p365 + to p365  x1 p366 + to p366  x1 p367 + to p367  x1 p368 + to p368
             x1 p369 + to p369  x1 p370 + to p370  x1 p371 + to p371  x1 p372 + to p372
             x1 p373 + to p373  x1 p374 + to p374  x1 p375 + to p375  x1 p376 + to p376
             x1 p377 + to p377  x1 p378 + to p378  x1 p379 + to p379  x1 p380 + to p380
             x1 p381 + to p381  x1 p382 + to p382  x1 p383 + to p383  x1 p384 + to p384
             x1 p385 + to p385  x1 p386 + to p386  x1 p387 + to p387  x1 p388 + to p388
             x1 p389 + to p389  x1 p390 + to p390  x1 p391 + to p391  x1 p392 + to p392
             x1 p393 + to p393  x1 p394 + to p394  x1 p395 + to p395  x1 p396 + to p396
             x1 p397 + to p397  x1 p398 + to p398  x1 p399 + to p399  x1 p400 + to p400
             x1 p401 + to p401  x1 p402 + to p402  x1 p403 + to p403  x1 p404 + to p404
             x1 p405 + to p405  x1 p406 + to p406  x1 p407 + to p407  x1 p408 + to p408
             x1 p409 + to p409  x1 p410 + to p410  x1 p411 + to p411  x1 p412 + to p412
             x1 p413 + to p413  x1 p414 + to p414  x1 p415 + to p415  x1 p416 + to p416
             x1 p417 + to p417  x1 p418 + to p418  x1 p419 + to p419  x1 p420 + to p420
             x1 p421 + to p421  x1 p422 + to p422  x1 p423 + to p423  x1 p424 + to p424
             x1 p425 + to p425  x1 p426 + to p426  x1 p427 + to p427  x1 p428 + to p428
             x1 p429 + to p429  x1 p430 + to p430  x1 p431 + to p431  x1 p432 + to p432
             x1 p433 + to p433  x1 p434 + to p434  x1 p435 + to p435  x1 p436 + to p436
             x1 p437 + to p437  x1 p438 + to p438  x1 p439 + to p439  x1 p440 + to p440
             x1 p441 + to p441  x1 p442 + to p442  x1 p443 + to p443  x1 p444 + to p444
             x1 p445 + to p445  x1 p446 + to p446  x1 p447 + to p447  x1 p448 + to p448
             x1 p449 + to p449  x1 p450 + to p450  x1 p451 + to p451  x1 p452 + to p452
             x1 p453 + to p453  x1 p454 + to p454  x1 p455 + to p455  x1 p456 + to p456
             x1 p457 + to p457  x1 p458 + to p458  x1 p459 + to p459  x1 p460 + to p460
             x1 p461 + to p461  x1 p462 + to p462  x1 p463 + to p463  x1 p464 + to p464
             x1 p465 + to p465  x1 p466 + to p466  x1 p467 + to p467  x1 p468 + to p468
             x1 p469 + to p469  x1 p470 + to p470  x1 p471 + to p471  x1 p472 + to p472
             x1 p473 + to p473  x1 p474 + to p474  x1 p475 + to p475  x1 p476 + to p476
             x1 p477 + to p477  x1 p478 + to p478  x1 p479 + to p479  x1 p480 + to p480
          repeat
          p1   slndx < if 0 p1   c!   p2   slndx < if 0 p2   c!   p3   slndx < if 0 p3   c!
          p4   slndx < if 0 p4   c!   p5   slndx < if 0 p5   c!   p6   slndx < if 0 p6   c!
          p7   slndx < if 0 p7   c!   p8   slndx < if 0 p8   c!   p9   slndx < if 0 p9   c!
          p10  slndx < if 0 p10  c!   p11  slndx < if 0 p11  c!   p12  slndx < if 0 p12  c!
          p13  slndx < if 0 p13  c!   p14  slndx < if 0 p14  c!   p15  slndx < if 0 p15  c!
          p16  slndx < if 0 p16  c!   p17  slndx < if 0 p17  c!   p18  slndx < if 0 p18  c!
          p19  slndx < if 0 p19  c!   p20  slndx < if 0 p20  c!   p21  slndx < if 0 p21  c!
          p22  slndx < if 0 p22  c!   p23  slndx < if 0 p23  c!   p24  slndx < if 0 p24  c!
          p25  slndx < if 0 p25  c!   p26  slndx < if 0 p26  c!   p27  slndx < if 0 p27  c!
          p28  slndx < if 0 p28  c!   p29  slndx < if 0 p29  c!   p30  slndx < if 0 p30  c!
          p31  slndx < if 0 p31  c!   p32  slndx < if 0 p32  c!   p33  slndx < if 0 p33  c!
          p34  slndx < if 0 p34  c!   p35  slndx < if 0 p35  c!   p36  slndx < if 0 p36  c!
          p37  slndx < if 0 p37  c!   p38  slndx < if 0 p38  c!   p39  slndx < if 0 p39  c!
          p40  slndx < if 0 p40  c!   p41  slndx < if 0 p41  c!   p42  slndx < if 0 p42  c!
          p43  slndx < if 0 p43  c!   p44  slndx < if 0 p44  c!   p45  slndx < if 0 p45  c!
          p46  slndx < if 0 p46  c!   p47  slndx < if 0 p47  c!   p48  slndx < if 0 p48  c!
          p49  slndx < if 0 p49  c!   p50  slndx < if 0 p50  c!   p51  slndx < if 0 p51  c!
          p52  slndx < if 0 p52  c!   p53  slndx < if 0 p53  c!   p54  slndx < if 0 p54  c!
          p55  slndx < if 0 p55  c!   p56  slndx < if 0 p56  c!   p57  slndx < if 0 p57  c!
          p58  slndx < if 0 p58  c!   p59  slndx < if 0 p59  c!   p60  slndx < if 0 p60  c!
          p61  slndx < if 0 p61  c!   p62  slndx < if 0 p62  c!   p63  slndx < if 0 p63  c!
          p64  slndx < if 0 p64  c!   p65  slndx < if 0 p65  c!   p66  slndx < if 0 p66  c!
          p67  slndx < if 0 p67  c!   p68  slndx < if 0 p68  c!   p69  slndx < if 0 p69  c!
          p70  slndx < if 0 p70  c!   p71  slndx < if 0 p71  c!   p72  slndx < if 0 p72  c!
          p73  slndx < if 0 p73  c!   p74  slndx < if 0 p74  c!   p75  slndx < if 0 p75  c!
          p76  slndx < if 0 p76  c!   p77  slndx < if 0 p77  c!   p78  slndx < if 0 p78  c!
          p79  slndx < if 0 p79  c!   p80  slndx < if 0 p80  c!   p81  slndx < if 0 p81  c!
          p82  slndx < if 0 p82  c!   p83  slndx < if 0 p83  c!   p84  slndx < if 0 p84  c!
          p85  slndx < if 0 p85  c!   p86  slndx < if 0 p86  c!   p87  slndx < if 0 p87  c!
          p88  slndx < if 0 p88  c!   p89  slndx < if 0 p89  c!   p90  slndx < if 0 p90  c!
          p91  slndx < if 0 p91  c!   p92  slndx < if 0 p92  c!   p93  slndx < if 0 p93  c!
          p94  slndx < if 0 p94  c!   p95  slndx < if 0 p95  c!   p96  slndx < if 0 p96  c!
          p97  slndx < if 0 p97  c!   p98  slndx < if 0 p98  c!   p99  slndx < if 0 p99  c!
          p100 slndx < if 0 p100 c!   p101 slndx < if 0 p101 c!   p102 slndx < if 0 p102 c!
          p103 slndx < if 0 p103 c!   p104 slndx < if 0 p104 c!   p105 slndx < if 0 p105 c!
          p106 slndx < if 0 p106 c!   p107 slndx < if 0 p107 c!   p108 slndx < if 0 p108 c!
          p109 slndx < if 0 p109 c!   p110 slndx < if 0 p110 c!   p111 slndx < if 0 p111 c!
          p112 slndx < if 0 p112 c!   p113 slndx < if 0 p113 c!   p114 slndx < if 0 p114 c!
          p115 slndx < if 0 p115 c!   p116 slndx < if 0 p116 c!   p117 slndx < if 0 p117 c!
          p118 slndx < if 0 p118 c!   p119 slndx < if 0 p119 c!   p120 slndx < if 0 p120 c!
          p121 slndx < if 0 p121 c!   p122 slndx < if 0 p122 c!   p123 slndx < if 0 p123 c!
          p124 slndx < if 0 p124 c!   p125 slndx < if 0 p125 c!   p126 slndx < if 0 p126 c!
          p127 slndx < if 0 p127 c!   p128 slndx < if 0 p128 c!   p129 slndx < if 0 p129 c!
          p130 slndx < if 0 p130 c!   p131 slndx < if 0 p131 c!   p132 slndx < if 0 p132 c!
          p133 slndx < if 0 p133 c!   p134 slndx < if 0 p134 c!   p135 slndx < if 0 p135 c!
          p136 slndx < if 0 p136 c!   p137 slndx < if 0 p137 c!   p138 slndx < if 0 p138 c!
          p139 slndx < if 0 p139 c!   p140 slndx < if 0 p140 c!   p141 slndx < if 0 p141 c!
          p142 slndx < if 0 p142 c!   p143 slndx < if 0 p143 c!   p144 slndx < if 0 p144 c!
          p145 slndx < if 0 p145 c!   p146 slndx < if 0 p146 c!   p147 slndx < if 0 p147 c!
          p148 slndx < if 0 p148 c!   p149 slndx < if 0 p149 c!   p150 slndx < if 0 p150 c!
          p151 slndx < if 0 p151 c!   p152 slndx < if 0 p152 c!   p153 slndx < if 0 p153 c!
          p154 slndx < if 0 p154 c!   p155 slndx < if 0 p155 c!   p156 slndx < if 0 p156 c!
          p157 slndx < if 0 p157 c!   p158 slndx < if 0 p158 c!   p159 slndx < if 0 p159 c!
          p160 slndx < if 0 p160 c!   p161 slndx < if 0 p161 c!   p162 slndx < if 0 p162 c!
          p163 slndx < if 0 p163 c!   p164 slndx < if 0 p164 c!   p165 slndx < if 0 p165 c!
          p166 slndx < if 0 p166 c!   p167 slndx < if 0 p167 c!   p168 slndx < if 0 p168 c!
          p169 slndx < if 0 p169 c!   p170 slndx < if 0 p170 c!   p171 slndx < if 0 p171 c!
          p172 slndx < if 0 p172 c!   p173 slndx < if 0 p173 c!   p174 slndx < if 0 p174 c!
          p175 slndx < if 0 p175 c!   p176 slndx < if 0 p176 c!   p177 slndx < if 0 p177 c!
          p178 slndx < if 0 p178 c!   p179 slndx < if 0 p179 c!   p180 slndx < if 0 p180 c!
          p181 slndx < if 0 p181 c!   p182 slndx < if 0 p182 c!   p183 slndx < if 0 p183 c!
          p184 slndx < if 0 p184 c!   p185 slndx < if 0 p185 c!   p186 slndx < if 0 p186 c!
          p187 slndx < if 0 p187 c!   p188 slndx < if 0 p188 c!   p189 slndx < if 0 p189 c!
          p190 slndx < if 0 p190 c!   p191 slndx < if 0 p191 c!   p192 slndx < if 0 p192 c!
          p193 slndx < if 0 p193 c!   p194 slndx < if 0 p194 c!   p195 slndx < if 0 p195 c!
          p196 slndx < if 0 p196 c!   p197 slndx < if 0 p197 c!   p198 slndx < if 0 p198 c!
          p199 slndx < if 0 p199 c!   p200 slndx < if 0 p200 c!   p201 slndx < if 0 p201 c!
          p202 slndx < if 0 p202 c!   p203 slndx < if 0 p203 c!   p204 slndx < if 0 p204 c!
          p205 slndx < if 0 p205 c!   p206 slndx < if 0 p206 c!   p207 slndx < if 0 p207 c!
          p208 slndx < if 0 p208 c!   p209 slndx < if 0 p209 c!   p210 slndx < if 0 p210 c!
          p211 slndx < if 0 p211 c!   p212 slndx < if 0 p212 c!   p213 slndx < if 0 p213 c!
          p214 slndx < if 0 p214 c!   p215 slndx < if 0 p215 c!   p216 slndx < if 0 p216 c!
          p217 slndx < if 0 p217 c!   p218 slndx < if 0 p218 c!   p219 slndx < if 0 p219 c!
          p220 slndx < if 0 p220 c!   p221 slndx < if 0 p221 c!   p222 slndx < if 0 p222 c!
          p223 slndx < if 0 p223 c!   p224 slndx < if 0 p224 c!   p225 slndx < if 0 p225 c!
          p226 slndx < if 0 p226 c!   p227 slndx < if 0 p227 c!   p228 slndx < if 0 p228 c!
          p229 slndx < if 0 p229 c!   p230 slndx < if 0 p230 c!   p231 slndx < if 0 p231 c!
          p232 slndx < if 0 p232 c!   p233 slndx < if 0 p233 c!   p234 slndx < if 0 p234 c!
          p235 slndx < if 0 p235 c!   p236 slndx < if 0 p236 c!   p237 slndx < if 0 p237 c!
          p238 slndx < if 0 p238 c!   p239 slndx < if 0 p239 c!   p240 slndx < if 0 p240 c!
          p241 slndx < if 0 p241 c!   p242 slndx < if 0 p242 c!   p243 slndx < if 0 p243 c!
          p244 slndx < if 0 p244 c!   p245 slndx < if 0 p245 c!   p246 slndx < if 0 p246 c!
          p247 slndx < if 0 p247 c!   p248 slndx < if 0 p248 c!   p249 slndx < if 0 p249 c!
          p250 slndx < if 0 p250 c!   p251 slndx < if 0 p251 c!   p252 slndx < if 0 p252 c!
          p253 slndx < if 0 p253 c!   p254 slndx < if 0 p254 c!   p255 slndx < if 0 p255 c!
          p256 slndx < if 0 p256 c!   p257 slndx < if 0 p257 c!   p258 slndx < if 0 p258 c!
          p259 slndx < if 0 p259 c!   p260 slndx < if 0 p260 c!   p261 slndx < if 0 p261 c!
          p262 slndx < if 0 p262 c!   p263 slndx < if 0 p263 c!   p264 slndx < if 0 p264 c!
          p265 slndx < if 0 p265 c!   p266 slndx < if 0 p266 c!   p267 slndx < if 0 p267 c!
          p268 slndx < if 0 p268 c!   p269 slndx < if 0 p269 c!   p270 slndx < if 0 p270 c!
          p271 slndx < if 0 p271 c!   p272 slndx < if 0 p272 c!   p273 slndx < if 0 p273 c!
          p274 slndx < if 0 p274 c!   p275 slndx < if 0 p275 c!   p276 slndx < if 0 p276 c!
          p277 slndx < if 0 p277 c!   p278 slndx < if 0 p278 c!   p279 slndx < if 0 p279 c!
          p280 slndx < if 0 p280 c!   p281 slndx < if 0 p281 c!   p282 slndx < if 0 p282 c!
          p283 slndx < if 0 p283 c!   p284 slndx < if 0 p284 c!   p285 slndx < if 0 p285 c!
          p286 slndx < if 0 p286 c!   p287 slndx < if 0 p287 c!   p288 slndx < if 0 p288 c!
          p289 slndx < if 0 p289 c!   p290 slndx < if 0 p290 c!   p291 slndx < if 0 p291 c!
          p292 slndx < if 0 p292 c!   p293 slndx < if 0 p293 c!   p294 slndx < if 0 p294 c!
          p295 slndx < if 0 p295 c!   p296 slndx < if 0 p296 c!   p297 slndx < if 0 p297 c!
          p298 slndx < if 0 p298 c!   p299 slndx < if 0 p299 c!   p300 slndx < if 0 p300 c!
          p301 slndx < if 0 p301 c!   p302 slndx < if 0 p302 c!   p303 slndx < if 0 p303 c!
          p304 slndx < if 0 p304 c!   p305 slndx < if 0 p305 c!   p306 slndx < if 0 p306 c!
          p307 slndx < if 0 p307 c!   p308 slndx < if 0 p308 c!   p309 slndx < if 0 p309 c!
          p310 slndx < if 0 p310 c!   p311 slndx < if 0 p311 c!   p312 slndx < if 0 p312 c!
          p313 slndx < if 0 p313 c!   p314 slndx < if 0 p314 c!   p315 slndx < if 0 p315 c!
          p316 slndx < if 0 p316 c!   p317 slndx < if 0 p317 c!   p318 slndx < if 0 p318 c!
          p319 slndx < if 0 p319 c!   p320 slndx < if 0 p320 c!   p321 slndx < if 0 p321 c!
          p322 slndx < if 0 p322 c!   p323 slndx < if 0 p323 c!   p324 slndx < if 0 p324 c!
          p325 slndx < if 0 p325 c!   p326 slndx < if 0 p326 c!   p327 slndx < if 0 p327 c!
          p328 slndx < if 0 p328 c!   p329 slndx < if 0 p329 c!   p330 slndx < if 0 p330 c!
          p331 slndx < if 0 p331 c!   p332 slndx < if 0 p332 c!   p333 slndx < if 0 p333 c!
          p334 slndx < if 0 p334 c!   p335 slndx < if 0 p335 c!   p336 slndx < if 0 p336 c!
          p337 slndx < if 0 p337 c!   p338 slndx < if 0 p338 c!   p339 slndx < if 0 p339 c!
          p340 slndx < if 0 p340 c!   p341 slndx < if 0 p341 c!   p342 slndx < if 0 p342 c!
          p343 slndx < if 0 p343 c!   p344 slndx < if 0 p344 c!   p345 slndx < if 0 p345 c!
          p346 slndx < if 0 p346 c!   p347 slndx < if 0 p347 c!   p348 slndx < if 0 p348 c!
          p349 slndx < if 0 p349 c!   p350 slndx < if 0 p350 c!   p351 slndx < if 0 p351 c!
          p352 slndx < if 0 p352 c!   p353 slndx < if 0 p353 c!   p354 slndx < if 0 p354 c!
          p355 slndx < if 0 p355 c!   p356 slndx < if 0 p356 c!   p357 slndx < if 0 p357 c!
          p358 slndx < if 0 p358 c!   p359 slndx < if 0 p359 c!   p360 slndx < if 0 p360 c!
          p361 slndx < if 0 p361 c!   p362 slndx < if 0 p362 c!   p363 slndx < if 0 p363 c!
          p364 slndx < if 0 p364 c!   p365 slndx < if 0 p365 c!   p366 slndx < if 0 p366 c!
          p367 slndx < if 0 p367 c!   p368 slndx < if 0 p368 c!   p369 slndx < if 0 p369 c!
          p370 slndx < if 0 p370 c!   p371 slndx < if 0 p371 c!   p372 slndx < if 0 p372 c!
          p373 slndx < if 0 p373 c!   p374 slndx < if 0 p374 c!   p375 slndx < if 0 p375 c!
          p376 slndx < if 0 p376 c!   p377 slndx < if 0 p377 c!   p378 slndx < if 0 p378 c!
          p379 slndx < if 0 p379 c!   p380 slndx < if 0 p380 c!   p381 slndx < if 0 p381 c!
          p382 slndx < if 0 p382 c!   p383 slndx < if 0 p383 c!   p384 slndx < if 0 p384 c!
          p385 slndx < if 0 p385 c!   p386 slndx < if 0 p386 c!   p387 slndx < if 0 p387 c!
          p388 slndx < if 0 p388 c!   p389 slndx < if 0 p389 c!   p390 slndx < if 0 p390 c!
          p391 slndx < if 0 p391 c!   p392 slndx < if 0 p392 c!   p393 slndx < if 0 p393 c!
          p394 slndx < if 0 p394 c!   p395 slndx < if 0 p395 c!   p396 slndx < if 0 p396 c!
          p397 slndx < if 0 p397 c!   p398 slndx < if 0 p398 c!   p399 slndx < if 0 p399 c!
          p400 slndx < if 0 p400 c!   p401 slndx < if 0 p401 c!   p402 slndx < if 0 p402 c!
          p403 slndx < if 0 p403 c!   p404 slndx < if 0 p404 c!   p405 slndx < if 0 p405 c!
          p406 slndx < if 0 p406 c!   p407 slndx < if 0 p407 c!   p408 slndx < if 0 p408 c!
          p409 slndx < if 0 p409 c!   p410 slndx < if 0 p410 c!   p411 slndx < if 0 p411 c!
          p412 slndx < if 0 p412 c!   p413 slndx < if 0 p413 c!   p414 slndx < if 0 p414 c!
          p415 slndx < if 0 p415 c!   p416 slndx < if 0 p416 c!   p417 slndx < if 0 p417 c!
          p418 slndx < if 0 p418 c!   p419 slndx < if 0 p419 c!   p420 slndx < if 0 p420 c!
          p421 slndx < if 0 p421 c!   p422 slndx < if 0 p422 c!   p423 slndx < if 0 p423 c!
          p424 slndx < if 0 p424 c!   p425 slndx < if 0 p425 c!   p426 slndx < if 0 p426 c!
          p427 slndx < if 0 p427 c!   p428 slndx < if 0 p428 c!   p429 slndx < if 0 p429 c!
          p430 slndx < if 0 p430 c!   p431 slndx < if 0 p431 c!   p432 slndx < if 0 p432 c!
          p433 slndx < if 0 p433 c!   p434 slndx < if 0 p434 c!   p435 slndx < if 0 p435 c!
          p436 slndx < if 0 p436 c!   p437 slndx < if 0 p437 c!   p438 slndx < if 0 p438 c!
          p439 slndx < if 0 p439 c!   p440 slndx < if 0 p440 c!   p441 slndx < if 0 p441 c!
          p442 slndx < if 0 p442 c!   p443 slndx < if 0 p443 c!   p444 slndx < if 0 p444 c!
          p445 slndx < if 0 p445 c!   p446 slndx < if 0 p446 c!   p447 slndx < if 0 p447 c!
          p448 slndx < if 0 p448 c!   p449 slndx < if 0 p449 c!   p450 slndx < if 0 p450 c!
          p451 slndx < if 0 p451 c!   p452 slndx < if 0 p452 c!   p453 slndx < if 0 p453 c!
          p454 slndx < if 0 p454 c!   p455 slndx < if 0 p455 c!   p456 slndx < if 0 p456 c!
          p457 slndx < if 0 p457 c!   p458 slndx < if 0 p458 c!   p459 slndx < if 0 p459 c!
          p460 slndx < if 0 p460 c!   p461 slndx < if 0 p461 c!   p462 slndx < if 0 p462 c!
          p463 slndx < if 0 p463 c!   p464 slndx < if 0 p464 c!   p465 slndx < if 0 p465 c!
          p466 slndx < if 0 p466 c!   p467 slndx < if 0 p467 c!   p468 slndx < if 0 p468 c!
          p469 slndx < if 0 p469 c!   p470 slndx < if 0 p470 c!   p471 slndx < if 0 p471 c!
          p472 slndx < if 0 p472 c!   p473 slndx < if 0 p473 c!   p474 slndx < if 0 p474 c!
          p475 slndx < if 0 p475 c!   p476 slndx < if 0 p476 c!   p477 slndx < if 0 p477 c!
          p478 slndx < if 0 p478 c!   p479 slndx < if 0 p479 c!   then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
          then then then then then then then then then then then then then then
       then
   loop
;

   0 value q1  0 value q2  0 value x2  0 value n1  0 value n2

: primz? ( N - ?)  \ deterministic primality tester
      abs dup to num
      \ return true  if n is 2, 3, or 5
      dup >r 2 = r@ 3 = or r@ 5 = or if r> drop true exit then

      \ return false if n == 1 OR n is even
      r@ 1 = r@ 1 and 0= or if r> drop false exit then

      \ return false if n > 5 AND ( n mod 6 != [1,5] OR n mod 5 = 0)
      r@ 5 mod 0=  r@ 6 mod dup 1 = swap 5 = or invert or r@ 5 > and
      if r> drop false exit then

      7 to n1  11 to n2
      r> sqrt 1+              \ sqrt(N)
      begin n1 over < while   \ do while  n1 <= sqrt N
	 \ pi = 5*i,   xi = 6*i,    qi = 7*i
	 \ p1 = 5*n1;  x1 = p1+n1;  q1 = x1+n1
	 \ p2 = 5*n2;  x2 = p2+n2;  q2 = x2+n2
	 \ non-prime if any (n-p1)%x1,(n-q1)%x1,(n-p2)%x2,(n-q2)%x2 are 0
         n1 dup 5 * dup to p1 over + dup to x1 + to q1
         num p1 - x1 mod 0=   num q1 - x1 mod 0= or if drop false exit then
         n2 dup 5 * dup to p2 over + dup to x2 + to q2
         num p2 - x2 mod 0=   num q2 - x2 mod 0= or if drop false exit then
         6 n1 + to n1   6 n2 + to n2
      repeat
      drop true
;

: prime?  primz? if ." true" else ." false" then ;

True [IF]  \ Set to True to use for gforth
\ Timing word to count seconds for gforth
: SECS TIME&DATE  2DROP DROP  60 * + 60 * + ;

: BENCHMARKS
  cr ." For N = " num . ." times in secs for these SoZ prime generators"
  cr ." SoZP11 " 0 sieve lndx erase  secs num SoZP11 secs swap - .
  cr ." SoZP7  " 0 sieve lndx erase  secs num SoZP7  secs swap - .
  cr ." SoZP5  " 0 sieve lndx erase  secs num SoZP5  secs swap - .
  cr ." SoZP60 " 0 sieve lndx erase  secs num SoZP60 secs swap - .
  cr ." SoZP3  " 0 sieve lndx erase  secs num SoZP3  secs swap - .
  cr ." SoE    " secs num SoE secs swap - .
;
[THEN]
