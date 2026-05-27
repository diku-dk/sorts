-- | ignore

import "test_utils"
import "merge_sort"

-- picking small block sizes should stress all codepaths within
-- merge_sort, even on small inputs
def params = {max_block_size = 2i64, max_merge_block_size = 2i64}

-- ==
-- property: sort_f32 by_key

#[prop]
entry sort_f32 = correct_sort (merge_sort_with_params params (f32.<=)) (<=)

#[prop]
entry by_key xs =
  correct_sort (merge_sort_with_params_by_key params (.0) (i32.<=))
               (\(x, _) (y, _) -> x <= y)
               (zip xs (indices xs))
