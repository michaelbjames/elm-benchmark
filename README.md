elm-benchmark
=============

Elm code benchmarking suite

###How to use this library:
First: import what you'll need
```haskell
import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)
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

####A little more advanced
Let's suppose you've got a **huge** logical test. You're testing something that happens so fast on small input most timers wouldn't catch it so you instead run it on a 1,000,000 element list. This is too much memory to just allocate at the start and hold on to until it is no longer needed. We can lazily allocate the input for the test when it is needed.
```haskell
emptyArray =
    let multiplier = 100000
        trials : [() -> Int]
        trials x = multiplier * x
        -- We just need to make the arrays, not keep them
        manyEmpty : Int -> Array
        manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i]
    in  lazyLogic "[1..10] * 100000 empty arrays" manyEmpty trials [1..10]
```
`lazyLogic` here is of type `String -> (a -> b) -> (c -> a) -> [c] -> Benchmark`


We can also run setup in a different way that is more similar to JSPerf's setup phase:
```haskell
logicalSetup : Benchmark
logicalSetup =
    let setup = inputMap (\x -> [1.. (1000 * x)]) [1..10]
        trials = reverse [1..10]
        appender xs x = x :: xs
    in  logicSetup "add 10..1 to (1000 * [1..10])" setup appender trials
```
Note that logicSetup is of type `String -> (a -> b) -> [a] -> (b -> c -> d) -> [c] -> Benchmark`.
This works in the same way for rendering, too!
```haskell
renderSetup : String -> (a -> b) -> [a] -> (b -> c -> Element) -> [c] -> Benchmark
```
