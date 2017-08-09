# -*- coding: utf-8 -*-
import psyco; psyco.full()
from math import sqrt, ceil

'''
Copyright 2009 by zerovolt.com
This code is free for non-commercial purposes, in which case you can just leave this comment as a credit for my work.
If you need this code for commercial purposes, please contact me by sending an email to: info [at] zerovolt [dot] com.
http://zerovolt.com/?p=88#more-88
'''
# python v. 2.6
 
from math import ceil, sqrt
 
# small primes array
__smallp = ( 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997)
 
def sievewheel30(N):
    ''' Returns a list of primes <= N using wheel criterion 2*3*5 = 30 '''

    wheel = (2, 3, 5)
    const = 30
    if N < 2:
        return []
    if N <= const:
        pos = 0
        while __smallp[pos] <= N:
            pos += 1
        return list(__smallp[:pos])
    # make the offsets list
    offsets = (7, 11, 13, 17, 19, 23, 29, 1)
    # prepare the list
    p = [2, 3, 5]
    dim = 2 + N // const
    tk1  = [True] * dim
    tk7  = [True] * dim
    tk11 = [True] * dim
    tk13 = [True] * dim
    tk17 = [True] * dim
    tk19 = [True] * dim
    tk23 = [True] * dim
    tk29 = [True] * dim
    tk1[0] = False
    # help dictionary d
    # d[a , b] = c  ==> if I want to find the smallest useful multiple of (30*pos)+a
    # on tkc, then I need the index given by the product of [(30*pos)+a][(30*pos)+b]
    # in general. If b < a, I need [(30*pos)+a][(30*(pos+1))+b]
    d = {}
    for x in offsets:
        for y in offsets:
            res = (x*y) % const
            d[(x, res)] = y
            #if res in offsets:
            #    d[(x, res)] = y
    # another help dictionary: gives tkx calling tmptk[x]
    tmptk = {1:tk1, 7:tk7, 11:tk11, 13:tk13, 17:tk17, 19:tk19, 23:tk23, 29:tk29}
    pos, prime, lastadded, stop = 0, 0, 0, int(ceil(sqrt(N)))
    # inner functions definition
    def del_mult(tk, start, step):
        for k in xrange(start, len(tk), step):
            tk[k] = False
    # end of inner functions definition
    cpos = const * pos
    while prime < stop:
        # 30k + 7
        if tk7[pos]:
            prime = cpos + 7
            p.append(prime)
            lastadded = 7
            for off in offsets:
                tmp = d[(7, off)]
                start = (pos + prime) if off == 7 else (prime * (const * (pos + 1 if tmp < 7 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 11
        if tk11[pos]:
            prime = cpos + 11
            p.append(prime)
            lastadded = 11
            for off in offsets:
                tmp = d[(11, off)]
                start = (pos + prime) if off == 11 else (prime * (const * (pos + 1 if tmp < 11 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 13
        if tk13[pos]:
            prime = cpos + 13
            p.append(prime)
            lastadded = 13
            for off in offsets:
                tmp = d[(13, off)]
                start = (pos + prime) if off == 13 else (prime * (const * (pos + 1 if tmp < 13 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 17
        if tk17[pos]:
            prime = cpos + 17
            p.append(prime)
            lastadded = 17
            for off in offsets:
                tmp = d[(17, off)]
                start = (pos + prime) if off == 17 else (prime * (const * (pos + 1 if tmp < 17 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 19
        if tk19[pos]:
            prime = cpos + 19
            p.append(prime)
            lastadded = 19
            for off in offsets:
                tmp = d[(19, off)]
                start = (pos + prime) if off == 19 else (prime * (const * (pos + 1 if tmp < 19 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 23
        if tk23[pos]:
            prime = cpos + 23
            p.append(prime)
            lastadded = 23
            for off in offsets:
                tmp = d[(23, off)]
                start = (pos + prime) if off == 23 else (prime * (const * (pos + 1 if tmp < 23 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # 30k + 29
        if tk29[pos]:
            prime = cpos + 29
            p.append(prime)
            lastadded = 29
            for off in offsets:
                tmp = d[(29, off)]
                start = (pos + prime) if off == 29 else (prime * (const * (pos + 1 if tmp < 29 else 0) + tmp) )//const
                del_mult(tmptk[off], start, prime)
        # now we go back to top tk1, so we need to increase pos by 1
        pos += 1
        cpos = const * pos
        # 30k + 1
        if tk1[pos]:
            prime = cpos + 1
            p.append(prime)
            lastadded = 1
            for off in offsets:
                tmp = d[(1, off)]
                start = (pos + prime) if off == 1 else (prime * (const * pos + tmp) )//const
                del_mult(tmptk[off], start, prime)
    # time to add remaining primes
    # if lastadded == 1, remove last element and start adding them from tk1
    # this way we don't need an "if" within the last while
    if lastadded == 1:
        p.pop()
    # now complete for every other possible prime
    while pos < len(tk1):
        cpos = const * pos
        if tk1[pos]:  p.append(cpos + 1)
        if tk7[pos]:  p.append(cpos + 7)
        if tk11[pos]: p.append(cpos + 11)
        if tk13[pos]: p.append(cpos + 13)
        if tk17[pos]: p.append(cpos + 17)
        if tk19[pos]: p.append(cpos + 19)
        if tk23[pos]: p.append(cpos + 23)
        if tk29[pos]: p.append(cpos + 29)
        pos += 1
    # remove exceeding if present    
    while p[-1] > N: p.pop()
    # return p list
    return p

'''
    pos = len(p) - 1
    while p[pos] > N:
        pos -= 1
    if pos < len(p) - 1:
        del p[pos+1:]
'''

'''
This code performs the Sieve of Zakiya (SoZ) with a segmented memory model
that mimics a wheel sieve.  I had tried this before but had an inefficient
architecture.  After (finally) studying wheel sieves, I realized how to do
the algorithm efficiently, which is reflected in these new implementations.

All the sozP(3,5,7,11) versions initialize the primes candidates array prms
as an array of maxprms 'true' values, that represents all the possilbe candidate
values each generator would produce. The sieve then marks as 'nil' (false) all
the nonprimes e.g. prms ends up with just the 'true' positions representing the
primes. These positions are converted at the end into their prime values.

All the sozP(..)a versions., with the 'a' suffix, fill the prms array with the
actual values first, and prms then ends up with the values in the positions.

The first versions use the least aomout of memory and benchmark to be somewhat
faster than the 'a' versions.

The sieve process can also be done as follow, which was a bit slower, in Ruby.

      # sieve to eliminate nonprimes from prms
      limit = Math.sqrt(num).to_i
      x,r,i=0,1,0
      prime = prms[0]  # first residue prime
      while limit > prime
         m = prime*rescnt  # position inc for prime multiples in prms
         residues[1..-1].each do |ri|
           product = prime*(x+ri)
           break if product > num
           # compute product position index in prms
           qq,rr = product.divmod mod
           nonprmpos = qq*rescnt + pos[rr]
           while nonprmpos < maxprms; prms[nonprmpos]=nil; nonprmpos += m end
         end
         # go to next position/value in prms array
         i +=1; if r < rescnt; r +=1 else r=1; x += mod end
         while !prms[i]; i +=1; if r < rescnt; r +=1 else r=1; x += mod end end
         prime = x + residues[r]
      end

In sozP5b I push the primes into the primes array as I find/use them in the sieve,
to reduce the number I have push at the end, but this is a bit slower too.

To see how/why this works, look at Tables 1 & 2 in my paper "The Sieve of Zakiya."
Table 1 shows how the prime candidates are generated, which are the values in prms.
Table 2 shows how the nonprimes are computed.

So, for sozP5, the first prime is 7, and product = prime*(x+ri) = 7*7 = 49.
This is the first spot in the diagonal in Table 2.

The prime increment m (prime*rescnt) is used to eliminate all the multiples of prime
in prms by just step through prms m positions. Where to start in prms is determined by
qq,rr = divmod(product, mod); nonprmpos = qq*rescnt + pos[rr]

So, from Table 2, the first nonprime is 7*7 = 49, which is in positions 13|prms[12].
Starting from 49 in Table 1, each 7th position in that row is a eliminated, etc.
For prime = 11, 11*11 = 121 is prms[31]; every 11th positions in that row is nonprime.
Do until prime > sqrt(N).

This is the simplest, most memory efficient, general wheellike algorithm I've seen.

Inlduded at top is wheelsieve using (what I termed) sozP5, I found doing research.
The performance differences between 3,1,1, 2.6.4 (without psyco) and 2.5.2 (w/psyco)
is really interesting, and doesn't mimic Ruby perfomance characteristics.
I modified code a couple of places to make it more efficient. Original code commented.

Jabari Zakiya

'''

def SoZP5(val):
    # all prime candidates > 5 are of form 30*k+(1,7,11,13,17,19,23,29)
    residues = [1,7,11,13,17,19,23,29,31]   

    num = val-1 | 1              # if val even number then subtract 1
    mod=30; rescnt=8             # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True
    
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int(ceil(sqrt(num)))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 7..N
    primes = [2,3,5]
    if num < 7: return primes[:1+num//2]
    modk=r=0
    for prime in prms:
       r += 1
       if r > rescnt: r = 1; modk += mod
       if prime: primes.append(modk+residues[r])
    return primes

def SoZP5a(val):
    # all prime candidates > 5 are of form 30*k+(1,7,11,13,17,19,23,29)
    residues = [1,7,11,13,17,19,23,29,31]
    
    num = val-1 | 1              # if val even number then subtract 1
    mod=30; rescnt=8             # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True
    primes = [2,3,5]
    
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int(ceil(sqrt(num)))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        primes.append(prime)
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 7..N
    if num < 7: return primes[:1+num//2]
    n = (modk//mod)*rescnt + r - 1
    for i in xrange(n,maxprms,1):
       if prms[i]: primes.append(modk+residues[r])
       r += 1
       if r > rescnt: r = 1; modk += mod
    return primes

def SoZP7(val):
    # all prime candidates > 7 are of form 210*k+(1,res[11:209])
    residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]

    num = val-1 | 1              # if val even number then subtract 1
    mod=210; rescnt=48           # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True

    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int(ceil(sqrt(val)))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 11..N
    primes = [2,3,5,7]
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes
    modk=r=0
    for prime in prms:
       r += 1
       if r > rescnt: r = 1; modk += mod
       if prime: primes.append(modk+residues[r])
    return primes

def SoZP7a(val):
    # all prime candidates > 7 are of form 210*k+(1,res[11:209])
    residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]

    num = val-1 | 1              # if val even number then subtract 1
    mod=210; rescnt=48           # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True
    primes = [2,3,5,7]    
 
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int(ceil(sqrt(val)))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        primes.append(prime)
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 11..N
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes
    n = (modk//mod)*rescnt + r - 1
    for i in xrange(n,maxprms,1):
       if prms[i]: primes.append(modk+residues[r])
       r += 1
       if r > rescnt: r = 1; modk += mod
    return primes

def SoZP11(val):
    # all prime canidates > 11 are of form 2310*k+(1,res[13:2309])
    residues = [1,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,
        97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,169,173,
        179,181,191,193,197,199,211,221,223,227,229,233,239,241,247,251,257,
        263,269,271,277,281,283,289,293,299,307,311,313,317,323,331,337,347,
        349,353,359,361,367,373,377,379,383,389,391,397,401,403,409,419,421,
        431,433,437,439,443,449,457,461,463,467,479,481,487,491,493,499,503,
        509,521,523,527,529,533,541,547,551,557,559,563,569,571,577,587,589,
        593,599,601,607,611,613,617,619,629,631,641,643,647,653,659,661,667,
        673,677,683,689,691,697,701,703,709,713,719,727,731,733,739,743,751,
        757,761,767,769,773,779,787,793,797,799,809,811,817,821,823,827,829,
        839,841,851,853,857,859,863,871,877,881,883,887,893,899,901,907,911,
        919,923,929,937,941,943,947,949,953,961,967,971,977,983,989,991,997,
        1003,1007,1009,1013,1019,1021,1027,1031,1033,1037,1039,1049,1051,1061,
        1063,1069,1073,1079,1081,1087,1091,1093,1097,1103,1109,1117,1121,1123,
        1129,1139,1147,1151,1153,1157,1159,1163,1171,1181,1187,1189,1193,1201,
        1207,1213,1217,1219,1223,1229,1231,1237,1241,1247,1249,1259,1261,1271,
        1273,1277,1279,1283,1289,1291,1297,1301,1303,1307,1313,1319,1321,1327,
        1333,1339,1343,1349,1357,1361,1363,1367,1369,1373,1381,1387,1391,1399,
        1403,1409,1411,1417,1423,1427,1429,1433,1439,1447,1451,1453,1457,1459,
        1469,1471,1481,1483,1487,1489,1493,1499,1501,1511,1513,1517,1523,1531,
        1537,1541,1543,1549,1553,1559,1567,1571,1577,1579,1583,1591,1597,1601,
        1607,1609,1613,1619,1621,1627,1633,1637,1643,1649,1651,1657,1663,1667,
        1669,1679,1681,1691,1693,1697,1699,1703,1709,1711,1717,1721,1723,1733,
        1739,1741,1747,1751,1753,1759,1763,1769,1777,1781,1783,1787,1789,1801,
        1807,1811,1817,1819,1823,1829,1831,1843,1847,1849,1853,1861,1867,1871,
        1873,1877,1879,1889,1891,1901,1907,1909,1913,1919,1921,1927,1931,1933,
        1937,1943,1949,1951,1957,1961,1963,1973,1979,1987,1993,1997,1999,2003,
        2011,2017,2021,2027,2029,2033,2039,2041,2047,2053,2059,2063,2069,2071,
        2077,2081,2083,2087,2089,2099,2111,2113,2117,2119,2129,2131,2137,2141,
        2143,2147,2153,2159,2161,2171,2173,2179,2183,2197,2201,2203,2207,2209,
        2213,2221,2227,2231,2237,2239,2243,2249,2251,2257,2263,2267,2269,2273,
        2279,2281,2287,2291,2293,2297,2309,2311]

    num = val-1 | 1              # if val even number then subtract 1
    mod=2310; rescnt=480         # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True

    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int((ceil(sqrt(val))))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 13..N
    primes = [2,3,5,7,11]
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes[:4]
    if num < 13: return primes[:5]
    modk=r=0
    for prime in prms:
       r += 1
       if r > rescnt: r = 1; modk += mod
       if prime: primes.append(modk+residues[r])
    return primes

def SoZP11a(val):
    # all prime canidates > 11 are of form 2310*k+(1,res[13:2309])
    residues = [1,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,
        97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,169,173,
        179,181,191,193,197,199,211,221,223,227,229,233,239,241,247,251,257,
        263,269,271,277,281,283,289,293,299,307,311,313,317,323,331,337,347,
        349,353,359,361,367,373,377,379,383,389,391,397,401,403,409,419,421,
        431,433,437,439,443,449,457,461,463,467,479,481,487,491,493,499,503,
        509,521,523,527,529,533,541,547,551,557,559,563,569,571,577,587,589,
        593,599,601,607,611,613,617,619,629,631,641,643,647,653,659,661,667,
        673,677,683,689,691,697,701,703,709,713,719,727,731,733,739,743,751,
        757,761,767,769,773,779,787,793,797,799,809,811,817,821,823,827,829,
        839,841,851,853,857,859,863,871,877,881,883,887,893,899,901,907,911,
        919,923,929,937,941,943,947,949,953,961,967,971,977,983,989,991,997,
        1003,1007,1009,1013,1019,1021,1027,1031,1033,1037,1039,1049,1051,1061,
        1063,1069,1073,1079,1081,1087,1091,1093,1097,1103,1109,1117,1121,1123,
        1129,1139,1147,1151,1153,1157,1159,1163,1171,1181,1187,1189,1193,1201,
        1207,1213,1217,1219,1223,1229,1231,1237,1241,1247,1249,1259,1261,1271,
        1273,1277,1279,1283,1289,1291,1297,1301,1303,1307,1313,1319,1321,1327,
        1333,1339,1343,1349,1357,1361,1363,1367,1369,1373,1381,1387,1391,1399,
        1403,1409,1411,1417,1423,1427,1429,1433,1439,1447,1451,1453,1457,1459,
        1469,1471,1481,1483,1487,1489,1493,1499,1501,1511,1513,1517,1523,1531,
        1537,1541,1543,1549,1553,1559,1567,1571,1577,1579,1583,1591,1597,1601,
        1607,1609,1613,1619,1621,1627,1633,1637,1643,1649,1651,1657,1663,1667,
        1669,1679,1681,1691,1693,1697,1699,1703,1709,1711,1717,1721,1723,1733,
        1739,1741,1747,1751,1753,1759,1763,1769,1777,1781,1783,1787,1789,1801,
        1807,1811,1817,1819,1823,1829,1831,1843,1847,1849,1853,1861,1867,1871,
        1873,1877,1879,1889,1891,1901,1907,1909,1913,1919,1921,1927,1931,1933,
        1937,1943,1949,1951,1957,1961,1963,1973,1979,1987,1993,1997,1999,2003,
        2011,2017,2021,2027,2029,2033,2039,2041,2047,2053,2059,2063,2069,2071,
        2077,2081,2083,2087,2089,2099,2111,2113,2117,2119,2129,2131,2137,2141,
        2143,2147,2153,2159,2161,2171,2173,2179,2183,2197,2201,2203,2207,2209,
        2213,2221,2227,2231,2237,2239,2243,2249,2251,2257,2263,2267,2269,2273,
        2279,2281,2287,2291,2293,2297,2309,2311]

    num = val-1 | 1              # if val even number then subtract 1
    mod=2310; rescnt=480         # modulus value; number of residues
    k=num/mod; modk = mod*k; r=1 # kth residue group, base num value
    while num >= modk+residues[r]: r +=1  # find last pc position <= num
    maxprms = k*rescnt + r-1     # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True
    primes = [2,3,5,7,11]

    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    sqrtN = int((ceil(sqrt(val))))
    modk=r=0
    for prm in prms:
        r += 1
        if r > rescnt: r = 1; modk += mod
        if not prm: continue
        prime = modk + residues[r]
        if prime > sqrtN: break
        primes.append(prime)
        prmstep = prime*rescnt
        for ri in residues[1:]:
           product = prime*(modk+ri)
           # compute product position index in prms
           k,rr  = divmod(product,mod)
           nonprmpos = k*rescnt + pos[rr]
           for nprm in xrange(nonprmpos,maxprms,prmstep): prms[nprm] = False
    # the prms array now has all the positions for primes 13..N
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes[:4]
    if num < 13: return primes[:5]
    n = (modk//mod)*rescnt + r - 1
    for i in xrange(n,maxprms,1):
       if prms[i]: primes.append(modk+residues[r])
       r += 1
       if r > rescnt: r = 1; modk += mod
    return primes

if __name__ == '__main__':
    import time

    #for i in range(100000007, 100000008, 2):  # my test
    for i in range(5, 30000007, 1000000):
    #for i in range(100000007, 100000008, 2):
        print i,

        a = time.time()
        wheel = sievewheel30(i)
        print time.time() -a,

        a = time.time()
        soz5 = SoZP5(i)
        print time.time() -a,

        a = time.time()
        soz5a = SoZP5a(i)
        print time.time() -a,

        a = time.time()
        soz7 = SoZP7(i)
        print time.time() -a,

        a = time.time()
        soz7a = SoZP7a(i)
        print time.time() -a,

        a = time.time()
        soz11 = SoZP11(i)
        print time.time() -a,

        a = time.time()
        soz11a = SoZP11a(i)
        print time.time() -a

        assert  wheel == soz11a #== soz5a == soz7 == soz7a == soz11 == soz11a