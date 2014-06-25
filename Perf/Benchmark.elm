module Perf.Benchmark 
    ( logic
    , render
    , staticRender
    , logicSetup
    , renderSetup
    , lazyLogic
    , inputMap
    , run
    ) where
{-| Benchmarking harnesses to determine the speed your code runs at.

# Benchmark constructors
@docs logic, render, staticRender

# Memory-smart logic functions
@docs lazyLogic, inputMap

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

{-| Run a function with a range of different values, benchmarking each separately.
 
    logic "factorial" fact [1..9]
-}
logic : String -> (a -> b) -> [a] -> T.Benchmark
logic name function inputs = 
  let noSetup f input = \_ -> let muted a = mute (f a)
                              in \_ -> muted input
  in  T.Logic name <| map (noSetup function) inputs


{-| Record a sequence of states and feed them to your render functions.
This will test the performance of *updating* the view for a given sequence
of events.
 
    render "graph" graph [ [(1,1),(2,2),(3,3)], [(1,1),(2,3),(3,4)], [(1,1),(3,2),(4,4)] ]
-}
render : String -> (a -> Element) -> [a] -> T.Benchmark
render name function inputs =
  let noSetup f input = \_ _-> f input
  in  T.Render name <| map (noSetup function) inputs


{-| Just get the cost of rendering from scratch. This does not get any of
the benefits of diffing to speed things up, so it is mainly useful for
assessing page load time.

    staticRender "Markdown rendering" markdownBlock
-}
staticRender : String -> Element -> T.Benchmark
staticRender name element = render name (\_ -> element) [()]




{-| Time a function after executing a setup function whose output will be
fed into the timed function. This will let you perform an operation required for
the timed function that won’t be counted against the timed function.

    logicSetup "Ackermann(fib(n),n)" fibs5to10 ackermann [5..10]
-}
logicSetup : String -> [() -> b] -> (b -> a -> c) -> [a] -> T.Benchmark
logicSetup name setups function inputs =
  let thunk f (setupFunc,testInput) = \_ -> let input =  setupFunc ()
                                                muted x y = mute (f x y)
                                           in  \_ -> muted input testInput
  in  T.Logic name <| map (thunk function) <| zip setups inputs


{-| Time a function after executing a setup function whose output will be
fed into the timed function. This will let you perform an operation required for
the timed function that won’t be counted against the timed function.

    renderSetup "Julia-Pan-Zoom-0-10" (juliaSetZoom0to10) panX [0..10]
-}
renderSetup : String -> [() -> b] -> (b -> a -> Element) -> [a] -> T.Benchmark
renderSetup name setups function inputs =
  let thunk f (setupFunc,testInput) = \_ -> let input =  setupFunc ()
                                           in  \_ -> f input testInput
  in  T.Render name <| map (thunk function) <| zip setups inputs



{-| The input to the timed function is now lazy. It will be evaluated
as it is actually needed. This will fix many out-of-memory issues. Note
that the list of inputs to the timed function are now themselves turnkey
functions.

    emptyBench =
        let multiplier = 100000
            trials = inputMap (\x -> multiplier * x) [1..10]
            manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i]
        in  lazyLogic "10 empty arrays" manyEmpty trials
-}
lazyLogic : String -> (a -> b) -> [() -> a] -> T.Benchmark
lazyLogic name function lazyInput =
  let thunk f lazyInputFunction = \_ -> let input = lazyInputFunction ()
                                            muted x = mute (f x)
                                        in  \_ -> muted input
  in T.Logic name <| map (thunk function) lazyInput


{-| Create turnkey functions from a function and presaturations.
This will come in handy for the lazyLogic benchmarks.

    trials = inputMap (\x -> [1..(1000 * x)]) [1..10]
-}
inputMap : (a -> b) -> [a] -> [() -> b]
inputMap f xs = map (\x _-> f x) xs 

