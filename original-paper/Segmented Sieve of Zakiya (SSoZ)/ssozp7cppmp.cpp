/*
 This C++ source file will compile to an executable program to
 perform the Segmented Sieve of Zakiya (SSoZ) to find primes <= N.
 It is based on the P7 Strictly Prime (SP) Prime Generator.

 Prime Genrators have the form:  mod*k + ri; ri -> {1,r1..mod-1}
 The residues ri are integers coprime to mod, i.e. gcd(ri,mod) = 1
 For P7, mod = 2*3*5*7 = 210 and the number of residues are
 rescnt = (2-1)(3-1)(5-1)(7-1) = 48, which are {1,11,13,17..209}.

 Adjust segment byte length parameter B (usually L1|l2 cache size)
 for optimum operational performance for cpu being used.

 It uses OpenMp to perfom parallel operation of loops in some subsection.

 On Linux to compile using OpenMp switches do:

 $ g++ -O -fopenmp ssozp7cppmp.cpp -o ssozp7cppmp

 Then run executable: $ ./ssozp7cppmp <cr>, and enter value for N.
 As coded, input values cover the range: 11 -- 2^64-1

 Related code, papers, and tutorials, are downloadable here:

 http://www.4shared.com/folder/TcMrUvTB/_online.html

 Use of this code is free subject to acknowledgment of copyright.
 Copyright (c) 2014 Jabari Zakiya -- jzakiya at gmail dot com
 Version Date: 2014/05/22

 This code is provided under the terms of the
 GNU General Public License Version 3, GPLv3, or greater.
 License copy/terms are here:  http://www.gnu.org/licenses/
*/

#include <cmath>
#include <vector>
#include <cstdlib>
#include <iostream>
#include <stdint.h>
#include <omp.h>

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

int residues[49] = {
   1, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67
, 71, 73, 79, 83, 89, 97,101,103,107,109,113,121,127,131,137,139
,143,149,151,157,163,167,169,173,179,181,187,191,193,197,199,209,211
};

// Global parameters
uint B;                // segment byte size
uint KB;               // segment resgroup size
uint mod = 210;        // prime generator mod value
uint bprg = 6;         // number of bytes per resgroups
uint rescnt = 48;      // number of residues for prime generator
uint pcnt;             // number of primes from r1..sqrt(N) 
uint64 primecnt;       // number of primes <= N
uint64 *next;          // pointer to array of primes first nonprimes
uint *primes;          // pointer to array of primes <= sqrt(N)
char *seg;             // pointer to seg[B] segment byte array

void sozP7(uint val)
{
  int posn[210];
  #pragma omp parallel for
  for (int i=0; i < rescnt; i++) posn[residues[i]] = i-1;

  uint i, k, r, modk;

  uint num = val-1 | 1;           // if value even number then subtract 1
  k=num/mod; modk = mod*k; r=1;   // kth residue group, base num value
  while (num >= modk+residues[r]) r++; // find last pc position <= num
  uint maxprms = k*rescnt + r-1;  // maximum number of prime candidates
  vector<char> prms(maxprms);     // array of prime candidates set False

  uint sqrtN = (uint) sqrt((double) num);
  modk=0; r=0; k=0;

  // sieve to eliminate nonprimes from small primes prms array
  for (i=0; i < maxprms; i++){
    r++; if (r > rescnt) {r=1; modk += mod; k++;}
    if (prms[i]) continue;
    uint res_r = residues[r];
    uint prime = modk + res_r;
    if (prime > sqrtN) break;
    uint prmstep = prime * rescnt;
    
    uint product,nonprm;
    #pragma omp parallel for private(product,nonprm)
    for (int ri=1; ri < (rescnt+1); ri++){
      uint product = res_r * residues[ri]; // residues cross-product
      uint nonprm = rescnt*(k*(prime+residues[ri])+product/mod) + posn[product % mod];
      //nonprm += posn[product % mod];       // residue track value
      for (; nonprm < maxprms; nonprm += prmstep) prms[nonprm]=true;
    }
  }  
  // the prms array now has all the positions for primes r1..N
  // approximate primes array size; make greater than N/ln(N)
  uint max = (double) ((num/log( (double) num) * 1.13)+8);
  primes = new uint[max]; // allocate mem at runtime
  pcnt = 0;
  // extract prime numbers and count from prms into prims array
  modk=0; r=0;
  for (i=0; i < maxprms; i++){
    r++; if (r > rescnt) {r=1; modk +=mod;}
    if (!prms[i]) primes[pcnt++] = modk + residues[r];
  }
}

void nextinit()
{
  int pos[mod];
  uint i,j,r,row,prod,prime;  uint64 k;
  #pragma omp parallel
  {
  #pragma omp for
  for (int i=1; i < rescnt; ++i) pos[residues[i]] = i-1;
  pos[1] = rescnt-1;

  // for each prime store resgroup on each restrack for prime*(modk+ri)
  //#pragma omp for private(j,k,r,row,prime,prod)
  for (uint j = 0; j < pcnt; ++j) {   // for the pcnt primes r1..sqrt(N)
    uint prime = primes[j];           // for each prime
    uint64 k = (prime-2)/mod;         // find the resgroup it's in
    uint r = (prime-2)%mod + 2;       // its base residue value
    #pragma omp for private(row,prod)
    for (uint i=1; i <= rescnt; ++i){ // for each residue value
      uint prod = r * residues[i];    // create residues cross-product r*ri
      uint row  = pos[prod % mod];    // find residue track its on
      next[row*pcnt + j] = k*(prime + residues[i]) + (prod-2)/mod;
    }
  }
  }
}

void ressieve(uint bi,uint Kn)
{
  for (uint r = 0; r < 8; ++r) {     // for each residue track in byte[i]
    uint biti = 1 << r;              // residue track bit mask in byte[i]
    uint row = (bi*8 + r) * pcnt;    // set address to ith row in next[]
    for (uint j=0; j < pcnt; ++j){   // for each prime <= sqrt(N) for restrack 
      if (next[row+j] < Kn) {        // if 1st mult resgroup index <= seg size
	uint k = next[row+j];        // get its resgroup value
	uint ki = k*bprg + bi;       // convert it to a byte address in seg[]
	uint prime = primes[j];      // get prime, convert it to number of
	uint prmstep = prime * bprg; // bytes to next primenth resgroup byte
	for (; k < Kn; k += prime){  // for each primeth resgroup in segment
	  seg[ki] |= biti;           // set ith residue in byte as nonprime
          ki += prmstep;             // create next nonprime byte address
	}
        next[row+j] = k - Kn;        // 1st resgroup in next eligible segment
      }
      else next[row+j] -= Kn;        // if 1st mult resgroup index > seg size
    }
  }
}

void segsieve(uint Kn)
{
  #pragma omp parallel
  {
  #pragma omp for
  for (uint b=0; b < Kn*bprg; b +=2){ // for all the bytes in a segment
    seg[b] = 0;   seg[b+1] = 0;}      // set every byte bit to prime (0)

  #pragma omp for
  for (uint bi = 0; bi < bprg; ++bi)  // for each residues group byte[i]
    ressieve(bi,Kn);                  // mark prime multiples on restracks

  #pragma omp for reduction(+:primecnt) // count the primes in the segment
  for (uint s = 0; s < Kn*bprg; ++s)  // for the Kn resgroup bytes
    primecnt += pbits[seg[s] & 0xff]; // count the '0' bits as primese
  }
}

void printprms(uint Kn, uint64 Ki)
{
  // Extract and print the primes in each segment:
  // recommend piping output to less: ./ssozxxx | less
  // can then use Home, End, Pgup, Pgdn keys to see primes
  for (uint k = 0; k < Kn; ++k)              // for Kn residues groups
    for (uint r = 0; r < rescnt; ++r)        // for each residue bit
      if (!(seg[k*bprg + r/8] & (1 << r%8))) // if its prime '0', show value
          cout << mod*(Ki+k) + residues[r+1] << " ";
  cout << "\n";
}

main()
{
  cout << "Enter number value: ";
  uint64 val;                    // find primes <= val (11..2^64-1)
  cin >> val;

  B = 262144;                    // L2D_CACHE_SIZE 256*1024 bytes, I5 cpu
  bprg = (rescnt-1)/8 + 1;       // number of bytes per resgroups
  KB = B/bprg;                   // number of segment resgroups
  B  = KB*bprg;                  // number of bytes per segment
  seg = new char[B];             // create segment array of B bytesize

  cout << "segment has "<< B << " bytes and " << KB << " residues groups\n";

  int i, r;
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

  primecnt  = 4;                   // 2,3,5,7 the P7 excluded primes count
  uint   Kn = KB;                  // set sieve resgroups size to segment size
  uint64 Ki = 0;                   // starting resgroup index for each segment

  cout << "perform segmented SoZ\n";

  for (; Ki < Kmax; Ki += KB) {    // for KB size resgroup slices up to Kmax
    if (Kmax-Ki < KB) Kn=Kmax-Ki;  // set sieve resgroups size for last segment
    segsieve(Kn);                  // sieve primes for current segment
    //printprms(Kn,Ki);            // print primes for the segment (optional)
  }

  uint64 lprime=0;                 // get last prime and primecnt <= val                        
  modk = mod*(Ki-KB+Kn-1);         // mod for last resgroup in last segment
  uint b = (Kn-1)*bprg;            // num bytes to last resgroup in segment
  r = rescnt-1;                    // from last restrack in resgroup
  while (true) {                   // repeat until last prime determined
    if (!(seg[b + r/8] & 1 << (r&7))) { // if restrack in byte[i] is prime
      lprime = modk+residues[r+1]; // determine the prime value
      if (lprime <= num) break;    // if <= num exit from loop with lprime
      primecnt--;                  // else reduce total primecnt
    }                              // reduce restrack, setup next resgroup
    r--; if (r < 0) {r=rescnt-1; modk -= mod; b -= bprg;} // if necessary
  }

  cout << "last segment = " << Kn << " resgroups; segment iterations = " << Ki/KB << "\n";
  cout << "last prime (of " << primecnt << ") is " << lprime << endl;

  delete[] next; delete[] primes;
  return 0;
}