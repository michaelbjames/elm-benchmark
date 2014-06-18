module Perf.Runner (run) where

import Perf.Benchmark (..)
import Native.Runner
import Either (..)

type Result = { name:String, times:[Time] }

run : [Benchmark] -> Signal Element
run bms = lift display <| Native.Runner.runMany bms

display : Either Element [Result] -> Element
display elementString = case elementString of
    Left element  -> element
    Right results -> flow down <| map asText results