module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner

data Result = Single String [Time]
            | Report String { total : Time,
                              individuals : [Result] }

run : Benchmark -> Signal (Element,[Time])
run bm =
  case bm of
    Logic name fs -> runLogic fs
    View name fs -> runView fs
    --Group name bms ->


runLogic : [()->()] -> Signal (Element,[Time])
runLogic fs = Native.Runner.runLogic fs

runView : [() -> Element] -> Signal (Element,[Time])
runView fs = Native.Runner.runView fs


--showResults : Result -> Element
