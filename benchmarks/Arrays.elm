module Main where

import Perf.Benchmark (..)
import Array


emptyBench =
    let multiplier = 100000
        trials = inputMap (\x -> multiplier * x) [1..10]
        manyEmpty i = foldr (\_ _ -> Array.empty) Array.empty [1..i]
    in  lazyLogic "empty arrays" manyEmpty trials


repeatBench =
    let multiplier = 1000000
        trials = inputMap (\x-> multiplier * x) [1..10]
        repeatWrap i = Array.repeat i ()
    in  lazyLogic "repeat arrays" repeatWrap trials


fromListBench =
    let multiplier = 1000000
        trialData = inputMap (\x -> [1..(multiplier * x)]) [1..10]
        fromListWrap xs = Array.fromList xs
    in  lazyLogic "fromLists" fromListWrap trialData


lengthBench =
    let multiplier = 1000000
        trials = inputMap (\x -> Array.repeat (multiplier * x) () ) [1..10]
        lengthWrap xs = Array.length xs
    in  lazyLogic "Lengths" lengthWrap trials


pushBench =
    let multiplier = 10000
        trialData = inputMap (\x -> (x,Array.repeat (multiplier * x) 0 )) [1..10]
        pushWrap (x,xs) = Array.push x xs
    in  lazyLogic "Pushes" pushWrap trialData


appendBench =
    let multiplier = 10000
        trialData = inputMap (\x -> (Array.repeat (multiplier * (11-x)) 1,
                         Array.repeat (multiplier * x) 0)) [1..10]
        appendWrap (l,r) = Array.append l r
    in  lazyLogic "Append of varying differences" appendWrap trialData


getBench =
    let multiplier = 100
        trialData = inputMap (\x -> ((multiplier * x), Array.repeat (5 * multiplier) () )) [1..5]
        getWrap (position, array) = Array.get position array
    in  lazyLogic "Get at different positions" getWrap trialData


sliceBench =
    let array = Array.repeat 10000 ()
        slices = [ (0, 100) , (0, -100), (-100, 900) , (-100, 0)
                 , (500, 501) , (500, 1000)]
        sliceWrap (start, end) = Array.slice start end array
    in  logic "Slice" sliceWrap slices


toListBench =
    let multiplier = 1000
        trialData = inputMap (\x -> Array.repeat (multiplier * x) () ) [1..10]
        toListWrap array = Array.toList
    in  lazyLogic "toList" toListWrap trialData


mapBench =
    let multiplier = 1000
        toyFunction = id
        trialData = inputMap (\x -> Array.repeat (multiplier * x) () ) [1..10]
        mapWrap array = Array.map toyFunction array
    in  lazyLogic "map" mapWrap trialData


foldlBench =
    let multiplier = 1000
        toyFunction _ _ = ()
        trialData = inputMap (\x -> Array.repeat (multiplier * x) () ) [1..10]
        foldlWrap array = Array.foldl toyFunction () array
    in  lazyLogic "foldl" foldlWrap trialData


foldrBench =
    let multiplier = 1000
        toyFunction _ _ = ()
        trialData = inputMap (\x -> Array.repeat (multiplier * x) () ) [1..10]
        foldrWrap array = Array.foldr toyFunction () array
    in  lazyLogic "foldr" foldrWrap trialData




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