module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)
import Dict as D


-- Convenience function for our set functions
--setGenerator : (number -> comparable) -> number -> [D.Dict comparable number]
setGenerator arrayModification multiplier =
    map D.fromList <| map (\x -> zip (arrayModification [1..(multiplier * x)])
                          [1..(multiplier * x)]) [1..10]

{-
    CRUD Functions
-}

insertBench =
    let multiplier = 1000
        trialData = map (\x -> [1..(multiplier * x)]) [1..10]
        insertWrap kvs = logicFunction  <| foldr (\kv d -> D.insert kv kv d) D.empty kvs
    in  logic "insert" insertWrap trialData


-- Point of discussion: what percent of the dictionary should we update?
updateBench =
    let dictSize = 1000
        updates = 200
        trialData = map D.fromList
                  <| map (\x -> zip [1..dictSize] [1..dictSize]) [1..10]
        updateFunction v = case v of
                            Just v -> Just (v + 1)
                            Nothing -> Nothing
        updateWrap dict = logicFunction <| foldr (\x d -> D.update x updateFunction d) dict [1..updates]
    in  logic "update" updateWrap trialData


-- No variable changes between runs. However from initial data, the first couple
-- runs take about 3x-2x as long as the rest.
removeBench =
    let dictSize = 1000
        removes = 200
        trialData = map D.fromList
                  <| map (\_ -> zip [1..dictSize] [1..dictSize]) [1..10]
        removeWrap dict = logicFunction <| foldr (\x d-> D.remove x d) dict [1..removes]
    in  logic "remove" removeWrap trialData


isMemberBench =
    let multiplier = 1000
        trials = 50
        trialData = setGenerator id multiplier
        isMemberWrap d = logicFunction <| map (\x -> D.member x d) [1..trials]
    in  logic "isMember" isMemberWrap trialData


isNotMemberBench =
    let multiplier = 1000
        trials = 200
        trialData = setGenerator id multiplier
        isNotMemberWrap d = logicFunction <| map (\x -> D.member (x-trials) d) [1..trials]
    in  logic "isNotMember" isNotMemberWrap trialData


getBench =
    let multiplier = 1000
        gets = 500
        trialData = setGenerator id multiplier
        getWrap dict = logicFunction <| map (\i -> D.get i dict) [1..gets]
    in  logic "get" getWrap trialData



{-
    Combine Functions
    We test the performance characteristics as the size of the sets increase.
-}

noCollisionUnion =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData = zip leftSets rightSets
        unionWrap (l,r) = logicFunction <| D.union l r
    in  logic "noCollisionUnion" unionWrap trialData


halfCollisionUnion =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = zip leftSets rightSets
        unionWrap (l,r) = logicFunction <| D.union l r
    in  logic "halfCollisionUnion" unionWrap trialData


noCollisionIntersect =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData = zip leftSets rightSets
        intersectWrap (l,r) = logicFunction <| D.intersect l r
    in  logic "noCollisionIntersect" intersectWrap trialData


halfCollisionIntersect =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = zip leftSets rightSets
        intersectWrap (l,r) = logicFunction <| D.intersect l r
    in  logic "halfCollisionIntersect" intersectWrap trialData


noCollisionDiff =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData = zip leftSets rightSets
        diffWrap (l,r) = logicFunction <| D.diff l r
    in  logic "noCollisionDiff" diffWrap trialData


halfCollisionDiff =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = zip leftSets rightSets
        diffWrap (l,r) = logicFunction <| D.diff l r
    in  logic "halfCollisionDiff" diffWrap trialData



{-
    List Functions
-}

keysBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        keysWrap d = logicFunction <| D.keys d
    in  logic "keys" keysWrap trialData


valuesBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        valuesWrap d = logicFunction <| D.values d
    in  logic "values" valuesWrap trialData


toListBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        toListWrap d = logicFunction <| D.toList d
    in  logic "toList" toListWrap trialData


fromListBench =
    let multiplier = 1000
        trialData = map (\x -> zip [1..(multiplier * x)] [1..(multiplier * x)]) [1..10]
        fromListWrap xs = logicFunction <| D.fromList xs
    in  logic "fromList" fromListWrap trialData



{-
    Higher Order Functions
-}

mapBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        mapWrap xs = logicFunction <| D.map id xs
    in logic "map" mapWrap trialData




benchmarks : [Benchmark]
benchmarks = [ insertBench
             , updateBench
             , removeBench
             , isMemberBench
             , isNotMemberBench
             , getBench
             , noCollisionUnion
             , halfCollisionUnion
             , noCollisionIntersect
             , halfCollisionIntersect
             , noCollisionDiff
             , halfCollisionDiff
             , keysBench
             , valuesBench
             , toListBench
             , fromListBench
             , mapBench
             ]

main : Signal Element
main = run benchmarks