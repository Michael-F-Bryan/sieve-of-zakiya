#![feature(inclusive_range_syntax)]
#![feature(conservative_impl_trait)]

#[cfg(test)]
#[macro_use]
extern crate pretty_assertions;

pub mod pg;
mod raw_translation;
mod functional;

pub use raw_translation::sieve_of_zakiya as translated_sieve_of_zakiya;
pub use functional::sieve_of_zakiya as functional_sieve_of_zakiya;
pub use pg::PrimeGenerator;

mod utils {
    pub fn is_even(n: usize) -> bool {
        n % 2 == 0
    }

    pub fn sqrt(n: usize) -> usize {
        (n as f32).sqrt().floor() as usize
    }

    /// Naively check if a number is prime by dividing by all the numbers in
    /// the range `[2, n)`.
    pub fn naive_is_prime(n: usize) -> bool {
        if n <= 1 {
            false
        } else {
            (2..n).all(|i| n % i != 0)
        }
    }

    pub fn is_coprime(a: usize, b: usize) -> bool {
        gcd(a, b) == 1
    }

    pub fn gcd(mut a: usize, mut b: usize) -> usize {
        while b != 0 {
            let tmp = a % b;
            a = b;
            b = tmp;
        }

        a
    }
}