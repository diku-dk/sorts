local
def ceil_log2 (a: i64) : i64 =
  i64.i32 (i64.num_bits - i64.clz (a - 1))

local
module mk_bucket_sort (I: integral) = {
  def sort 'a [n] (num_buckets: i64) (get_bucket: a -> i64) (vs: [n]a) : [n]a =
    let block_size = num_buckets
    let block_num = (n + block_size - 1) / block_size
    let block_count block_i =
      let start = block_i * block_size
      let end = i64.min n ((block_i + 1) * block_size)
      let rank = replicate block_size (I.i64 0)
      let count = replicate block_size 0i64
      in loop (rank, count)
         for j < end - start do
           let i = get_bucket vs[j]
           let rank[j] = I.i64 count[i]
           let count[i] = count[i] + 1
           in (rank, count)
    let (ranks, counts) =
      tabulate block_num block_count
      |> unzip
    let counts = transpose counts |> flatten
    let offsets =
      counts
      |> scan (+) 0
      |> flip (map2 (-)) counts
      |> unflatten
      |> transpose
    let flat_ranks = flatten ranks
    let is =
      tabulate n (\i ->
                    let block_id = i / block_size
                    let j = get_bucket vs[i]
                    in offsets[block_id][j] + I.to_i64 flat_ranks[i])
    let sorted_values = scatter (#[scratch] replicate n vs[0]) is vs
    in sorted_values
}

local module bucket_sort_u8 = mk_bucket_sort u8
local module bucket_sort_u16 = mk_bucket_sort u16
local module bucket_sort_u32 = mk_bucket_sort u32
local module bucket_sort_i64 = mk_bucket_sort i64

-- | Implementation of bucket sort. Where `num_buckets` is the number
-- of buckets and `get_bucket` is a function which maps a value to a
-- integer in a contiguous interval of integers from 0 to
-- `num_buckets` - 1.
--
-- **Work:** *O(n ✕ W(get_bucket))*
--
-- **Span:** *O(num_buckets ✕ W(get_bucket) + log n)*
def bucket_sort 'k [n] (num_buckets: i64) (get_bucket: k -> i64) (xs: [n]k) : [n]k =
  if num_buckets <= 1i64 + i64.u8 u8.highest
  then bucket_sort_u8.sort num_buckets get_bucket xs
  else if num_buckets <= 1i64 + i64.u16 u16.highest
  then bucket_sort_u16.sort num_buckets get_bucket xs
  else if num_buckets <= 1i64 + i64.u32 u32.highest
  then bucket_sort_u32.sort num_buckets get_bucket xs
  else bucket_sort_i64.sort num_buckets get_bucket xs
