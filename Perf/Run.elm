module Perf.Run where

import Perf.Benchmark (..)

data Result = Single String Time
            | Report String { total : Time,
                              individuals : [Result] }

run : Benchmark -> Result
run bm =
  case bm of
    Logic name f ->
    View name f -> let t1 = 