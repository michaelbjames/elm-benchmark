module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)
import Dict as D


-- Convenience function for our set functions
setGenerator : ([number] -> [comparable]) -> number -> [() -> D.Dict comparable number]
setGenerator arrayModification multiplier =
    inputMap D.fromList <| map (\x -> zip (arrayModification [1..(multiplier * x)])
                          [1..(multiplier * x)]) [1..10]

{-
    CRUD Functions
-}

insertBench =
    let multiplier = 1000
        trialData = inputMap (\x -> [1..(multiplier * x)]) [1..10]
        insertWrap kvs =  foldr (\kv d -> D.insert kv kv d) D.empty kvs
    in  lazyLogic "insert" insertWrap trialData


-- Point of discussion: what percent of the dictionary should we update?
updateBench =
    let dictSize = 1000
        updates = 200
        trialData = inputMap D.fromList
                  <| map (\x -> zip [1..dictSize] [1..dictSize]) [1..10]
        updateFunction v = case v of
                            Just v -> Just (v + 1)
                            Nothing -> Nothing
        updateWrap dict = foldr (\x d -> D.update x updateFunction d) dict [1..updates]
    in  lazyLogic "update" updateWrap trialData


-- No variable changes between runs. However from initial data, the first couple
-- runs take about 3x-2x as long as the rest.
removeBench =
    let dictSize = 1000
        removes = 200
        trialData = inputMap D.fromList
                  <| map (\_ -> zip [1..dictSize] [1..dictSize]) [1..10]
        removeWrap dict = foldr (\x d-> D.remove x d) dict [1..removes]
    in  lazyLogic "remove" removeWrap trialData


isMemberBench =
    let multiplier = 1000
        trials = 50
        trialData = setGenerator id multiplier
        isMemberWrap d = map (\x -> D.member x d) [1..trials]
    in  lazyLogic "isMember" isMemberWrap trialData


isNotMemberBench =
    let multiplier = 1000
        trials = 200
        trialData = setGenerator id multiplier
        isNotMemberWrap d = map (\x -> D.member (x-trials) d) [1..trials]
    in  lazyLogic "isNotMember" isNotMemberWrap trialData


getBench =
    let multiplier = 1000
        gets = 500
        trialData = setGenerator id multiplier
        getWrap dict = map (\i -> D.get i dict) [1..gets]
    in  lazyLogic "get" getWrap trialData



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
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        unionWrap (l,r) = D.union l r
    in  lazyLogic "noCollisionUnion" unionWrap trialData


halfCollisionUnion =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        unionWrap (l,r) = D.union l r
    in  lazyLogic "halfCollisionUnion" unionWrap trialData


noCollisionIntersect =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        intersectWrap (l,r) = D.intersect l r
    in  lazyLogic "noCollisionIntersect" intersectWrap trialData


halfCollisionIntersect =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        intersectWrap (l,r) = D.intersect l r
    in  lazyLogic "halfCollisionIntersect" intersectWrap trialData


noCollisionDiff =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        diffWrap (l,r) = D.diff l r
    in  lazyLogic "noCollisionDiff" diffWrap trialData


halfCollisionDiff =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData = inputMap (\(l,r) -> (l(),r())) <| zip leftSets rightSets
        diffWrap (l,r) = D.diff l r
    in  lazyLogic "halfCollisionDiff" diffWrap trialData



{-
    List Functions
-}

keysBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        keysWrap d = D.keys d
    in  lazyLogic "keys" keysWrap trialData


valuesBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        valuesWrap d = D.values d
    in  lazyLogic "values" valuesWrap trialData


toListBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        toListWrap d = D.toList d
    in  lazyLogic "toList" toListWrap trialData


fromListBench =
    let multiplier = 1000
        trialData = inputMap (\x -> zip [1..(multiplier * x)] [1..(multiplier * x)]) [1..10]
        fromListWrap xs = D.fromList xs
    in  lazyLogic "fromList" fromListWrap trialData



{-
    Higher Order Functions
-}

mapBench =
    let multiplier = 1000
        trialData = setGenerator id multiplier
        mapWrap xs = D.map id xs
    in lazyLogic "map" mapWrap trialData




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