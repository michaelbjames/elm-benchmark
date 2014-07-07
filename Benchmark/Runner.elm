module Benchmark.Runner
    ( run
    ) where

import Benchmark.Types (..)
import Benchmark.LineGraph (..)
import Native.Runner
import Either (..)
import Window


numRepeats = 10

flatten : Benchmark -> [Benchmark]
flatten bm = case bm of 
    Suite name benchmarks -> benchmarks
    _ -> [bm]

applyStructure : [Result] -> [Benchmark] -> [Group Result]
applyStructure results bms = case bms of
    Suite name benchmarks :: rest ->
        let suiteSize = length benchmarks
            rHead = take suiteSize results
            rTail = drop suiteSize results
        in  Set name (applyStructure rHead benchmarks) :: applyStructure rTail rest
    Logic _ _ :: rest -> Single (head results) :: applyStructure (tail results) rest 
    Render _ _ :: rest -> Single (head results) :: applyStructure (tail results) rest
    [] -> [] 

duplicateEach : Int -> [a] -> [a]
duplicateEach n xs = foldr (++) [] <| map (repeat n) xs

{-| Condenses every N elements in a list with `f`
-}
condenseEach : Int -> ([a] -> a) -> [a] -> [a]
condenseEach n f xs = case xs of
    [] -> []
    ys -> f (take n ys) :: condenseEach n f (drop n ys)

{-| Implicit assumption that we've got the same type of result.
They should all have the same name and the same number of elements in .times
-}
averageResults : [Result] -> Result
averageResults results =
    let n = length results
        times = map .times results
        numberOfData = length <| head times
        summed = foldr (\t s -> zipWith (+) t s) (repeat numberOfData 0) times
        avgs = map (\x -> toFloat (round ((x / toFloat n) * 10))/10 ) summed
    in { name=(head results).name, times=avgs }


run : [Benchmark] -> Signal Element
run bms =
    let flattenedBenchmarks = foldr (++) [] <| map flatten bms
        repeatedBms = duplicateEach numRepeats flattenedBenchmarks
    in  lift2 (display bms) Window.width <| Native.Runner.runMany repeatedBms


display : [Benchmark] -> Int -> Either Element [Result] -> Element
display structure w elementString = case elementString of
    Left element  -> element
    Right results -> 
        let avgs = condenseEach numRepeats averageResults results
            structuredResults = applyStructure results structure
        in  showResults w avgs
