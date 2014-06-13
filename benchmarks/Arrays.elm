module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Array


emptyBench = let multiplier = 100000
                 trials = map (\x -> multiplier * x) [1..10]
                 manyEmpty i = let _ = foldr (\_ _ -> Array.empty) Array.empty [1..i] in ()
             in  logicGroup "10 empty arrays" manyEmpty trials


repeatBench = let multiplier = 1000000
                  trials = map (\x -> multiplier * x) [1..10]
                  repeatWrap i = let _ = Array.repeat i 'a' in ()
              in  logicGroup ("10 repeat arrays") repeatWrap trials

-- We're not testing how fast function application is but how the functions
-- perform on large datasets.
fromListBench = let multiplier = 1000000
                    trialData = map (\x -> [1..(multiplier * x)]) [1..10]
                    fromListWrap xs = let _ = Array.fromList xs in ()
                in  logicGroup "10 fromLists" fromListWrap trialData


lengthBench = let multiplier = 1000000
                  trials = map (\x -> Array.repeat (multiplier * x) 0) [1..10]
                  lengthWrap xs = let _ = Array.length xs in ()
              in  logicGroup "10 Lengths" lengthWrap trials


pushBench = let multiplier = 10000
                trialData = map (\x -> (x,Array.repeat (multiplier * x) 0)) [1..10]
                pushWrap (x,xs) = let _ = Array.push x xs in ()
            in  logicGroup "10 Pushes" pushWrap trialData


appendBench = let multiplier = 10000
                  trialData = map (\x -> (Array.repeat (multiplier * (11-x)) 1,
                                   Array.repeat (multiplier * x) 0)) [1..10]
                  appendWrap (l,r) = let _ = Array.append l r in ()
              in  logicGroup "Append of varying differences" appendWrap trialData

getBench = let multiplier = 100
               trialData = map (\x -> ((multiplier * x), Array.repeat (5 * multiplier) 0) ) [1..5]
               getWrap (position, array) = let _ = Array.get position array in ()
           in  logicGroup "Get at different positions" getWrap trialData


sliceBench = let array = Array.repeat 10000 0
                 slices = [ (0, 100) , (0, -100), (-100, 900) , (-100, 0)
                          , (500, 501) , (500, 1000)]
                 sliceWrap (start, end) = let _ = Array.slice start end array in ()
            in  logicGroup "Slice" sliceWrap slices


benchmarks : [Benchmark]
benchmarks = [ emptyBench
             , repeatBench
             , fromListBench
             , lengthBench
             , pushBench
             , appendBench
             ]

main : Signal Element
main = run [sliceBench]