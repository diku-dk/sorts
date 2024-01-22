-- | A non-comparison-based sort that sorts an array in *O(k n)* work
-- and *O(k log(n))* span, where *k* is the number of bits in each element.
--
-- Generally, this is the sorting function we recommend for Futhark
-- programs, but be careful about negative integers (use
-- `radix_sort_int`@term) and floating-point numbers (use
-- `radix_sort_float`@term).  If you need a comparison-based sort,
-- consider `merge_sort`@term@"merge_sort".
--
-- ## See Also
--
-- * `merge_sort`@term@"merge_sort"

local def radix_sort_step [n] 't (xs: [n]t) (get_bit: i32 -> t -> i32)
                                 (digit_n: i32): [n]t =
  let num x = get_bit (digit_n+1) x * 2 + get_bit digit_n x
  let pairwise op (a1,b1,c1,d1) (a2,b2,c2,d2) =
    (a1 `op` a2, b1 `op` b2, c1 `op` c2, d1 `op` d2)
  let bins = xs |> map num
  let flags = bins |> map (\x ->
      ( i64.bool (x==0)
      , i64.bool (x==1)
      , i64.bool (x==2)
      , i64.bool (x==3) ) )
  let offsets = scan (pairwise (+)) (0,0,0,0) flags
  let (na,nb,nc,_nd) = last offsets
  let f bin (a,b,c,d) = (-1)
      + a * (i64.bool (bin == 0)) + na * (i64.bool (bin > 0))
      + b * (i64.bool (bin == 1)) + nb * (i64.bool (bin > 1))
      + c * (i64.bool (bin == 2)) + nc * (i64.bool (bin > 2))
      + d * (i64.bool (bin == 3)) 
  let is = map2 f bins offsets
  in scatter (copy xs) is xs

-- | The `num_bits` and `get_bit` arguments can be taken from one of
-- the numeric modules of module type `integral`@mtype@"/prelude/math"
-- or `float`@mtype@"/prelude/math", such as `i32`@term@"/prelude/math"
-- or `f64`@term@"/prelude/math".  However, if you know that
-- the input array only uses lower-order bits (say, if all integers
-- are less than 100), then you can profitably pass a smaller
-- `num_bits` value to reduce the number of sequential iterations.
--
-- **Warning:** while radix sort can be used with numbers, the bitwise
-- representation of of both integers and floats means that negative
-- numbers are sorted as *greater* than non-negative.  Negative floats
-- are further sorted according to their absolute value.  For example,
-- radix-sorting `[-2.0, -1.0, 0.0, 1.0, 2.0]` will produce `[0.0,
-- 1.0, 2.0, -1.0, -2.0]`.  Use `radix_sort_int`@term and
-- `radix_sort_float`@term in the (likely) cases that this is not what
-- you want.
def radix_sort [n] 't (num_bits: i32) (get_bit: i32 -> t -> i32)
                      (xs: [n]t): [n]t =
  let iters = if n == 0 then 0 else (num_bits+2-1)/2
  in loop xs for i < iters do radix_sort_step xs get_bit (i*2)

def with_indices [n] 'a (xs: [n]a) : [n](a, i64) =
  zip xs (iota n)

local def by_key_wrapper [n] 't sorter key num_bits get_bit (xs: [n]t) : [n]t =
  map key xs
  |> with_indices
  |> sorter num_bits (\i (k, _) -> get_bit i k)
  |> map (\(_, i: i64) -> xs[i]) -- OK because '0<=i<n'.

-- | Like `radix_sort`, but sort based on key function.
def radix_sort_by_key [n] 't 'k
    (key: t -> k)
    (num_bits: i32) (get_bit: i32 -> k -> i32) (xs: [n]t): [n]t =
  by_key_wrapper radix_sort key num_bits get_bit xs

-- | A thin wrapper around `radix_sort`@term that ensures negative
-- integers are sorted as expected.  Simply pass the usual `num_bits`
-- and `get_bit` definitions from e.g. `i32`@term@"/prelude/math".
def radix_sort_int [n] 't (num_bits: i32) (get_bit: i32 -> t -> i32)
                          (xs: [n]t): [n]t =
  let get_bit' i x =
    -- Flip the most significant bit.
    let b = get_bit i x
    in if i == num_bits-1 then b ^ 1 else b
  in radix_sort num_bits get_bit' xs

-- | Like `radix_sort_int`, but sort based on key function.
def radix_sort_int_by_key [n] 't 'k
    (key: t -> k)
    (num_bits: i32) (get_bit: i32 -> k -> i32) (xs: [n]t): [n]t =
  by_key_wrapper radix_sort_int key num_bits get_bit xs

-- | A thin wrapper around `radix_sort`@term that ensures floats are
-- sorted as expected.  Simply pass the usual `num_bits` and `get_bit`
-- definitions from `f32`@term@"/prelude/math" and
-- `f64`@term@"/prelude/math".
def radix_sort_float [n] 't (num_bits: i32) (get_bit: i32 -> t -> i32)
                            (xs: [n]t): [n]t =
  let get_bit' i x =
    -- We flip the bit returned if:
    --
    -- 0) the most significant bit is set (this makes more negative
    --    numbers sort before less negative numbers), or
    --
    -- 1) we are asked for the most significant bit (this makes
    --    negative numbers sort before positive numbers).
    let b = get_bit i x
    in if get_bit (num_bits-1) x == 1 || i == num_bits-1
       then b ^ 1 else b
  in radix_sort num_bits get_bit' xs

-- | Like `radix_sort_float`, but sort based on key function.
def radix_sort_float_by_key [n] 't 'k
    (key: t -> k)
    (num_bits: i32) (get_bit: i32 -> k -> i32) (xs: [n]t): [n]t =
  by_key_wrapper radix_sort_float key num_bits get_bit xs

local def exscan op ne xs =
  let s =
    scan op ne xs
    |> rotate (-1)
  let s[0] = ne
  in s

local def get_bin 't
                  (get_bit: i32 -> t -> i32)
                  (digit_n: i32)
                  (x: t): i64  =
  i64.i32 <| get_bit (digit_n+1) x * 2 + get_bit digit_n x

local def radix_sort_step_i16 [n] 't (xs: [n]t)
                              (get_bit: i32 -> t -> i32)
                              (digit_n: i32): ([n]t, (i16, i16, i16, i16)) =
  let num x = i16.i32 (get_bit (digit_n+1) x * 2 + get_bit digit_n x)
  let pairwise op (a1,b1,c1,d1) (a2,b2,c2,d2) =
    (a1 `op` a2, b1 `op` b2, c1 `op` c2, d1 `op` d2)
  let bins = xs |> map num
  let flags = bins |> map (\x ->
      ( i16.bool (x==0)
      , i16.bool (x==1)
      , i16.bool (x==2)
      , i16.bool (x==3) ) )
  let offsets = scan (pairwise (+)) (0,0,0,0) flags
  let (na,nb,nc,nd) = last offsets
  let f bin (a,b,c,d) = i64.i16 ((-1)
      + a * (i16.bool (bin == 0)) + na * (i16.bool (bin > 0))
      + b * (i16.bool (bin == 1)) + nb * (i16.bool (bin > 1))
      + c * (i16.bool (bin == 2)) + nc * (i16.bool (bin > 2))
      + d * (i16.bool (bin == 3))) 
  let is = map2 f bins offsets
  in (scatter (copy xs) is xs, (na, nb, nc, nd))


local def chunked_radix_sort_step [n] [m] 't
                          (get_bit: i32 -> t -> i32)
                          (digit_n: i32)
                          (xs: *[n*m]t) =
  let hist_size = 4
  let (xs', histograms) =
    unflatten xs
    |> map (
         \arr ->
           let (ys, (a, b, c, d)) =
             radix_sort_step_i16 arr get_bit digit_n
           let hist' = sized hist_size [i64.i16 a
                                       ,i64.i16 b
                                       ,i64.i16 c
                                       ,i64.i16 d]
           in (ys, hist')
       )
    |> unzip
  let ys = flatten xs'
  let flat_trans_hist =
    histograms
    |> transpose
    |> flatten
  let flat_hist =
    histograms
    |> flatten
    |> sized (hist_size * n)
  let (flat_trans_hist_scan, flat_hist_scan) =
    zip flat_trans_hist flat_hist
    |> exscan (\(a, b) (x, y) -> (a + x, b + y)) (0, 0)
    |> unzip
  let hist_scan =
    flat_hist_scan
    |> sized (n * hist_size)
    |> unflatten
  let trans_hist_scan =
    flat_trans_hist_scan
    |> unflatten
  let (is, elems) =
    map (
      \i ->
        let elem = ys[i]
        let bin = get_bin get_bit digit_n elem
        let new_offset = trans_hist_scan[bin][i / m]
        let old_offset = hist_scan[i / m][bin]
        let idx = (i - old_offset) + new_offset
        in (idx, elem)
    ) (iota (n * m))
    |> unzip
  in scatter xs is elems

local def (///) (a: i32) (b: i32) : i32 =
  a / b + i32.bool (a % b != 0)

local def (////) (a: i64) (b: i64) : i64 =
  a / b + i64.bool (a % b != 0)

-- | This implementation of radix sort works on the outside almost like
-- `radix_sort` but the implementation is based of a design where you
-- chunk the input into subarrays [1]. This leads to performance gains
-- if you choose a good `chunk` size based on the GPU thread block.
-- Using 512 as a `chunk` size leads to about twice the speed on
-- a RTX 3060 as the normal `radix_sort`. The implementation also
-- needs a `highest` element which is used for padding when sorting.
-- The `highest` element needs to be larger or equal to the largest
-- element in the input array. The sorting algorithm is stable and its
-- work is *O(k n)* and the span is *O(k log(n))* as in `radix_sort`
-- assuming the chunk size is some constant and not varied in the
-- analysis.
--
-- [1] N. Satish, M. Harris and M. Garland, "Designing efficient
-- sorting algorithms for manycore GPUs," 2009 IEEE International
-- Symposium on Parallel & Distributed Processing, Rome, Italy, 2009,
-- pp. 1-10, doi: 10.1109/IPDPS.2009.5161005.
def chunked_radix_sort [n] 't
                       (chunk: i16)
                       (highest: t)
                       (num_bits: i32)
                       (get_bit: i32 -> t -> i32)
                       (xs: [n]t): [n]t =
  let iters = if n == 0 then 0 else (num_bits + 2 - 1) / 2
  let chunk = i64.i16 chunk
  let n_chunks = n //// chunk
  let padding = replicate (n_chunks * chunk - n) highest
  let xs = sized (n_chunks * chunk) (xs ++ padding)
  in take n <|
     loop xs for i < iters do
       chunked_radix_sort_step get_bit (i * 2) xs

-- | Like `radix_sort_by_key` but chunked.
def chunked_radix_sort_by_key [n] 't 'k
                              (chunk: i16)
                              (highest: k)
                              (key: t -> k)
                              (num_bits: i32)
                              (get_bit: i32 -> k -> i32)
                              (xs: [n]t): [n]t =
  let sorter = chunked_radix_sort chunk (highest, -1)
  in by_key_wrapper sorter key num_bits get_bit xs

-- | Like `radix_sort_by_int` but chunked.
def chunked_radix_sort_int [n] 't
                           (chunk: i16)
                           (highest: t)
                           (num_bits: i32)
                           (get_bit: i32 -> t -> i32)
                           (xs: [n]t): [n]t =
  let get_bit' i x =
    let b = get_bit i x
    in if i == num_bits-1 then b ^ 1 else b
  in chunked_radix_sort chunk highest num_bits get_bit' xs

-- | Like `radix_sort_int_by_key` but chunked.
def chunked_radix_sort_int_by_key [n] 't 'k
                                  (chunk: i16)
                                  (highest: k)
                                  (key: t -> k)
                                  (num_bits: i32)
                                  (get_bit: i32 -> k -> i32)
                                  (xs: [n]t): [n]t =
  let sorter = chunked_radix_sort_int chunk (highest, -1)
  in by_key_wrapper sorter key num_bits get_bit xs

-- | Like `radix_sort_float` but chunked.
def chunked_radix_sort_float [n] 't
                             (chunk: i16)
                             (highest: t)
                             (num_bits: i32)
                             (get_bit: i32 -> t -> i32)
                             (xs: [n]t): [n]t =
  let get_bit' i x =
    let b = get_bit i x
    in if get_bit (num_bits-1) x == 1 || i == num_bits-1
       then b ^ 1 else b
  in chunked_radix_sort chunk highest num_bits get_bit' xs

-- | Like `radix_sort_float_by_key` but chunked.
def chunked_radix_sort_float_by_key [n] 't 'k
                                    (chunk: i16)
                                    (highest: k)
                                    (key: t -> k)
                                    (num_bits: i32)
                                    (get_bit: i32 -> k -> i32)
                                    (xs: [n]t): [n]t =
  let sorter = chunked_radix_sort_float chunk (highest, -1)
  in by_key_wrapper sorter key num_bits get_bit xs
