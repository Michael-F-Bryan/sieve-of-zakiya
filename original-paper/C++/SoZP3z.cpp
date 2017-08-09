/*
 This source file can be used to compile an executable program to
 perform the Sieve of Zakiya (SoZ) for Strictly Prime (SP)
 generator P3. On Linux to compile do: $ g++ SoZP3z.cpp -o sozp3
   
 Then run executable: $ ./sozp3 <cr>, then enter positve integer N.

 Related code, papers, and tutorials, are downloadable here:

 http://www.4shared.com/folder/TcMrUvTB/_online.html

 Use of this code is free subject to acknowledgment of copyright.
 Copyright (c) 2010/11 Jabari Zakiya -- jzakiya at gmail dot com
 This code is provided under the terms of the
 GNU General Public License Version 3, GPLv3.
 License copy/terms are here:  http://www.gnu.org/licenses/
*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include <sys/time.h>

#define USECS 1000000.0  // per sec
double currtime()
{
   struct timeval tv;
   gettimeofday(&tv, NULL);
   return( (double) (tv.tv_sec*USECS + tv.tv_usec) );
}

int main()
{
      // init modulus, rescnt, and residues array for P3 prime generator

#define np 2    // np is initial primes count
#define gen 3   // output designator

      // all prime candidates > 3 are of form 6*k+(1,5)
	
      unsigned int i,k,n,r,num,val,maxprms,*primes;
      unsigned long long prmstep, product, prime, nonprmpos;
      char *sp, *prms, string[24];
      int modk;
      
      printf( "Enter number N : ");
      sp = gets(string);
      sscanf(string, "%u", &val);
      
      printf("Initialize variables and arrays. \n");
      double start_time = currtime();  // begin timing total process      

      num = val-1 | 1;                 // if value even number then subtract 1
      k=num/6; modk = k*6;             // kth residue group, base num value
      r=0; if (num == modk+5){r=1;}    // find last pc position <= num
      maxprms = k*2 + r;               // maximum number of prime candidates
      prms = (char *) malloc(sizeof(char) * maxprms); // array of prime candidates
      for (i=0; i < maxprms; i++) prms[i]=1;   // set all prime candidates to True

      unsigned int sqrtpos = sqrt(num)/3;      // closest index of sqrt(N) in prms
      modk=-6; r=7;

      // sieve to eliminate nonprimes from prms
      printf("Perform sieve on prime candidates. \n");
      double soz_start = currtime();   // begin timing sieve process
	
      for (i=0; i < sqrtpos; i++){     // do upto index of pc <= sqrtN
         r ^= 2; if (r == 5) modk += 6;
         if (!prms[i]) continue;
         prime = modk + r;
         prmstep = prime*2;
         nonprmpos = (prime*(modk+5))/3 - 1;
         while (nonprmpos < maxprms){ prms[nonprmpos]=0; nonprmpos += prmstep;}
	 nonprmpos = (prime*(modk+7))/3 - 1;
         while (nonprmpos < maxprms){ prms[nonprmpos]=0; nonprmpos += prmstep;}
      }
      
      double soz_end = currtime(); // end timing sieve process

      // the prms array now has all the positions for primes 5..N
      // approximate primes array size; make greater than N/ln(N)      
      double max = (double) ((num/log( (double) num) * 1.13)+8);
      primes = (unsigned int *) malloc(sizeof(unsigned int) * (unsigned int) max);
           
      printf("Allocated size for primes = %d\n", (unsigned int) max);

      primes[0]=n=np; // primes[0] holds number of primes upto N
      primes[1]=2; primes[2]=3;	

      if (num < 5) {n=1+num/2;}
      else {
        // extract prime numbers and count from prms into primes array
        modk=-6; r=7; n++;  // n is next prime count past initial primes
        for (i=0; i < maxprms; i++){
           r ^= 2; if (r == 5) modk += 6;
           if (prms[i]) {primes[n] = modk + r; n++;}
        }
      primes[0]=n--;  // store primes count
      }

      double end_time = currtime(); // end timing primes extraction and routine
      
      printf("Init    time (P%u) = %.3lf\n", gen, (soz_start-start_time)/USECS);
      printf("Sieve   time (P%u) = %.3lf\n", gen, (soz_end-soz_start)/USECS);
      printf("Primes  time (P%u) = %.3lf\n", gen, (end_time-soz_end)/USECS);
      printf("Elapsed time (P%u) = %.3lf\n", gen, (end_time-start_time)/USECS);
      printf("Last prime (of %u) = %u\n", n, primes[n]);
      return (primes[n]);
}
