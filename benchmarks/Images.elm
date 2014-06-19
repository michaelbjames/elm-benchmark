module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)

imagePaths : [String]
imagePaths = map (\x -> "images/" ++ show x ++ ".jpg") [1..12]


imageDisplay : Benchmark
imageDisplay = render "images" (image 500 500) imagePaths

fittedImage500 : Benchmark
fittedImage500 = render "fittedImage500" (fittedImage 500 500) imagePaths

fittedImage5 : Benchmark
fittedImage5 = render "fittedImage5" (fittedImage 5 5) imagePaths

croppedImage20x500 : Benchmark
croppedImage20x500 = render "croppedImage20x500" (croppedImage (20,20) 500 500) imagePaths

tiledImage20 : Benchmark
tiledImage20 = render "tiledImage20" (tiledImage 20 20) imagePaths

tiledImage500 : Benchmark
tiledImage500 = render "tiledImage500" (tiledImage 500 500) imagePaths

benchmark : [Benchmark]
benchmark = [ imageDisplay
            , fittedImage500
            , fittedImage5
            , croppedImage20x500
            , tiledImage20
            , tiledImage500
            ]

main : Signal Element
main = run benchmark