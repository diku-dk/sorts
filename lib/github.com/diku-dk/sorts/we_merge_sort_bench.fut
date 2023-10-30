import "merge_sort"
import "we_merge_sort"
import "radix_sort"


let leq_i32: i32 -> i32 -> bool = (<=)
let leq_i64: i64 -> i64 -> bool = (<=)


------------------------------------------------------------------------------
-- 32-bit keys


-- ==
-- entry: merge_sort_i32
-- random input { [100000]i32 }
-- random input { [1000000]i32 }
-- random input { [10000000]i32 }
entry merge_sort_i32 = merge_sort leq_i32

-- ==
-- entry: we_merge_sort_i32
-- random input { [100000]i32 }
-- random input { [1000000]i32 }
-- random input { [10000000]i32 }
entry we_merge_sort_i32 = we_merge_sort leq_i32

-- ==
-- entry: radix_sort_i32
-- random input { [100000]i32 }
-- random input { [1000000]i32 }
-- random input { [10000000]i32 }
entry radix_sort_i32 = radix_sort 32 i32.get_bit


------------------------------------------------------------------------------
-- 64-bit keys

-- ==
-- entry: merge_sort_i64
-- random input { [100000]i64 }
-- random input { [1000000]i64 }
-- random input { [10000000]i64 }
entry merge_sort_i64 = merge_sort leq_i64

-- ==
-- entry: we_merge_sort_i64
-- random input { [100000]i64 }
-- random input { [1000000]i64 }
-- random input { [10000000]i64 }
entry we_merge_sort_i64 = we_merge_sort leq_i64

-- ==
-- entry: radix_sort_i64
-- random input { [100000]i64 }
-- random input { [1000000]i64 }
-- random input { [10000000]i64 }
entry radix_sort_i64 = radix_sort 64 i64.get_bit