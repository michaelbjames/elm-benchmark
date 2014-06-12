module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)


imagePaths : [String]
imagePaths = map (\x -> "images/" ++ show x ++ ".jpg") [1..12]

directions : [Direction]
directions = [up, down, left, right, inward, outward]

intToCircle : Int -> Form
intToCircle n = filled red <| circle <| toFloat n

sampleContent : [Element]
sampleContent =  map (image 500 100) imagePaths
              ++ repeat 10 sampleMarkdown
              ++ map (\x -> collage 500 100 [x]) (map intToCircle [96..100])

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

--Adding & Removing
elemsPerSet : [Int] -> [[Element]]
elemsPerSet xs = map (\x -> take x sampleContent) xs

flowBenchmark: (String, [Int]) -> Direction -> Benchmark
flowBenchmark (name,num) d = render (name ++ show d) (flow d) (elemsPerSet num)

flowNames : [(String,[Int])]
flowNames = [("addToFlow",[1..25]), ("removeFromFlow", reverse [1..25])]

flowStep : (String,[Int]) -> [Benchmark] -> [Benchmark]
flowStep (name,num) xs = xs ++ (map (flowBenchmark (name,num)) directions)

flowLayers : (String,[Int]) -> Benchmark
flowLayers (name,num) = render (name ++ "-layer") layers (elemsPerSet num)

flows : [Benchmark]
flows = (foldr flowStep [] flowNames) ++ map flowLayers flowNames
--Swapping elements in a flow

--Nested Flows




main : Signal Element
main = run flows