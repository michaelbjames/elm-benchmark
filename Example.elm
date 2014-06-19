module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)

fib : Int -> Int
fib n =  case n of
          0 -> 1
          1 -> 1
          _ -> fib (n-1) + fib (n-2)

--fibWrapper : Int -> (()->())
fibWrapper n = logicFunction <| fib n

fibMark : Benchmark
fibMark = logic "high fibonacci" fib [20..30]

circleWrapper : Color -> Int -> Element
circleWrapper col n = collage 200 200 [filled col <| circle <| toFloat n]

renderMark : Benchmark
renderMark = render "Circle" (circleWrapper red) [10..49]

staticMark : Benchmark
staticMark = staticRender "Blue Circle" (circleWrapper blue 100)

logicalSetup : Benchmark
logicalSetup =
    let setup = inputMap (\x -> [1.. (1000 * x)]) [1..10]
        trials = reverse [1..10]
        appender xs x = x :: xs
    in  logicSetup "add 10..1 to (1000 * [1..10])" setup appender trials

groupMark : [Benchmark]
groupMark = [ staticMark
            , fibMark
            , renderMark
            , logicalSetup
            ]

main : Signal Element
main = run groupMark