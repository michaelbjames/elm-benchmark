module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner


run : [Benchmark] -> Signal Element
run bms = Native.Runner.runMany bms
