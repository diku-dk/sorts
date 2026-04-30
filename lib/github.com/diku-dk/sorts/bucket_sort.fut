local
def ceil_log2 (a: i64) : i64 =
  i64.i32 (i64.num_bits - i64.clz (a - 1))

local
module mk_bucket_sort (I: integral) = {
  def sort 'a [n] (m: i64) (get_key: a -> i64) (vs: [n]a) : [n]a =
    let block_size = m
    let block_num = (n + block_size - 1) / block_size
    let block_count block_i =
      let start = block_i * block_size
      let end = i64.min n ((block_i + 1) * block_size)
      let rank = replicate block_size (I.i64 0)
      let count = replicate block_size 0i64
      in loop (rank, count)
         for j < end - start do
           let i = get_key vs[j]
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
                    let j = get_key vs[i]
                    in offsets[block_id][j] + I.to_i64 flat_ranks[i])
    let sorted_values = scatter (#[scratch] replicate n vs[0]) is vs
    in sorted_values
}

local module bucket_sort_u8 = mk_bucket_sort u8
local module bucket_sort_u16 = mk_bucket_sort u16
local module bucket_sort_u32 = mk_bucket_sort u32
local module bucket_sort_i64 = mk_bucket_sort i64

-- | Implementation of bucket sort. Where `m` is the number of keys
-- and `get_key` is a function which maps a value to a integer in a
-- contiguous interval of integers from 0 to `m` - 1.
--
-- **Work:** *O(n ✕ W(get_key))*
--
-- **Span:** *O(m ✕ W(get_key) + log n)*
def bucket_sort 'a [n] (m: i64) (get_key: a -> i64) (vs: [n]a) : [n]a =
  if m <= 1i64 + i64.u8 u8.highest
  then bucket_sort_u8.sort m get_key vs
  else if m <= 1i64 + i64.u16 u16.highest
  then bucket_sort_u16.sort m get_key vs
  else if m <= 1i64 + i64.u32 u32.highest
  then bucket_sort_u32.sort m get_key vs
  else bucket_sort_i64.sort m get_key vs
