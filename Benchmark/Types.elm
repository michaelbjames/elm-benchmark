module Benchmark.Types where

type Result = { name:String, times:[Time] }

data Group a = Single a
             | Set String [Group a]

data Benchmark = Logic String [() -> () -> ()]
               | Render String [() -> () -> Element]
               | Suite String [Benchmark]
