module Perf.Runner where

import Perf.Benchmark (..)
import Native.Runner

data Result = Running String (Element,[Time])
            | Single String [Time]
            | Report String [Result]

display : Result -> Element
display result = case result of
  Running name (element,times) -> asText name `above` element `above` (asText times)
  Single name times ->   asText name `above` (asText times)
  Report name results -> foldr (\acc base -> base `above` (display acc)) (asText name) results

run : Benchmark -> Signal Result
run bm =
  case bm of
    Logic name fs -> let totalFunctions = length fs
                     in lift (benchmarkComplete name totalFunctions)
                        (lift (\x -> (spacer 0 0, x)) (runLogic fs))
    View name fs ->
      let totalFunctions = length fs
      in lift (benchmarkComplete name totalFunctions) (runView fs)
    Group name bms -> lift (Report name) (combine (map run bms))
    {-| We need `run` to wait for each element in bms to complete
        before going on to the next benchmark
    -}


benchmarkComplete : String -> Int -> (Element, [Time]) -> Result
benchmarkComplete name totalFunctions (element, times) =
  if totalFunctions == (length times)
  then Single name times
  else Running name (element, times)

runLogic : [()->()] -> Signal [Time]
runLogic fs = Native.Runner.runLogic fs

runView : [() -> Element] -> Signal (Element,[Time])
runView fs = Native.Runner.runView fs


--showResults : Result -> Element
