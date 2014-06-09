module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner

data Result = Running String (Element,[Time])
            | Single String [Time]
            | Report String [Result]

display : Result -> Element
display result = case result of
    Running name (element,times) ->
                           asText name `above` element `above` (asText times)
    Single name times ->   asText name `above` (asText times)
    Report name results -> asText name `above`
        foldr (\result baseElement -> baseElement `below` (display result))
            (spacer 0 0) results

run : Benchmark -> Signal Result
run bm = case bm of
    Logic name fs -> let totalFunctions = length fs
                     in lift (status name totalFunctions)
                        (lift (\x -> (spacer 0 0, x)) (runLogic fs))
    View name fs ->
      let totalFunctions = length fs
      in lift (status name totalFunctions) (runView fs)
    Group name bms -> lift (Report name) (combine (map run bms))
    {-| We need `run` to wait for each element in bms to complete
        before going on to the next benchmark
    -}

{-| Get the status of a benchmark. As it is lifted, it will change
    from a running test to a completed single benchmark.
    Groups of benchmarks are broken down to individual tests and the status
    is displayed from there

    Question: Do we need to pass a string in? So therefore, we would return
    functions String -> Result. This would get lifted, so we would get
    Signal (String -> Result). Does Elm have a way to apply a value to this?
-}
status : String -> Int -> (Element, [Time]) -> Result
status name totalFunctions (element, times) =
    if totalFunctions == (length times)
    then Single name times
    else Running name (element, times)

runLogic : [()->()] -> Signal [Time]
runLogic fs = Native.Runner.runLogic fs

runView : [() -> Element] -> Signal (Element,[Time])
runView fs = Native.Runner.runView fs
