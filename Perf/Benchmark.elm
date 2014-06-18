module Perf.Benchmark where

import Perf.Types (..)

{- | Wrapping function for logical benchmarks.

    logic "fibonacci" (logicFunction fib) [1..30]

    Note: If your function takes no parameters, it will be prematurely evalutated!
-}

logicFunction : a -> ()
logicFunction function = always () <| function

{- | Run a benchmark after executing a setup function. Occasionally your
     benchmark needs some large amounts of data to function. This provides
     a harness to evaluate the big data immediately before it is needed

     logicSetup "Fibonacci" fibbDB (logicFunction fib) [30..35]
-}
logicSetup : String -> (() -> b) -> (b -> a -> ()) -> [a] -> Benchmark
logicSetup name setup function inputs =
  let thunk f setupInput testInput = \_ _-> f (setupInput ()) testInput
  in  Logic name <| map (thunk function setup) inputs


{-| Run a function with a range of different values, benchmarking each separately.
 
    logic "factorial" fact [1..9]
-}
logic : String -> (a -> ()) -> [a] -> Benchmark
logic name function inputs = 
  let thunker f input = \_ _-> f input
  in  Logic name <| map (thunker function) inputs


renderSetup : String -> (() -> b) -> (b -> a -> Element) -> [a] -> Benchmark
renderSetup name setup function inputs =
  let thunk f setupInput testInput = \_ _-> f (setupInput ()) testInput
  in  Render name <| map (thunk function setup) inputs

{-| Record a sequence of states and feed them to your render functions.
This will test the performance of *updating* the view for a given sequence
of events.
 
    render "graph" graph [ [(1,1),(2,2),(3,3)], [(1,1),(2,3),(3,4)], [(1,1),(3,2),(4,4)] ]
-}
render : String -> (a -> Element) -> [a] -> Benchmark
render name function inputs =
  let thunker f input = \_ _-> f input
  in  Render name <| map (thunker function) inputs

{-| Just get the cost of rendering from scratch. This does not get any of
the benefits of diffing to speed things up, so it is mainly useful for
assessing page load time.
-}
staticRender : String -> Element -> Benchmark
staticRender name element = render name (\_ -> element) [()]
