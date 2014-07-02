module Main where

import Perf.Benchmark (..)
import Perf.AdvancedBenchmarks (logicWithDeferedInput)
import Array


emptyBench =
    let multiplier = 100000
        trialInput x = multiplier * x
        manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i]
    in  logicWithDeferedInput "empty arrays" manyEmpty trialInput [1..10]


repeatBench =
    let multiplier = 1000000
        trialInput x = multiplier * x
        repeatWrap i = Array.repeat i ()
    in  logicWithDeferedInput "repeat arrays" repeatWrap trialInput [1..10]


fromListBench =
    let multiplier = 1000000
        trialData x = [1..(multiplier * x)]
        fromListWrap xs = Array.fromList xs
    in  logicWithDeferedInput "fromLists" fromListWrap trialData [1..10]


lengthBench =
    let multiplier = 1000000
        trials x = Array.repeat (multiplier * x) ()
        lengthWrap xs = Array.length xs
    in  logicWithDeferedInput "Lengths" lengthWrap trials [1..10]


pushBench =
    let multiplier = 10000
        trialData x = (x,Array.repeat (multiplier * x) 0 )
        pushWrap (x,xs) = Array.push x xs
    in  logicWithDeferedInput "Pushes" pushWrap trialData [1..10]


appendBench =
    let multiplier = 10000
        trialData x = (Array.repeat (multiplier * (11-x)) 1,
                         Array.repeat (multiplier * x) 0)
        appendWrap (l,r) = Array.append l r
    in  logicWithDeferedInput "Append of varying differences" appendWrap trialData [1..10]


getBench =
    let multiplier = 100
        trialData x = ((multiplier * x), Array.repeat (5 * multiplier) () )
        getWrap (position, array) = Array.get position array
    in  logicWithDeferedInput "Get at different positions" getWrap trialData [1..5]


sliceBench =
    let array = Array.repeat 10000 ()
        slices = [ (0, 100) , (0, -100), (-100, 900) , (-100, 0)
                 , (500, 501) , (500, 1000)]
        sliceWrap (start, end) = Array.slice start end array
    in  logic "Slice" sliceWrap slices


toListBench =
    let multiplier = 1000
        trialData x = Array.repeat (multiplier * x) ()
        toListWrap array = Array.toList
    in  logicWithDeferedInput "toList" toListWrap trialData [1..10]


mapBench =
    let multiplier = 1000
        toyFunction = id
        trialData x = Array.repeat (multiplier * x) ()
        mapWrap array = Array.map toyFunction array
    in  logicWithDeferedInput "map" mapWrap trialData [1..10]


foldlBench =
    let multiplier = 1000
        toyFunction _ _ = ()
        trialData x = Array.repeat (multiplier * x) ()
        foldlWrap array = Array.foldl toyFunction () array
    in  logicWithDeferedInput "foldl" foldlWrap trialData [1..10]


foldrBench =
    let multiplier = 1000
        toyFunction _ _ = ()
        trialData x = Array.repeat (multiplier * x) ()
        foldrWrap array = Array.foldr toyFunction () array
    in  logicWithDeferedInput "foldr" foldrWrap trialData [1..10]




benchmarks : [Benchmark]
benchmarks = [ emptyBench
             , repeatBench
             , fromListBench
             , lengthBench
             , pushBench
             , appendBench
             , toListBench
             , mapBench
             , foldlBench
             , foldrBench
             ]

main : Signal Element
main = run benchmarks