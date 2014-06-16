module Perf.Benchmark where

data Benchmark = Logic String [(() -> ())]
               | Render String [(() -> Element)]


{- | Wrapping function for logical benchmarks.

    logic "fibonacci" (logicFunction fib) [1..30]

    Note: If your function takes no parameters, it will be prematurely evalutated!
-}

logicFunction : a -> ()
logicFunction function = always () <| function

{-| Just create a benchmark for a specific function with a specific argument.
 
    logic "factorial" fact 40
    logic "max" (\(a,b) -> max a b) (3,4)
-}
logic : String -> (a -> ()) -> a -> Benchmark
logic name function input = logicGroup name function [input]


{-| Run a function with a range of different values, benchmarking each separately.
 
    logicGroup "factorial" fact [1..9]
-}
logicGroup : String -> (a -> ()) -> [a] -> Benchmark
logicGroup name function inputs = 
  let thunker f input = (\_ -> f input)
  in
  Logic name <| map (thunker function) inputs

{-| Record a sequence of states and feed them to your render functions.
This will test the performance of *updating* the view for a given sequence
of events.
 
    render "graph" graph [ [(1,1),(2,2),(3,3)], [(1,1),(2,3),(3,4)], [(1,1),(3,2),(4,4)] ]
-}
render : String -> (a -> Element) -> [a] -> Benchmark
render name function inputs =
  let thunker f input = (\_ -> f input)
  in
  Render name <| map (thunker function) inputs

{-| Just get the cost of rendering from scratch. This does not get any of
the benefits of diffing to speed things up, so it is mainly useful for
assessing page load time.
-}
staticRender : String -> Element -> Benchmark
staticRender name element = render name (\_ -> element) [()]
