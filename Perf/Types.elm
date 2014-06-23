module Perf.Types where

type Result = { name:String, times:[Time] }

data Benchmark = Logic String [() -> () -> ()]
               | Render String [() -> () -> Element]