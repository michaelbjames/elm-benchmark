elm-benchmark
=============

Elm code benchmarking suite

###How to use this library:
First: import what you'll need
```haskell
import Perf.Benchmark (..)
```

Now a simple rendering benchmarck. How long does it take to render circles of different sizes?
```haskell
circleBench : Benchmark
circleBench =
    let circleGen : Int -> Element 
        circleGen n = collage 200 200 [filled col <| circle <| toFloat n]
    in  render "Circle from radius 25 to 100" circleGen [25..100]
```
A function that is going to be benchmarked for its rendering speed MUST be of type `(a->Element)`.


Alright, but how fast can Elm do logic?
```haskell
fibBench : Benchmark
fibBench =
    let fib n = case n of
                    0 -> 1
                    1 -> 1
                    _ -> fib (n-1) + fib (n-2)
    in  logic "Fibonacci numbers from 1 to 25" fib [1..25]
```
A pure function to be benchmarked must be of type `(a->b)`.


Let's actually run these guys and see how fast they are
```haskell
benchmarks : [Benchmark]
benchmarks = [ circleBench
             , fibBench
             ]

main : Signal Element
main = run benchmarks
```

The screen will change before you to display the results when all benchmarks are completed.

####Need more power?
Look to the advanced benchmarks. For most cases, the basic benchmarks should suffice
but you may be bounded by memory issues or have some initial setup that shouldn't
be timed.
You'll need to import the advanced library:
```haskell
import Perf.AdvancedBenchmarks (..)
```
Read about `logicDeferedInput` and `renderSetup` in their file.
