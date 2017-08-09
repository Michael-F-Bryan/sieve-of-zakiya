use utils;

pub fn sieve_of_zakiya(n: usize) {
    let modulus = 30;
    let residue_count = 8;
    let residues = vec![1, 7, 11, 13, 17, 19, 23, 29, 31];

    let val = n;
    let num = if utils::is_even(val) { val - 1 } else { val };

    let mut k = num / modulus;
    let mut mod_k = modulus * k;
    let mut r = 1;

    let max_primes = k * residue_count + r - 1;
    let mut primes = vec![false; max_primes];

    let mut pos = vec![0; modulus];

    for i in 1..residue_count {
        pos[residues[i]] = i - 1;
    }

    let sqrt_n = utils::sqrt(num);
    mod_k = 0;
    r = 0;
    k = 0;

    for i in 0..max_primes {
        r += 1;

        if r > residue_count {
            r = 1;
            mod_k += modulus;
        }

        if primes[i] {
            continue;
        }

        let prime = mod_k + residues[r];

        if prime > sqrt_n {
            break;
        }

        let prime_step = prime * residue_count;

        for r_i in 1...residue_count {
            let prod = prime * (mod_k + residues[r_i]);

            if prod > num {
                break;
            }

            let rr = prod % modulus;
            let ki = prod / modulus;

            let mut np = ki * residue_count + pos[rr];

            while np < max_primes {
                primes[np] = true;
                np += prime_step;
            }

            let max = (num as f32 / (num as f32).ln() * 1.13) as usize + 8;

            let mut temp_primes = vec![0; max + 100];
            let mut prime_count = 0;

            mod_k = 0;
            r = 0;

            for i in 0..max_primes {
                r += 1;
                if r > residue_count {
                    r = 1;
                    mod_k += modulus;
                }

                if !primes[i] {
                    temp_primes[prime_count] = mod_k + residues[r];
                    prime_count += 1;
                }
            }

            println!("{} {:?}", prime_count, temp_primes);
        }
    }
}