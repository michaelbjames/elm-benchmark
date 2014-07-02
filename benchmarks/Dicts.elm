module Main where

import Perf.Benchmark (..)
import Perf.AdvancedBenchmarks (logicDeferedInput)
import Dict as D


-- Convenience function for our set functions
--setGenerator : ([number] -> [comparable]) -> number -> [() -> D.Dict comparable number]
setGenerator arrayModification multiplier =
    map (\x -> zip (arrayModification [1..(multiplier * x)])
        [1..(multiplier * x)]) [1..10]

dictList multiplier = map (\x -> zip ([1..(multiplier * x)])
                          [1..(multiplier * x)]) [1..10]

{-
    CRUD Functions
-}

insertBench =
    let multiplier = 1000
        trialData x = [1..(multiplier * x)]
        insertWrap kvs =  foldr (\kv d -> D.insert kv kv d) D.empty kvs
    in  logicDeferedInput "insert" insertWrap trialData [1..10]


-- Point of discussion: what percent of the dictionary should we update?
updateBench =
    let dictSize = 1000
        updates = 200
        listDictionary = map (\x -> zip [1..dictSize] [1..dictSize]) [1..10]
        updateFunction v = case v of
                            Just v -> Just (v + 1)
                            Nothing -> Nothing
        updateWrap dict = foldr (\x d -> D.update x updateFunction d) dict [1..updates]
    in  logicDeferedInput "update" updateWrap D.fromList listDictionary


-- No variable changes between runs. However from initial data, the first couple
-- runs take about 3x-2x as long as the rest.
removeBench =
    let dictSize = 1000
        removes = 200
        listDictionary = map (\_ -> zip [1..dictSize] [1..dictSize]) [1..10]
        removeWrap dict = foldr (\x d-> D.remove x d) dict [1..removes]
    in  logicDeferedInput "remove" removeWrap D.fromList listDictionary


isMemberBench =
    let multiplier = 1000
        trials = 50
        listDictionary = dictList multiplier
        isMemberWrap d = map (\x -> D.member x d) [1..trials]
    in  logicDeferedInput "isMember" isMemberWrap D.fromList listDictionary


isNotMemberBench =
    let multiplier = 1000
        trials = 200
        listDictionary = dictList multiplier
        isNotMemberWrap d = map (\x -> D.member (x-trials) d) [1..trials]
    in  logicDeferedInput "isNotMember" isNotMemberWrap D.fromList listDictionary


getBench =
    let multiplier = 1000
        gets = 500
        listDictionary = dictList multiplier
        getWrap dict = map (\i -> D.get i dict) [1..gets]
    in  logicDeferedInput "get" getWrap D.fromList listDictionary



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
        trialData (l,r) = (D.fromList l , D.fromList r)
        unionWrap (l,r) = D.union l r
    in  logicDeferedInput "noCollisionUnion" unionWrap trialData (zip leftSets rightSets)


halfCollisionUnion =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData (l,r) = (D.fromList l , D.fromList r)
        unionWrap (l,r) = D.union l r
    in  logicDeferedInput "halfCollisionUnion" unionWrap trialData (zip leftSets rightSets)


noCollisionIntersect =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData (l,r) = (D.fromList l , D.fromList r)
        intersectWrap (l,r) = D.intersect l r
    in  logicDeferedInput "noCollisionIntersect" intersectWrap trialData (zip leftSets rightSets)


halfCollisionIntersect =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData (l,r) = (D.fromList l , D.fromList r)
        intersectWrap (l,r) = D.intersect l r
    in  logicDeferedInput "halfCollisionIntersect" intersectWrap trialData (zip leftSets rightSets)


noCollisionDiff =
    let multiplier = 100
        evenArray xs = map (\x -> x * 2) xs
        oddArray xs = map (\x -> x + 1) <| evenArray xs
        leftSets = setGenerator evenArray multiplier
        rightSets = setGenerator oddArray multiplier
        trialData (l,r) = (D.fromList l , D.fromList r)
        diffWrap (l,r) = D.diff l r
    in  logicDeferedInput "noCollisionDiff" diffWrap trialData (zip leftSets rightSets)


halfCollisionDiff =
    let multiplier = 100
        times2 xs = map (\x -> x * 2) xs
        times4 xs = map (\x -> x * 4) xs
        leftSets = setGenerator times2 multiplier
        rightSets = setGenerator times4 multiplier
        trialData (l,r) = (D.fromList l , D.fromList r)
        diffWrap (l,r) = D.diff l r
    in  logicDeferedInput "halfCollisionDiff" diffWrap trialData (zip leftSets rightSets)



{-
    List Functions
-}

keysBench =
    let multiplier = 1000
        listDictionary = dictList multiplier
        keysWrap d = D.keys d
    in  logicDeferedInput "keys" keysWrap D.fromList listDictionary


valuesBench =
    let multiplier = 1000
        listDictionary = dictList multiplier
        valuesWrap d = D.values d
    in  logicDeferedInput "values" valuesWrap D.fromList listDictionary


toListBench =
    let multiplier = 1000
        listDictionary = dictList multiplier
        toListWrap d = D.toList d
    in  logicDeferedInput "toList" toListWrap D.fromList listDictionary


fromListBench =
    let multiplier = 1000
        trialData x = zip [1..(multiplier * x)] [1..(multiplier * x)]
        fromListWrap xs = D.fromList xs
    in  logicDeferedInput "fromList" fromListWrap trialData [1..10]



{-
    Higher Order Functions
-}

mapBench =
    let multiplier = 1000
        listDictionary = dictList multiplier
        mapWrap xs = D.map id xs
    in logicDeferedInput "map" mapWrap D.fromList listDictionary




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