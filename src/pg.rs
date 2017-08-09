use utils;

/// A *Prime Generator* which will yield an infinite number of prime
/// candidates.
pub struct PrimeGenerator {
    modulus: usize,
    residues: Vec<usize>,
    current_residue: usize,
    k: usize,
}

impl PrimeGenerator {
    pub fn new(modulus: usize) -> PrimeGenerator {
        PrimeGenerator {
            modulus: modulus,
            residues: residues_for(modulus),
            k: 0,
            current_residue: 0,
        }
    }

    /// The list of primes which this `PrimeGenerator` will miss.
    ///
    /// The list of `excluded_primes` contains all primes smaller than the
    /// first residual. Therefore to correctly do a prime sieve, you need
    /// to combine the primes found by sieving this prime generator with
    /// the list of primes it skips (`excluded_primes`).
    ///
    /// Because this list is very small, we just calculate it using brute
    /// force.
    pub fn excluded_primes(&self) -> Vec<usize> {
        let first_residue = self.residues.iter().find(|n| **n > 1).unwrap().clone();
        (2..first_residue)
            .filter(|&n| utils::naive_is_prime(n))
            .collect()
    }

    pub fn residues(&self) -> &[usize] {
        &self.residues
    }
}

impl Iterator for PrimeGenerator {
    type Item = usize;
    fn next(&mut self) -> Option<Self::Item> {
        let residue = self.residues[self.current_residue];
        let p_n = self.modulus * self.k + residue;

        // Make sure we cycle through the residues, incrementing k before
        // resetting `current_residue` if we get to the end.
        self.current_residue += 1;
        if self.current_residue == self.residues.len() {
            self.current_residue = 0;
            self.k += 1;
        }

        Some(p_n)
    }
}

fn is_strictly_prime(n: usize) -> bool {
    let mut primes = (2..).filter(|&i| utils::naive_is_prime(i));
    let mut accumulator = 1;

    while accumulator <= n {
        let prime = primes.next().expect("infinite sequence");
        accumulator *= prime;

        if accumulator == n {
            return true;
        }
    }
    false
}

/// Calculate the residues for a particular number.
pub fn residues_for(n: usize) -> Vec<usize> {
    (1..n).filter(move |&i| utils::is_coprime(n, i)).collect()
}



#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_gcd() {
        let inputs = vec![
            (1, 5, true),
            (2, 3, true),
            (2, 4, false),
            (2, 6, false),
            (150, 5, false),
        ];

        for (a, b, should_be) in inputs {
            let got = utils::is_coprime(a, b);
            assert_eq!(
                got,
                should_be,
                "expected: coprime({}, {}) = {}",
                a,
                b,
                should_be
            );
        }
    }

    #[test]
    fn get_expected_residues() {
        let should_be = vec![1, 5];
        let modulo = 6;

        let got: Vec<usize> = residues_for(modulo);
        assert_eq!(got, should_be);
    }

    #[test]
    fn get_strictly_primes() {
        let strictly_primes = vec![6, 30, 210, 2310];

        for candidate in strictly_primes {
            assert!(is_strictly_prime(candidate), "{}", candidate);
        }
    }

    #[test]
    #[ignore]
    fn generate_list_of_prime_candidates() {
        let mut prime_gen_5 = PrimeGenerator::new(30);
        let prime_candidates_under_30: Vec<usize> = prime_gen_5.take_while(|&n| n <= 541).collect();

        println!("{:?}", prime_candidates_under_30);
        assert!(false);
    }
}