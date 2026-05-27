-- | ignore

def count p = map p >-> map i64.bool >-> i64.sum

def correct_sort 'a [n] (sort: [n]a -> [n]a) (lte: a -> a -> bool) (xs: [n]a) : bool =
  let xs' = sort xs
  let eql x y = lte x y && lte y x
  in and (tabulate n (\i -> i == 0 || (xs'[i - 1] `lte` xs'[i])))
     && all (\x -> count (eql x) xs' == count (eql x) xs) xs'

import "radix_sort"

-- ==
-- property: radix_sort_u16 radix_sort_i32 radix_sort_u64 radix_sort_f32 is_stable

#[prop]
entry radix_sort_u16 = correct_sort (radix_sort u16.num_bits u16.get_bit) (<=)

#[prop]
entry radix_sort_i32 = correct_sort (radix_sort_int i32.num_bits i32.get_bit) (<=)

#[prop]
entry radix_sort_u64 = correct_sort (radix_sort u64.num_bits u64.get_bit) (<=)

#[prop]
entry radix_sort_f32 = correct_sort (radix_sort_float f32.num_bits f32.get_bit) (<=)

#[prop]
entry is_stable [n] (arrs: [][n]u8) : bool =
  all (\arr ->
         let (keys, idx) =
           map (% 5) arr
           |> flip zip (iota n)
           |> radix_sort_by_key (.0) u8.num_bits u8.get_bit
           |> unzip
         in tabulate n (\i -> i == 0 || keys[i - 1] != keys[i] || idx[i - 1] < idx[i])
            |> and)
      arrs
