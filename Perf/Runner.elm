module Perf.Runner
    ( run
    ) where

import Perf.Benchmark (..)
import Perf.Types (..)
import Native.Runner
import Either (..)
import Window
import Perf.LineGraph (..)



run : [Benchmark] -> Signal Element
run bms = lift2 display Window.width <| Native.Runner.runMany bms

display : Int -> Either Element [Result] -> Element
display w elementString = case elementString of
    Left element  -> element
    Right results -> showResults w results
