import "lib/github.com/diku-dk/sorts/radix_sort"
import "lib/github.com/diku-dk/sorts/bucket_sort"

def floor_log2 (a: i64) : i32 =
  (i64.num_bits - 1) - i64.clz a

def hash (x: i32) : i32 =
  let x = u32.i32 x
  let x = ((x >> 16) ^ x) * 0x45d9f3b
  let x = ((x >> 16) ^ x) * 0x45d9f3b
  let x = ((x >> 16) ^ x)
  in i32.u32 x

entry mk_input (num_buckets: i64) (n: i64) =
  let xs =
    iota n
    |> map i32.i64
    |> map hash
    |> map i64.i32
    |> map (% num_buckets)
  in (num_buckets, xs)

-- ==
-- entry: bucket_sort radix_sort
-- "n=10**7, num_buckets=32" compiled notest script input { mk_input 64i64 10000000i64 }
-- "n=10**7, num_buckets=64" compiled notest script input { mk_input 64i64 10000000i64 }
-- "n=10**7, num_buckets=128" compiled notest script input { mk_input 64i64 10000000i64 }
-- "n=10**7, num_buckets=512" compiled notest script input { mk_input 512i64 10000000i64 }
-- "n=10**8, num_buckets=32" compiled notest script input { mk_input 64i64 100000000i64 }
-- "n=10**8, num_buckets=64" compiled notest script input { mk_input 64i64 100000000i64 }
-- "n=10**8, num_buckets=128" compiled notest script input { mk_input 64i64 100000000i64 }
-- "n=10**8, num_buckets=512" compiled notest script input { mk_input 512i64 100000000i64 }
-- "n=10**9, num_buckets=32" compiled notest script input { mk_input 64i64 1000000000i64 }
-- "n=10**9, num_buckets=64" compiled notest script input { mk_input 64i64 1000000000i64 }
-- "n=10**9, num_buckets=128" compiled notest script input { mk_input 64i64 1000000000i64 }
-- "n=10**9, num_buckets=512" compiled notest script input { mk_input 512i64 1000000000i64 }
entry bucket_sort (num_buckets, xs) =
  bucket_sort num_buckets id xs

entry radix_sort (num_buckets, xs) =
  radix_sort (floor_log2 num_buckets) i64.get_bit xs
