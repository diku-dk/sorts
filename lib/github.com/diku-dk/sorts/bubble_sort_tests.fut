-- | ignore

import "test_utils"
import "bubble_sort"

-- ==
-- property: sort_f32 by_key

#[prop]
entry sort_f32 = correct_sort (bubble_sort (f32.<=)) (<=)

#[prop]
entry by_key xs =
  correct_sort (bubble_sort_by_key (.0) (i32.<=))
               (\(x, _) (y, _) -> x <= y)
               (zip xs (indices xs))
