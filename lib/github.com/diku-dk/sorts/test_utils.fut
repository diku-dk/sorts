-- | ignore

-- This file contains various utilities for doing tests of the sorting functions.

-- | How many elements satisfy the predicate?
def count p = map p >-> map i64.bool >-> i64.sum

-- | Correctness property: a sorting function is valid if it produces a sorted
-- sequence, and for every element in the original sequence, the same number of
-- equal elements is present in the original and sorted sequence.
--
-- This is quadratic-time to check, but hopefully this will not be a big problem
-- in practice.
def correct_sort 'a [n] (sort: [n]a -> [n]a) (lte: a -> a -> bool) (xs: [n]a) : bool =
  let xs' = sort xs
  let eql x y = lte x y && lte y x
  in and (tabulate n (\i -> i == 0 || (xs'[i - 1] `lte` xs'[i])))
     && all (\x -> count (eql x) xs' == count (eql x) xs) xs'
