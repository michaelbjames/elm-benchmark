module Perf.BenchExec where

import Perf.Benchmark (..)
import Native.BenchExec

data Result = Single String [Time]
            | Report String { total : Time,
                              individuals : [Result] }

run : Benchmark -> Signal Element
run bm =
  case bm of
    --Logic name fs -> lift showResults logicTimeTrials fs
    View name fs -> viewTimeTrials fs
    --Group name bms ->


logicTimeTrials : [()->()] -> Signal Result
logicTimeTrials fs = Native.BenchExec.logicTimeTrial fs

viewTimeTrials : [() -> Element] -> Signal Element
viewTimeTrials fs = Native.BenchExec.viewTimeTrial fs


showResults : Result -> Element
