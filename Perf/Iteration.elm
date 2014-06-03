module Perf.Iteration where

{-
  The simple timer that runs a function
-}

data Iteration = Function (() -> ())
               | Rendering (() -> Element)


rendering0 : Element -> Iteration
rendering0 f = Rendering (\_ -> f)

rendering1 : (a -> Element) -> [a] -> [Iteration]
rendering1 f xs = map (\x -> Rendering (\_ -> f x)) xs

rendering2 : (a -> b -> Element) -> [a] -> [b] -> [Iteration]
rendering2 f xs ys = zipWith (\x y -> Rendering (\_ -> f x y)) xs ys