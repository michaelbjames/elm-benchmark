module Main where

import Perf.Runner (..)
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

circleWrapper : Color -> Int -> Element
circleWrapper col n = collage 200 200 [filled col <| circle <| toFloat n]

visMark : Benchmark
visMark = view "Circle" (circleWrapper red) [10..50]

staticMark : Benchmark
staticMark = staticView "Blue Circle" (circleWrapper blue 100)

groupMark : Benchmark
groupMark = Group "groupMark"
                [ visMark
                , fibMark
                , staticMark
                ]

runner : Signal Result
runner = run <| visMark

main : Signal Element
main = lift display runner