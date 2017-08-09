# The original python code for the Sieve of Atkin (SoA)
# and Sieve of Eratosthenes (SoE) was presented here:
# http://krenzel.info/static/atkin.py
# It has been subsequently cosmetically modified.
# I then added versions of P3 & P5 for the Sieve of Zakiya (SoZ).
# George Sakkis subsequently further modified this code here:
# http://codepad.org/C2nQ8syr
# He explained the modifications here:
# http://groups.google.com/group/comp.lang.python/browse_thread/thread/acb3349e84a39f26/0d6a3a84b4372ebf?lnk=gst&q=Ultimate+Prime+Sieve#0d6a3a84b4372ebf
# Using this code, I added more efficient/optimized versions
# of P3 & P5, along with handcoded versions of P7 & P11.
# This is the code presented herein.
#
# Read my paper 'Ultimate Prime Sieve -- Sieve of Zakiya (SoZ)'
# to understand the math and concepts behind the code. See here:
# http://www.4shared.com/folder/TcMrUvTB/_online.html
#
# This code verified on an Intel P4, 2.8Ghz, 1 GB laptop,
# with PCLinuxOS, and Python 2.4.3, 2.5.2 and 2.6.0.
# 
# Jabari Zakiya - 2008/7/19
#
# Updated: 2008/11/03 -- architectural & coding improvements to
#                        all SoZ generators. Renamed SoZ generators.
# Updated: 2008/11/17 -- fixed code that made SoZ generators run
#                        slower than SoA using psyco. SoZs now faster
#                        than SoA with and without psyco.
#                        Nested IF statements used for optimum efficiency.
# Updated: 2011/08/27 -- Made hash code for SozP5a same as rest, its much faster now
# 
# Code much faster on Intel I5, 2.3GHz, 6 GB laptop, PCLinuxOS 2011.6

import psyco; psyco.full()
from math import sqrt, ceil

def sieveOfAtkin(end):
    end += 1
    lng = (end-1)>>1   # originally: lng = (end/2)-1+(end&1)
    sieve = [False]*(lng + 1)
    x_max, x2 = int(sqrt((end-1)/4.0)), 0
    for xd in xrange(4, 8*x_max + 2, 8):
        x2 += xd
        y_max = int(sqrt(end-x2))
        n = x2 + y_max*y_max
        n_diff = (y_max << 1) - 1
        if n&1 == 0: n -= n_diff; n_diff -= 2
        for d in xrange((n_diff - 1) << 1, -1, -8):
            m = n%12
            if (m == 1 or m == 5):
                m = n >> 1; sieve[m] = not sieve[m]
            n -= d

    x_max, x2 = int(sqrt((end-1)/3.0)), 0
    for xd in xrange(3, 6*x_max + 2, 6):
        x2 += xd
        y_max = int(sqrt(end-x2))
        n = x2 + y_max*y_max
        n_diff = (y_max << 1) - 1
        if n&1 == 0: n -= n_diff; n_diff -= 2
        for d in xrange((n_diff - 1) << 1, -1, -8):
            if (n%12 == 7):
                m = n >> 1; sieve[m] = not sieve[m]
            n -= d

    x_max, y_min, x2, xd = int((2 + sqrt(4-8*(1-end)))/4), -1, 0, 3
    for x in xrange(1, x_max + 1):
        x2 += xd
        xd += 6
        if x2 >= end: y_min = (((int(ceil(sqrt(x2-end)))- 1) << 1)- 2) << 1
        n = ((x*x + x) << 1) - 1
        n_diff = (((x-1) << 1) - 2) << 1
        for d in xrange(n_diff, y_min, -8):
            if (n%12 == 11):
                m = n >> 1; sieve[m] = not sieve[m]
            n += d

    primes = [2,3]; append= primes.append
    if end <= 3 : return primes[:max(0,end-2)]
    sqrtN  = int(sqrt(end)) + 1
    for n in xrange(2, sqrtN >> 1):
        if sieve[n]:
            i = (n << 1) +1;  j=i*i;  append(i)
            for k in xrange(j, end, 2*j):
                sieve[k>>1] = False
    if sqrtN&1 == 0: sqrtN += 1
    primes.extend([i for i in xrange(sqrtN, end, 2) if sieve[i >> 1]])
    return primes

def sieveOfErat(end):
    if end < 2: return []
    #The array doesn't need to include even numbers
    lng = (end-1)>>1   # originally: lng = (end/2)-1+(end&1)
    # Create array and assume all numbers in array are prime
    sieve = [True]*(lng+1)
    # In the following code, you're going to see some funky
    # bit shifting and stuff, this is just transforming i and j
    # so that they represent the proper elements in the array
    # Only go up to square root of the end
    for i in xrange(int(sqrt(end)) >> 1):
        # Skip numbers that aren't marked as prime
        if not sieve[i]: continue
        # Unmark all multiples of i, starting at i**2
        for j in xrange( (i*(i + 3) << 1) + 3, lng, (i << 1) + 3):
            sieve[j] = False
    # Don't forget 2!
    primes = [2]
    # Gather all the primes into a list, leaving out the composite numbers
    primes.extend([(i << 1) + 3 for i in xrange(lng) if sieve[i]])
    return primes

def SoZP3(val):
    # all prime candidates > 3 are of form  6*k+(1,5)
    # initialize sieve array with only these candidate values
    # where sieve contains the odd integers representatives
    # convert integers to array indices/vals by i = (n-3)>>1
    n1, n2 = -1, 1; lndx = (val-1)>>1
    sieve = [False]*(lndx+3)
    while  n2 < lndx:
        n1 += 3;   n2 += 3;  sieve[n1] = sieve[n2] = True
    # now initialize sieve with (odd) primes < 6; in this case 3 and 5
    sieve[0]= sieve[1]= True
    n = 0;  rescnt = 2
    for i in xrange( 1, ((int(sqrt(val))-3)>>1)+1, 1) :
        if not sieve[i]:  continue
        # j  i  5i  7i  6i    p1=5i,  p2=7i,  k=6i
        # 5->1  11  16  15
        j = (i<<1)+3; p1 = (j<<1)+i; p2 = p1+j; k = p2-i
	x = k*(n>>1); n += 1  # x = k*(n/rescnt)
	p1 += x;  p2 += x
        while p2 < lndx:
           sieve[p1] = sieve[p2] = False;  p1 += k;  p2 += k
        if p1 < lndx:  sieve[p1] = False
    if val < 3 : return [2]
    primes = [(i<<1)+3 for i in xrange(1, lndx, 1)  if sieve[i]]
    primes[0:0] = [2,3]
    return primes

def SoZP5(val):
    # all prime candidates > 5 are of form  30*k+(1,7,11,13,17,19,23,29)
    # initialize sieve array with only these candidate values
    # where sieve contains the odd integers representatives
    # convert integers to array indices/vals by  i = (n-3)>>1
    n1, n2, n3, n4, n5, n6, n7, n8 = -1, 2, 4, 5, 7, 8, 10, 13
    lndx = (val-1)>>1; sieve = [False]*(lndx+15)
    while n8 < lndx:
        n1 += 15;   n2 += 15;   n3 += 15;   n4 += 15
        n5 += 15;   n6 += 15;   n7 += 15;   n8 += 15
        sieve[n1] = sieve[n2] = sieve[n3] = sieve[n4] = \
        sieve[n5] = sieve[n6] = sieve[n7] = sieve[n8] = True
    # now initialize sieve with (odd) primes < 30
    sieve[0] = sieve[1] = sieve[2]  = sieve[4]  = sieve[5] = \
    sieve[7] = sieve[8] = sieve[10] = sieve[13] = True
    n = 0;  rescnt = 8
    for i in xrange(2, ((int(sqrt(val))-3)>>1)+1, 1):
        if not sieve[i]:  continue
        # p1=7*i, p2=11*i, p3=13*i --- p6=23*i, p7=29*i, p8=31*i,  k=30*i
        # j  i  7i  11i  13i  17i  19i  23i  29i  31i  30i
        # 7->2  23   37   44   58   65   79  100  107  105	
        j = (i<<1)+3; j2 = j<<1; p1 = j2+j+i; p2 = p1+j2; p3 = p2+j; p4 = p3+j2
        p5 = p4+j; p6 = p5+j2; p7 = p6+j2+j;  p8 = p7+j;  k = p8-i
	x = k*(n>>3);  n += 1  # x = k*(n/rescnt)
        p1 += x; p2 += x; p3 += x; p4 += x; p5 += x; p6 += x; p7 += x; p8 += x	
        while p8 < lndx:
           sieve[p1] = sieve[p2] = sieve[p3] = sieve[p4] = \
           sieve[p5] = sieve[p6] = sieve[p7] = sieve[p8] = False
           p1 += k; p2 += k; p3 += k; p4 += k; p5 += k; p6 += k; p7 += k; p8 += k
        if p1 < lndx:
	 sieve[p1] = False
         if p2 < lndx:
          sieve[p2] = False
          if p3 < lndx:
	   sieve[p3] = False
           if p4 < lndx:
	    sieve[p4] = False
            if p5 < lndx:
	     sieve[p5] = False
             if p6 < lndx:
	      sieve[p6] = False
              if p7 < lndx: sieve[p7] = False
    if val < 3 : return [2]
    if val < 5 : return [2,3]
    primes = [(i<<1)+3 for i in xrange(2, lndx, 1)  if sieve[i]]
    primes[0:0] = [2,3,5]
    return primes

def SoZP7(val):
    # all prime candidates > 7 are of form  210*k+(1,11,13,17,19,23,29,31,37
    # 41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,121,127,131
    # 137,139,143,149,151,157,163,167,169,173,179,181,187,191,193,197,199,209)
    # initialize sieve array with only these candidate values
    # where sieve contains the odd integers representatives
    # convert integers to array indices/vals by i = (n-3)>>1
    n1, n2, n3, n4, n5, n6, n7, n8, n9, n10 = -1, 4, 5, 7, 8, 10, 13, 14, 17, 19
    n11, n12, n13, n14, n15, n16, n17, n18 = 20, 22, 25, 28, 29, 32, 34, 35
    n19, n20, n21, n22, n23, n24, n25, n26 = 38, 40, 43, 47, 49, 50, 52, 53
    n27, n28, n29, n30, n31, n32, n33, n34 = 55, 62, 64, 67, 68, 73, 74, 77
    n35, n36, n37, n38, n39, n40, n41, n42, n43 = 80,82, 85, 88, 89, 94, 95,97,98
    n44, n45, n46, n47, n48 = 59, 70, 83, 92, 103
    lndx= (val-1)>>1;  sieve = [False]*(lndx+105)
    while n48 < lndx:
        n1  += 105; n2  += 105; n3  += 105; n4  += 105; n5  += 105; n6  += 105
	n7  += 105; n8  += 105; n9  += 105; n10 += 105; n11 += 105; n12 += 105
	n13 += 105; n14 += 105; n15 += 105; n16 += 105; n17 += 105; n18 += 105
	n19 += 105; n20 += 105; n21 += 105; n22 += 105; n23 += 105; n24 += 105
	n25 += 105; n26 += 105; n27 += 105; n28 += 105; n29 += 105; n30 += 105
        n31 += 105; n32 += 105; n33 += 105; n34 += 105; n35 += 105; n36 += 105
	n37 += 105; n38 += 105; n39 += 105; n40 += 105; n41 += 105; n42 += 105
	n43 += 105; n44 += 105; n45 += 105; n46 += 105; n47 += 105; n48 += 105
        sieve[n1] =sieve[n2] =sieve[n3] =sieve[n4] =sieve[n5] =sieve[n6]  = \
	sieve[n7] =sieve[n8] =sieve[n9] =sieve[n10]=sieve[n11]=sieve[n12] = \
        sieve[n13]=sieve[n14]=sieve[n15]=sieve[n16]=sieve[n17]=sieve[n18] = \
	sieve[n19]=sieve[n20]=sieve[n21]=sieve[n22]=sieve[n23]=sieve[n24] = \
        sieve[n25]=sieve[n26]=sieve[n27]=sieve[n28]=sieve[n29]=sieve[n30] = \
	sieve[n31]=sieve[n32]=sieve[n33]=sieve[n34]=sieve[n35]=sieve[n36] = \
        sieve[n37]=sieve[n38]=sieve[n39]=sieve[n40]=sieve[n41]=sieve[n42] = \
	sieve[n43]=sieve[n44]=sieve[n45]=sieve[n46]=sieve[n47]=sieve[n48] = True
    # now initialize sieve with the (odd) primes < 210,
    sieve[0]  = sieve[1]  = sieve[2]  = sieve[4]  = sieve[5]  = \
    sieve[7]  = sieve[8]  = sieve[10] = sieve[13] = sieve[14] = \
    sieve[17] = sieve[19] = sieve[20] = sieve[22] = sieve[25] = \
    sieve[28] = sieve[29] = sieve[32] = sieve[34] = sieve[35] = \
    sieve[38] = sieve[40] = sieve[43] = sieve[47] = sieve[49] = \
    sieve[50] = sieve[52] = sieve[53] = sieve[55] = sieve[62] = \
    sieve[64] = sieve[67] = sieve[68] = sieve[73] = sieve[74] = \
    sieve[77] = sieve[80] = sieve[82] = sieve[85] = sieve[88] = \
    sieve[89] = sieve[94] = sieve[95] = sieve[97] = sieve[98] = True
    n = 0; rescnt = 48
    for i in xrange(4, ((int(sqrt(val))-3)>>1)+1, 1):
        if not sieve[i]:  continue
        # residues are (11,13,17,19,23, 29,31,37 41,43, 47,53,59,61,67, 71,73,79,83,89,
        # 97,101,103,107,109, 113,121,127,131,137, 139,143,149,151,157,
        # 163,167,169,173,179, 181,187,191,193,197, 199,209, 211)	
        # p1=11*i, p2=13*i, p3=17*i -- p46=199*i, p47=209*i, p48=211*i,  k=210*i
        #  j  i 11i 13i 17i 19i 23i 29i 31i 37i..193i 197i 199i 209i 211i 210i
        # 11->4  59  70  92 103 125 191 202 128  1060 1082 1093 1148 1159 1155
        j=(i<<1)+3; j2=j<<1; j3=j2+j; j4=j2<<1; j5=j4+j
        p1=j5+i; p2=p1+j; p3=p2+j2; p4=p3+j; p5=p4+j2; p6=p5+j3; p7=p6+j; p8=p7+j3
        p9=p8+j2; p10=p9+j; p11=p10+j2; p12=p11+j3; p13=p12+j3; p14=p13+j;p15=p14+j3
        p16=p15+j2; p17=p16+j;  p18=p17+j3; p19=p18+j2; p20=p19+j3; p21=p20+j4
        p22=p21+j2; p23=p22+j;  p24=p23+j2; p25=p24+j;  p26=p25+j2; p27=p26+j4
        p28=p27+j3; p29=p28+j2; p30=p29+j3; p31=p30+j;  p32=p31+j2; p33=p32+j3
        p34=p33+j;  p35=p34+j3; p36=p35+j3; p37=p36+j2; p38=p37+j;  p39=p38+j2
        p40=p39+j3; p41=p40+j;  p42=p41+j3; p43=p42+j2; p44=p43+j;  p45=p44+j2
        p46=p45+j;  p47=p46+j5; p48=p47+j;  k = p48-i
	x = k*(n/rescnt);  n += 1
        p1  +=x; p2  +=x; p3  +=x; p4  +=x; p5  +=x; p6  +=x; p7  +=x; p8  +=x
        p9  +=x; p10 +=x; p11 +=x; p12 +=x; p13 +=x; p14 +=x; p15 +=x; p16 +=x
        p17 +=x; p18 +=x; p19 +=x; p20 +=x; p21 +=x; p22 +=x; p23 +=x; p24 +=x
        p25 +=x; p26 +=x; p27 +=x; p28 +=x; p29 +=x; p30 +=x; p31 +=x; p32 +=x
        p33 +=x; p34 +=x; p35 +=x; p36 +=x; p37 +=x; p38 +=x; p39 +=x; p40 +=x
        p41 +=x; p42 +=x; p43 +=x; p44 +=x; p45 +=x; p46 +=x; p47 +=x; p48 +=x	
        while p48 < lndx:
           sieve[p1] = sieve[p2] = sieve[p3] = sieve[p4] = sieve[p5] = sieve[p6]=  \
           sieve[p7] = sieve[p8] = sieve[p9] = sieve[p10]= sieve[p11]= sieve[p12]= \
           sieve[p13]= sieve[p14]= sieve[p15]= sieve[p16]= sieve[p17]= sieve[p18]= \
           sieve[p19]= sieve[p20]= sieve[p21]= sieve[p22]= sieve[p23]= sieve[p24]= \
           sieve[p25]= sieve[p26]= sieve[p27]= sieve[p28]= sieve[p29]= sieve[p30]= \
           sieve[p31]= sieve[p32]= sieve[p33]= sieve[p34]= sieve[p35]= sieve[p36]= \
           sieve[p37]= sieve[p38]= sieve[p39]= sieve[p40]= sieve[p41]= sieve[p42]= \
           sieve[p43]= sieve[p44]= sieve[p45]= sieve[p46]= sieve[p47]= sieve[p48]= False
           p1  +=k; p2  +=k; p3  +=k; p4  +=k; p5  +=k; p6  +=k; p7  +=k; p8  +=k
           p9  +=k; p10 +=k; p11 +=k; p12 +=k; p13 +=k; p14 +=k; p15 +=k; p16 +=k
           p17 +=k; p18 +=k; p19 +=k; p20 +=k; p21 +=k; p22 +=k; p23 +=k; p24 +=k
           p25 +=k; p26 +=k; p27 +=k; p28 +=k; p29 +=k; p30 +=k; p31 +=k; p32 +=k
           p33 +=k; p34 +=k; p35 +=k; p36 +=k; p37 +=k; p38 +=k; p39 +=k; p40 +=k
           p41 +=k; p42 +=k; p43 +=k; p44 +=k; p45 +=k; p46 +=k; p47 +=k; p48 +=k
        if p1 < lndx:
	 sieve[p1] = False
         if p2 < lndx:
          sieve[p2] = False
          if p3 < lndx:
           sieve[p3] = False
           if p4 < lndx:
	    sieve[p4] = False
            if p5 < lndx:
	     sieve[p5] = False
             if p6 < lndx:
	      sieve[p6] = False
              if p7 < lndx:
	       sieve[p7] = False
               if p8 < lndx:
		sieve[p8] = False
                if p9 < lndx:
		 sieve[p9] = False
                 if p10 < lndx:
	          sieve[p10] = False
                  if p11 < lndx:
		   sieve[p11] = False
                   if p12 < lndx:
		    sieve[p12] = False
                    if p13 < lndx:
		     sieve[p13] = False
                     if p14 < lndx:
		      sieve[p14] = False
                      if p15 < lndx:
		       sieve[p15] = False
                       if p16 < lndx:
			sieve[p16] = False
                        if p17 < lndx:
			 sieve[p17] = False
                         if p18 < lndx:
			  sieve[p18] = False
                          if p19 < lndx:
			   sieve[p19] = False
                           if p20 < lndx:
			    sieve[p20] = False
                            if p21 < lndx:
		             sieve[p21] = False
                             if p22 < lndx:
			      sieve[p22] = False
                              if p23 < lndx:
			       sieve[p23] = False
                               if p24 < lndx:
				sieve[p24] = False
                                if p25 < lndx:
				 sieve[p25] = False
                                 if p26 < lndx:
			          sieve[p26] = False
                                  if p27 < lndx:
			           sieve[p27] = False
                                   if p28 < lndx:
			            sieve[p28] = False
                                    if p29 < lndx:
				     sieve[p29] = False
                                     if p30 < lndx:
				      sieve[p30] = False
                                      if p31 < lndx:
				       sieve[p31] = False
                                       if p32 < lndx:
					sieve[p32] = False
                                        if p33 < lndx:
					 sieve[p33] = False
                                         if p34 < lndx:
				          sieve[p34] = False
                                          if p35 < lndx:
					   sieve[p35] = False
                                           if p36 < lndx:
					    sieve[p36] = False
                                            if p37 < lndx:
				             sieve[p37] = False
                                             if p38 < lndx:
				              sieve[p38] = False
                                              if p39 < lndx:
					       sieve[p39] = False
                                               if p40 < lndx:
						sieve[p40] = False
                                                if p41 < lndx:
						 sieve[p41] = False
                                                 if p42 < lndx:
						  sieve[p42] = False
                                                  if p43 < lndx:
						   sieve[p43] = False
                                                   if p44 < lndx:
						    sieve[p44] = False
                                                    if p45 < lndx:
						     sieve[p45] = False
                                                     if p46 < lndx:
						      sieve[p46] = False
                                                      if p47 < lndx: sieve[p47] = False
    if val < 3 : return [2]
    if val < 5 : return [2,3]
    if val < 7 : return [2,3,5]
    primes = [(i<<1)+3 for i in xrange(4, lndx, 1)  if sieve[i]]
    primes[0:0] = [2,3,5,7]
    return primes

def SoZP11(val):
    # all prime candidates > 11 are of form  2310*k+(1,13,17,19,23,29,31,37,41
    # 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
    # 127, 131, 137, 139, 149, 151, 157, 163, 167, 169, 173, 179, 181, 191, 193,
    # 197, 199, 211, 221, 223, 227, 229, 233, 239, 241, 247, 251, 257, 263, 269,
    # 271, 277, 281, 283, 289, 293, 299, 307, 311, 313, 317, 323, 331, 337, 347,
    # 349, 353, 359, 361, 367, 373, 377, 379, 383, 389, 391, 397, 401, 403, 409,
    # 419, 421, 431, 433, 437, 439, 443, 449, 457, 461, 463, 467, 479, 481, 487,
    # 491, 493, 499, 503, 509, 521, 523, 527, 529, 533, 541, 547, 551, 557, 559,
    # 563, 569, 571, 577, 587, 589, 593, 599, 601, 607, 611, 613, 617, 619, 629,
    # 631, 641, 643, 647, 653, 659, 661, 667, 673, 677, 683, 689, 691, 697, 701,
    # 703, 709, 713, 719, 727, 731, 733, 739, 743, 751, 757, 761, 767, 769, 773,
    # 779, 787, 793, 797, 799, 809, 811, 817, 821, 823, 827, 829, 839, 841, 851,
    # 853, 857, 859, 863, 871, 877, 881, 883, 887, 893, 899, 901, 907, 911, 919,
    # 923, 929, 937, 941, 943, 947, 949, 953, 961, 967, 971, 977, 983, 989, 991,
    # 997, 1003, 1007, 1009, 1013, 1019, 1021, 1027, 1031, 1033, 1037, 1039, 1049,
    # 1051,1061, 1063, 1069, 1073, 1079, 1081, 1087, 1091, 1093, 1097, 1103, 1109,
    # 1117,1121, 1123, 1129, 1139, 1147, 1151, 1153, 1157, 1159, 1163, 1171, 1181,
    # 1187,1189, 1193, 1201, 1207, 1213, 1217, 1219, 1223, 1229, 1231, 1237, 1241,
    # 1247,1249, 1259, 1261, 1271, 1273, 1277, 1279, 1283, 1289, 1291, 1297, 1301,
    # 1303,1307, 1313, 1319, 1321, 1327, 1333, 1339, 1343, 1349, 1357, 1361, 1363,
    # 1367,1369, 1373, 1381, 1387, 1391, 1399, 1403, 1409, 1411, 1417, 1423, 1427,
    # 1429,1433, 1439, 1447, 1451, 1453, 1457, 1459, 1469, 1471, 1481, 1483, 1487,
    # 1489,1493, 1499, 1501, 1511, 1513, 1517, 1523, 1531, 1537, 1541, 1543, 1549,
    # 1553,1559, 1567, 1571, 1577, 1579, 1583, 1591, 1597, 1601, 1607, 1609, 1613,
    # 1619,1621, 1627, 1633, 1637, 1643, 1649, 1651, 1657, 1663, 1667, 1669, 1679,
    # 1681,1691, 1693, 1697, 1699, 1703, 1709, 1711, 1717, 1721, 1723, 1733, 1739,
    # 1741,1747, 1751, 1753, 1759, 1763, 1769, 1777, 1781, 1783, 1787, 1789, 1801,
    # 1807,1811, 1817, 1819, 1823, 1829, 1831, 1843, 1847, 1849, 1853, 1861, 1867,
    # 1871,1873, 1877, 1879, 1889, 1891, 1901, 1907, 1909, 1913, 1919, 1921, 1927,
    # 1931,1933, 1937, 1943, 1949, 1951, 1957, 1961, 1963, 1973, 1979, 1987, 1993,
    # 1997,1999, 2003, 2011, 2017, 2021, 2027, 2029, 2033, 2039, 2041, 2047, 2053,
    # 2059,2063, 2069, 2071, 2077, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2117,
    # 2119,2129, 2131, 2137, 2141, 2143, 2147, 2153, 2159, 2161, 2171, 2173, 2179,
    # 2183,2197, 2201, 2203, 2207, 2209, 2213, 2221, 2227, 2231, 2237, 2239, 2243,
    # 2249,2251,2257,2263,2267,2269,2273,2279, 2281, 2287, 2291, 2293, 2297, 2309)
    # initialize sieve array with only these candidate values
    # where sieve contains the odd integers representatives
    # convert integers to array indices/vals by i = (n-3)>>1
    n1, n2, n3, n4, n5, n6, n7, n8, n9, n10 = -1, 5, 7, 8, 10, 13, 14, 17, 19, 20
    n11, n12, n13, n14, n15, n16, n17, n18 = 22, 25, 28, 29, 32, 34, 35, 38
    n19, n20, n21, n22, n23, n24, n25, n26 = 40, 43, 47, 49, 50, 52, 53, 55
    n27, n28, n29, n30, n31, n32, n33, n34 = 62, 64, 67, 68, 73, 74, 77, 80
    n35, n36, n37, n38, n39, n40, n41, n42 = 82, 83, 85, 88, 89, 94, 95, 97
    n43, n44, n45, n46, n47, n48, n49, n50 = 98, 104, 109, 110, 112, 113, 115, 118
    n51, n52, n53, n54, n55, n56, n57, n58 = 119,122, 124, 127, 130, 133, 134, 137
    n59, n60, n61, n62, n63, n64, n65, n66 = 139,140, 143, 145, 148, 152, 154, 155
    n67, n68, n69, n70, n71, n72, n73, n74 = 157,160, 164, 167, 172, 173, 175, 178
    n75, n76, n77, n78, n79, n80, n81, n82 = 179,182, 185, 187, 188, 190, 193, 194
    n83, n84, n85, n86, n87, n88, n89, n90 = 197,199, 200, 203, 208, 209, 214, 215
    n91, n92, n93, n94, n95, n96, n97, n98 = 217,218, 220, 223, 227, 229, 230, 232
    n99,n100,n101,n102,n103,n104,n105,n106 = 238,239, 242, 244, 245, 248, 250, 253
    n107,n108,n109,n110,n111,n112,n113,n114= 259,260, 262, 263, 265, 269, 272, 274
    n115,n116,n117,n118,n119,n120,n121,n122= 277,278, 280, 283, 284, 287, 292, 293
    n123,n124,n125,n126,n127,n128,n129,n130= 295,298, 299, 302, 304, 305, 307, 308
    n131,n132,n133,n134,n135,n136,n137,n138= 313,314, 319, 320, 322, 325, 328, 329
    n139,n140,n141,n142,n143,n144,n145,n146= 332,335, 337, 340, 343, 344, 347, 349
    n147,n148,n149,n150,n151,n152,n153,n154= 350,353, 355, 358, 362, 364, 365, 368
    n155,n156,n157,n158,n159,n160,n161,n162= 370,374, 377, 379, 382, 383, 385, 388
    n163,n164,n165,n166,n167,n168,n169,n170= 392,395, 397, 398, 403, 404, 407, 409
    n171,n172,n173,n174,n175,n176,n177,n178= 410,412, 413, 418, 419, 424, 425, 427
    n179,n180,n181,n182,n183,n184,n185,n186= 428,430, 434, 437, 439, 440, 442, 445
    n187,n188,n189,n190,n191,n192,n193,n194= 448,449, 452, 454, 458, 460, 463, 467
    n195,n196,n197,n198,n199,n200,n201,n202= 469,470, 472, 473, 475, 479, 482, 484
    n203,n204,n205,n206,n207,n208,n209,n210= 487,490, 493, 494, 497, 500, 502, 503
    n211,n212,n213,n214,n215,n216,n217,n218= 505,508, 509, 512, 514, 515, 517, 518
    n219,n220,n221,n222,n223,n224,n225,n226= 523,524, 529, 530, 533, 535, 538, 539
    n227,n228,n229,n230,n231,n232,n233,n234= 542,544, 545, 547, 550, 553, 557, 559
    n235,n236,n237,n238,n239,n240,n241,n242= 560,563, 568, 572, 574, 575, 577, 578
    n243,n244,n245,n246,n247,n248,n249,n250= 580,584, 589, 592, 593, 595, 599, 602
    n251,n252,n253,n254,n255,n256,n257,n258= 605,607, 608, 610, 613, 614, 617, 619
    n259,n260,n261,n262,n263,n264,n265,n266= 622,623, 628, 629, 634, 635, 637, 638
    n267,n268,n269,n270,n271,n272,n273,n274= 640,643, 644, 647, 649, 650, 652, 655
    n275,n276,n277,n278,n279,n280,n281,n282= 658,659, 662, 665, 668, 670, 673, 677
    n283,n284,n285,n286,n287,n288,n289,n290= 679,680, 682, 683, 685, 689, 692, 694
    n291,n292,n293,n294,n295,n296,n297,n298= 698,700, 703, 704, 707, 710, 712, 713
    n299,n300,n301,n302,n303,n304,n305,n306= 715,718, 722, 724, 725, 727, 728, 733
    n307,n308,n309,n310,n311,n312,n313,n314= 734,739, 740, 742, 743, 745, 748, 749
    n315,n316,n317,n318,n319,n320,n321,n322= 754,755, 757, 760, 764, 767, 769, 770
    n323,n324,n325,n326,n327,n328,n329,n330= 773,775, 778, 782, 784, 787, 788, 790
    n331,n332,n333,n334,n335,n336,n337,n338= 794,797, 799, 802, 803, 805, 808, 809
    n339,n340,n341,n342,n343,n344,n345,n346= 812,815, 817, 820, 823, 824, 827, 830
    n347,n348,n349,n350,n351,n352,n353,n354= 832,833, 838, 839, 844, 845, 847, 848
    n355,n356,n357,n358,n359,n360,n361,n362= 850,853, 854, 857, 859, 860, 865, 868
    n363,n364,n365,n366,n367,n368,n369,n370= 869,872, 874, 875, 878, 880, 883, 887
    n371,n372,n373,n374,n375,n376,n377,n378= 889,890, 892, 893, 899, 902, 904, 907
    n379,n380,n381,n382,n383,n384,n385,n386= 908,910, 913, 914, 920, 922, 923, 925
    n387,n388,n389,n390,n391,n392,n393,n394= 929,932, 934, 935, 937, 938, 943, 944
    n395,n396,n397,n398,n399,n400,n401,n402= 949,952, 953, 955, 958, 959, 962, 964
    n403,n404,n405,n406,n407,n408,n409,n410= 965,967, 970, 973, 974, 977, 979, 980
    n411,n412,n413,n414,n415,n416,n417,n418= 985,988, 992, 995, 997, 998,1000,1004
    n419,n420,n421,n422,n423,n424,n425,n426= 1007,1009,1012,1013,1015,1018,1019,1022
    n427,n428,n429,n430,n431,n432,n433,n434= 1025,1028,1030,1033,1034,1037,1039,1040
    n435,n436,n437,n438,n439,n440,n441,n442= 1042,1043,1048,1054,1055,1057,1058,1063
    n443,n444,n445,n446,n447,n448,n449,n450= 1064,1067,1069,1070,1072,1075,1078,1079
    n451,n452,n453,n454,n455,n456,n457,n458= 1084,1085,1088,1090,1097,1099,1100,1102
    n459,n460,n461,n462,n463,n464,n465,n466= 1103,1105,1109,1112,1114,1117,1118,1120
    n467,n468,n469,n470,n471,n472,n473,n474= 1123,1124,1127,1130,1132,1133,1135,1138
    n475,n476,n477,n478,n479,n480 = 1139, 1142, 1144, 1145, 1147, 1153
    lndx= (val-1)>>1;  sieve = [False]*(lndx+1155)
    while n480 < lndx:
        n1   += 1155;  n2  += 1155;  n3  += 1155;  n4  += 1155;  n5  += 1155
        n6   += 1155;  n7  += 1155;  n8  += 1155;  n9  += 1155;  n10 += 1155
        n11  += 1155;  n12 += 1155;  n13 += 1155;  n14 += 1155;  n15 += 1155
        n16  += 1155;  n17 += 1155;  n18 += 1155;  n19 += 1155;  n20 += 1155
        n21  += 1155;  n22 += 1155;  n23 += 1155;  n24 += 1155;  n25 += 1155
        n26  += 1155;  n27 += 1155;  n28 += 1155;  n29 += 1155;  n30 += 1155
        n31  += 1155;  n32 += 1155;  n33 += 1155;  n34 += 1155;  n35 += 1155
        n36  += 1155;  n37 += 1155;  n38 += 1155;  n39 += 1155;  n40 += 1155
        n41  += 1155;  n42 += 1155;  n43 += 1155;  n44 += 1155;  n45 += 1155
        n46  += 1155;  n47 += 1155;  n48 += 1155;  n49 += 1155;  n50 += 1155
        n51  += 1155;  n52 += 1155;  n53 += 1155;  n54 += 1155;  n55 += 1155
        n56  += 1155;  n57 += 1155;  n58 += 1155;  n59 += 1155;  n60 += 1155
        n61  += 1155;  n62 += 1155;  n63 += 1155;  n64 += 1155;  n65 += 1155
        n66  += 1155;  n67 += 1155;  n68 += 1155;  n69 += 1155;  n70 += 1155
        n71  += 1155;  n72 += 1155;  n73 += 1155;  n74 += 1155;  n75 += 1155
        n76  += 1155;  n77 += 1155;  n78 += 1155;  n79 += 1155;  n80 += 1155
        n81  += 1155;  n82 += 1155;  n83 += 1155;  n84 += 1155;  n85 += 1155
        n86  += 1155;  n87 += 1155;  n88 += 1155;  n89 += 1155;  n90 += 1155
        n91  += 1155;  n92 += 1155;  n93 += 1155;  n94 += 1155;  n95 += 1155
        n96  += 1155;  n97 += 1155;  n98 += 1155;  n99 += 1155; n100 += 1155
        n101 += 1155; n102 += 1155; n103 += 1155; n104 += 1155; n105 += 1155
        n106 += 1155; n107 += 1155; n108 += 1155; n109 += 1155; n110 += 1155
        n111 += 1155; n112 += 1155; n113 += 1155; n114 += 1155; n115 += 1155
        n116 += 1155; n117 += 1155; n118 += 1155; n119 += 1155; n120 += 1155
        n121 += 1155; n122 += 1155; n123 += 1155; n124 += 1155; n125 += 1155
        n126 += 1155; n127 += 1155; n128 += 1155; n129 += 1155; n130 += 1155
        n131 += 1155; n132 += 1155; n133 += 1155; n134 += 1155; n135 += 1155
        n136 += 1155; n137 += 1155; n138 += 1155; n139 += 1155; n140 += 1155
        n141 += 1155; n142 += 1155; n143 += 1155; n144 += 1155; n145 += 1155
        n146 += 1155; n147 += 1155; n148 += 1155; n149 += 1155; n150 += 1155
	n151 += 1155; n152 += 1155; n153 += 1155; n154 += 1155; n155 += 1155
        n156 += 1155; n157 += 1155; n158 += 1155; n159 += 1155; n160 += 1155
        n161 += 1155; n162 += 1155; n163 += 1155; n164 += 1155; n165 += 1155
        n166 += 1155; n167 += 1155; n168 += 1155; n169 += 1155; n170 += 1155
        n171 += 1155; n172 += 1155; n173 += 1155; n174 += 1155; n175 += 1155
        n176 += 1155; n177 += 1155; n178 += 1155; n179 += 1155; n180 += 1155
        n181 += 1155; n182 += 1155; n183 += 1155; n184 += 1155; n185 += 1155
        n186 += 1155; n187 += 1155; n188 += 1155; n189 += 1155; n190 += 1155
        n191 += 1155; n192 += 1155; n193 += 1155; n194 += 1155; n195 += 1155
        n196 += 1155; n197 += 1155; n198 += 1155; n199 += 1155; n200 += 1155
        n201 += 1155; n202 += 1155; n203 += 1155; n204 += 1155; n205 += 1155
        n206 += 1155; n207 += 1155; n208 += 1155; n209 += 1155; n210 += 1155
        n211 += 1155; n212 += 1155; n213 += 1155; n214 += 1155; n215 += 1155
        n216 += 1155; n217 += 1155; n218 += 1155; n219 += 1155; n220 += 1155
        n221 += 1155; n222 += 1155; n223 += 1155; n224 += 1155; n225 += 1155
        n226 += 1155; n227 += 1155; n228 += 1155; n229 += 1155; n230 += 1155
        n231 += 1155; n232 += 1155; n233 += 1155; n234 += 1155; n235 += 1155
        n236 += 1155; n237 += 1155; n238 += 1155; n239 += 1155; n240 += 1155
        n241 += 1155; n242 += 1155; n243 += 1155; n244 += 1155; n245 += 1155
        n246 += 1155; n247 += 1155; n248 += 1155; n249 += 1155; n250 += 1155
	n251 += 1155; n252 += 1155; n253 += 1155; n254 += 1155; n255 += 1155
        n256 += 1155; n257 += 1155; n258 += 1155; n259 += 1155; n260 += 1155
        n261 += 1155; n262 += 1155; n263 += 1155; n264 += 1155; n265 += 1155
        n266 += 1155; n267 += 1155; n268 += 1155; n269 += 1155; n270 += 1155
        n271 += 1155; n272 += 1155; n273 += 1155; n274 += 1155; n275 += 1155
        n276 += 1155; n277 += 1155; n278 += 1155; n279 += 1155; n280 += 1155
        n281 += 1155; n282 += 1155; n283 += 1155; n284 += 1155; n285 += 1155
        n286 += 1155; n287 += 1155; n288 += 1155; n289 += 1155; n290 += 1155
        n291 += 1155; n292 += 1155; n293 += 1155; n294 += 1155; n295 += 1155
        n296 += 1155; n297 += 1155; n298 += 1155; n299 += 1155; n300 += 1155
        n301 += 1155; n302 += 1155; n303 += 1155; n304 += 1155; n305 += 1155
        n306 += 1155; n307 += 1155; n308 += 1155; n309 += 1155; n310 += 1155
        n311 += 1155; n312 += 1155; n313 += 1155; n314 += 1155; n315 += 1155
        n316 += 1155; n317 += 1155; n318 += 1155; n319 += 1155; n320 += 1155
        n321 += 1155; n322 += 1155; n323 += 1155; n324 += 1155; n325 += 1155
        n326 += 1155; n327 += 1155; n328 += 1155; n329 += 1155; n330 += 1155
        n331 += 1155; n332 += 1155; n333 += 1155; n334 += 1155; n335 += 1155
        n336 += 1155; n337 += 1155; n338 += 1155; n339 += 1155; n340 += 1155
        n341 += 1155; n342 += 1155; n343 += 1155; n344 += 1155; n345 += 1155
        n346 += 1155; n347 += 1155; n348 += 1155; n349 += 1155; n350 += 1155
        n351 += 1155; n352 += 1155; n353 += 1155; n354 += 1155; n355 += 1155
        n356 += 1155; n357 += 1155; n358 += 1155; n359 += 1155; n360 += 1155
        n361 += 1155; n362 += 1155; n363 += 1155; n364 += 1155; n365 += 1155
        n366 += 1155; n367 += 1155; n368 += 1155; n369 += 1155; n370 += 1155
        n371 += 1155; n372 += 1155; n373 += 1155; n374 += 1155; n375 += 1155
        n376 += 1155; n377 += 1155; n378 += 1155; n379 += 1155; n380 += 1155
        n381 += 1155; n382 += 1155; n383 += 1155; n384 += 1155; n385 += 1155
        n386 += 1155; n387 += 1155; n388 += 1155; n389 += 1155; n390 += 1155
        n391 += 1155; n392 += 1155; n393 += 1155; n394 += 1155; n395 += 1155
        n396 += 1155; n397 += 1155; n398 += 1155; n399 += 1155; n400 += 1155
        n401 += 1155; n402 += 1155; n403 += 1155; n404 += 1155; n405 += 1155
        n406 += 1155; n407 += 1155; n408 += 1155; n409 += 1155; n410 += 1155
        n411 += 1155; n412 += 1155; n413 += 1155; n414 += 1155; n415 += 1155
        n416 += 1155; n417 += 1155; n418 += 1155; n419 += 1155; n420 += 1155
        n421 += 1155; n422 += 1155; n423 += 1155; n424 += 1155; n425 += 1155
        n426 += 1155; n427 += 1155; n428 += 1155; n429 += 1155; n430 += 1155
        n431 += 1155; n432 += 1155; n433 += 1155; n434 += 1155; n435 += 1155
        n436 += 1155; n437 += 1155; n438 += 1155; n439 += 1155; n440 += 1155
        n441 += 1155; n442 += 1155; n443 += 1155; n444 += 1155; n445 += 1155
        n446 += 1155; n447 += 1155; n448 += 1155; n449 += 1155; n450 += 1155
        n451 += 1155; n452 += 1155; n453 += 1155; n454 += 1155; n455 += 1155
        n456 += 1155; n457 += 1155; n458 += 1155; n459 += 1155; n460 += 1155
        n461 += 1155; n462 += 1155; n463 += 1155; n464 += 1155; n465 += 1155
        n466 += 1155; n467 += 1155; n468 += 1155; n469 += 1155; n470 += 1155
        n471 += 1155; n472 += 1155; n473 += 1155; n474 += 1155; n475 += 1155
        n476 += 1155; n477 += 1155; n478 += 1155; n479 += 1155; n480 += 1155
        sieve[n1]  =sieve[n2]  =sieve[n3]  =sieve[n4]  =sieve[n5]  =sieve[n6]  = \
	sieve[n7]  =sieve[n8]  =sieve[n9]  =sieve[n10] =sieve[n11] =sieve[n12] = \
        sieve[n13] =sieve[n14] =sieve[n15] =sieve[n16] =sieve[n17] =sieve[n18] = \
	sieve[n19] =sieve[n20] =sieve[n21] =sieve[n22] =sieve[n23] =sieve[n24] = \
        sieve[n25] =sieve[n26] =sieve[n27] =sieve[n28] =sieve[n29] =sieve[n30] = \
	sieve[n31] =sieve[n32] =sieve[n33] =sieve[n34] =sieve[n35] =sieve[n36] = \
        sieve[n37] =sieve[n38] =sieve[n39] =sieve[n40] =sieve[n41] =sieve[n42] = \
	sieve[n43] =sieve[n44] =sieve[n45] =sieve[n46] =sieve[n47] =sieve[n48] = \
	sieve[n49] =sieve[n50] =sieve[n51] =sieve[n52] =sieve[n53] =sieve[n54] = \
	sieve[n55] =sieve[n56] =sieve[n57] =sieve[n58] =sieve[n59] =sieve[n60] = \
	sieve[n61] =sieve[n62] =sieve[n63] =sieve[n64] =sieve[n65] =sieve[n66] = \
	sieve[n67] =sieve[n68] =sieve[n69] =sieve[n70] =sieve[n71] =sieve[n72] = \
	sieve[n73] =sieve[n74] =sieve[n75] =sieve[n76] =sieve[n77] =sieve[n78] = \
	sieve[n79] =sieve[n80] =sieve[n81] =sieve[n82] =sieve[n83] =sieve[n84] = \
	sieve[n85] =sieve[n86] =sieve[n87] =sieve[n88] =sieve[n89] =sieve[n90] = \
	sieve[n91] =sieve[n92] =sieve[n93] =sieve[n94] =sieve[n95] =sieve[n96] = \
        sieve[n97] =sieve[n98] =sieve[n99] =sieve[n100]=sieve[n101]=sieve[n102]= \
	sieve[n103]=sieve[n104]=sieve[n105]=sieve[n106]=sieve[n107]=sieve[n108]= \
	sieve[n109]=sieve[n110]=sieve[n111]=sieve[n112]=sieve[n113]=sieve[n114]= \
	sieve[n115]=sieve[n116]=sieve[n117]=sieve[n118]=sieve[n119]=sieve[n120]= \
        sieve[n121]=sieve[n122]=sieve[n123]=sieve[n124]=sieve[n125]=sieve[n126]= \
	sieve[n127]=sieve[n128]=sieve[n129]=sieve[n130]=sieve[n131]=sieve[n132]= \
	sieve[n133]=sieve[n134]=sieve[n135]=sieve[n136]=sieve[n137]=sieve[n138]= \
	sieve[n139]=sieve[n140]=sieve[n141]=sieve[n142]=sieve[n143]=sieve[n144]= \
	sieve[n145]=sieve[n146]=sieve[n147]=sieve[n148]=sieve[n149]=sieve[n150]= \
	sieve[n151]=sieve[n152]=sieve[n153]=sieve[n154]=sieve[n155]=sieve[n156]= \
	sieve[n157]=sieve[n158]=sieve[n159]=sieve[n160]=sieve[n161]=sieve[n162]= \
	sieve[n163]=sieve[n164]=sieve[n165]=sieve[n166]=sieve[n167]=sieve[n168]= \
	sieve[n169]=sieve[n170]=sieve[n171]=sieve[n172]=sieve[n173]=sieve[n174]= \
	sieve[n175]=sieve[n176]=sieve[n177]=sieve[n178]=sieve[n179]=sieve[n180]= \
	sieve[n181]=sieve[n182]=sieve[n183]=sieve[n184]=sieve[n185]=sieve[n186]= \
	sieve[n187]=sieve[n188]=sieve[n189]=sieve[n190]=sieve[n191]=sieve[n192]= \
	sieve[n193]=sieve[n194]=sieve[n195]=sieve[n196]=sieve[n197]=sieve[n198]= \
	sieve[n199]=sieve[n200]=sieve[n201]=sieve[n202]=sieve[n203]=sieve[n204]= \
	sieve[n205]=sieve[n206]=sieve[n207]=sieve[n208]=sieve[n209]=sieve[n210]= \
	sieve[n211]=sieve[n212]=sieve[n213]=sieve[n214]=sieve[n215]=sieve[n216]= \
	sieve[n217]=sieve[n218]=sieve[n219]=sieve[n220]=sieve[n221]=sieve[n222]= \
	sieve[n223]=sieve[n224]=sieve[n225]=sieve[n226]=sieve[n227]=sieve[n228]= \
	sieve[n229]=sieve[n230]=sieve[n231]=sieve[n232]=sieve[n233]=sieve[n234]= \
	sieve[n235]=sieve[n236]=sieve[n237]=sieve[n238]=sieve[n239]=sieve[n240]= \
	sieve[n241]=sieve[n242]=sieve[n243]=sieve[n244]=sieve[n245]=sieve[n246]= \
	sieve[n247]=sieve[n248]=sieve[n249]=sieve[n250]=sieve[n251]=sieve[n252]= \
	sieve[n253]=sieve[n254]=sieve[n255]=sieve[n256]=sieve[n257]=sieve[n258]= \
	sieve[n259]=sieve[n260]=sieve[n261]=sieve[n262]=sieve[n263]=sieve[n264]= \
	sieve[n265]=sieve[n266]=sieve[n267]=sieve[n268]=sieve[n269]=sieve[n270]= \
	sieve[n271]=sieve[n272]=sieve[n273]=sieve[n274]=sieve[n275]=sieve[n276]= \
	sieve[n277]=sieve[n278]=sieve[n279]=sieve[n280]=sieve[n281]=sieve[n282]= \
	sieve[n283]=sieve[n284]=sieve[n285]=sieve[n286]=sieve[n287]=sieve[n288]= \
	sieve[n289]=sieve[n290]=sieve[n291]=sieve[n292]=sieve[n293]=sieve[n294]= \
	sieve[n295]=sieve[n296]=sieve[n297]=sieve[n298]=sieve[n299]=sieve[n300]= \
        sieve[n301]=sieve[n302]=sieve[n303]=sieve[n304]=sieve[n305]=sieve[n306]= \
	sieve[n307]=sieve[n308]=sieve[n309]=sieve[n310]=sieve[n311]=sieve[n312]= \
	sieve[n313]=sieve[n314]=sieve[n315]=sieve[n316]=sieve[n317]=sieve[n318]= \
	sieve[n319]=sieve[n320]=sieve[n321]=sieve[n322]=sieve[n323]=sieve[n324]= \
	sieve[n325]=sieve[n326]=sieve[n327]=sieve[n328]=sieve[n329]=sieve[n330]= \
	sieve[n331]=sieve[n332]=sieve[n333]=sieve[n334]=sieve[n335]=sieve[n336]= \
	sieve[n337]=sieve[n338]=sieve[n339]=sieve[n340]=sieve[n341]=sieve[n342]= \
	sieve[n343]=sieve[n344]=sieve[n345]=sieve[n346]=sieve[n347]=sieve[n348]= \
	sieve[n349]=sieve[n350]=sieve[n351]=sieve[n352]=sieve[n353]=sieve[n354]= \
	sieve[n355]=sieve[n356]=sieve[n357]=sieve[n358]=sieve[n359]=sieve[n360]= \
	sieve[n361]=sieve[n362]=sieve[n363]=sieve[n364]=sieve[n365]=sieve[n366]= \
	sieve[n367]=sieve[n368]=sieve[n369]=sieve[n370]=sieve[n371]=sieve[n372]= \
	sieve[n373]=sieve[n374]=sieve[n375]=sieve[n376]=sieve[n377]=sieve[n378]= \
	sieve[n379]=sieve[n380]=sieve[n381]=sieve[n382]=sieve[n383]=sieve[n384]= \
	sieve[n385]=sieve[n386]=sieve[n387]=sieve[n388]=sieve[n389]=sieve[n390]= \
	sieve[n391]=sieve[n392]=sieve[n393]=sieve[n394]=sieve[n395]=sieve[n396]= \
	sieve[n397]=sieve[n398]=sieve[n399]=sieve[n400]=sieve[n401]=sieve[n402]= \
	sieve[n403]=sieve[n404]=sieve[n405]=sieve[n406]=sieve[n407]=sieve[n408]= \
        sieve[n409]=sieve[n410]=sieve[n411]=sieve[n412]=sieve[n413]=sieve[n414]= \
	sieve[n415]=sieve[n416]=sieve[n417]=sieve[n418]=sieve[n419]=sieve[n420]= \
	sieve[n421]=sieve[n422]=sieve[n423]=sieve[n424]=sieve[n425]=sieve[n426]= \
	sieve[n427]=sieve[n428]=sieve[n429]=sieve[n430]=sieve[n431]=sieve[n432]= \
	sieve[n433]=sieve[n434]=sieve[n435]=sieve[n436]=sieve[n437]=sieve[n438]= \
	sieve[n439]=sieve[n440]=sieve[n441]=sieve[n442]=sieve[n443]=sieve[n444]= \
	sieve[n445]=sieve[n446]=sieve[n447]=sieve[n448]=sieve[n449]=sieve[n450]= \
	sieve[n451]=sieve[n452]=sieve[n453]=sieve[n454]=sieve[n455]=sieve[n456]= \
	sieve[n457]=sieve[n458]=sieve[n459]=sieve[n460]=sieve[n461]=sieve[n462]= \
	sieve[n463]=sieve[n464]=sieve[n465]=sieve[n466]=sieve[n467]=sieve[n468]= \
	sieve[n469]=sieve[n470]=sieve[n471]=sieve[n472]=sieve[n473]=sieve[n474]= \
	sieve[n475]=sieve[n476]=sieve[n477]=sieve[n478]=sieve[n479]=sieve[n480]= True
   # now initialize sieve with the (odd) primes < 2310
    sieve[0]   =sieve[1]   =sieve[2]   =sieve[4]   =sieve[5]   =sieve[7]   =sieve[8]  = \
    sieve[10]  =sieve[13]  =sieve[14]  =sieve[17]  =sieve[19]  =sieve[20]  =sieve[22] = \
    sieve[25]  =sieve[28]  =sieve[29]  =sieve[32]  =sieve[34]  =sieve[35]  =sieve[38] = \
    sieve[40]  =sieve[43]  =sieve[47]  =sieve[49]  =sieve[50]  =sieve[52]  =sieve[53] = \
    sieve[55]  =sieve[62]  =sieve[64]  =sieve[67]  =sieve[68]  =sieve[73]  =sieve[74] = \
    sieve[77]  =sieve[80]  =sieve[82]  =sieve[85]  =sieve[88]  =sieve[89]  =sieve[94] = \
    sieve[95]  =sieve[97]  =sieve[98]  =sieve[104] =sieve[110] =sieve[112] =sieve[113]= \
    sieve[115] =sieve[118] =sieve[119] =sieve[124] =sieve[127] =sieve[130] =sieve[133]= \
    sieve[134] =sieve[137] =sieve[139] =sieve[140] =sieve[145] =sieve[152] =sieve[154]= \
    sieve[155] =sieve[157] =sieve[164] =sieve[167] =sieve[172] =sieve[173] =sieve[175]= \
    sieve[178] =sieve[182] =sieve[185] =sieve[188] =sieve[190] =sieve[193] =sieve[197]= \
    sieve[199] =sieve[203] =sieve[208] =sieve[209] =sieve[214] =sieve[215] =sieve[218]= \
    sieve[220] =sieve[223] =sieve[227] =sieve[229] =sieve[230] =sieve[232] =sieve[238]= \
    sieve[242] =sieve[244] =sieve[248] =sieve[250] =sieve[253] =sieve[259] =sieve[260]= \
    sieve[269] =sieve[272] =sieve[277] =sieve[280] =sieve[283] =sieve[284] =sieve[287]= \
    sieve[292] =sieve[295] =sieve[298] =sieve[299] =sieve[302] =sieve[305] =sieve[307]= \
    sieve[308] =sieve[314] =sieve[319] =sieve[320] =sieve[322] =sieve[325] =sieve[328]= \
    sieve[329] =sieve[335] =sieve[337] =sieve[340] =sieve[344] =sieve[349] =sieve[353]= \
    sieve[358] =sieve[362] =sieve[365] =sieve[368] =sieve[370] =sieve[374] =sieve[377]= \
    sieve[379] =sieve[383] =sieve[385] =sieve[392] =sieve[397] =sieve[403] =sieve[404]= \
    sieve[409] =sieve[410] =sieve[412] =sieve[413] =sieve[418] =sieve[425] =sieve[427]= \
    sieve[428] =sieve[430] =sieve[437] =sieve[439] =sieve[440] =sieve[442] =sieve[452]= \
    sieve[454] =sieve[458] =sieve[463] =sieve[467] =sieve[469] =sieve[472] =sieve[475]= \
    sieve[482] =sieve[484] =sieve[487] =sieve[490] =sieve[494] =sieve[497] =sieve[503]= \
    sieve[505] =sieve[508] =sieve[509] =sieve[514] =sieve[515] =sieve[518] =sieve[523]= \
    sieve[524] =sieve[529] =sieve[530] =sieve[533] =sieve[542] =sieve[544] =sieve[545]= \
    sieve[547] =sieve[550] =sieve[553] =sieve[557] =sieve[560] =sieve[563] =sieve[574]= \
    sieve[575] =sieve[580] =sieve[584] =sieve[589] =sieve[592] =sieve[595] =sieve[599]= \
    sieve[605] =sieve[607] =sieve[610] =sieve[613] =sieve[614] =sieve[617] =sieve[623]= \
    sieve[628] =sieve[637] =sieve[638] =sieve[640] =sieve[643] =sieve[644] =sieve[647]= \
    sieve[649] =sieve[650] =sieve[652] =sieve[658] =sieve[659] =sieve[662] =sieve[679]= \
    sieve[682] =sieve[685] =sieve[689] =sieve[698] =sieve[703] =sieve[710] =sieve[712]= \
    sieve[713] =sieve[715] =sieve[718] =sieve[722] =sieve[724] =sieve[725] =sieve[728]= \
    sieve[734] =sieve[739] =sieve[740] =sieve[742] =sieve[743] =sieve[745] =sieve[748]= \
    sieve[754] =sieve[760] =sieve[764] =sieve[770] =sieve[773] =sieve[775] =sieve[778]= \
    sieve[782] =sieve[784] =sieve[788] =sieve[790] =sieve[797] =sieve[799] =sieve[802]= \
    sieve[803] =sieve[805] =sieve[808] =sieve[809] =sieve[812] =sieve[817] =sieve[827]= \
    sieve[830] =sieve[832] =sieve[833] =sieve[845] =sieve[847] =sieve[848] =sieve[853]= \
    sieve[859] =sieve[860] =sieve[865] =sieve[869] =sieve[872] =sieve[875] =sieve[878]= \
    sieve[887] =sieve[890] =sieve[892] =sieve[893] =sieve[899] =sieve[904] =sieve[910]= \
    sieve[914] =sieve[922] =sieve[929] =sieve[932] =sieve[934] =sieve[935] =sieve[937]= \
    sieve[938] =sieve[943] =sieve[949] =sieve[952] =sieve[955] =sieve[964] =sieve[965]= \
    sieve[973] =sieve[974] =sieve[985] =sieve[988] =sieve[992] =sieve[995] =sieve[997]= \
    sieve[998] =sieve[1000]=sieve[1004]=sieve[1007]=sieve[1012]=sieve[1013]=sieve[1018]=\
    sieve[1025]=sieve[1030]=sieve[1033]=sieve[1039]=sieve[1040]=sieve[1042]=sieve[1043]=\
    sieve[1048]=sieve[1054]=sieve[1055]=sieve[1063]=sieve[1064]=sieve[1067]=sieve[1069]=\
    sieve[1070]=sieve[1075]=sieve[1079]=sieve[1088]=sieve[1100]=sieve[1102]=sieve[1105]=\
    sieve[1109]=sieve[1117]=sieve[1118]=sieve[1120]=sieve[1124]=sieve[1132]=sieve[1133]=\
    sieve[1135]=sieve[1139]=sieve[1142]=sieve[1145]=sieve[1147]=sieve[1153]= True
    n = 0;  rescnt = 480
    for i in xrange(5, ((int(sqrt(val))-3)>>1)+1, 1):
        if not sieve[i]:  continue
        # p1=13*i, p2=17*i, p3=19*i -- p478=2297*i,p479=2309*i,p480=2311*i,k=2310*i
        #  j  i 13i 17i 19i 23i 29i 31i 37i..2291i 2293i 2297i 2309i 2311i 2310i
        # 13->5  83 109 122 148 187 200 239  14890 14903 14929 15007 15020 15015
        j=(i<<1)+3; j2=j<<1; j3=j2+j; j4=j2<<1; j5=j4+j; j6=j4+j2; j7=j4+j3
        p1=j6+i; p2=p1+j2; p3=p2+j; p4=p3+j2; p5=p4+j3; p6=p5+j; p7=p6+j3; p8=p7+j2
        p9=p8+j; p10=p9+j2; p11=p10+j3; p12=p11+j3; p13=p12+j; p14=p13+j3; p15=p14+j2
        p16=p15+j;  p17=p16+j3; p18=p17+j2; p19=p18+j3; p20=p19+j4; p21=p20+j2
        p22=p21+j;  p23=p22+j2; p24=p23+j;  p25=p24+j2; p26=p25+j7; p27=p26+j2
        p28=p27+j3; p29=p28+j;  p30=p29+j5; p31=p30+j;  p32=p31+j3; p33=p32+j3
        p34=p33+j2; p35=p34+j;  p36=p35+j2; p37=p36+j3; p38=p37+j;  p39=p38+j5
        p40=p39+j;  p41=p40+j2; p42=p41+j;  p43=p42+j6; p44=p43+j5; p45=p44+j
        p46=p45+j2; p47=p46+j;  p48=p47+j2; p49=p48+j3; p50=p49+j;  p51=p50+j3
        p52=p51+j2; p53=p52+j3; p54=p53+j3; p55=p54+j3; p56=p55+j;  p57=p56+j3
	p58=p57+j2; p59=p58+j;  p60=p59+j3; p61=p60+j2; p62=p61+j3; p63=p62+j4
	p64=p63+j2; p65=p64+j;  p66=p65+j2; p67=p66+j3; p68=p67+j4; p69=p68+j3
	p70=p69+j5; p71=p70+j;  p72=p71+j2; p73=p72+j3; p74=p73+j;  p75=p74+j3
	p76=p75+j3; p77=p76+j2; p78=p77+j;  p79=p78+j2; p80=p79+j3; p81=p80+j
	p82=p81+j3; p83=p82+j2; p84=p83+j;  p85=p84+j3; p86=p85+j5; p87=p86+j
	p88=p87+j5; p89=p88+j;  p90=p89+j2; p91=p90+j;  p92=p91+j2; p93=p92+j3
	p94=p93+j4; p95=p94+j2; p96=p95+j;  p97=p96+j2; p98=p97+j6; p99=p98+j
	p100=p99+j3; p101=p100+j2;p102=p101+j;  p103=p102+j3; p104=p103+j2; p105=p104+j3
	p106=p105+j6;p107=p106+j; p108=p107+j2; p109=p108+j;  p110=p109+j2; p111=p110+j4
	p112=p111+j3;p113=p112+j2;p114=p113+j3; p115=p114+j;  p116=p115+j2; p117=p116+j3
	p118=p117+j; p119=p118+j3;p120=p119+j5; p121=p120+j;  p122=p121+j2; p123=p122+j3
	p124=p123+j; p125=p124+j3;p126=p125+j2; p127=p126+j;  p128=p127+j2; p129=p128+j
	p130=p129+j5;p131=p130+j; p132=p131+j5; p133=p132+j;  p134=p133+j2; p135=p134+j3
	p136=p135+j3;p137=p136+j; p138=p137+j3; p139=p138+j3; p140=p139+j2; p141=p140+j3
	p142=p141+j3;p143=p142+j; p144=p143+j3; p145=p144+j2; p146=p145+j;  p147=p146+j3
	p148=p147+j2;p149=p148+j3;p150=p149+j4; p151=p150+j2; p152=p151+j;  p153=p152+j3
	p154=p153+j2;p155=p154+j4;p156=p155+j3; p157=p156+j2; p158=p157+j3; p159=p158+j
	p160=p159+j2;p161=p160+j3;p162=p161+j4; p163=p162+j3; p164=p163+j2; p165=p164+j
	p166=p165+j5;p167=p166+j; p168=p167+j3; p169=p168+j2; p170=p169+j;  p171=p170+j2
	p172=p171+j; p173=p172+j5;p174=p173+j;  p175=p174+j5; p176=p175+j;  p177=p176+j2
	p178=p177+j; p179=p178+j2;p180=p179+j4; p181=p180+j3; p182=p181+j2; p183=p182+j
	p184=p183+j2;p185=p184+j3;p186=p185+j3; p187=p186+j;  p188=p187+j3; p189=p188+j2
	p190=p189+j4;p191=p190+j2;p192=p191+j3; p193=p192+j4; p194=p193+j2; p195=p194+j
	p196=p195+j2;p197=p196+j; p198=p197+j2; p199=p198+j4; p200=p199+j3; p201=p200+j2
	p202=p201+j3;p203=p202+j3;p204=p203+j3; p205=p204+j;  p206=p205+j3; p207=p206+j3
	p208=p207+j2;p209=p208+j; p210=p209+j2; p211=p210+j3; p212=p211+j;  p213=p212+j3
	p214=p213+j2;p215=p214+j; p216=p215+j2; p217=p216+j;  p218=p217+j5; p219=p218+j
	p220=p219+j5;p221=p220+j; p222=p221+j3; p223=p222+j2; p224=p223+j3; p225=p224+j
	p226=p225+j3;p227=p226+j2;p228=p227+j;  p229=p228+j2; p230=p229+j3; p231=p230+j3
	p232=p231+j4;p233=p232+j2;p234=p233+j;  p235=p234+j3; p236=p235+j5; p237=p236+j4
	p238=p237+j2;p239=p238+j; p240=p239+j2; p241=p240+j;  p242=p241+j2; p243=p242+j4
	p244=p243+j5;p245=p244+j3;p246=p245+j;  p247=p246+j2; p248=p247+j4; p249=p248+j3
	p250=p249+j3;p251=p250+j2;p252=p251+j;  p253=p252+j2; p254=p253+j3; p255=p254+j
	p256=p255+j3;p257=p256+j2;p258=p257+j3; p259=p258+j;  p260=p259+j5; p261=p260+j
	p262=p261+j5;p263=p262+j; p264=p263+j2; p265=p264+j;  p266=p265+j2; p267=p266+j3
	p268=p267+j; p269=p268+j3;p270=p269+j2; p271=p270+j;  p272=p271+j2; p273=p272+j3
	p274=p273+j3;p275=p274+j; p276=p275+j3; p277=p276+j3; p278=p277+j3; p279=p278+j2
	p280=p279+j3;p281=p280+j4;p282=p281+j2; p283=p282+j;  p284=p283+j2; p285=p284+j
	p286=p285+j2;p287=p286+j4;p288=p287+j3; p289=p288+j2; p290=p289+j4; p291=p290+j2
	p292=p291+j3;p293=p292+j; p294=p293+j3; p295=p294+j3; p296=p295+j2; p297=p296+j
	p298=p297+j2;p299=p298+j3;p300=p299+j4; p301=p300+j2; p302=p301+j;  p303=p302+j2
	p304=p303+j; p305=p304+j5;p306=p305+j;  p307=p306+j5; p308=p307+j;  p309=p308+j2
	p310=p309+j; p311=p310+j2;p312=p311+j3; p313=p312+j;  p314=p313+j5; p315=p314+j
        p316=p315+j2;p317=p316+j3;p318=p317+j4; p319=p318+j3; p320=p319+j2; p321=p320+j
	p322=p321+j3;p323=p322+j2;p324=p323+j3; p325=p324+j4; p326=p325+j2; p327=p326+j3
	p328=p327+j; p329=p328+j2;p330=p329+j4; p331=p330+j3; p332=p331+j2; p333=p332+j3
	p334=p333+j; p335=p334+j2;p336=p335+j3; p337=p336+j;  p338=p337+j3; p339=p338+j3
	p340=p339+j2;p341=p340+j3;p342=p341+j3; p343=p342+j;  p344=p343+j3; p345=p344+j3
        p346=p345+j2;p347=p346+j; p348=p347+j5; p349=p348+j;  p350=p349+j5; p351=p350+j
	p352=p351+j2;p353=p352+j; p354=p353+j2; p355=p354+j3; p356=p355+j;  p357=p356+j3
	p358=p357+j2;p359=p358+j; p360=p359+j5; p361=p360+j3; p362=p361+j;  p363=p362+j3
	p364=p363+j2;p365=p364+j; p366=p365+j3; p367=p366+j2; p368=p367+j3; p369=p368+j4
	p370=p369+j2;p371=p370+j; p372=p371+j2; p373=p372+j;  p374=p373+j6; p375=p374+j3
	p376=p375+j2;p377=p376+j3;p378=p377+j;  p379=p378+j2; p380=p379+j3; p381=p380+j
	p382=p381+j6;p383=p382+j2;p384=p383+j;  p385=p384+j2; p386=p385+j4; p387=p386+j3
	p388=p387+j2;p389=p388+j; p390=p389+j2; p391=p390+j;  p392=p391+j5; p393=p392+j
	p394=p393+j5;p395=p394+j3;p396=p395+j;  p397=p396+j2; p398=p397+j3; p399=p398+j
	p400=p399+j3;p401=p400+j2;p402=p401+j;  p403=p402+j2; p404=p403+j3; p405=p404+j3
	p406=p405+j; p407=p406+j3;p408=p407+j2; p409=p408+j;  p410=p409+j5; p411=p410+j3
	p412=p411+j4;p413=p412+j3;p414=p413+j2; p415=p414+j;  p416=p415+j2; p417=p416+j4
	p418=p417+j3;p419=p418+j2;p420=p419+j3; p421=p420+j;  p422=p421+j2; p423=p422+j3
	p424=p423+j; p425=p424+j3;p426=p425+j3; p427=p426+j3; p428=p427+j2; p429=p428+j3
	p430=p429+j; p431=p430+j3;p432=p431+j2; p433=p432+j;  p434=p433+j2; p435=p434+j
	p436=p435+j5;p437=p436+j6;p438=p437+j;  p439=p438+j2; p440=p439+j ; p441=p440+j5
	p442=p441+j; p443=p442+j3;p444=p443+j2; p445=p444+j;  p446=p445+j2; p447=p446+j3
	p448=p447+j3;p449=p448+j; p450=p449+j5; p451=p450+j;  p452=p451+j3; p453=p452+j2
	p454=p453+j7;p455=p454+j2;p456=p455+j;  p457=p456+j2; p458=p457+j;  p459=p458+j2
	p460=p459+j4;p461=p460+j3;p462=p461+j2; p463=p462+j3; p464=p463+j;  p465=p464+j2
	p466=p465+j3;p467=p466+j; p468=p467+j3; p469=p468+j3; p470=p469+j2; p471=p470+j
	p472=p471+j2;p473=p472+j3;p474=p473+j;  p475=p474+j3; p476=p475+j2; p477=p476+j
	p478=p477+j2;p479=p478+j6;p480=p479+j;  k = p480-i
	x = k*(n/rescnt);  n +=1
        p1  +=x;   p2  +=x;  p3  +=x;  p4  +=x;  p5  +=x;  p6  +=x;  p7  +=x;  p8  +=x
        p9  +=x;   p10 +=x;  p11 +=x;  p12 +=x;  p13 +=x;  p14 +=x;  p15 +=x;  p16 +=x
        p17 +=x;   p18 +=x;  p19 +=x;  p20 +=x;  p21 +=x;  p22 +=x;  p23 +=x;  p24 +=x
        p25 +=x;   p26 +=x;  p27 +=x;  p28 +=x;  p29 +=x;  p30 +=x;  p31 +=x;  p32 +=x
        p33 +=x;   p34 +=x;  p35 +=x;  p36 +=x;  p37 +=x;  p38 +=x;  p39 +=x;  p40 +=x
        p41 +=x;   p42 +=x;  p43 +=x;  p44 +=x;  p45 +=x;  p46 +=x;  p47 +=x;  p48 +=x
        p49 +=x;   p50 +=x;  p51 +=x;  p52 +=x;  p53 +=x;  p54 +=x;  p55 +=x;  p56 +=x
        p57 +=x;   p58 +=x;  p59 +=x;  p60 +=x;  p61 +=x;  p62 +=x;  p63 +=x;  p64 +=x
        p65 +=x;   p66 +=x;  p67 +=x;  p68 +=x;  p69 +=x;  p70 +=x;  p71 +=x;  p72 +=x
        p73 +=x;   p74 +=x;  p75 +=x;  p76 +=x;  p77 +=x;  p78 +=x;  p79 +=x;  p80 +=x
        p81 +=x;   p82 +=x;  p83 +=x;  p84 +=x;  p85 +=x;  p86 +=x;  p87 +=x;  p88 +=x
        p89 +=x;   p90 +=x;  p91 +=x;  p92 +=x;  p93 +=x;  p94 +=x;  p95 +=x;  p96 +=x
        p97 +=x;   p98 +=x;  p99 +=x; p100 +=x; p101 +=x; p102 +=x; p103 +=x; p104 +=x
        p105 +=x; p106 +=x; p107 +=x; p108 +=x; p109 +=x; p110 +=x; p111 +=x; p112 +=x
        p113 +=x; p114 +=x; p115 +=x; p116 +=x; p117 +=x; p118 +=x; p119 +=x; p120 +=x
        p121 +=x; p122 +=x; p123 +=x; p124 +=x; p125 +=x; p126 +=x; p127 +=x; p128 +=x
        p129 +=x; p130 +=x; p131 +=x; p132 +=x; p133 +=x; p134 +=x; p135 +=x; p136 +=x
        p137 +=x; p138 +=x; p139 +=x; p140 +=x; p141 +=x; p142 +=x; p143 +=x; p144 +=x
        p145 +=x; p146 +=x; p147 +=x; p148 +=x; p149 +=x; p150 +=x; p151 +=x; p152 +=x
        p153 +=x; p154 +=x; p155 +=x; p156 +=x; p157 +=x; p158 +=x; p159 +=x; p160 +=x
        p161 +=x; p162 +=x; p163 +=x; p164 +=x; p165 +=x; p166 +=x; p167 +=x; p168 +=x
        p169 +=x; p170 +=x; p171 +=x; p172 +=x; p173 +=x; p174 +=x; p175 +=x; p176 +=x
        p177 +=x; p178 +=x; p179 +=x; p180 +=x; p181 +=x; p182 +=x; p183 +=x; p184 +=x
        p185 +=x; p186 +=x; p187 +=x; p188 +=x; p189 +=x; p190 +=x; p191 +=x; p192 +=x
        p193 +=x; p194 +=x; p195 +=x; p196 +=x; p197 +=x; p198 +=x; p199 +=x; p200 +=x
        p201 +=x; p202 +=x; p203 +=x; p204 +=x; p205 +=x; p206 +=x; p207 +=x; p208 +=x
        p209 +=x; p210 +=x; p211 +=x; p212 +=x; p213 +=x; p214 +=x; p215 +=x; p216 +=x
        p217 +=x; p218 +=x; p219 +=x; p220 +=x; p221 +=x; p222 +=x; p223 +=x; p224 +=x
        p225 +=x; p226 +=x; p227 +=x; p228 +=x; p229 +=x; p230 +=x; p231 +=x; p232 +=x
        p233 +=x; p234 +=x; p235 +=x; p236 +=x; p237 +=x; p238 +=x; p239 +=x; p240 +=x
        p241 +=x; p242 +=x; p243 +=x; p244 +=x; p245 +=x; p246 +=x; p247 +=x; p248 +=x
        p249 +=x; p250 +=x; p251 +=x; p252 +=x; p253 +=x; p254 +=x; p255 +=x; p256 +=x
        p257 +=x; p258 +=x; p259 +=x; p260 +=x; p261 +=x; p262 +=x; p263 +=x; p264 +=x
        p265 +=x; p266 +=x; p267 +=x; p268 +=x; p269 +=x; p270 +=x; p271 +=x; p272 +=x
        p273 +=x; p274 +=x; p275 +=x; p276 +=x; p277 +=x; p278 +=x; p279 +=x; p280 +=x
        p281 +=x; p282 +=x; p283 +=x; p284 +=x; p285 +=x; p286 +=x; p287 +=x; p288 +=x
        p289 +=x; p290 +=x; p291 +=x; p292 +=x; p293 +=x; p294 +=x; p295 +=x; p296 +=x
        p297 +=x; p298 +=x; p299 +=x; p300 +=x; p301 +=x; p302 +=x; p303 +=x; p304 +=x
        p305 +=x; p306 +=x; p307 +=x; p308 +=x; p309 +=x; p310 +=x; p311 +=x; p312 +=x
        p313 +=x; p314 +=x; p315 +=x; p316 +=x; p317 +=x; p318 +=x; p319 +=x; p320 +=x
        p321 +=x; p322 +=x; p323 +=x; p324 +=x; p325 +=x; p326 +=x; p327 +=x; p328 +=x
        p329 +=x; p330 +=x; p331 +=x; p332 +=x; p333 +=x; p334 +=x; p335 +=x; p336 +=x
        p337 +=x; p338 +=x; p339 +=x; p340 +=x; p341 +=x; p342 +=x; p343 +=x; p344 +=x
        p345 +=x; p346 +=x; p347 +=x; p348 +=x; p349 +=x; p350 +=x; p351 +=x; p352 +=x
        p353 +=x; p354 +=x; p355 +=x; p356 +=x; p357 +=x; p358 +=x; p359 +=x; p360 +=x
        p361 +=x; p362 +=x; p363 +=x; p364 +=x; p365 +=x; p366 +=x; p367 +=x; p368 +=x
        p369 +=x; p370 +=x; p371 +=x; p372 +=x; p373 +=x; p374 +=x; p375 +=x; p376 +=x
        p377 +=x; p378 +=x; p379 +=x; p380 +=x; p381 +=x; p382 +=x; p383 +=x; p384 +=x
        p385 +=x; p386 +=x; p387 +=x; p388 +=x; p389 +=x; p390 +=x; p391 +=x; p392 +=x
        p393 +=x; p394 +=x; p395 +=x; p396 +=x; p397 +=x; p398 +=x; p399 +=x; p400 +=x
        p401 +=x; p402 +=x; p403 +=x; p404 +=x; p405 +=x; p406 +=x; p407 +=x; p408 +=x
        p409 +=x; p410 +=x; p411 +=x; p412 +=x; p413 +=x; p414 +=x; p415 +=x; p416 +=x
        p417 +=x; p418 +=x; p419 +=x; p420 +=x; p421 +=x; p422 +=x; p423 +=x; p424 +=x
        p425 +=x; p426 +=x; p427 +=x; p428 +=x; p429 +=x; p430 +=x; p431 +=x; p432 +=x
        p433 +=x; p434 +=x; p435 +=x; p436 +=x; p437 +=x; p438 +=x; p439 +=x; p440 +=x
        p441 +=x; p442 +=x; p443 +=x; p444 +=x; p445 +=x; p446 +=x; p447 +=x; p448 +=x
        p449 +=x; p450 +=x; p451 +=x; p452 +=x; p453 +=x; p454 +=x; p455 +=x; p456 +=x
        p457 +=x; p458 +=x; p459 +=x; p460 +=x; p461 +=x; p462 +=x; p463 +=x; p464 +=x
        p465 +=x; p466 +=x; p467 +=x; p468 +=x; p469 +=x; p470 +=x; p471 +=x; p472 +=x
        p473 +=x; p474 +=x; p475 +=x; p476 +=x; p477 +=x; p478 +=x; p479 +=x; p480 +=x	
        while p480 < lndx:
           sieve[p1] = sieve[p2] = sieve[p3] = sieve[p4] = sieve[p5] = sieve[p6]=  \
           sieve[p7] = sieve[p8] = sieve[p9] = sieve[p10]= sieve[p11]= sieve[p12]= \
           sieve[p13]= sieve[p14]= sieve[p15]= sieve[p16]= sieve[p17]= sieve[p18]= \
           sieve[p19]= sieve[p20]= sieve[p21]= sieve[p22]= sieve[p23]= sieve[p24]= \
           sieve[p25]= sieve[p26]= sieve[p27]= sieve[p28]= sieve[p29]= sieve[p30]= \
           sieve[p31]= sieve[p32]= sieve[p33]= sieve[p34]= sieve[p35]= sieve[p36]= \
           sieve[p37]= sieve[p38]= sieve[p39]= sieve[p40]= sieve[p41]= sieve[p42]= \
           sieve[p43]= sieve[p44]= sieve[p45]= sieve[p46]= sieve[p47]= sieve[p48]= \
	   sieve[p49]= sieve[p50]= sieve[p51]= sieve[p52]= sieve[p53]= sieve[p54]= \
	   sieve[p55]= sieve[p56]= sieve[p57]= sieve[p58]= sieve[p59]= sieve[p60]= \
	   sieve[p61]= sieve[p62]= sieve[p63]= sieve[p64]= sieve[p65]= sieve[p66]= \
	   sieve[p67]= sieve[p68]= sieve[p69]= sieve[p70]= sieve[p71]= sieve[p72]= \
	   sieve[p73]= sieve[p74]= sieve[p75]= sieve[p76]= sieve[p77]= sieve[p78]= \
	   sieve[p79]= sieve[p80]= sieve[p81]= sieve[p82]= sieve[p83]= sieve[p84]= \
	   sieve[p85]= sieve[p86]= sieve[p87]= sieve[p88]= sieve[p89]= sieve[p90]= \
	   sieve[p91]= sieve[p92]= sieve[p93]= sieve[p94]= sieve[p95]= sieve[p96]= \
	   sieve[p97]= sieve[p98]= sieve[p99]= sieve[p100]=sieve[p101]=sieve[p102]= \
	   sieve[p103]=sieve[p104]=sieve[p105]=sieve[p106]=sieve[p107]=sieve[p108]= \
	   sieve[p109]=sieve[p110]=sieve[p111]=sieve[p112]=sieve[p113]=sieve[p114]= \
	   sieve[p115]=sieve[p116]=sieve[p117]=sieve[p118]=sieve[p119]=sieve[p120]= \
	   sieve[p121]=sieve[p122]=sieve[p123]=sieve[p124]=sieve[p125]=sieve[p126]= \
	   sieve[p127]=sieve[p128]=sieve[p129]=sieve[p130]=sieve[p131]=sieve[p132]= \
	   sieve[p133]=sieve[p134]=sieve[p135]=sieve[p136]=sieve[p137]=sieve[p138]= \
	   sieve[p139]=sieve[p140]=sieve[p141]=sieve[p142]=sieve[p143]=sieve[p144]= \
	   sieve[p145]=sieve[p146]=sieve[p147]=sieve[p148]=sieve[p149]=sieve[p150]= \
	   sieve[p151]=sieve[p152]=sieve[p153]=sieve[p154]=sieve[p155]=sieve[p156]= \
	   sieve[p157]=sieve[p158]=sieve[p159]=sieve[p160]=sieve[p161]=sieve[p162]= \
	   sieve[p163]=sieve[p164]=sieve[p165]=sieve[p166]=sieve[p167]=sieve[p168]= \
	   sieve[p169]=sieve[p170]=sieve[p171]=sieve[p172]=sieve[p173]=sieve[p174]= \
	   sieve[p175]=sieve[p176]=sieve[p177]=sieve[p178]=sieve[p179]=sieve[p180]= \
	   sieve[p181]=sieve[p182]=sieve[p183]=sieve[p184]=sieve[p185]=sieve[p186]= \
	   sieve[p187]=sieve[p188]=sieve[p189]=sieve[p190]=sieve[p191]=sieve[p192]= \
	   sieve[p193]=sieve[p194]=sieve[p195]=sieve[p196]=sieve[p197]=sieve[p198]= \
	   sieve[p199]=sieve[p200]=sieve[p201]=sieve[p202]=sieve[p203]=sieve[p204]= \
	   sieve[p205]=sieve[p206]=sieve[p207]=sieve[p208]=sieve[p209]=sieve[p210]= \
	   sieve[p211]=sieve[p212]=sieve[p213]=sieve[p214]=sieve[p215]=sieve[p216]= \
	   sieve[p217]=sieve[p218]=sieve[p219]=sieve[p220]=sieve[p221]=sieve[p222]= \
	   sieve[p223]=sieve[p224]=sieve[p225]=sieve[p226]=sieve[p227]=sieve[p228]= \
	   sieve[p229]=sieve[p230]=sieve[p231]=sieve[p232]=sieve[p233]=sieve[p234]= \
	   sieve[p235]=sieve[p236]=sieve[p237]=sieve[p238]=sieve[p239]=sieve[p240]= \
	   sieve[p241]=sieve[p242]=sieve[p243]=sieve[p244]=sieve[p245]=sieve[p246]= \
	   sieve[p247]=sieve[p248]=sieve[p249]=sieve[p250]=sieve[p251]=sieve[p252]= \
	   sieve[p253]=sieve[p254]=sieve[p255]=sieve[p256]=sieve[p257]=sieve[p258]= \
	   sieve[p259]=sieve[p260]=sieve[p261]=sieve[p262]=sieve[p263]=sieve[p264]= \
	   sieve[p265]=sieve[p266]=sieve[p267]=sieve[p268]=sieve[p269]=sieve[p270]= \
	   sieve[p271]=sieve[p272]=sieve[p273]=sieve[p274]=sieve[p275]=sieve[p276]= \
	   sieve[p277]=sieve[p278]=sieve[p279]=sieve[p280]=sieve[p281]=sieve[p282]= \
	   sieve[p283]=sieve[p284]=sieve[p285]=sieve[p286]=sieve[p287]=sieve[p288]= \
	   sieve[p289]=sieve[p290]=sieve[p291]=sieve[p292]=sieve[p293]=sieve[p294]= \
	   sieve[p295]=sieve[p296]=sieve[p297]=sieve[p298]=sieve[p299]=sieve[p300]= \
	   sieve[p301]=sieve[p302]=sieve[p303]=sieve[p304]=sieve[p305]=sieve[p306]= \
	   sieve[p307]=sieve[p308]=sieve[p309]=sieve[p310]=sieve[p311]=sieve[p312]= \
	   sieve[p313]=sieve[p314]=sieve[p315]=sieve[p316]=sieve[p317]=sieve[p318]= \
	   sieve[p319]=sieve[p320]=sieve[p321]=sieve[p322]=sieve[p323]=sieve[p324]= \
	   sieve[p325]=sieve[p326]=sieve[p327]=sieve[p328]=sieve[p329]=sieve[p330]= \
	   sieve[p331]=sieve[p332]=sieve[p333]=sieve[p334]=sieve[p335]=sieve[p336]= \
	   sieve[p337]=sieve[p338]=sieve[p339]=sieve[p340]=sieve[p341]=sieve[p342]= \
	   sieve[p343]=sieve[p344]=sieve[p345]=sieve[p346]=sieve[p347]=sieve[p348]= \
	   sieve[p349]=sieve[p350]=sieve[p351]=sieve[p352]=sieve[p353]=sieve[p354]= \
	   sieve[p355]=sieve[p356]=sieve[p357]=sieve[p358]=sieve[p359]=sieve[p360]= \
	   sieve[p361]=sieve[p362]=sieve[p363]=sieve[p364]=sieve[p365]=sieve[p366]= \
	   sieve[p367]=sieve[p368]=sieve[p369]=sieve[p370]=sieve[p371]=sieve[p372]= \
	   sieve[p373]=sieve[p374]=sieve[p375]=sieve[p376]=sieve[p377]=sieve[p378]= \
	   sieve[p379]=sieve[p380]=sieve[p381]=sieve[p382]=sieve[p383]=sieve[p384]= \
	   sieve[p385]=sieve[p386]=sieve[p387]=sieve[p388]=sieve[p389]=sieve[p390]= \
	   sieve[p391]=sieve[p392]=sieve[p393]=sieve[p394]=sieve[p395]=sieve[p396]= \
	   sieve[p397]=sieve[p398]=sieve[p399]=sieve[p400]=sieve[p401]=sieve[p402]= \
	   sieve[p403]=sieve[p404]=sieve[p405]=sieve[p406]=sieve[p407]=sieve[p408]= \
	   sieve[p409]=sieve[p410]=sieve[p411]=sieve[p412]=sieve[p413]=sieve[p414]= \
	   sieve[p415]=sieve[p416]=sieve[p417]=sieve[p418]=sieve[p419]=sieve[p420]= \
	   sieve[p421]=sieve[p422]=sieve[p423]=sieve[p424]=sieve[p425]=sieve[p426]= \
	   sieve[p427]=sieve[p428]=sieve[p429]=sieve[p430]=sieve[p431]=sieve[p432]= \
	   sieve[p433]=sieve[p434]=sieve[p435]=sieve[p436]=sieve[p437]=sieve[p438]= \
	   sieve[p439]=sieve[p440]=sieve[p441]=sieve[p442]=sieve[p443]=sieve[p444]= \
	   sieve[p445]=sieve[p446]=sieve[p447]=sieve[p448]=sieve[p449]=sieve[p450]= \
	   sieve[p451]=sieve[p452]=sieve[p453]=sieve[p454]=sieve[p455]=sieve[p456]= \
	   sieve[p457]=sieve[p458]=sieve[p459]=sieve[p460]=sieve[p461]=sieve[p462]= \
	   sieve[p463]=sieve[p464]=sieve[p465]=sieve[p466]=sieve[p467]=sieve[p468]= \
	   sieve[p469]=sieve[p470]=sieve[p471]=sieve[p472]=sieve[p473]=sieve[p474]= \
	   sieve[p475]=sieve[p476]=sieve[p477]=sieve[p478]=sieve[p479]=sieve[p480]= False
           p1   +=k; p2   +=k; p3   +=k; p4   +=k; p5   +=k; p6   +=k; p7   +=k; p8   +=k
           p9   +=k; p10  +=k; p11  +=k; p12  +=k; p13  +=k; p14  +=k; p15  +=k; p16  +=k
           p17  +=k; p18  +=k; p19  +=k; p20  +=k; p21  +=k; p22  +=k; p23  +=k; p24  +=k
           p25  +=k; p26  +=k; p27  +=k; p28  +=k; p29  +=k; p30  +=k; p31  +=k; p32  +=k
           p33  +=k; p34  +=k; p35  +=k; p36  +=k; p37  +=k; p38  +=k; p39  +=k; p40  +=k
           p41  +=k; p42  +=k; p43  +=k; p44  +=k; p45  +=k; p46  +=k; p47  +=k; p48  +=k
           p49  +=k; p50  +=k; p51  +=k; p52  +=k; p53  +=k; p54  +=k; p55  +=k; p56  +=k
           p57  +=k; p58  +=k; p59  +=k; p60  +=k; p61  +=k; p62  +=k; p63  +=k; p64  +=k
           p65  +=k; p66  +=k; p67  +=k; p68  +=k; p69  +=k; p70  +=k; p71  +=k; p72  +=k
           p73  +=k; p74  +=k; p75  +=k; p76  +=k; p77  +=k; p78  +=k; p79  +=k; p80  +=k
           p81  +=k; p82  +=k; p83  +=k; p84  +=k; p85  +=k; p86  +=k; p87  +=k; p88  +=k
           p89  +=k; p90  +=k; p91  +=k; p92  +=k; p93  +=k; p94  +=k; p95  +=k; p96  +=k
           p97  +=k; p98  +=k; p99  +=k; p100 +=k; p101 +=k; p102 +=k; p103 +=k; p104 +=k
           p105 +=k; p106 +=k; p107 +=k; p108 +=k; p109 +=k; p110 +=k; p111 +=k; p112 +=k
           p113 +=k; p114 +=k; p115 +=k; p116 +=k; p117 +=k; p118 +=k; p119 +=k; p120 +=k
           p121 +=k; p122 +=k; p123 +=k; p124 +=k; p125 +=k; p126 +=k; p127 +=k; p128 +=k
           p129 +=k; p130 +=k; p131 +=k; p132 +=k; p133 +=k; p134 +=k; p135 +=k; p136 +=k
           p137 +=k; p138 +=k; p139 +=k; p140 +=k; p141 +=k; p142 +=k; p143 +=k; p144 +=k
           p145 +=k; p146 +=k; p147 +=k; p148 +=k; p149 +=k; p150 +=k; p151 +=k; p152 +=k
           p153 +=k; p154 +=k; p155 +=k; p156 +=k; p157 +=k; p158 +=k; p159 +=k; p160 +=k
           p161 +=k; p162 +=k; p163 +=k; p164 +=k; p165 +=k; p166 +=k; p167 +=k; p168 +=k
           p169 +=k; p170 +=k; p171 +=k; p172 +=k; p173 +=k; p174 +=k; p175 +=k; p176 +=k
           p177 +=k; p178 +=k; p179 +=k; p180 +=k; p181 +=k; p182 +=k; p183 +=k; p184 +=k
           p185 +=k; p186 +=k; p187 +=k; p188 +=k; p189 +=k; p190 +=k; p191 +=k; p192 +=k
           p193 +=k; p194 +=k; p195 +=k; p196 +=k; p197 +=k; p198 +=k; p199 +=k; p200 +=k
           p201 +=k; p202 +=k; p203 +=k; p204 +=k; p205 +=k; p206 +=k; p207 +=k; p208 +=k
           p209 +=k; p210 +=k; p211 +=k; p212 +=k; p213 +=k; p214 +=k; p215 +=k; p216 +=k
           p217 +=k; p218 +=k; p219 +=k; p220 +=k; p221 +=k; p222 +=k; p223 +=k; p224 +=k
           p225 +=k; p226 +=k; p227 +=k; p228 +=k; p229 +=k; p230 +=k; p231 +=k; p232 +=k
           p233 +=k; p234 +=k; p235 +=k; p236 +=k; p237 +=k; p238 +=k; p239 +=k; p240 +=k
           p241 +=k; p242 +=k; p243 +=k; p244 +=k; p245 +=k; p246 +=k; p247 +=k; p248 +=k
           p249 +=k; p250 +=k; p251 +=k; p252 +=k; p253 +=k; p254 +=k; p255 +=k; p256 +=k
           p257 +=k; p258 +=k; p259 +=k; p260 +=k; p261 +=k; p262 +=k; p263 +=k; p264 +=k
           p265 +=k; p266 +=k; p267 +=k; p268 +=k; p269 +=k; p270 +=k; p271 +=k; p272 +=k
           p273 +=k; p274 +=k; p275 +=k; p276 +=k; p277 +=k; p278 +=k; p279 +=k; p280 +=k
           p281 +=k; p282 +=k; p283 +=k; p284 +=k; p285 +=k; p286 +=k; p287 +=k; p288 +=k
           p289 +=k; p290 +=k; p291 +=k; p292 +=k; p293 +=k; p294 +=k; p295 +=k; p296 +=k
           p297 +=k; p298 +=k; p299 +=k; p300 +=k; p301 +=k; p302 +=k; p303 +=k; p304 +=k
           p305 +=k; p306 +=k; p307 +=k; p308 +=k; p309 +=k; p310 +=k; p311 +=k; p312 +=k
           p313 +=k; p314 +=k; p315 +=k; p316 +=k; p317 +=k; p318 +=k; p319 +=k; p320 +=k
           p321 +=k; p322 +=k; p323 +=k; p324 +=k; p325 +=k; p326 +=k; p327 +=k; p328 +=k
           p329 +=k; p330 +=k; p331 +=k; p332 +=k; p333 +=k; p334 +=k; p335 +=k; p336 +=k
           p337 +=k; p338 +=k; p339 +=k; p340 +=k; p341 +=k; p342 +=k; p343 +=k; p344 +=k
           p345 +=k; p346 +=k; p347 +=k; p348 +=k; p349 +=k; p350 +=k; p351 +=k; p352 +=k
           p353 +=k; p354 +=k; p355 +=k; p356 +=k; p357 +=k; p358 +=k; p359 +=k; p360 +=k
           p361 +=k; p362 +=k; p363 +=k; p364 +=k; p365 +=k; p366 +=k; p367 +=k; p368 +=k
           p369 +=k; p370 +=k; p371 +=k; p372 +=k; p373 +=k; p374 +=k; p375 +=k; p376 +=k
           p377 +=k; p378 +=k; p379 +=k; p380 +=k; p381 +=k; p382 +=k; p383 +=k; p384 +=k
           p385 +=k; p386 +=k; p387 +=k; p388 +=k; p389 +=k; p390 +=k; p391 +=k; p392 +=k
           p393 +=k; p394 +=k; p395 +=k; p396 +=k; p397 +=k; p398 +=k; p399 +=k; p400 +=k
           p401 +=k; p402 +=k; p403 +=k; p404 +=k; p405 +=k; p406 +=k; p407 +=k; p408 +=k
           p409 +=k; p410 +=k; p411 +=k; p412 +=k; p413 +=k; p414 +=k; p415 +=k; p416 +=k
           p417 +=k; p418 +=k; p419 +=k; p420 +=k; p421 +=k; p422 +=k; p423 +=k; p424 +=k
           p425 +=k; p426 +=k; p427 +=k; p428 +=k; p429 +=k; p430 +=k; p431 +=k; p432 +=k
           p433 +=k; p434 +=k; p435 +=k; p436 +=k; p437 +=k; p438 +=k; p439 +=k; p440 +=k
           p441 +=k; p442 +=k; p443 +=k; p444 +=k; p445 +=k; p446 +=k; p447 +=k; p448 +=k
           p449 +=k; p450 +=k; p451 +=k; p452 +=k; p453 +=k; p454 +=k; p455 +=k; p456 +=k
           p457 +=k; p458 +=k; p459 +=k; p460 +=k; p461 +=k; p462 +=k; p463 +=k; p464 +=k
           p465 +=k; p466 +=k; p467 +=k; p468 +=k; p469 +=k; p470 +=k; p471 +=k; p472 +=k
           p473 +=k; p474 +=k; p475 +=k; p476 +=k; p477 +=k; p478 +=k; p479 +=k; p480 +=k
	while True:
	  if p1   > lndx: break
	  sieve[p1] = False
          if p2   > lndx: break
          sieve[p2] = False
          if p3   > lndx: break
	  sieve[p3] = False
          if p4   > lndx: break
	  sieve[p4] = False
          if p5   > lndx: break
	  sieve[p5] = False
          if p6   > lndx: break
	  sieve[p6] = False
          if p7   > lndx: break
          sieve[p7] = False
          if p8   > lndx: break
	  sieve[p8]   = False
          if p9   > lndx: break
	  sieve[p9]   = False
          if p10  > lndx: break
	  sieve[p10]  = False
          if p11  > lndx: break
	  sieve[p11]  = False
          if p12  > lndx: break
	  sieve[p12]  = False
          if p13  > lndx: break
	  sieve[p13]  = False
          if p14  > lndx: break
	  sieve[p14]  = False
          if p15  > lndx: break
	  sieve[p15]  = False
          if p16  > lndx: break
	  sieve[p16]  = False
          if p17  > lndx: break
	  sieve[p17]  = False
          if p18  > lndx: break
	  sieve[p18]  = False
          if p19  > lndx: break
	  sieve[p19]  = False
          if p20  > lndx: break
	  sieve[p20]  = False
          if p21  > lndx: break
	  sieve[p21]  = False
          if p22  > lndx: break
	  sieve[p22]  = False
          if p23  > lndx: break
	  sieve[p23]  = False
          if p24  > lndx: break
	  sieve[p24]  = False
          if p25  > lndx: break
	  sieve[p25]  = False
          if p26  > lndx: break
	  sieve[p26]  = False
          if p27  > lndx: break
	  sieve[p27]  = False
          if p28  > lndx: break
	  sieve[p28]  = False
          if p29  > lndx: break
	  sieve[p29]  = False
          if p30  > lndx: break
	  sieve[p30]  = False
          if p31  > lndx: break
	  sieve[p31]  = False
          if p32  > lndx: break
	  sieve[p32]  = False
          if p33  > lndx: break
	  sieve[p33]  = False
          if p34  > lndx: break
	  sieve[p34]  = False
          if p35  > lndx: break
	  sieve[p35]  = False
          if p36  > lndx: break
	  sieve[p36]  = False
          if p37  > lndx: break
	  sieve[p37]  = False
          if p38  > lndx: break
	  sieve[p38]  = False
          if p39  > lndx: break
	  sieve[p39]  = False
          if p40  > lndx: break
	  sieve[p40]  = False
          if p41  > lndx: break
	  sieve[p41]  = False
          if p42  > lndx: break
	  sieve[p42]  = False
          if p43  > lndx: break
	  sieve[p43]  = False
          if p44  > lndx: break
	  sieve[p44]  = False
          if p45  > lndx: break
	  sieve[p45]  = False
          if p46  > lndx: break
	  sieve[p46]  = False
          if p47  > lndx: break
	  sieve[p47]  = False
          if p48  > lndx: break
	  sieve[p48]  = False
          if p49  > lndx: break
	  sieve[p49]  = False
          if p50  > lndx: break
	  sieve[p50]  = False
          if p51  > lndx: break
	  sieve[p51]  = False
          if p52  > lndx: break
	  sieve[p52]  = False
          if p53  > lndx: break
	  sieve[p53]  = False
          if p54  > lndx: break
	  sieve[p54]  = False
          if p55  > lndx: break
	  sieve[p55]  = False
          if p56  > lndx: break
	  sieve[p56]  = False
          if p57  > lndx: break
	  sieve[p57]  = False
          if p58  > lndx: break
	  sieve[p58]  = False
          if p59  > lndx: break
	  sieve[p59]  = False
          if p60  > lndx: break
	  sieve[p60]  = False
          if p61  > lndx: break
	  sieve[p61]  = False
          if p62  > lndx: break
	  sieve[p62]  = False
          if p63  > lndx: break
	  sieve[p63]  = False
          if p64  > lndx: break
	  sieve[p64]  = False
          if p65  > lndx: break
	  sieve[p65]  = False
          if p66  > lndx: break
	  sieve[p66]  = False
          if p67  > lndx: break
	  sieve[p67]  = False
          if p68  > lndx: break
	  sieve[p68]  = False
          if p69  > lndx: break
	  sieve[p69]  = False
          if p70  > lndx: break
	  sieve[p70]  = False
          if p71  > lndx: break
	  sieve[p71]  = False
          if p72  > lndx: break
	  sieve[p72]  = False
          if p73  > lndx: break
	  sieve[p73]  = False
          if p74  > lndx: break
	  sieve[p74]  = False
          if p75  > lndx: break
	  sieve[p75]  = False
          if p76  > lndx: break
	  sieve[p76]  = False
          if p77  > lndx: break
	  sieve[p77]  = False
          if p78  > lndx: break
	  sieve[p78]  = False
          if p79  > lndx: break
	  sieve[p79]  = False
          if p80  > lndx: break
	  sieve[p80]  = False
          if p81  > lndx: break
	  sieve[p81]  = False
          if p82  > lndx: break
	  sieve[p82]  = False
          if p83  > lndx: break
	  sieve[p83]  = False
          if p84  > lndx: break
	  sieve[p84]  = False
          if p85  > lndx: break
	  sieve[p85]  = False
          if p86  > lndx: break
	  sieve[p86]  = False
          if p87  > lndx: break
	  sieve[p87]  = False
          if p88  > lndx: break
	  sieve[p88]  = False
          if p89  > lndx: break
	  sieve[p89]  = False
          if p90  > lndx: break
	  sieve[p90]  = False
          if p91  > lndx: break
	  sieve[p91]  = False
          if p92  > lndx: break
	  sieve[p92]  = False
          if p93  > lndx: break
	  sieve[p93]  = False
          if p94  > lndx: break
	  sieve[p94]  = False
          if p95  > lndx: break
	  sieve[p95]  = False
          if p96  > lndx: break
	  sieve[p96]  = False
          if p97  > lndx: break
	  sieve[p97]  = False
          if p98  > lndx: break
	  sieve[p98]  = False
          if p99  > lndx: break
	  sieve[p99]  = False
          if p100 > lndx: break
	  sieve[p100] = False
	  if p101 > lndx: break
	  sieve[p101] = False
          if p102 > lndx: break
          sieve[p102] = False
          if p103 > lndx: break
	  sieve[p103] = False
          if p104 > lndx: break
	  sieve[p104] = False
          if p105 > lndx: break
	  sieve[p105] = False
          if p106 > lndx: break
	  sieve[p106] = False
          if p107 > lndx: break
          sieve[p107] = False
          if p108 > lndx: break
	  sieve[p108] = False
          if p109 > lndx: break
	  sieve[p109] = False
          if p110 > lndx: break
	  sieve[p110] = False
          if p111 > lndx: break
	  sieve[p111] = False
          if p112 > lndx: break
	  sieve[p112] = False
          if p113 > lndx: break
	  sieve[p113] = False
          if p114 > lndx: break
	  sieve[p114] = False
          if p115 > lndx: break
	  sieve[p115] = False
          if p116 > lndx: break
	  sieve[p116] = False
          if p117 > lndx: break
	  sieve[p117] = False
          if p118 > lndx: break
	  sieve[p118] = False
          if p119 > lndx: break
	  sieve[p119] = False
          if p120 > lndx: break
	  sieve[p120] = False
          if p121 > lndx: break
	  sieve[p121] = False
          if p122 > lndx: break
	  sieve[p122] = False
          if p123 > lndx: break
	  sieve[p123] = False
          if p124 > lndx: break
	  sieve[p124] = False
          if p125 > lndx: break
	  sieve[p125] = False
          if p126 > lndx: break
	  sieve[p126] = False
          if p127 > lndx: break
	  sieve[p127] = False
          if p128 > lndx: break
	  sieve[p128] = False
          if p129 > lndx: break
	  sieve[p129] = False
          if p130 > lndx: break
	  sieve[p130] = False
          if p131 > lndx: break
	  sieve[p131] = False
          if p132 > lndx: break
	  sieve[p132] = False
          if p133 > lndx: break
	  sieve[p133] = False
          if p134 > lndx: break
	  sieve[p134] = False
          if p135 > lndx: break
	  sieve[p135] = False
          if p136 > lndx: break
	  sieve[p136] = False
          if p137 > lndx: break
	  sieve[p137] = False
          if p138 > lndx: break
	  sieve[p138] = False
          if p139 > lndx: break
	  sieve[p139] = False
          if p140 > lndx: break
	  sieve[p140] = False
          if p141 > lndx: break
	  sieve[p141] = False
          if p142 > lndx: break
	  sieve[p142] = False
          if p143 > lndx: break
	  sieve[p143] = False
          if p144 > lndx: break
	  sieve[p144] = False
          if p145 > lndx: break
	  sieve[p145] = False
          if p146 > lndx: break
	  sieve[p146] = False
          if p147 > lndx: break
	  sieve[p147] = False
          if p148 > lndx: break
	  sieve[p148] = False
          if p149 > lndx: break
	  sieve[p149] = False
          if p150 > lndx: break
	  sieve[p150] = False
          if p151 > lndx: break
	  sieve[p151] = False
          if p152 > lndx: break
	  sieve[p152] = False
          if p153 > lndx: break
	  sieve[p153] = False
          if p154 > lndx: break
	  sieve[p154] = False
          if p155 > lndx: break
	  sieve[p155] = False
          if p156 > lndx: break
	  sieve[p156] = False
          if p157 > lndx: break
	  sieve[p157] = False
          if p158 > lndx: break
	  sieve[p158] = False
          if p159 > lndx: break
	  sieve[p159] = False
          if p160 > lndx: break
	  sieve[p160] = False
          if p161 > lndx: break
	  sieve[p161] = False
          if p162 > lndx: break
	  sieve[p162] = False
          if p163 > lndx: break
	  sieve[p163] = False
          if p164 > lndx: break
	  sieve[p164] = False
          if p165 > lndx: break
	  sieve[p165] = False
          if p166 > lndx: break
	  sieve[p166] = False
          if p167 > lndx: break
	  sieve[p167] = False
          if p168 > lndx: break
	  sieve[p168] = False
          if p169 > lndx: break
	  sieve[p169] = False
          if p170 > lndx: break
	  sieve[p170] = False
          if p171 > lndx: break
	  sieve[p171] = False
          if p172 > lndx: break
	  sieve[p172] = False
          if p173 > lndx: break
	  sieve[p173] = False
          if p174 > lndx: break
	  sieve[p174] = False
          if p175 > lndx: break
	  sieve[p175] = False
          if p176 > lndx: break
	  sieve[p176] = False
          if p177 > lndx: break
	  sieve[p177] = False
          if p178 > lndx: break
	  sieve[p178] = False
          if p179 > lndx: break
	  sieve[p179] = False
          if p180 > lndx: break
	  sieve[p180] = False
          if p181 > lndx: break
	  sieve[p181] = False
          if p182 > lndx: break
	  sieve[p182] = False
          if p183 > lndx: break
	  sieve[p183] = False
          if p184 > lndx: break
	  sieve[p184] = False
          if p185 > lndx: break
	  sieve[p185] = False
          if p186 > lndx: break
	  sieve[p186] = False
          if p187 > lndx: break
	  sieve[p187] = False
          if p188 > lndx: break
	  sieve[p188] = False
          if p189 > lndx: break
	  sieve[p189] = False
          if p190 > lndx: break
	  sieve[p190] = False
          if p191 > lndx: break
	  sieve[p191] = False
          if p192 > lndx: break
	  sieve[p192] = False
          if p193 > lndx: break
	  sieve[p193] = False
          if p194 > lndx: break
	  sieve[p194] = False
          if p195 > lndx: break
	  sieve[p195] = False
          if p196 > lndx: break
	  sieve[p196] = False
          if p197 > lndx: break
	  sieve[p197] = False
          if p198 > lndx: break
	  sieve[p198] = False
          if p199 > lndx: break
	  sieve[p199] = False
          if p200 > lndx: break
	  sieve[p200] = False
	  if p201 > lndx: break
	  sieve[p201] = False
          if p202 > lndx: break
          sieve[p202] = False
          if p203 > lndx: break
	  sieve[p203] = False
          if p204 > lndx: break
	  sieve[p204] = False
          if p205 > lndx: break
	  sieve[p205] = False
          if p206 > lndx: break
	  sieve[p206] = False
          if p207 > lndx: break
          sieve[p207] = False
          if p208 > lndx: break
	  sieve[p208] = False
          if p209 > lndx: break
	  sieve[p209] = False
          if p210 > lndx: break
	  sieve[p210] = False
          if p211 > lndx: break
	  sieve[p211] = False
          if p212 > lndx: break
	  sieve[p212] = False
          if p213 > lndx: break
	  sieve[p213] = False
          if p214 > lndx: break
	  sieve[p214] = False
          if p215 > lndx: break
	  sieve[p215] = False
          if p216 > lndx: break
	  sieve[p216] = False
          if p217 > lndx: break
	  sieve[p217] = False
          if p218 > lndx: break
	  sieve[p218] = False
          if p219 > lndx: break
	  sieve[p219] = False
          if p220 > lndx: break
	  sieve[p220] = False
          if p221 > lndx: break
	  sieve[p221] = False
          if p222 > lndx: break
	  sieve[p222] = False
          if p223 > lndx: break
	  sieve[p223] = False
          if p224 > lndx: break
	  sieve[p224] = False
          if p225 > lndx: break
	  sieve[p225] = False
          if p226 > lndx: break
	  sieve[p226] = False
          if p227 > lndx: break
	  sieve[p227] = False
          if p228 > lndx: break
	  sieve[p228] = False
          if p229 > lndx: break
	  sieve[p229] = False
          if p230 > lndx: break
	  sieve[p230] = False
          if p231 > lndx: break
	  sieve[p231] = False
          if p232 > lndx: break
	  sieve[p232] = False
          if p233 > lndx: break
	  sieve[p233] = False
          if p234 > lndx: break
	  sieve[p234] = False
          if p235 > lndx: break
	  sieve[p235] = False
          if p236 > lndx: break
	  sieve[p236] = False
          if p237 > lndx: break
	  sieve[p237] = False
          if p238 > lndx: break
	  sieve[p238] = False
          if p239 > lndx: break
	  sieve[p239] = False
          if p240 > lndx: break
	  sieve[p240] = False
          if p241 > lndx: break
	  sieve[p241] = False
          if p242 > lndx: break
	  sieve[p242] = False
          if p243 > lndx: break
	  sieve[p243] = False
          if p244 > lndx: break
	  sieve[p244] = False
          if p245 > lndx: break
	  sieve[p245] = False
          if p246 > lndx: break
	  sieve[p246] = False
          if p247 > lndx: break
	  sieve[p247] = False
          if p248 > lndx: break
	  sieve[p248] = False
          if p249 > lndx: break
	  sieve[p249] = False
          if p250 > lndx: break
	  sieve[p250] = False
          if p251 > lndx: break
	  sieve[p251] = False
          if p252 > lndx: break
	  sieve[p252] = False
          if p253 > lndx: break
	  sieve[p253] = False
          if p254 > lndx: break
	  sieve[p254] = False
          if p255 > lndx: break
	  sieve[p255] = False
          if p256 > lndx: break
	  sieve[p256] = False
          if p257 > lndx: break
	  sieve[p257] = False
          if p258 > lndx: break
	  sieve[p258] = False
          if p259 > lndx: break
	  sieve[p259] = False
          if p260 > lndx: break
	  sieve[p260] = False
          if p261 > lndx: break
	  sieve[p261] = False
          if p262 > lndx: break
	  sieve[p262] = False
          if p263 > lndx: break
	  sieve[p263] = False
          if p264 > lndx: break
	  sieve[p264] = False
          if p265 > lndx: break
	  sieve[p265] = False
          if p266 > lndx: break
	  sieve[p266] = False
          if p267 > lndx: break
	  sieve[p267] = False
          if p268 > lndx: break
	  sieve[p268] = False
          if p269 > lndx: break
	  sieve[p269] = False
          if p270 > lndx: break
	  sieve[p270] = False
          if p271 > lndx: break
	  sieve[p271] = False
          if p272 > lndx: break
	  sieve[p272] = False
          if p273 > lndx: break
	  sieve[p273] = False
          if p274 > lndx: break
	  sieve[p274] = False
          if p275 > lndx: break
	  sieve[p275] = False
          if p276 > lndx: break
	  sieve[p276] = False
          if p277 > lndx: break
	  sieve[p277] = False
          if p278 > lndx: break
	  sieve[p278] = False
          if p279 > lndx: break
	  sieve[p279] = False
          if p280 > lndx: break
	  sieve[p280] = False
          if p281 > lndx: break
	  sieve[p281] = False
          if p282 > lndx: break
	  sieve[p282] = False
          if p283 > lndx: break
	  sieve[p283] = False
          if p284 > lndx: break
	  sieve[p284] = False
          if p285 > lndx: break
	  sieve[p285] = False
          if p286 > lndx: break
	  sieve[p286] = False
          if p287 > lndx: break
	  sieve[p287] = False
          if p288 > lndx: break
	  sieve[p288] = False
          if p289 > lndx: break
	  sieve[p289] = False
          if p290 > lndx: break
	  sieve[p290] = False
          if p291 > lndx: break
	  sieve[p291] = False
          if p292 > lndx: break
	  sieve[p292] = False
          if p293 > lndx: break
	  sieve[p293] = False
          if p294 > lndx: break
	  sieve[p294] = False
          if p295 > lndx: break
	  sieve[p295] = False
          if p296 > lndx: break
	  sieve[p296] = False
          if p297 > lndx: break
	  sieve[p297] = False
          if p298 > lndx: break
	  sieve[p298] = False
          if p299 > lndx: break
	  sieve[p299] = False
          if p300 > lndx: break
	  sieve[p300] = False
	  if p301 > lndx: break
	  sieve[p301] = False
          if p302 > lndx: break
          sieve[p302] = False
          if p303 > lndx: break
	  sieve[p303] = False
          if p304 > lndx: break
	  sieve[p304] = False
          if p305 > lndx: break
	  sieve[p305] = False
          if p306 > lndx: break
	  sieve[p306] = False
          if p307 > lndx: break
          sieve[p307] = False
          if p308 > lndx: break
	  sieve[p308] = False
          if p309 > lndx: break
	  sieve[p309] = False
          if p310 > lndx: break
	  sieve[p310] = False
          if p311 > lndx: break
	  sieve[p311] = False
          if p312 > lndx: break
	  sieve[p312] = False
          if p313 > lndx: break
	  sieve[p313] = False
          if p314 > lndx: break
	  sieve[p314] = False
          if p315 > lndx: break
	  sieve[p315] = False
          if p316 > lndx: break
	  sieve[p316] = False
          if p317 > lndx: break
	  sieve[p317] = False
          if p318 > lndx: break
	  sieve[p318] = False
          if p319 > lndx: break
	  sieve[p319] = False
          if p320 > lndx: break
	  sieve[p320] = False
          if p321 > lndx: break
	  sieve[p321] = False
          if p322 > lndx: break
	  sieve[p322] = False
          if p323 > lndx: break
	  sieve[p323] = False
          if p324 > lndx: break
	  sieve[p324] = False
          if p325 > lndx: break
	  sieve[p325] = False
          if p326 > lndx: break
	  sieve[p326] = False
          if p327 > lndx: break
	  sieve[p327] = False
          if p328 > lndx: break
	  sieve[p328] = False
          if p329 > lndx: break
	  sieve[p329] = False
          if p330 > lndx: break
	  sieve[p330] = False
          if p331 > lndx: break
	  sieve[p331] = False
          if p332 > lndx: break
	  sieve[p332] = False
          if p333 > lndx: break
	  sieve[p333] = False
          if p334 > lndx: break
	  sieve[p334] = False
          if p335 > lndx: break
	  sieve[p335] = False
          if p336 > lndx: break
	  sieve[p336] = False
          if p337 > lndx: break
	  sieve[p337] = False
          if p338 > lndx: break
	  sieve[p338] = False
          if p339 > lndx: break
	  sieve[p339] = False
          if p340 > lndx: break
	  sieve[p340] = False
          if p341 > lndx: break
	  sieve[p341] = False
          if p342 > lndx: break
	  sieve[p342] = False
          if p343 > lndx: break
	  sieve[p343] = False
          if p344 > lndx: break
	  sieve[p344] = False
          if p345 > lndx: break
	  sieve[p345] = False
          if p346 > lndx: break
	  sieve[p346] = False
          if p347 > lndx: break
	  sieve[p347] = False
          if p348 > lndx: break
	  sieve[p348] = False
          if p349 > lndx: break
	  sieve[p349] = False
          if p350 > lndx: break
	  sieve[p350] = False
          if p351 > lndx: break
	  sieve[p351] = False
          if p352 > lndx: break
	  sieve[p352] = False
          if p353 > lndx: break
	  sieve[p353] = False
          if p354 > lndx: break
	  sieve[p354] = False
          if p355 > lndx: break
	  sieve[p355] = False
          if p356 > lndx: break
	  sieve[p356] = False
          if p357 > lndx: break
	  sieve[p357] = False
          if p358 > lndx: break
	  sieve[p358] = False
          if p359 > lndx: break
	  sieve[p359] = False
          if p360 > lndx: break
	  sieve[p360] = False
          if p361 > lndx: break
	  sieve[p361] = False
          if p362 > lndx: break
	  sieve[p362] = False
          if p363 > lndx: break
	  sieve[p363] = False
          if p364 > lndx: break
	  sieve[p364] = False
          if p365 > lndx: break
	  sieve[p365] = False
          if p366 > lndx: break
	  sieve[p366] = False
          if p367 > lndx: break
	  sieve[p367] = False
          if p368 > lndx: break
	  sieve[p368] = False
          if p369 > lndx: break
	  sieve[p369] = False
          if p370 > lndx: break
	  sieve[p370] = False
          if p371 > lndx: break
	  sieve[p371] = False
          if p372 > lndx: break
	  sieve[p372] = False
          if p373 > lndx: break
	  sieve[p373] = False
          if p374 > lndx: break
	  sieve[p374] = False
          if p375 > lndx: break
	  sieve[p375] = False
          if p376 > lndx: break
	  sieve[p376] = False
          if p377 > lndx: break
	  sieve[p377] = False
          if p378 > lndx: break
	  sieve[p378] = False
          if p379 > lndx: break
	  sieve[p379] = False
          if p380 > lndx: break
	  sieve[p380] = False
          if p381 > lndx: break
	  sieve[p381] = False
          if p382 > lndx: break
	  sieve[p382] = False
          if p383 > lndx: break
	  sieve[p383] = False
          if p384 > lndx: break
	  sieve[p384] = False
          if p385 > lndx: break
	  sieve[p385] = False
          if p386 > lndx: break
	  sieve[p386] = False
          if p387 > lndx: break
	  sieve[p387] = False
          if p388 > lndx: break
	  sieve[p388] = False
          if p389 > lndx: break
	  sieve[p389] = False
          if p390 > lndx: break
	  sieve[p390] = False
          if p391 > lndx: break
	  sieve[p391] = False
          if p392 > lndx: break
	  sieve[p392] = False
          if p393 > lndx: break
	  sieve[p393] = False
          if p394 > lndx: break
	  sieve[p394] = False
          if p395 > lndx: break
	  sieve[p395] = False
          if p396 > lndx: break
	  sieve[p396] = False
          if p397 > lndx: break
	  sieve[p397] = False
          if p398 > lndx: break
	  sieve[p398] = False
          if p399 > lndx: break
	  sieve[p399] = False
          if p400 > lndx: break
	  sieve[p400] = False
	  if p401 > lndx: break
	  sieve[p401] = False
          if p402 > lndx: break
          sieve[p402] = False
          if p403 > lndx: break
	  sieve[p403] = False
          if p404 > lndx: break
	  sieve[p404] = False
          if p405 > lndx: break
	  sieve[p405] = False
          if p406 > lndx: break
	  sieve[p406] = False
          if p407 > lndx: break
          sieve[p407] = False
          if p408 > lndx: break
	  sieve[p408] = False
          if p409 > lndx: break
	  sieve[p409] = False
          if p410 > lndx: break
	  sieve[p410] = False
          if p411 > lndx: break
	  sieve[p411] = False
          if p412 > lndx: break
	  sieve[p412] = False
          if p413 > lndx: break
	  sieve[p413] = False
          if p414 > lndx: break
	  sieve[p414] = False
          if p415 > lndx: break
	  sieve[p415] = False
          if p416 > lndx: break
	  sieve[p416] = False
          if p417 > lndx: break
	  sieve[p417] = False
          if p418 > lndx: break
	  sieve[p418] = False
          if p419 > lndx: break
	  sieve[p419] = False
          if p420 > lndx: break
	  sieve[p420] = False
          if p421 > lndx: break
	  sieve[p421] = False
          if p422 > lndx: break
	  sieve[p422] = False
          if p423 > lndx: break
	  sieve[p423] = False
          if p424 > lndx: break
	  sieve[p424] = False
          if p425 > lndx: break
	  sieve[p425] = False
          if p426 > lndx: break
	  sieve[p426] = False
          if p427 > lndx: break
	  sieve[p427] = False
          if p428 > lndx: break
	  sieve[p428] = False
          if p429 > lndx: break
	  sieve[p429] = False
          if p430 > lndx: break
	  sieve[p430] = False
          if p431 > lndx: break
	  sieve[p431] = False
          if p432 > lndx: break
	  sieve[p432] = False
          if p433 > lndx: break
	  sieve[p433] = False
          if p434 > lndx: break
	  sieve[p434] = False
          if p435 > lndx: break
	  sieve[p435] = False
          if p436 > lndx: break
	  sieve[p436] = False
          if p437 > lndx: break
	  sieve[p437] = False
          if p438 > lndx: break
	  sieve[p438] = False
          if p439 > lndx: break
	  sieve[p439] = False
          if p440 > lndx: break
	  sieve[p440] = False
          if p441 > lndx: break
	  sieve[p441] = False
          if p442 > lndx: break
	  sieve[p442] = False
          if p443 > lndx: break
	  sieve[p443] = False
          if p444 > lndx: break
	  sieve[p444] = False
          if p445 > lndx: break
	  sieve[p445] = False
          if p446 > lndx: break
	  sieve[p446] = False
          if p447 > lndx: break
	  sieve[p447] = False
          if p448 > lndx: break
	  sieve[p448] = False
          if p449 > lndx: break
	  sieve[p449] = False
          if p450 > lndx: break
	  sieve[p450] = False
          if p451 > lndx: break
	  sieve[p451] = False
          if p452 > lndx: break
	  sieve[p452] = False
          if p453 > lndx: break
	  sieve[p453] = False
          if p454 > lndx: break
	  sieve[p454] = False
          if p455 > lndx: break
	  sieve[p455] = False
          if p456 > lndx: break
	  sieve[p456] = False
          if p457 > lndx: break
	  sieve[p457] = False
          if p458 > lndx: break
	  sieve[p458] = False
          if p459 > lndx: break
	  sieve[p459] = False
          if p460 > lndx: break
	  sieve[p460] = False
          if p461 > lndx: break
	  sieve[p461] = False
          if p462 > lndx: break
	  sieve[p462] = False
          if p463 > lndx: break
	  sieve[p463] = False
          if p464 > lndx: break
	  sieve[p464] = False
          if p465 > lndx: break
	  sieve[p465] = False
          if p466 > lndx: break
	  sieve[p466] = False
          if p467 > lndx: break
	  sieve[p467] = False
          if p468 > lndx: break
	  sieve[p468] = False
          if p469 > lndx: break
	  sieve[p469] = False
          if p470 > lndx: break
	  sieve[p470] = False
          if p471 > lndx: break
	  sieve[p471] = False
          if p472 > lndx: break
	  sieve[p472] = False
          if p473 > lndx: break
	  sieve[p473] = False
          if p474 > lndx: break
	  sieve[p474] = False
          if p475 > lndx: break
	  sieve[p475] = False
          if p476 > lndx: break
	  sieve[p476] = False
          if p477 > lndx: break
	  sieve[p477] = False
          if p478 > lndx: break
	  sieve[p478] = False
          if p479 > lndx: break
	  sieve[p479] = False
          break
    if val < 3 : return [2]
    if val < 5 : return [2,3]
    if val < 7 : return [2,3,5]
    if val < 11: return [2,3,5,7]
    primes = [(i<<1)+3 for i in xrange(5, lndx, 1)  if sieve[i]]
    primes[0:0] = [2,3,5,7,11]
    return primes

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
            if res in offsets:
                d[(x, res)] = y
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
        if tk1[pos]: p.append(cpos + 1)
        if tk7[pos]: p.append(cpos + 7)
        if tk11[pos]: p.append(cpos + 11)
        if tk13[pos]: p.append(cpos + 13)
        if tk17[pos]: p.append(cpos + 17)
        if tk19[pos]: p.append(cpos + 19)
        if tk23[pos]: p.append(cpos + 23)
        if tk29[pos]: p.append(cpos + 29)
        pos += 1
    # remove exceeding if present
    pos = len(p) - 1
    while p[pos] > N:
        pos -= 1
    if pos < len(p) - 1:
        del p[pos+1:]
    # return p list
    return p

def SoZP5a(val):
    # all prime candidates > 5 are of form 30*k+(1,7,11,13,17,19,23,29)
    num = val-1 | 1              # if val even number then subtract 1
    mod=30; rescnt=8             # modulus value; number of residues
    maxprms = (rescnt*num)//mod  # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True

    # array of residues to compute primes and candidates values
    residues = [1,7,11,13,17,19,23,29,31]
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1

    # sieve to eliminate nonprimes from prms
    limit = int(ceil(sqrt(num)))
    x=r=0
    for prm in prms:
	r += 1
	if r > rescnt: r = 1; x += mod
        if not prm: continue
        prime = x + residues[r]
        if limit < prime: break
        m = prime*rescnt  # prime multiples position inc in prms
        for ri in residues[1:]:
           product = prime*(x+ri)
           if product > num: break
           # compute product position index in prms
           qq,rr  = divmod(product,mod)
           nonprmpos = qq*rescnt + pos[rr]
	   for nprm in xrange(nonprmpos,maxprms,m): prms[nprm] = False
    # the prms array now has all the positions for primes 7..N
    primes = [2,3,5]
    if num < 7: return primes[:1+num//2]
    x,r=0,0
    for prime in prms:
       r += 1
       if r > rescnt: r = 1; x += mod
       if prime: primes.append(x+residues[r])
    if primes[-1] > num: primes.pop()
    return primes

def SoZP7a(val):
    # all prime candidates > 7 are of form 210*k+(1,11,13,17,19,23,29,31,37
    # 41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,121,127,131
    # 137,139,143,149,151,157,163,167,169,173,179,181,187,191,193,197,199,209)
    num = val-1 | 1              # if val even number then subtract 1
    mod=210; rescnt=48           # modulus value; number of residues
    maxprms = (rescnt*num)//mod  # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True

    # array of residues to compute primes and candidates values
    residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1
	 
    # sieve to eliminate nonprimes from prms
    limit = int(ceil(sqrt(num)))
    x=r=0
    for prm in prms:
	r += 1
	if r > rescnt: r = 1; x += mod
        if not prm: continue
        prime = x + residues[r]
        if limit < prime: break
        m = prime*rescnt  # prime multiples position inc in prms
        for ri in residues[1:]:
           product = prime*(x+ri)
           if product > num: break
           # compute product position index in prms
           qq,rr  = divmod(product,mod)
           nonprmpos = qq*rescnt + pos[rr]
	   for nprm in xrange(nonprmpos,maxprms,m): prms[nprm] = False
    # the prms array now has all the positions for primes 11..N
    primes = [2,3,5,7]
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes
    x,r=0,0
    for prime in prms:
       r += 1
       if rescnt < r: r = 1; x += mod
       if prime: primes.append(x+residues[r])
    if primes[-1] > num: primes.pop()
    return primes

def SoZP11a(val):
    # all prime canidates > 11 are of form 2310*k+(1, 13, 17, 19, 23, 29, 31, 37,
    # 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
    # 127, 131, 137, 139, 149, 151, 157, 163, 167, 169, 173, 179, 181, 191, 193,
    # 197, 199, 211, 221, 223, 227, 229, 233, 239, 241, 247, 251, 257, 263, 269,
    # 271, 277, 281, 283, 289, 293, 299, 307, 311, 313, 317, 323, 331, 337, 347,
    # 349, 353, 359, 361, 367, 373, 377, 379, 383, 389, 391, 397, 401, 403, 409,
    # 419, 421, 431, 433, 437, 439, 443, 449, 457, 461, 463, 467, 479, 481, 487,
    # 491, 493, 499, 503, 509, 521, 523, 527, 529, 533, 541, 547, 551, 557, 559,
    # 563, 569, 571, 577, 587, 589, 593, 599, 601, 607, 611, 613, 617, 619, 629,
    # 631, 641, 643, 647, 653, 659, 661, 667, 673, 677, 683, 689, 691, 697, 701,
    # 703, 709, 713, 719, 727, 731, 733, 739, 743, 751, 757, 761, 767, 769, 773,
    # 779, 787, 793, 797, 799, 809, 811, 817, 821, 823, 827, 829, 839, 841, 851,
    # 853, 857, 859, 863, 871, 877, 881, 883, 887, 893, 899, 901, 907, 911, 919,
    # 923, 929, 937, 941, 943, 947, 949, 953, 961, 967, 971, 977, 983, 989, 991,
    # 997, 1003, 1007, 1009, 1013, 1019, 1021, 1027, 1031, 1033, 1037, 1039, 1049,
    # 1051,1061, 1063, 1069, 1073, 1079, 1081, 1087, 1091, 1093, 1097, 1103, 1109,
    # 1117,1121, 1123, 1129, 1139, 1147, 1151, 1153, 1157, 1159, 1163, 1171, 1181,
    # 1187,1189, 1193, 1201, 1207, 1213, 1217, 1219, 1223, 1229, 1231, 1237, 1241,
    # 1247,1249, 1259, 1261, 1271, 1273, 1277, 1279, 1283, 1289, 1291, 1297, 1301,
    # 1303,1307, 1313, 1319, 1321, 1327, 1333, 1339, 1343, 1349, 1357, 1361, 1363,
    # 1367,1369, 1373, 1381, 1387, 1391, 1399, 1403, 1409, 1411, 1417, 1423, 1427,
    # 1429,1433, 1439, 1447, 1451, 1453, 1457, 1459, 1469, 1471, 1481, 1483, 1487,
    # 1489,1493, 1499, 1501, 1511, 1513, 1517, 1523, 1531, 1537, 1541, 1543, 1549,
    # 1553,1559, 1567, 1571, 1577, 1579, 1583, 1591, 1597, 1601, 1607, 1609, 1613,
    # 1619,1621, 1627, 1633, 1637, 1643, 1649, 1651, 1657, 1663, 1667, 1669, 1679,
    # 1681,1691, 1693, 1697, 1699, 1703, 1709, 1711, 1717, 1721, 1723, 1733, 1739,
    # 1741,1747, 1751, 1753, 1759, 1763, 1769, 1777, 1781, 1783, 1787, 1789, 1801,
    # 1807,1811, 1817, 1819, 1823, 1829, 1831, 1843, 1847, 1849, 1853, 1861, 1867,
    # 1871,1873, 1877, 1879, 1889, 1891, 1901, 1907, 1909, 1913, 1919, 1921, 1927,
    # 1931,1933, 1937, 1943, 1949, 1951, 1957, 1961, 1963, 1973, 1979, 1987, 1993,
    # 1997,1999, 2003, 2011, 2017, 2021, 2027, 2029, 2033, 2039, 2041, 2047, 2053,
    # 2059,2063, 2069, 2071, 2077, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2117,
    # 2119,2129, 2131, 2137, 2141, 2143, 2147, 2153, 2159, 2161, 2171, 2173, 2179,
    # 2183,2197, 2201, 2203, 2207, 2209, 2213, 2221, 2227, 2231, 2237, 2239, 2243,
    # 2249,2251,2257,2263,2267,2269,2273,2279, 2281, 2287, 2291, 2293, 2297, 2309)
    num = val-1 | 1              # if val even number then subtract 1
    mod=2310; rescnt=480         # modulus value; number of residues
    maxprms = (rescnt*num)//mod  # max number of prime candidates
    prms = [True]*maxprms        # set all prime candidates to True

    # array of residues to compute primes and candidates values
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
    # hash of residues offsets to compute nonprimes positions in prms
    pos = {}
    for i in xrange(rescnt): pos[residues[i]] = i-1
	
    # sieve to eliminate nonprimes from prms
    limit = int((ceil(sqrt(val))))
    x=r=0
    for prm in prms:
	r += 1
	if r > rescnt: r = 1; x += mod
        if not prm: continue
        prime = x + residues[r]
        if limit < prime: break
        m = prime*rescnt  # prime multiples position inc in prms
        for ri in residues[1:]:
           product = prime*(x+ri)
           if product > num: break
           # compute product position index in prms
           qq,rr  = divmod(product,mod)
           nonprmpos = qq*rescnt + pos[rr]
	   for nprm in xrange(nonprmpos,maxprms,m): prms[nprm] = False
    # the prms array now has all the positions for primes 13..N
    primes = [2,3,5,7,11]
    if num < 9:  return primes[:1+num//2]
    if num < 11: return primes[:4]
    if num < 13: return primes[:5]
    x=r=0
    for prime in prms:
       r += 1
       if r > rescnt: r = 1; x += mod
       if prime: primes.append(x+residues[r])
    if primes[-1] > num: primes.pop()
    return primes

if __name__ == '__main__':
    import time

    for j in range(5, 20000007, 1000000):
        print j,

        #a = time.time()
        #soe = sieveOfErat(j)
        #print time.time() -a,

        #a = time.time()
        #soa = sieveOfAtkin(j)
        #print time.time() -a,

        a = time.time()
        soz5 = SoZP5(j)
        print time.time() -a,

        a = time.time()
        soz7 = SoZP7(j)
        print time.time() -a,

        a = time.time()
        soz11 = SoZP11(j)
        print time.time() -a,

        a = time.time()
        wheel = sievewheel30(j)
        print time.time() -a,

        a = time.time()
        soz5a = SoZP5a(j)
        print time.time() -a,

        a = time.time()
        soz7a = SoZP7a(j)
        print time.time() -a,

        a = time.time()
        soz11a = SoZP11a(j)
        print time.time() -a

        assert  soz5 == soz7 == soz11 == wheel == soz5a == soz7a == soz11a