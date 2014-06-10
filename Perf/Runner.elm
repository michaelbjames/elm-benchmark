module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner

run : Benchmark -> Signal Element
run bm = case bm of
    Logic name fs -> lift (above (asText name)) <| Native.Runner.runLogic fs
    Render name fs -> lift (above (asText name)) <| Native.Runner.runRender fs

runMany : [Benchmark] -> Signal Element
runMany bms = Native.Runner.runMany bms
