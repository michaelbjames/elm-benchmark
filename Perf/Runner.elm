module Perf.Runner
    ( run
    ) where

import Perf.Benchmark (..)
import Perf.Types (..)
import Native.Runner
import Either (..)
import Window (..)
import Perf.LineGraph (..)



run : [Benchmark] -> Signal Element
run bms = lift display <| Native.Runner.runMany bms

display : Either Element [Result] -> Element
display elementString = case elementString of
    Left element  -> element
    Right results -> showResults results
