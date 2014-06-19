elm-benchmark
=============

Elm code benchmarking suite

###How to use this library:
First: import what you'll need
```elm
import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)
```

Now a simple rendering benchmarck. How long does it take to render circles of different sizes?
```elm
circleBench : Benchmark
circleBench =
    let circleGen : Int -> Element 
        circleGen n = collage 200 200 [filled col <| circle <| toFloat n]
    in  render "Circle from radius 25 to 100" circleGen [25..100]
```
A function that is going to be benchmarked for its rendering speed MUST be of type `(a->Element)`.


Alright, but how fast can Elm do logic?
```elm
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
```elm
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
```elm
emptyArray =
    let multiplier = 100000
        trials : [() -> Int]
        trials = inputMap (\x -> multiplier * x) [1..10]
        manyEmpty : Int -> Array
        manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i] -- We just need to make the arrays, not keep them
    in  lazyLogic "[1..10] * 100000 empty arrays" manyEmpty trials
```
`lazyLogic` here is of type `String -> (a -> b) -> [() -> a] -> Benchmark`


We can also run setup in a different way that is more similar to JSPerf's setup phase:
```elm
logicalSetup : Benchmark
logicalSetup =
    let setup = inputMap (\x -> [1.. (1000 * x)]) [1..10]
        trials = reverse [1..10]
        appender xs x = x :: xs
    in  logicSetup "add 10..1 to (1000 * [1..10])" setup appender trials
```
Note that logicSetup is of type `String -> [() -> b] -> (b -> a -> c) -> [a] -> Benchmark`.
This works in the same way for rendering, too!
```elm
renderSetup : String -> [() -> b] -> (b -> a -> Element) -> [a] -> Benchmark
```


###Design:

####What we want to do:
We want to run a snippet of code and get a numeric value of how it performs.
We want to be able to run the same snippet of code on varying inputs to
simulate a section of a real world application (i.e., how does performance
change as a function of time or window dimensions).

####The atom of computation:
At the heart of benchmarking a set of inputs is the execution of one input.
Subatomically is the function itself without input, but it may be best to
think of our atom as a saturated function waiting to be executed.

#####Hydrogen & Helium:
There are two different kinds of atoms in this benchmarking suite.
One is for pure functions `() -> ()`. We want to know how fast Elm will
execute a snippet of code that require no rendering.
Then there are ones that create a visual effect `() -> Element`.
These require the renderer to bring the elements to life.

####Results:
We eventually want the results of our tests. We want that numeric value
of our function. We want the time taken for a `Benchmark` to complete, along
with the information about what the test did.

####Running the tests:
#####Pure Functions:
Pure functions are easy to test. They do not have side effects. They do not render to the screen. We can simply time the function and see how long it takes to run.
#####Rendering Functions:
We need a strategy to fully render the functions while also allowing us to cleanly display the results. There are two obvious strategies:
1. Render the function in a 1px area. We squish the output to a tiny size.
2. Render the function in a hidden area.
3. Render on screen in a predefined area
We choose #3.
