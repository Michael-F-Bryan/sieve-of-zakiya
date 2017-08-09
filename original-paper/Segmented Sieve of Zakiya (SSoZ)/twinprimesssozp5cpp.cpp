/*
 This C++ source file is a single threaded implementation to perform an
 extremely fast Segmented Sieve of Zakiya (SSoZ) to find Twin Primes <= N.
 It is based on the P5 Strictly Prime (SP) Prime Generator.

 Prime Genrators have the form:  mod*k + ri; ri -> {1,r1..mod-1}
 The residues ri are integers coprime to mod, i.e. gcd(ri,mod) = 1
 For P5, mod = 2*3*5 = 30 and the number of residues are
 rescnt = (2-1)(3-1)(5-1) = 8, which are {1,7,11,13,17,19,23,29}.
 For just Twin Primes, use generator: Pn = 30*k + {11,13,17,19,29,31}

 Adjust segment byte length parameter B (usually L1|l2 cache size)
 for optimum operational performance for cpu being used.

 On Linux use -O compiler flag to compile for optimum speed:

 $ g++ -O twinprimesssozp5cpp.cpp -o twinprimesssozp5cpp

 Then run executable: $ ./twinprimesssozp5cpp <cr>, and enter value for N.
 As coded, input values cover the range: 13 -- 2^64-1

 Related code, papers, and tutorials, are downloadable here:

 http://www.4shared.com/folder/TcMrUvTB/_online.html

 Use of this code is free subject to acknowledgment of copyright.
 Copyright (c) 2014 Jabari Zakiya -- jzakiya at gmail dot com
 Version Date: 2014/07/23

 This code is provided under the terms of the
 GNU General Public License Version 3, GPLv3, or greater.
 License copy/terms are here:  http://www.gnu.org/licenses/
*/

#include <cmath>
#include <vector>
#include <cstdlib>
#include <iostream>
#include <stdint.h>

using namespace std;

typedef uint64_t uint64;

// Convert segment byte values into number of twin primes in byte
// For P5 r1=7 and r6=23 aren't used, so byte-mask is b_00100001
// A byte can identify 3 tp, '00xxxxxx', 'xxx00xxx', 'xxxxx00x'
// Thus, convert byte values 0-255 into table of twin primes
// Ex: 33=b_00100001 -> 3; 35=b_00100011 -> 2; 43=b_00101011 -> 1
char pbits[256] = {
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,3,0,2,0,2,0,2,0,2,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,2,0,1,0,1,0,1
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,2,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,2,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,2,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0
};

char residues[9] = {1, 7, 11, 13, 17, 19, 23, 29, 31};

// Global parameters
uint B;                // segment byte size
uint KB;               // segment resgroup size
uint mod = 30;         // prime generator mod value
uint rescnt = 8;       // number of residues for prime generator
uint pcnt;             // number of primes from r1..sqrt(N) 
uint64 primecnt;       // number of primes <= N
uint64 *next;          // pointer to array of primes first nonprimes
uint *primes;          // pointer to array of primes <= sqrt(N)
char *seg;             // pointer to seg[B] segment byte array

void sozP7(uint val)
{
  int md = 210;
  int rscnt = 48;  
  int res[49] = {
     1, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67
  , 71, 73, 79, 83, 89, 97,101,103,107,109,113,121,127,131,137,139
  ,143,149,151,157,163,167,169,173,179,181,187,191,193,197,199,209,211};

  int posn[210];
  for (int i=0; i < rscnt; i++) posn[res[i]] = i-1;

  uint i, r, modk;

  uint num = val-1 | 1;            // if value even number then subtract 1
  uint k=num/md; modk = md*k; r=1; // kth residue group, base num value
  while (num >= modk+res[r]) r++;  // find last pc position <= num
  uint maxprms = k*rscnt + r - 1;  // maximum number of prime candidates
  vector<char> prms(maxprms);      // array of prime candidates set False

  uint sqrtN = (uint) sqrt((double) num);
  modk=0; r=0; k=0;

  // sieve to eliminate nonprimes from small primes prms array
  for (i=0; i < maxprms; i++){
    r++; if (r > rscnt) {r=1; modk += md; k++;}
    if (prms[i]) continue;
    uint res_r = res[r];
    uint prime = modk + res_r;
    if (prime > sqrtN) break;
    uint prmstep = prime * rscnt;
    for (int ri=1; ri < (rscnt+1); ri++){
      uint prod = res_r * res[ri];   // residues cross-product
      uint nonprm = (k*(prime + res[ri]) + prod/md)*rscnt;
      nonprm += posn[prod % md];     // residue track value
      for (; nonprm < maxprms; nonprm += prmstep) prms[nonprm]=true;
    }
  }
  // the prms array now has all the positions for primes r1..N
  // approximate primes array size; make greater than N/ln(N)
  uint max = (double) ((num/log( (double) num) * 1.13)+8);
  primes = new uint[max];          // allocate mem at runtime
  pcnt = 1;
  primes[0] = 7;                   // r1 prime for P5
  // extract prime numbers and count from prms into prims array
  modk=0; r=0;
  for (i=0; i < maxprms; i++){
    r++; if (r > rscnt) {r=1; modk +=md;}
    if (!prms[i]) primes[pcnt++] = modk + res[r];
  }
}

void nextinit()
{ 
  char pos[30] = {
    0,7,0,0,0,0,0,0,0,0,0,1,0,2,0,0,0,3,0,4,0,0,0,5,0,0,0,0,0,6};

  char k_row[64] = {
    4, 3, 7, 6, 2, 1, 5, 0
  , 3, 7, 5, 0, 6, 2, 4, 1
  , 7, 5, 4, 1, 0, 6, 3, 2
  , 6, 0, 1, 4, 5, 7, 2, 3
  , 2, 6, 0, 5, 7, 3, 1, 4
  , 1, 2, 6, 7, 3, 4, 0, 5
  , 5, 4, 3, 2, 1, 0, 7, 6
  , 0, 1, 2, 3, 4, 5, 6, 7
  };

  char k_col[64] = {
    1, 2, 2, 3, 4, 5, 6, 7
  , 2, 3, 4, 6, 6, 8,10,11
  , 2, 4, 5, 7, 8, 9,12,13
  , 3, 6, 7, 9,10,12,16,17
  , 4, 6, 8,10,11,14,18,19
  , 5, 8, 9,12,14,17,22,23
  , 6,10,12,16,18,22,27,29
  , 7,11,13,17,19,23,29,31
  };

  // for each prime store resgroup on each restrack for prime*(modk+ri)
  for (uint j = 0; j < pcnt; ++j) {  // for the pcnt primes r1..sqrt(N)
    uint prime = primes[j];          // for each prime
    uint64 k  = (prime-2)/mod;       // find the resgroup it's in 
    uint row = pos[prime % mod] * rescnt; // row start for k_row|col tables
    for (uint r=0; r < rescnt; ++r)  // for each residue value
      next[k_row[row+r]*pcnt + j] = k*(prime+residues[r+1]) + k_col[row+r];
  }
}

void segsieve(uint Kn)
{                                     // for Kn resgroups in segment
  for (uint b = 0; b < Kn; ++b)       // set every byte bit to prime (0)
    seg[b] = 0x21;                    // except restracks for ri = 7 and 23
  for (uint r = 1; r < rescnt; ++r) { // start at restrack for ri = 11, r = 1
    if (r == 0x20) continue;          // skip sieve for ri = 23, r = 0x20
    uint biti = 1 << r;               // set the ith residue track bit mask
    uint row  = r*pcnt;               // set address to ith row in next[]
    for (uint j = 0; j < pcnt; ++j) { // for each prime <= sqrt(N) for restrack
      if (next[row+j] < Kn) {         // if 1st mult resgroup index <= seg size
	uint k = next[row+j];         // get its resgroup value
        uint prime = primes[j];       // get the prime
        for (; k < Kn; k += prime)    // for each primenth byte < segment size
	  seg[k] |= biti;             // set ith residue in byte as nonprime
        next[row+j] = k - Kn;         // 1st resgroup in next eligible segment
      }
      else next[row+j] -= Kn;         // if 1st mult resgroup index > seg size
    }
  }
                                      // count the primes in the segment
  for (uint s = 0; s < Kn; ++s)       // for the Kn resgroup bytes
    primecnt += pbits[seg[s] & 0xff]; // count the '0' bits as primes  
}
  
void printprms(uint Kn, uint64 Ki)
{
  // Extract and print the lower twin primes in each segment:
  // recommend piping output to less: ./ssozpxxx | less
  // can then use Home, End, Pgup, Pgdn keys to see primes
  uint64 modk = mod*Ki;           // create base modk for this segment
  for (uint k = 0; k < Kn; ++k) { // for Kn residues groups|bytes
    if ((~seg[k] & 0x06) == 0x06) // if restrack for ri = 11 and 13 prime
      cout << " " << modk + 11;   // print lower value of twin prime
    if ((~seg[k] & 0x18) == 0x18) // if restrack for ri = 17 and 19 prime
      cout << " " << modk + 17;   // print lower value of twin prime
    if ((~seg[k] & 0xc0) == 0xc0) // if restrack for ri = 29 and 31 prime
      cout << " " << modk + 29;   // print lower value of twin prime
    modk += mod;                  // create modk for next resgroup|byte 
  }
  cout << "\n"; 
}

main()
{
  cout << "Enter number value: ";
  uint64 val;                      // find primes <= val (13..2^64-1)
  cin >> val;

  B = 262144;                      // L2D_CACHE_SIZE 256*1024 bytes, I5 cpu
  KB = B;                          // number of segment resgroups
  seg = new char[B];               // create segment array of B bytesize

  cout << "segment has "<< B << " bytes and " << KB << " residues groups\n";

  int r;
  uint64 k, modk;

  uint64 num = val-1 | 1;          // if val even subtract 1
  k=num/mod; modk = mod*k; r=1;    // kth residue group, base num value
  while (num >= modk+residues[r]) r++; // find last pc position <= num
  uint64 maxpcs =k*rescnt + r-1;   // maximum number of prime candidates
  uint64 Kmax = (num-2)/mod + 1;   // maximum number of resgroups for val

  cout <<"prime candidates = "<< maxpcs <<"; resgroups = "<< Kmax << endl;

  uint sqrtN = (uint) sqrt((double) num);

  sozP7(sqrtN);                    // get pcnt and primes <= sqrt(nun)

  cout << "create next["<< rescnt << "x" << pcnt << "] array\n";

  next = new uint64[rescnt*pcnt];  // create the next[] array
  nextinit();                      // load with first nonprimes resgroups

  primecnt  = 2;                   // for first two twin primes (3,5)|(5,7)
  uint   Kn = KB;                  // set sieve resgroups size to segment size
  uint64 Ki = 0;                   // starting resgroup index for each segment

  cout << "perform Twin Prime segmented SoZ\n";

  for (; Ki < Kmax; Ki += KB) {    // for KB size resgroup slices up to Kmax
    if (Kmax-Ki < KB) Kn=Kmax-Ki;  // set sieve resgroups size for last segment
    segsieve(Kn);                  // sieve twin primes for current segment
    //printprms(Kn,Ki);            // print twin primes for the segment
  }

  uint64 lprime=0;                 // get last twin prime and primecnt <= val                        
  modk = mod*(Kmax-1);             // mod for last resgroup in last segment
  uint b = Kn-1;                   // num bytes to last resgroup in segment
  while (true) {                   // repeat until last twin prime determined
    if ((~seg[b] & 0xc0) == 0xc0) {// if restrack for both ri = 29 and 31 prime
      lprime = modk + 31;          // determine larger twin prime value
      if (lprime <= num) break;    // if <= num exit from loop with lprime
      primecnt--;                  // else reduce total primecnt
    }
    if ((~seg[b] & 0x18) == 0x18) {// if restrack for both ri = 17 and 19 prime
      lprime = modk + 19;          // determine larger twin prime value
      if (lprime <= num) break;    // if <= num exit from loop with lprime
      primecnt--;                  // else reduce total primecnt
    }
    if ((~seg[b] & 0x06) == 0x06) {// if restrack for both ri = 11 and 13 prime
      lprime = modk + 13;          // determine largest twin prime value
      if (lprime <= num) break;    // if <= num exit from loop with lprime
      primecnt--;                  // else reduce total primecnt
    }                              // reduce modk and bytesize for next resgroup
    modk -= mod; b--;              // if twin prime <= num not in this resgroup
  }

  cout << "last segment = " << Kn << " resgroups; segment iterations = " << Ki/KB << "\n";
  cout << "last twin prime (of " << primecnt << ") is " << lprime-1 << "+/-1\n";

  delete[] next; delete[] primes;
  return 0;
}