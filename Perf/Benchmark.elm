module Perf.Benchmark where

data Benchmark = Logic String [(() -> ())]
               | View String [(() -> Element)]
               | Group String [Benchmark]


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
 
    view "graph" graph [ [(1,1),(2,2),(3,3)], [(1,1),(2,3),(3,4)], [(1,1),(3,2),(4,4)] ]
-}
view : String -> (a -> Element) -> [a] -> Benchmark
view name function inputs =
  let thunker f input = (\_ -> f input)
  in
  View name <| map (thunker function) inputs

{-| Just get the cost of rendering from scratch. This does not get any of
the benefits of diffing to speed things up, so it is mainly useful for
assessing page load time.
-}
staticView : String -> Element -> Benchmark
staticView name element = view name (\_ -> element) [()]
 
group : String -> [Benchmark] -> Benchmark
group = Group
