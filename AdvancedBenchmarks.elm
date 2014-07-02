module AdvancedBenchmarks
    ( renderWithSetup
    , logicWithDeferedInput
    ) where
{-|
Benchmarks for more specific purposes where the basic ones will not suffice

# Memory-smart logic function
@docs logicWithDeferedInput

# Benchmark with setup
@docs renderWithSetup
-}

import Types as T

-- Bindings from other files for a cleaner export
type Benchmark = T.Benchmark


{-| Run a staged benchmark. There is a setup phase and a timed phase.
This is similar to JSPerf's setup area. You pass in a benchmark name, a function
to time, a function that does untimed work converting seeds to inputs, and a list
of seeds.

This kind of benchmark may be helpful where the function you want to time requires
input that itself takes a non-trivial amount of time to compute but doesn't need
to be included in the benchmark

      let frames = [0..120]
          getFrame index = getFrame (musicStore "Rhapsody in Blue") index
      in  renderWithSetup "Visualize audio frame"
              visualizeFrame getFrame frames

In this example, you don't care how long it takes to get the frame but you want
to know how long it takes to visualize the audio frame. So you use a function to
set things up for the visualizer (i.e., get the song and go to the specific
frame).
-}
renderWithSetup : String -> (intput -> Element) -> (seed -> input) -> [seed] -> Benchmark
renderWithSetup name function seedFunction seeds =
  let thunk f seededInputFunction = \_ -> let input = seededInputFunction ()
                                              muted x = always () (f x)
                                          in  \_ -> muted input
  in  T.Render name <| map (thunk function) (inputMap seedFunction seeds)



{-| If you run into out-of-memory problems, this function is for you.
Create a benchmark that allocates memory when it's needed, as opposed to
all at once. This is handy when you hit memory limitations from logic benchmarks.
You pass in a string to name the benchmark, a funciton to time, a function
that sets up your input, and your input.

      insertBench =
          let multiplier = 1000
              inputToLongList x = [1..(multiplier * x)]
              insertToDictionary = foldr (\value d -> Dict.insert value value d) D.empty
          in  logicWithDeferedInput "Insert 1000 up to 10000 elements into an empty dictionary"
                  insertToDictionary inputToLongList [1..10]

It would be too much for many browsers to allocate dozens of 10000 element lists
at the same time, so instead we allocate them when we need them. Garbage collection
can reclaim the lists once the benchmark is done.
-}
logicWithDeferedInput : String -> (input -> output) -> (seed -> input) -> [seed] -> Benchmark
logicWithDeferedInput name function seedFunction seeds =
  let thunk f seededInputFunction = \_ -> let input = seededInputFunction ()
                                              muted x = always () (f x)
                                          in  \_ -> muted input
  in T.Logic name <| map (thunk function) (inputMap seedFunction seeds)




{-| Internal function to create turnkey functions from a function and presaturations.
This will come in handy for the logicWithDeferedInput benchmarks.

      trials = inputMap (\x -> [1..(1000 * x)]) [1..10]
-}
inputMap : (seed -> input) -> [seed] -> [() -> input]
inputMap f xs = map (\x -> \() -> f x) xs
