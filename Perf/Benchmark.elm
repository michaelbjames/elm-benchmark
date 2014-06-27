module Perf.Benchmark 
    ( logic
    , render
    , renderStatic
    , logicSetup
    , renderSetup
    , lazyLogic
    , Benchmark
    , run
    ) where
{-| 

# Create
@docs logic, render, renderStatic

# Memory-smart logic functions
@docs lazyLogic

# Benchmarks with setup
@docs logicSetup, renderSetup
-}

import Perf.Types as T
import Perf.Runner as R

-- Bindings from other files for a cleaner export
type Benchmark = T.Benchmark
run = R.run

{-| Internal function to easily wrap the timed function so its type is easier
to work with. It also more concretely demonstrates that we don't care about the
function's return type.
-}
mute : a -> ()
mute f = always () f

{-| Internal function to create turnkey functions from a function and presaturations.
This will come in handy for the lazyLogic benchmarks.

      trials = inputMap (\x -> [1..(1000 * x)]) [1..10]
-}
inputMap : (a -> b) -> [a] -> [() -> b]
inputMap f xs = map (\x -> \() -> f x) xs



{-| Create a logic benchmark, running a function on many different inputs.
You provide a name, a function, and a list of input values. After the benchmark
suite runs, you will see results for each input all labeled with the given name.
 
      logic "Date Parsing" parseDate [ "1/2/1990", "1 Feb 1990", "February 1, 1990" ]
-}
logic : String -> (a -> b) -> [a] -> T.Benchmark
logic name function inputs = 
  let noSetup f input = \_ -> let muted a = mute (f a)
                              in \_ -> muted input
  in  T.Logic name <| map (noSetup function) inputs


{-| Create a rendering benchmark, rendering a sequence of states. You provide a
name, a rendering function, and a sequence of states. Running this benchmark
measures the whole rendering pipeline.
 
      render "Profile" userProfile [ { user=123, friends=0 }
                                   , { user=123, friends=1 }
                                   , { user=123, friends=2 }
                                   , { user=123, friends=1 }
                                   ]

The sequence of states really is a *sequence*. They are run in order, so you can
see how well Elm's diffing engine does given the particular sequence you give it.
It may help to record a sequence of states directly from your project. Better to
use real data instead of making it up!
-}
render : String -> (a -> Element) -> [a] -> T.Benchmark
render name function inputs =
  let noSetup f input = \_ _-> f input
  in  T.Render name <| map (noSetup function) inputs


{-| Just get the cost of rendering from scratch. This does not get any of
the benefits of diffing to speed things up, so it is mainly useful for
assessing page load time.

      renderStatic "Markdown rendering" markdownBlock
-}
renderStatic : String -> Element -> T.Benchmark
renderStatic name element = render name (\_ -> element) [()]




{-| Time a function after executing a setup function whose output will be
fed into the timed function. This will let you perform an operation required for
the timed function that won’t be counted against the timed function.

      logicSetup "Ackermann(fib(n),n)" fib [5..10] ackermann [5..10]
-}
logicSetup : String -> (a -> b) -> [a] -> (b -> c -> d) -> [c] -> T.Benchmark
logicSetup name setup setupInputs function inputs =
  let thunk f (setupFunc,testInput) = \_ -> let input =  setupFunc ()
                                                muted x y = mute (f x y)
                                           in  \_ -> muted input testInput
      setups = inputMap setup setupInputs
  in  T.Logic name <| map (thunk function) <| zip setups inputs


{-| Time a function after executing a setup function whose output will be
fed into the timed function. This will let you perform an operation required for
the timed function that won’t be counted against the timed function.

      renderSetup "Julia-Pan-Zoom-0-10" juliaSetZoom [0..10] panX [0..10]
-}
renderSetup : String -> (a -> b) -> [a] -> (b -> c -> Element) -> [c] -> T.Benchmark
renderSetup name setup setupInputs function inputs =
  let thunk f (setupFunc,testInput) = \_ -> let input =  setupFunc ()
                                           in  \_ -> f input testInput
      setups = inputMap setup setupInputs
  in  T.Render name <| map (thunk function) <| zip setups inputs



{-| The input to the timed function is now lazy. It will be evaluated
as it is actually needed. This will fix many out-of-memory issues. Note
that the list of inputs to the timed function are now themselves turnkey
functions.

      emptyBench =
          let multiplier = 100000
              trialFunction x = multiplier * x
              manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i]
          in
              lazyLogic "10 empty arrays" manyEmpty trialFunction [1..10]
-}
lazyLogic : String -> (a -> b) -> (c -> a) -> [c] -> T.Benchmark
lazyLogic name function lazyInputFunc inputs =
  let thunk f lazyInputFunction = \_ -> let input = lazyInputFunction ()
                                            muted x = mute (f x)
                                        in  \_ -> muted input
  in T.Logic name <| map (thunk function) (inputMap lazyInputFunc inputs)
