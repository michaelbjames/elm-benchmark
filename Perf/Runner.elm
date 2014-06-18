module Perf.Runner
    ( run
    ) where

import Perf.Benchmark (..)
import Perf.Types (..)
import Native.Runner
import Either (..)
import Window (..)
import Perf.LineGraph (..)



data PrepBenchmark = PrepLogic String [() -> ()]
                   | PrepRender String [() -> Element]

run : [Benchmark] -> Signal Element
run bms =
    let prepedBenchmark bm = case bm of
        Logic name tthunks -> PrepLogic name <| map (\thunk -> thunk ()) tthunks
        Render name tthunks -> PrepRender name <| map (\thunk -> thunk ()) tthunks
    in  lift display <| Native.Runner.runMany <| map prepedBenchmark bms

display : Either Element [Result] -> Element
display elementString = case elementString of
    Left element  -> element
    Right results -> showResults results