module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)

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

elements : [[Element]]
elements = map (\x -> take x simpleContent) [1..25]

addListToFlow : Direction -> [Element] -> Element 
addListToFlow direction elems = flow direction elems

directionForFlow : Direction -> Benchmark
directionForFlow d = render ("addingToFlow" ++ show d) (addListToFlow d) elements

addingToFlow : [Benchmark]
addingToFlow = map directionForFlow directions


benchmark : [Benchmark]
benchmark = foldr (\a b -> b ++ repeat 3 a) [] addingToFlow

main : Signal Element
main = run benchmark

--main = flow down <| collage 500 500 (map filled)