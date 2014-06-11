module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)

{-| Setup. These are some helpful functions
-}
imagePaths : [String]
imagePaths = map (\x -> "images/" ++ show x ++ ".jpg") [1..12]

directions : [Direction]
directions = [up, down, left, right, inward, outward]

intToCircle : Int -> Form
intToCircle n = filled red <| circle <| toFloat n

simpleContent : [Element]
simpleContent =  map (image 500 100) imagePaths
              ++ map asText [0..9]
              ++ map (\x -> collage 500 100 [x]) (map intToCircle [96..100])




flowDirection : Direction -> Benchmark
flowDirection d = staticRender ("flowDirection" ++ show d) (flow d simpleContent)
flowDirections : [Benchmark]
flowDirections = map flowDirection [ up, down, up, left, right, inward, outward ]

increasingElems : [[Element]]
increasingElems = map (\x -> take x simpleContent) [1..25]
decreasingElems : [[Element]]
decreasingElems = map (\x -> take x simpleContent) <| reverse [1..25]

directionForIncreasingFlow : Direction -> Benchmark
directionForIncreasingFlow d = render ("addingToFlow" ++ show d) (flow d) increasingElems

directionForDecreasingFlow : Direction -> Benchmark
directionForDecreasingFlow d = render ("removingFromFlow" ++ show d) (flow d) decreasingElems

addingToFlow : [Benchmark]
addingToFlow = map directionForIncreasingFlow directions

removingFromFlow : [Benchmark]
removingFromFlow = map directionForDecreasingFlow directions

benchmarks : [Benchmark]
benchmarks = removingFromFlow ++ addingToFlow ++ flowDirections

extraBenchmarks : [Benchmark]
extraBenchmarks = foldr (\a b -> b ++ repeat 3 a) [] benchmarks

main : Signal Element
main = run extraBenchmarks