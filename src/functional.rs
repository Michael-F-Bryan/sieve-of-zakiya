use pg::PrimeGenerator;

pub fn sieve_of_zakiya(upper_limit: usize, modulus: usize) -> Vec<usize> {
    let generator = PrimeGenerator::new(modulus);

    let residues = generator.residues().to_vec();
    let excluded_primes = generator.excluded_primes();

    // this can be done really easily in parallel...
    //
    // - For each residue:
    //   - create a list of prime candidates
    // - collect into a Vec<Vec<usize>> (list of prime candidate lists)
    // - merge the prime candidate lists (individually sorted) into one
    //   big list
    //
    // Note by design it should be impossible to have double-ups
    let prime_candidates: Vec<usize> = generator.take_while(|&n| n <= upper_limit).collect();

    let sieved_primes = remove_non_primes(&residues, &prime_candidates);

    // merge the set of primes we've found with the ones we've excluded
    let mut primes = Vec::new();
    primes.extend(excluded_primes);
    primes.extend(sieved_primes);
    primes.sort();

    primes
}

fn remove_non_primes(residues: &[usize], candidates: &[usize]) -> Vec<usize> {
    candidates.to_vec()
}


#[cfg(test)]
mod tests {
    use super::*;
    use utils::naive_is_prime;

    fn primes_up_to(max: usize) -> Vec<usize> {
        (2...max).filter(|&n| naive_is_prime(n)).collect()
    }

    #[test]
    fn generate_some_primes() {
        let modulus = 30;
        let max = 100;
        let should_be: Vec<usize> = primes_up_to(max);

        let got = sieve_of_zakiya(max, modulus);

        assert_eq!(got, should_be);
    }
}