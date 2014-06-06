module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner

data Result = Single String [Time]
            | Report String { total : Time,
                              individuals : [Result] }

run : Benchmark -> (Signal Element, Signal Time)
run bm =
  case bm of
    --Logic name fs -> lift showResults runLogic fs
    View name fs -> runView fs
    --Group name bms ->


--runLogic : [()->()] -> Signal Result
--runLogic fs = Native.Runner.runLogic fs

runView : [() -> Element] -> (Signal Element, Signal Time)
runView fs = Native.Runner.runView fs


--showResults : Result -> Element
