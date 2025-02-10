import "lib/github.com/diku-dk/sorts/bitonic_sort"
import "lib/github.com/diku-dk/sorts/merge_sort"
import "lib/github.com/diku-dk/sorts/radix_sort"
import "lib/github.com/diku-dk/sorts/blocked_partition"

-- 32-bit keys
-- ==
-- entry: bitonic_sort_i32 merge_sort_i32 radix_sort_i32 blocked_radix_sort_i32 partition_i32 blocked_partition_i32
-- random input { [100000]i32 }
-- random input { [1000000]i32 }
-- random input { [10000000]i32 }
-- random input { [100000000]i32 }
entry bitonic_sort_i32 = bitonic_sort (i32.<=)
entry merge_sort_i32 = merge_sort (i32.<=)
entry radix_sort_i32 = radix_sort 32 i32.get_bit
entry blocked_radix_sort_i32 = blocked_radix_sort 256 32 i32.get_bit
entry partition_i32 = partition (< 0i32)
entry blocked_partition_i32 = blocked_partition 256 (< 0i32)

-- 64-bit keys
-- ==
-- entry: bitonic_sort_i64 merge_sort_i64 radix_sort_i64 blocked_radix_sort_i64 partition_i64 blocked_partition_i64
-- random input { [100000]i64 }
-- random input { [1000000]i64 }
-- random input { [10000000]i64 }
-- random input { [100000000]i64 }
entry bitonic_sort_i64 = bitonic_sort (i64.<=)
entry merge_sort_i64 = merge_sort (i64.<=)
entry radix_sort_i64 = radix_sort 64 i64.get_bit
entry blocked_radix_sort_i64 = blocked_radix_sort 256 64 i64.get_bit
entry partition_i64 = partition (< 0i64)
entry blocked_partition_i64 = blocked_partition 256 (< 0i64)

-- Special 64-bit keys dataset for partition to show the performance
-- improvement of blocked partition.
-- ==
-- entry: partition_i64 blocked_partition_i64
-- random input { [500000000]i64 }
