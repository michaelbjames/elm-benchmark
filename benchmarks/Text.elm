module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)

{-| Setup. These are some helpful functions
-}

copy : Text
copy = toText "8-bit art party slow-carb authentic VHS next level, fixie Tumblr High Life put a bird on it ethical 90's swag scenester Kickstarter. Truffaut gastropub swag, drinking vinegar bitters Carles hashtag. Cray locavore jean shorts Tumblr drinking vinegar, trust fund Odd Future Helvetica PBR fingerstache iPhone food truck swag brunch tote bag. Food truck farm-to-table 90's fashion axe. Salvia synth bespoke, Shoreditch hoodie pour-over fixie typewriter leggings McSweeney's small batch. Forage DIY mustache, viral irony leggings salvia blog slow-carb. Pug fixie gentrify banh mi, Blue Bottle aesthetic direct trade food truck art party Tonx pour-over chillwave.

Pickled pour-over paleo Brooklyn fap seitan. Actually wolf seitan mixtape artisan. Bicycle rights Banksy wayfarers messenger bag roof party. Slow-carb letterpress pour-over Vice post-ironic, readymade chambray YOLO. Scenester try-hard whatever pickled, messenger bag before they sold out tofu meggings wolf biodiesel mumblecore. Swag Etsy tofu Blue Bottle, hella disrupt tattooed freegan kale chips cray pickled Neutra flannel. Cornhole butcher keytar disrupt gastropub Truffaut gentrify, asymmetrical roof party kitsch 3 wolf moon Neutra fashion axe.

Shoreditch wayfarers photo booth, bicycle rights farm-to-table asymmetrical paleo chia cliche Helvetica fanny pack hella mustache semiotics. Jean shorts biodiesel church-key Intelligentsia. Forage messenger bag deep v PBR 90's. Trust fund butcher twee, 90's asymmetrical post-ironic shabby chic YOLO letterpress ugh freegan Brooklyn disrupt four loko Austin. Distillery craft beer flexitarian beard gluten-free. Odd Future scenester +1, narwhal freegan Neutra before they sold out food truck. Irony gluten-free Cosby sweater, Pitchfork craft beer swag forage bicycle rights jean shorts pug selfies Wes Anderson Tonx.

Keffiyeh raw denim Williamsburg, iPhone flexitarian swag shabby chic semiotics banjo mumblecore sriracha pork belly. Meggings street art distillery banh mi mumblecore, selvage art party asymmetrical synth. Vice street art salvia mixtape Banksy tote bag, meh cray. Put a bird on it plaid Helvetica viral, mlkshk biodiesel banh mi artisan pour-over Austin Intelligentsia authentic chia aesthetic sartorial. Ennui twee bespoke Blue Bottle Godard. Irony gentrify actually, quinoa Tumblr locavore small batch four loko PBR&B cray raw denim Vice. Fingerstache cornhole meh keffiyeh, Kickstarter synth squid bespoke lo-fi viral ethnic McSweeney's."

md : Element
md = [markdown|

An h1 header
============

Paragraphs are separated by a blank line.

2nd paragraph. *Italic*, **bold**, `monospace`. Itemized lists
look like:

  * this one
  * that one
  * the other one

Note that --- not considering the asterisk --- the actual text
content starts at 4-columns in.

> Block quotes are
> written like so.
>
> They can span multiple paragraphs,
> if you like.

Use 3 dashes for an em-dash. Use 2 dashes for ranges (ex. "it's all in
chapters 12--14"). Three dots ... will be converted to an ellipsis.



An h2 header
------------

Here's a numbered list:

 1. first item
 2. second item
 3. third item

Note again how the actual text starts at 4 columns in (4 characters
from the left side). Here's a code sample:

    # Let me re-iterate ...
    for i in 1 .. 10 { do-something(i) }

As you probably guessed, indented 4 spaces. By the way, instead of
indenting the block, you can use delimited blocks, if you like:

~~~
define foobar() {
    print "Welcome to flavor country!";
}
~~~

(which makes copying & pasting easier). You can optionally mark the
delimited block for Pandoc to syntax highlight it:

~~~python
import time
# Quick, count to ten!
for i in range(10):
    # (but not *too* quick)
    time.sleep(0.5)
    print i
~~~



### An h3 header ###

Now a nested list:

 1. First, get these ingredients:

      * carrots
      * celery
      * lentils

 2. Boil some water.

 3. Dump everything in the pot and follow
    this algorithm:

        find wooden spoon
        uncover pot
        stir
        cover pot
        balance wooden spoon precariously on pot handle
        wait 10 minutes
        goto first step (or shut off burner when done)

    Do not bump wooden spoon or it will fall.

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

Again, text is indented 4 spaces. (Alternately, put blank lines in
between each of the above definition list lines to spread things
out more.)

Inline math equations go in like so: $\omega = d\phi / dt$. Display
math should get its own line and be put in in double-dollarsigns:

$$I = \int \rho R^{2} dV$$

Done.

From [here](http://www.unexpected-vortices.com/sw/gouda/quick-markdown-example.html)

|]




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
showmd = staticRender "Markdown" md

downsizing : Benchmark
downsizing = render "Text.Height" (\x -> justified <| Text.height x copy)
                <| reverse [1..100]

resizing : Benchmark
resizing = render "Resizing Markdown" (\x -> width x md)
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
            in  render "Style Spin" spinner (map (\x -> x*100) [1..100])


longStrings : Benchmark
longStrings = let lengths = (map (\x -> x*100)[1..100])
                  string n = foldr (\_ a -> "a" ++ a) "a" [1..n]
                  --string n = show <| repeat n 'a'
                  fit n string = width n <| plainText string
              in  render "Long Strings" (fit 800) (map string lengths)

benchmarks : [Benchmark]
benchmarks = [ showmd
             , downsizing
             , resizing
             , stylespin
             , longStrings
             ]

main : Signal Element
main = run benchmarks
