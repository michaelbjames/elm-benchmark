module Main where

import Perf.BenchExec (..)
import Perf.Benchmark (..)

fib : Int -> Int
fib n =  case n of
          0 -> 1
          1 -> 1
          _ -> fib (n-1) + fib (n-2)

fibWrapper : Int -> ()
fibWrapper n = let _ = fib n in ()

fibMark : Benchmark
fibMark = logicGroup "high fibonacci" fibWrapper [20..30]



circleWrapper : Int -> Element
circleWrapper n = collage 200 200 [filled red <| circle <| toFloat n]

visMark : Benchmark
visMark = view "Circle" circleWrapper [10,50]




benchmark : Benchmark
benchmark = visMark

numeric : Result -> [Time]
numeric (Single name times) = times

results : [Time]
results = numeric <| run benchmark

main : Element
main = flow down <| map asText results