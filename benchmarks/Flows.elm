module Main where

import Perf.Benchmark (..)


imagePaths : [String]
imagePaths = map (\x -> "images/" ++ show x ++ ".jpg") [1..12]

directions : [Direction]
directions = [up, left, down, right, inward, outward]

intToCircle : Int -> Form
intToCircle n = filled red <| circle <| toFloat n

sampleContent : [Element]
sampleContent = 
    let images = map (image 500 100) imagePaths
        markdowns = repeat 10 sampleMarkdown
        collages = map (\x -> collage 500 100 [x]) (map intToCircle [91..100])
        combine1 = zip markdowns collages
        combine2 = zip images combine1
        flatten (a,(b,c)) = [a,b,c]
    in foldr (++) [] <| map flatten combine2

sampleMarkdown : Element
sampleMarkdown = [markdown|
Notice again how text always lines up on 4-space indents (including
that last line which continues item 3 above). Here's a link to [a
website](http://foo.bar). Here's a link to a [local
doc](local-doc.html). Here's a footnote [^1].

[^1]: Footnote text goes here.

Tables can look like this:

size  material      color
----  ------------  ------------
9     leather       brown
10    hemp canvas   natural
11    glass         transparent

Table: Shoes, their sizes, and what they're made of

(The above is the caption for the table.) Here's a definition list:

apples
  : Good for making applesauce.
oranges
  : Citrus!
tomatoes
  : There's no "e" in tomatoe.
|]


sampleColorSpacers =
    let colors = [ darkRed, red, lightRed
                 , darkOrange, orange, lightOrange
                 , darkYellow, yellow, lightYellow
                 , darkGreen, green, lightGreen
                 , darkBlue, blue, lightBlue
                 , darkPurple, purple, lightPurple ]
    in  map (spacer 50 50 |> flip color) colors


{-
    Add & Remove from a flow
    We add and remove in every direction. This generates all those benchmarks
-}

elemsPerSet : [Int] -> [[Element]]
elemsPerSet xs = map (\x -> take x sampleContent) xs

flowBenchmark: (String, [Int]) -> Direction -> Benchmark
flowBenchmark (name,num) d = render (name ++ show d) (flow d) (elemsPerSet num)

flowNames : [(String,[Int])]
flowNames = [ ("addToFlow (start at 1 end at 25 elements) -",[1..25])
            , ("removeFromFlow (start at 25 end at 1 element) -", reverse [1..25])
            ]

flowStep : (String,[Int]) -> [Benchmark] -> [Benchmark]
flowStep (name,num) xs = xs ++ (map (flowBenchmark (name,num)) directions)

flowLayers : (String,[Int]) -> Benchmark
flowLayers (name,num) = render (name ++ "-layer") layers (elemsPerSet num)

flows : [Benchmark]
flows = (foldr flowStep [] flowNames) ++ map flowLayers flowNames


addingToFlow =
    let trialData = map (\n -> repeat n sampleMarkdown) [1..20]
    in  render "Start at 1 element, add 1 up to 20 total" (flow right) trialData


removingFromFlow =
    let trialData = map (\n -> map asText [1..n]) <| reverse [1..20]
    in  render "Start at 20 elements, remove 1 down to 1 total" (flow down) trialData


flowSpin =
    let trialData = foldr (\_ d -> d ++ directions) [] [1..5]
    in  render "Spin 5 times" (\d -> flow d sampleContent) trialData


{-
    Swapping elements in a flow
-}

increasingSwapsBench =
    let baseState = sampleContent
        newContent = empty
        diffs = map (\x -> (repeat x newContent) ++ (drop x baseState)) [1..10]
        trials = intersperse baseState diffs
    in  render "increasingSwapsBench" (flow down) trials


swapNElements =
    let baseState = sampleColorSpacers
        swap n = (reverse (take n baseState)) ++ (drop n baseState)
        swaps = map swap [1..10]
        trials = intersperse baseState swaps
    in  render "swapNElements" (flow right) trials

{-
    Nested flows
-}

nestedFlowBench =
    let clear = [empty]
        diffs = map (\x -> take x sampleContent) [1..10]
        trials = intersperse clear diffs
        repeatedDirectsion = foldr (\_ d -> d ++ directions) directions [1..5]
        step (element,direction) state = flow direction [element, state]
        sprialNest elems = zip elems repeatedDirectsion |> foldr step empty 
    in  render "sprialNestBench" sprialNest trials


relativePositionReflow =
    let index = 16
        baseStateL = take index sampleContent
        baseStateR = drop (index + 1) sampleContent
        middleElement = head <| drop index sampleContent
        otherType = collage 50 100 [circle 25 |> filled red |> move (0,0)]
        middles = (intersperse otherType <| repeat 5 middleElement)
        trialData = map (\x -> baseStateL ++ [x] ++ baseStateR) middles
    in  render "Swapping element of the same dimesions for a different type"
            (flow down) trialData




benchmarks : [Benchmark]
benchmarks = flows ++
             [ addingToFlow
             , removingFromFlow
             , flowSpin 
             , increasingSwapsBench
             , nestedFlowBench
             , swapNElements
             , relativePositionReflow
             ]

main : Signal Element
main = run benchmarks
