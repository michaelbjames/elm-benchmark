module Main where

import Benchmark (..)

slowFib : Int -> Int
slowFib n =  case n of
          0 -> 1
          1 -> 1
          _ -> slowFib (n-1) + slowFib (n-2)

phiFib : Int -> Int
phiFib n = 
    let sq5 = sqrt 5
        phi = (sq5 + 1) / 2
    in  round ((phi ^ toFloat n) / sq5)

slowFibonacci : Benchmark
slowFibonacci = logic "Fibonacci numbers, recursively, from F(20) to F(30)" slowFib [20..30]

fastFibonacci : Benchmark
fastFibonacci = logic "Fibonacci numbers, with phi exponentiation, from F(20) to F(30)" phiFib [20..30]

circleWrapper : Color -> Int -> Element
circleWrapper col n = collage 200 200 [filled col <| circle <| toFloat n]

renderMark : Benchmark
renderMark = render "Increase the radius of a circle" (circleWrapper red) [10..49]

staticMark : Benchmark
staticMark = renderStatic "Blue Circle, radius 100" (circleWrapper blue 100)

groupMark : [Benchmark]
groupMark = [ staticMark
            , renderMark
            , slowFibonacci
            , fastFibonacci
            ]

main : Signal Element
main = run groupMark