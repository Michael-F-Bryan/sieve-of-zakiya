/*
 This C++ source file will compile to an executable program to
 find the nth prime. It's foundation is the Sieve of Zakiya, and it
 performs the Segmented Sieve of Zakiya (SSoZ) to find primes <= N.
 This version is based on the P5 Strictly Prime (SP) Prime Generator.

 Prime Genrators have the form:  mod*k + ri; ri -> {1,r1..mod-1}
 The residues ri are integers coprime to mod, i.e. gcd(ri,mod) = 1
 For P5, mod = 2*3*5 = 30 and the number of residues are
 rescnt = (2-1)(3-1)(5-1) = 8, which are {1,7,11,13,17,19,23,29}.

 On Linux use -O compiler flag to compile for optimum speed:

 $ g++ -O nthprimessozp5cpp.cpp -o nthprimessozp5cpp

 Then run executable: $ ./nthprimessozp5cpp <cr>, and enter nth value.
 Input and output values are 64-bit.

 Related code, papers, and tutorials, are downloadable here:

 http://www.4shared.com/folder/TcMrUvTB/_online.html

 Use of this code is free subject to acknowledgment of copyright.
 Copyright (c) 2014 Jabari Zakiya -- jzakiya at gmail dot com
 Version Date: 2014/07/14

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

char pbits[256] = {
 8,7,7,6,7,6,6,5,7,6,6,5,6,5,5,4,7,6,6,5,6,5,5,4,6,5,5,4,5,4,4,3
,7,6,6,5,6,5,5,4,6,5,5,4,5,4,4,3,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2
,7,6,6,5,6,5,5,4,6,5,5,4,5,4,4,3,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2
,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2,5,4,4,3,4,3,3,2,4,3,3,2,3,2,2,1
,7,6,6,5,6,5,5,4,6,5,5,4,5,4,4,3,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2
,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2,5,4,4,3,4,3,3,2,4,3,3,2,3,2,2,1
,6,5,5,4,5,4,4,3,5,4,4,3,4,3,3,2,5,4,4,3,4,3,3,2,4,3,3,2,3,2,2,1
,5,4,4,3,4,3,3,2,4,3,3,2,3,2,2,1,4,3,3,2,3,2,2,1,3,2,2,1,2,1,1,0
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
  for (uint b = 0; b < Kn; ++b)       // for every byte in the segment
    seg[b] = 0;                       // set every byte bit to prime (0)
  for (uint r = 0; r < rescnt; ++r) { // for each ith (of 8) residues for P5
    uint biti  = 1 << r;              // set the ith residue track bit mask
    uint row = r*pcnt;                // set address to ith row in next[]
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
  // Extract and print the primes in each segment:
  // recommend piping output to less: ./ssozpxxx | less
  // can then use Home, End, Pgup, Pgdn keys to see primes
  for (uint k = 0; k < Kn; ++k)       // for Kn residues groups|bytes
    for (uint r = 0; r < 8; ++r)      // for each residue|bit in a byte
      if (!(seg[k] & (1 << r)))       // if it's '0' it's a prime
        cout << " " << mod*(Ki+k) + residues[r+1];
  cout << "\n"; 
}

main()
{
  cout << "Enter nth prime desired: ";
  uint64 n;                        
  cin >> n;
  
  if (n < 4) {
    if (n == 3) cout << n << "rd prime = " << n+2 << endl;
    if (n == 2) cout << n << "nd prime = " << n+1 << endl;
    if (n == 1) cout << n << "st prime = " << n+1 << endl;
    return 0;
  }

  // approximate value of (>) nth prime to find primes up to
  uint64 val = n*(log(n) + 0.74*log(log(n)))+3;
  cout << "approximate nth prime is " << val << endl;

  B = 262144;                      // L2D_CACHE_SIZE 256*1024 bytes, I5 cpu
  KB = B;                          // number of segment resgroups
  seg = new char[B];               // create segment array of B bytesize

  //cout << "segment has "<< B << " bytes and " << KB << " residues groups\n";

  int r;
  uint64 k, modk;

  uint64 num = val-1 | 1;          // if val even subtract 1
  k=num/mod; modk = mod*k; r=1;    // kth residue group, base num value
  while (num >= modk+residues[r]) r++; // find last pc position <= num
  uint64 maxpcs =k*rescnt + r-1;   // maximum number of prime candidates
  uint64 Kmax = (num-2)/mod + 1;   // maximum number of resgroups for val

  //cout <<"prime candidates = "<< maxpcs <<"; resgroups = "<< Kmax << endl;

  uint sqrtN = (uint) sqrt((double) num);

  sozP7(sqrtN);                    // get pcnt and primes <= sqrt(nun)

  //cout << "create next["<< rescnt << "x" << pcnt << "] array\n";

  next = new uint64[rescnt*pcnt];  // create the next[] array
  nextinit();                      // load with first nonprimes resgroups

  primecnt  = 3;                   // 2,3,5 the P5 excluded primes count
  uint   Kn = KB;                  // set sieve resgroups size to segment size
  uint64 Ki = 0;                   // starting resgroup index for each segment

  //cout << "perform segmented SoZ\n";

  for (; Ki < Kmax; Ki += KB) {    // for KB size resgroup slices up to Kmax
    if (Kmax-Ki < KB) Kn=Kmax-Ki;  // set sieve resgroups size for last segment
    segsieve(Kn);                  // sieve primes for current segment
    if (primecnt >= n) break;      // stop in segment that contains nth prime
  }

  //cout << "find prime " << n << ", current primecount is " << primecnt << endl;
  
  uint64 nthprime = 0;             // get last prime and primecnt <= val                        
  modk = mod*(Ki-1+Kn);            // mod for last resgroup in last segment
  uint b = Kn-1;                   // num bytes to last resgroup in segment
  r = rescnt-1;                    // from last restrack in resgroup
  while (true) {                   // repeat until nth prime determined
    if (!(seg[b] & 1 << r)) {      // if restrack in byte[i] is prime
      if (primecnt == n) {         // if this is the nth prime
        nthprime = modk+residues[r+1]; // store its value
        break;                     // exit loop
      }
      primecnt--;                  // else reduce total primecnt
    }                              // reduce restrack, setup next resgroup
    r--; if (r < 0) {r=rescnt-1; modk -= mod; b--;} // if necessary
  }

  cout << n << "th prime = " << nthprime << endl;

  delete[] next; delete[] primes;
  return 0;
}