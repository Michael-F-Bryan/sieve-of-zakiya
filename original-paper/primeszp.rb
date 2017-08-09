#!/usr/local/bin/ruby -w

require 'rational' if RUBY_VERSION =~ /^(1.8)/   # for 'gcd' method

=begin
Author:  Jabari Zakiya
Version: June 26, 2013
Version: August 1, 2013  -- shorter/faster/adjustable primemr?
Version: August 28, 2013 -- two new methods use cli command "factor"
Version: September 13, 2013 -- refactored/simplified "primality"
Version: October 18, 2013 -- refactored/simplified "primality
Description:
For an Integer n, methods primzp*? returns 'true' if n
is prime, or 'false' if not.  The method factorzp
returns an array of the prime factors of n or n if it
is prime.  These methods are significantly faster and
simpler the the standard Ruby methods 'prime' and
'prime_division' found in the library file prime.rb.

Discussion of developing this code can be found below:
http://www.scribd.com/doc/150217723/Improved-Primality-Testing-and-Factorization-in-Ruby?post_id=791539872_10151726037699873#_=_

http://www.4shared.com/dir/7467736/97bd7b71/sharing.html
=end

class Integer

   def primzp5?
      residues = [1,7,11,13,17,19,23,29,31]
      mod=30; rescnt=8

      n = self.abs
      return true  if [2,3,5].include? n
      return false if not residues.include?(n%mod) || n == 1

      sqrtN = Math.sqrt(n).to_i
      modk,r=0,1;  p=7        # first test prime pj
      while p <= sqrtN
        return false if n%p == 0
        r +=1; if r > rescnt; r=1; modk +=mod end
        p = modk+residues[r]  # next prime candidate
      end
      return true
   end

   def primzp5a?
      residues = [1,7,11,13,17,19,23,29,31]
      mod=30; rescnt=8

      n = self.abs
      return true  if [2,3,5].include? n
      return false if not residues.include?(n%mod) || n == 1

      sqrtN = Math.sqrt(n).to_i
      p=7         # first test prime pj
      while p <= sqrtN
        return false if
          n%(p)   == 0 or n%(p+4) ==0 or n%(p+6) == 0 or n%(p+10)==0 or
          n%(p+12)== 0 or n%(p+16)==0 or n%(p+22)== 0 or n%(p+24)==0
        p += mod  # first prime candidate for next kth residues group
      end
      return true
   end

   def primzp7?
      residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]
      mod=210; rescnt=48

      n = self.abs
      return true  if [2, 3, 5, 7].include? n
      return false if not residues.include?(n%mod) || n == 1

      sqrtN = Math.sqrt(n).to_i
      modk,r=0,1;  p=11        # first test prime pj
      while p <= sqrtN
        return false if n%p == 0
        r +=1; if r > rescnt; r=1; modk +=mod end
        p = modk+residues[r]   # next prime candidate
      end
      return true
   end
  
   def primzp7a?
      residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]
      mod=210; rescnt=48

      n = self.abs
      return true  if [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43,
                       47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103,
                       107, 109, 113, 127, 131, 137, 139, 149, 151, 157,163,
                       167, 173, 179, 181, 191, 193, 197, 199, 211].include? n
      return false if not residues.include?(n%mod) || n == 1

      sqrtN = Math.sqrt(n).to_i
      p=11          # first test prime pj
      while p <= sqrtN
        return false if
          n%(p)    == 0 or n%(p+2)  ==0 or n%(p+6)  == 0 or n%(p+8)  ==0 or
          n%(p+12) == 0 or n%(p+18) ==0 or n%(p+20) == 0 or n%(p+26) ==0 or
          n%(p+30) == 0 or n%(p+32) ==0 or n%(p+36) == 0 or n%(p+42) ==0 or
          n%(p+48) == 0 or n%(p+50) ==0 or n%(p+56) == 0 or n%(p+60) ==0 or
          n%(p+62) == 0 or n%(p+68) ==0 or n%(p+72) == 0 or n%(p+78) ==0 or
          n%(p+86) == 0 or n%(p+90) ==0 or n%(p+92) == 0 or n%(p+96) ==0 or
          n%(p+98) == 0 or n%(p+102)==0 or n%(p+110)== 0 or n%(p+116)==0 or
          n%(p+120)== 0 or n%(p+126)==0 or n%(p+128)== 0 or n%(p+132)==0 or
          n%(p+138)== 0 or n%(p+140)==0 or n%(p+146)== 0 or n%(p+152)==0 or
          n%(p+156)== 0 or n%(p+158)==0 or n%(p+162)== 0 or n%(p+168)==0 or
          n%(p+170)== 0 or n%(p+176)==0 or n%(p+180)== 0 or n%(p+182)==0 or
          n%(p+186)== 0 or n%(p+188)==0 or n%(p+198)== 0 or n%(p+200)==0
        p += mod    # first prime candidate for next kth residues group
      end
      return true
   end

   def primzp7b?
      residues = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,
         89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,157,163,
         167,169,173,179,181,187,191,193,197,199,209,211]
      mod=210; rescnt=48

      n = self.abs
      return true  if [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43,
                       47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103,
                       107, 109, 113, 127, 131, 137, 139, 149, 151, 157,163,
                       167, 173, 179, 181, 191, 193, 197, 199, 211].include? n
      return false if not residues.include?(n%mod) || n == 1

      sqrtN = Math.sqrt(n).to_i
      modk=0
      while (11+modk) <= sqrtN
        return false if
          n%(11+modk) == 0 or n%(13+modk) ==0 or n%(17+modk) == 0 or n%(19+modk) ==0 or
          n%(23+modk) == 0 or n%(29+modk) ==0 or n%(31+modk) == 0 or n%(37+modk) ==0 or
          n%(41+modk) == 0 or n%(43+modk) ==0 or n%(47+modk) == 0 or n%(53+modk) ==0 or
          n%(59+modk) == 0 or n%(61+modk) ==0 or n%(67+modk) == 0 or n%(71+modk) ==0 or
          n%(73+modk) == 0 or n%(79+modk) ==0 or n%(83+modk) == 0 or n%(89+modk) ==0 or
          n%(97+modk) == 0 or n%(101+modk)==0 or n%(103+modk)== 0 or n%(107+modk)==0 or
          n%(109+modk)== 0 or n%(113+modk)==0 or n%(121+modk)== 0 or n%(127+modk)==0 or
          n%(131+modk)== 0 or n%(137+modk)==0 or n%(139+modk)== 0 or n%(143+modk)==0 or
          n%(149+modk)== 0 or n%(151+modk)==0 or n%(157+modk)== 0 or n%(163+modk)==0 or
          n%(167+modk)== 0 or n%(169+modk)==0 or n%(173+modk)== 0 or n%(179+modk)==0 or
          n%(181+modk)== 0 or n%(187+modk)==0 or n%(191+modk)== 0 or n%(193+modk)==0 or
          n%(197+modk)== 0 or n%(199+modk)==0 or n%(209+modk)== 0 or n%(211+modk)==0
        modk += mod  # modulus for next kth residues group prime candidates
      end
      return true
   end

   def primzpa?(p=13)      # P13 is default prime generator here
     seeds  = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
     return 'PRIME OPTION NOT A SEEDS PRIME' if !seeds.include? p

     n = self.abs

     # find primes <= Pn, compute modPn then Prime Gen residues for Pn
     primes = seeds[0..seeds.index(p)]; mod = primes.inject {|a,b| a*b }
     mod = 30 if p > 5 and n < mod+2  # for Pp > P5 and n within Pp residues
     residues=[1]; 3.step(mod,2) {|i| residues << i if mod.gcd(i) == 1}
     residues << mod+1; rescnt = residues.size-1

     return true  if primes.include? n
     return false if not residues.include?(n%mod) || n == 1

     sqrtN = Math.sqrt(n).to_i
     modk = 0;  p=residues[1]             # first prime candidate pj
     res = residues[1..-1].map {|r| r-p } # residues distance from first prime
     while p <= sqrtN
       return false if res.map {|r| n%(r+p)}.include? 0
       p += mod   # first prime candidate for next residues group
     end
     return true
   end

   def primzp?(p=13)       # P13 is default prime generator here
     seeds  = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
     return 'PRIME OPTION NOT A SEEDS PRIME' if !seeds.include? p
     
     n = self.abs
     p = 5 if n < 510513   # use P5 prime generator for small numbers

     # find primes <= Pn, compute modPn then Prime Gen residues for Pn
     primes = seeds[0..seeds.index(p)]; mod = primes.inject {|a,b| a*b }
     residues=[1]; 3.step(mod,2) {|i| residues << i if mod.gcd(i) == 1}
     residues << mod+1; rescnt = residues.size-1

     return true  if primes.include? n
     return false if not residues.include?(n%mod) || n == 1

     sqrtN = Math.sqrt(n).to_i
     modk,r=0,1; p=residues[1] # first test prime pj
     while p <= sqrtN
       return false if n%p == 0
       r +=1; if r > rescnt; r=1; modk +=mod end
       p = modk+residues[r]    # next prime candidate
     end
     return true
   end

   def factorzp(p=13)      # P13 is default prime generator here
     seeds  = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
     return 'PRIME OPTION NOT A SEEDS PRIME' if !seeds.include? p

     # find primes <= Pn, compute modPn then Prime Gen residues for Pn
     primes = seeds[0..seeds.index(p)]; mod = primes.inject {|a,b| a*b }
     residues=[1]; 3.step(mod,2) {|i| residues << i if mod.gcd(i) == 1}
     residues << mod+1; rescnt = residues.size-1

     n = self.abs
     factors = []

     return factors << n if primes.include? n
     primes.each {|p| while n%p ==0; factors << p; n /= p end }
     return factors if n == 1  # for when n is product of only seed primes

     sqrtN= Math.sqrt(n).to_i
     modk,r=0,1; p=residues[1] # first test prime pj
     while p <= sqrtN
       if n%p == 0
         factors << p; r -=1; n /= p; sqrtN = Math.sqrt(n).to_i
       end
       r +=1; if r > rescnt; r=1; modk +=mod end
       p = modk+residues[r]    # next (or current) prime candidate
     end
     factors << n
     factors.sort # return n if prime, or its prime factors
   end

   # This produces the same output format as lib method prime_division
   def prime_division_new(p=13) # P13 is default prime generator here
     h=Hash.new(0); factorzp(p).each {|f| h[f] +=1}; h.to_a.sort
   end

   # These two method use the [Un/L]inux cli command "factor"
   # They will perform consistently fast for all *nix based Ruby versions
   def factors
     factors = `factor #{self.abs}`.split(' ')[1..-1].map {|i| i.to_i}
     h = Hash.new(0); factors.each {|f| h[f] +=1}; h.to_a.sort
   end
     
   def primality?
     # return true if number is prime or false otherwise
     `factor #{self.abs}`.split(' ').size == 2
   end

   # Miller-Rabin prime test in Ruby
   # From: http://en.wikipedia.org/wiki/Miller-Rabin_primality_test
   # Ruby Rosetta Code: http://rosettacode.org/wiki/Miller-Rabin_primality_test
   # I modified the Rosetta Code, as shown below
   
   require 'openssl'
   def primemr?(k=20) # increase k for more reliability
     n = self.abs     
     return true  if n == 2 or n == 3
     return false if n % 6 != 1 && n % 6 != 5 or n == 1
     
     d = n - 1
     s = 0
     (d >>= 1; s += 1) while d & 1 == 0  # while d even
     k.times do
       a = 2 + rand(n-4)
       x = OpenSSL::BN::new(a.to_s).mod_exp(d,n)   #x = (a**d) % n
       next if x == 1 or x == n-1
       (s-1).times do
         x = x.mod_exp(2,n)                        #x = (x**2) % n
         return false if x == 1
         break if x == n-1
       end
       return false if x != n-1
     end
     true  # probably
   end
end

def tm; s=Time.now; yield; Time.now-s end  # tm { 10001.primzp?}

require 'benchmark'
require 'prime'
def primetests(prime)
  Benchmark.bmbm(14) do |t|
     t.report("prime tests for P = #{prime}") do    end
     t.report("Miller-Rabin ") do prime.primemr?    end
     t.report("primality?   ") do prime.primality?  end
     t.report("primzp7?     ") do prime.primzp7?    end
     t.report("primzp7a?    ") do prime.primzp7a?   end
     t.report("primzp7b?    ") do prime.primzp7b?   end
     t.report("primzp? 13   ") do prime.primzp? 13  end
     t.report("primzp? 17   ") do prime.primzp? 17  end
     t.report("primzpa? 13  ") do prime.primzpa? 13 end
     t.report("primzpa? 17  ") do prime.primzpa? 17 end
     t.report("factors      ") do prime.factors     end
     t.report("factorzp 13  ") do prime.factorzp 13 end
     t.report("factorzp 17  ") do prime.factorzp 17 end
     t.report("prime? [ruby lib] ") do prime.prime? end
     t.report("prime_division [ruby lib]") do prime.prime_division end
  end
end

prime = 20_000_000_000_000_003  # 17 digits
primetests(prime)