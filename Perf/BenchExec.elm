module Perf.BenchExec where

import Perf.Benchmark (..)
import Native.BenchExec

data Result = Single String [Time]
            | Report String { total : Time,
                              individuals : [Result] }

run : Benchmark -> Result
run bm =
  case bm of
    Logic name fs -> Single name <| logicTimeTrials fs
    View name fs -> Single name <| viewTimeTrials fs
    --Group name bms ->

{-| Run a benchmark and get the list of how long each function took to run
-}
logicTimeTrials : [()->()] -> [Time]
logicTimeTrials fs = map Native.BenchExec.logicTimeTrial fs

viewTimeTrials : [() -> Element] -> [Time]
viewTimeTrials fs = Native.BenchExec.timeTrial fs