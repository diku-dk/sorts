# Sorting implementations in Futhark

This package contains various sorting algorithms implemented in
Futhark.  Check the documentation for each file for details.

## Installation

```
$ futhark-pkg add github.com/diku-dk/sorts
$ futhark-pkg sync
```

## Usage

```
$ futharki
> import "lib/github.com/diku-dk/sorts/radix_sort"
> radix_sort_int i32.num_bits i32.get_bit [5,7,-1,2,-2]
[-2i32, -1i32, 2i32, 5i32, 7i32]
```
