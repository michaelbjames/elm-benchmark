module Perf.AdvancedBenchmarks
    ( renderSetup
    , logicDeferedInput
    ) where
{-|
Benchmarks for more specific purposes where the basic ones will not suffice

# Memory-smart logic function
@docs logicDeferedInput

# Benchmark with setup
@docs renderSetup
-}

import Perf.Types as T


{-| Run some function on a list of inputs to setup information for benchmark.
This is similar to JSPerf's setup area. You pass in a benchmark name, a function
that turns initial data into setup data, a function to time, and another
list of inputs to finish up the timed function. The following rule must hold true:
      
      length setupInputs == length inputs

This kind of benchmark may be helpful where the function you want to time requires
input that itself takes a non-trivial amount of time to compute but doesn't need
to be included in the benchmark

      let frames = [0..120]
          getFrame index = getFrame (musicStore "Rhapsody in Blue") index
      in  renderSetup "Visualize audio frame"
              getFrame frames visualizeFrame frames

In this example, you don't care how long it takes to get the frame but you want
to know how long it takes to visualize the audio frame. So you use a function to
set things up for the visualizer (i.e., get the song and go to the specific
frame).
-}
renderSetup : String -> (a -> b) -> [a] -> (b -> c -> Element) -> [c] -> T.Benchmark
renderSetup name setupFunction setupInputs function inputs =
  let thunk f (setupFunc,testInput) = \_ -> let input =  setupFunc ()
                                           in  \_ -> f input testInput
      setups = inputMap setupFunction setupInputs
  in  T.Render name <| map (thunk function) <| zip setups inputs



{-| If you run into out-of-memory problems, this function is for you.
Create a benchmark that allocates memory when it's needed, as opposed to
all at once. This is handy when you hit memory limitations from logic benchmarks.
You pass in a string to name the benchmark, a funciton to time, a function
that sets up your input, and your input.

      insertBench =
          let multiplier = 1000
              inputToLongList x = [1..(multiplier * x)]
              insertToDictionary = foldr (\value d -> Dict.insert value value d) D.empty
          in  logicDeferedInput "Insert 1000 up to 10000 elements into an empty dictionary"
                  insertToDictionary inputToLongList [1..10]

It would be too much for many browsers to allocate dozens of 10000 element lists
at the same time, so instead we allocate them when we need them. Garbage collection
can reclaim the lists once the benchmark is done.
-}
logicDeferedInput : String -> (a -> b) -> (c -> a) -> [c] -> T.Benchmark
logicDeferedInput name function deferedInput inputs =
  let thunk f lazyInputFunction = \_ -> let input = lazyInputFunction ()
                                            muted x = always () (f x)
                                        in  \_ -> muted input
  in T.Logic name <| map (thunk function) (inputMap deferedInput inputs)




{-| Internal function to create turnkey functions from a function and presaturations.
This will come in handy for the logicDeferedInput benchmarks.

      trials = inputMap (\x -> [1..(1000 * x)]) [1..10]
-}
inputMap : (a -> b) -> [a] -> [() -> b]
inputMap f xs = map (\x -> \() -> f x) xs
