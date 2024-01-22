import "lib/github.com/diku-dk/sorts/bitonic_sort"
import "lib/github.com/diku-dk/sorts/merge_sort"
import "lib/github.com/diku-dk/sorts/radix_sort"

-- 32-bit keys
-- ==
-- entry: bitonic_sort_i32 merge_sort_i32 radix_sort_i32 chunked_radix_sort_i32
-- random input { [100000]i32 }
-- random input { [1000000]i32 }
-- random input { [10000000]i32 }
-- random input { [100000000]i32 }
entry bitonic_sort_i32 = bitonic_sort (i32.<=)
entry merge_sort_i32 = merge_sort (i32.<=)
entry radix_sort_i32 = radix_sort 32 i32.get_bit
entry chunked_radix_sort_i32 = chunked_radix_sort 256 i32.highest 32 i32.get_bit

-- 64-bit keys
-- ==
-- entry: bitonic_sort_i64 merge_sort_i64 radix_sort_i64 chunked_radix_sort_i64
-- random input { [100000]i64 }
-- random input { [1000000]i64 }
-- random input { [10000000]i64 }
-- random input { [100000000]i64 }
entry bitonic_sort_i64 = bitonic_sort (i64.<=)
entry merge_sort_i64 = merge_sort (i64.<=)
entry radix_sort_i64 = radix_sort 64 i64.get_bit
entry chunked_radix_sort_i64 = chunked_radix_sort 256 i64.highest 64 i64.get_bit
