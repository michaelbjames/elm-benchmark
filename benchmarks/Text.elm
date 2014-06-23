module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)


staticBenchs = [ staticRender "Left" <| leftAligned copy
               , staticRender "Right" <| rightAligned copy
               , staticRender "Centered" <| centered copy
               , staticRender "Justified" <| justified copy
               ]

spinningBenchs = [ render "alignment" (\f -> f copy) [ leftAligned
                                                     , rightAligned
                                                     , centered
                                                     , justified]
                 ]


showmd : Benchmark
showmd = staticRender "Markdown" md1

downsizing : Benchmark
downsizing = render "Text.Height getting smaller" (\x -> justified <| Text.height x copy)
                <| reverse [1..100]

resizing : Benchmark
resizing = render "Markdown fitting into a smaller width" (\x -> width x md1)
                <| reverse (map (\x -> x*5) [1..100])


{-
    This benchmark shows what time is taken changing between two different styles
    There should be an optimization to resolve only the last style
-}
stylespin : Benchmark
stylespin = let flipflopper i text = case i `mod` 2 of 
                                     0 -> monospace text
                                     1 -> typeface ["sans-serif"] text
                spinner times = leftAligned <| foldr flipflopper copy [1..times]
            in  render "More and more style spins" spinner (map (\x -> x*100) [1..100])


longStrings : Benchmark
longStrings = let lengths = (map (\x -> x*100)[1..100])
                  string n = foldr (\_ a -> "a" ++ a) "a" [1..n]
                  --string n = show <| repeat n 'a'
                  fit n string = width n <| plainText string
              in  render "Longer and longer strings" (fit 800) (map string lengths)


textBetweenMarkdown =
    let display n = flow down [md1, n, md2]
        trialData = map asText [1..20]
    in  render "Changing text between static markdown" display trialData

changingTypesBetweenMarkdown =
    let display n = flow down [md1, n, md2]
        differentElems = [ asText "Text"
                         , collage 200 200 [circle 5 |> filled red]
                         , spacer 500 50 |> color blue
                         ]
        trialData = foldr (\_ d -> differentElems ++ d) [] [1..5]
    in  [ render "Changing types of elements betweens static markdown" display trialData
        , render "Changing types of elements no markdown" id trialData ]

duplicateMd =
    let flipFlop n = case n `mod` 2 of
        0 -> md1
        1 -> md3
    in render "Switching between logically identical md blocks" flipFlop [1..20]

changingMd =
    let trialData = foldr (\_ md -> md ++ [md1,md2,md4] ) [] [1..5]
    in  render "Changing markdown blocks" id trialData

benchmarks : [Benchmark]
benchmarks = [ showmd
             , downsizing
             , resizing
             , stylespin
             , longStrings
             , textBetweenMarkdown
             , duplicateMd
             , changingMd
             ]
             ++ changingTypesBetweenMarkdown

main : Signal Element
main = run benchmarks






{-| Setup. These are some helpful functions
-}

copy : Text
copy = toText "8-bit art party slow-carb authentic VHS next level, fixie Tumblr High Life put a bird on it ethical 90's swag scenester Kickstarter. Truffaut gastropub swag, drinking vinegar bitters Carles hashtag. Cray locavore jean shorts Tumblr drinking vinegar, trust fund Odd Future Helvetica PBR fingerstache iPhone food truck swag brunch tote bag. Food truck farm-to-table 90's fashion axe. Salvia synth bespoke, Shoreditch hoodie pour-over fixie typewriter leggings McSweeney's small batch. Forage DIY mustache, viral irony leggings salvia blog slow-carb. Pug fixie gentrify banh mi, Blue Bottle aesthetic direct trade food truck art party Tonx pour-over chillwave.

Pickled pour-over paleo Brooklyn fap seitan. Actually wolf seitan mixtape artisan. Bicycle rights Banksy wayfarers messenger bag roof party. Slow-carb letterpress pour-over Vice post-ironic, readymade chambray YOLO. Scenester try-hard whatever pickled, messenger bag before they sold out tofu meggings wolf biodiesel mumblecore. Swag Etsy tofu Blue Bottle, hella disrupt tattooed freegan kale chips cray pickled Neutra flannel. Cornhole butcher keytar disrupt gastropub Truffaut gentrify, asymmetrical roof party kitsch 3 wolf moon Neutra fashion axe.

Shoreditch wayfarers photo booth, bicycle rights farm-to-table asymmetrical paleo chia cliche Helvetica fanny pack hella mustache semiotics. Jean shorts biodiesel church-key Intelligentsia. Forage messenger bag deep v PBR 90's. Trust fund butcher twee, 90's asymmetrical post-ironic shabby chic YOLO letterpress ugh freegan Brooklyn disrupt four loko Austin. Distillery craft beer flexitarian beard gluten-free. Odd Future scenester +1, narwhal freegan Neutra before they sold out food truck. Irony gluten-free Cosby sweater, Pitchfork craft beer swag forage bicycle rights jean shorts pug selfies Wes Anderson Tonx.

Keffiyeh raw denim Williamsburg, iPhone flexitarian swag shabby chic semiotics banjo mumblecore sriracha pork belly. Meggings street art distillery banh mi mumblecore, selvage art party asymmetrical synth. Vice street art salvia mixtape Banksy tote bag, meh cray. Put a bird on it plaid Helvetica viral, mlkshk biodiesel banh mi artisan pour-over Austin Intelligentsia authentic chia aesthetic sartorial. Ennui twee bespoke Blue Bottle Godard. Irony gentrify actually, quinoa Tumblr locavore small batch four loko PBR&B cray raw denim Vice. Fingerstache cornhole meh keffiyeh, Kickstarter synth squid bespoke lo-fi viral ethnic McSweeney's."

md1 : Element
md1 = [markdown|

# Markdown Support

Elm has native markdown support, making it easy to create complex
text elements. You can easily make:

  - Headers
  - [Links](/)
  - Images
  - **Bold**, *italic*, and `monospaced` text
  - Lists (numbered, nested, multi-paragraph bullets)

It all feels quite natural to type. For more information on Markdown,
see [this site](http://daringfireball.net/projects/markdown/).

|]

md2 = [markdown|

# Anienis terebrata quoque Hector undae subit illo

## Adiecerit lentaque mandata vaga

Lorem markdownum quanto dilataque milibus alvo, esse dabant nostrae in cupiens.
Atque flavum inrita, fecit ille pacis inmiscuit pependit ait. Et vivum renasci,
suasque, sepulta ambo vagantem vecordia.

Ab ista muneris coniunx manebant. Bis quam incomitata sine celebrabere in tantum
et Stygius tibia laevaque tempora coniunx nequiquam cur animos velle in.

## Cum freta cruorem

Laedor **caelo annos sunt** timemus; mea non Cyllaron, videres! Pictis si tamen
motaeque amantem **tuas haec compescuit**, mihi candida? Pallada hasta Themis
pictis memor non homines potest, male nuribusque area tendentemque illo, quid?

|]

md3 : Element
md3 = [markdown|

# Markdown Support

Elm has native markdown support, making it easy to create complex
text elements. You can easily make:

  - Headers
  - [Links](/)
  - Images
  - **Bold**, *italic*, and `monospaced` text
  - Lists (numbered, nested, multi-paragraph bullets)

It all feels quite natural to type. For more information on Markdown,
see [this site](http://daringfireball.net/projects/markdown/).

|]

md4 : Element
md4 = [markdown|

# Markdown Support

Elm has nwn support, making it easy to create complex
text elements. You can easily make:

  - Headers
  - [Liks](/)
  - Imag
  - *Bolditc*, and `monospaced` text
  - Lists (numbered, nested, multi-paragraph bullets)

It all feels quite natural to type. For more information on Markdown,
see [this site](http://daringfireball.net/projects/markdown/).

# Markdown Support

Elm has nwn support, making it easy to create complex
text elements. You can easily make:

  - Headers
  - [Liks](/)
  - Imag
  - *Bolditc*, and `monospaced` text
  - Lists (numbered, nested, multi-paragraph bullets)

It all feels quite natural to type. For more information on Markdown,
see [this site](http://daringfireball.net/projects/markdown/).

|]



