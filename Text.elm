module Main where

import Perf.Runner (..)
import Perf.Benchmark (..)

{-| Setup. These are some helpful functions
-}

copy : Text
copy = toText "8-bit art party slow-carb authentic VHS next level, fixie Tumblr High Life put a bird on it ethical 90's swag scenester Kickstarter. Truffaut gastropub swag, drinking vinegar bitters Carles hashtag. Cray locavore jean shorts Tumblr drinking vinegar, trust fund Odd Future Helvetica PBR fingerstache iPhone food truck swag brunch tote bag. Food truck farm-to-table 90's fashion axe. Salvia synth bespoke, Shoreditch hoodie pour-over fixie typewriter leggings McSweeney's small batch. Forage DIY mustache, viral irony leggings salvia blog slow-carb. Pug fixie gentrify banh mi, Blue Bottle aesthetic direct trade food truck art party Tonx pour-over chillwave.

Pickled pour-over paleo Brooklyn fap seitan. Actually wolf seitan mixtape artisan. Bicycle rights Banksy wayfarers messenger bag roof party. Slow-carb letterpress pour-over Vice post-ironic, readymade chambray YOLO. Scenester try-hard whatever pickled, messenger bag before they sold out tofu meggings wolf biodiesel mumblecore. Swag Etsy tofu Blue Bottle, hella disrupt tattooed freegan kale chips cray pickled Neutra flannel. Cornhole butcher keytar disrupt gastropub Truffaut gentrify, asymmetrical roof party kitsch 3 wolf moon Neutra fashion axe.

Shoreditch wayfarers photo booth, bicycle rights farm-to-table asymmetrical paleo chia cliche Helvetica fanny pack hella mustache semiotics. Jean shorts biodiesel church-key Intelligentsia. Forage messenger bag deep v PBR 90's. Trust fund butcher twee, 90's asymmetrical post-ironic shabby chic YOLO letterpress ugh freegan Brooklyn disrupt four loko Austin. Distillery craft beer flexitarian beard gluten-free. Odd Future scenester +1, narwhal freegan Neutra before they sold out food truck. Irony gluten-free Cosby sweater, Pitchfork craft beer swag forage bicycle rights jean shorts pug selfies Wes Anderson Tonx.

Keffiyeh raw denim Williamsburg, iPhone flexitarian swag shabby chic semiotics banjo mumblecore sriracha pork belly. Meggings street art distillery banh mi mumblecore, selvage art party asymmetrical synth. Vice street art salvia mixtape Banksy tote bag, meh cray. Put a bird on it plaid Helvetica viral, mlkshk biodiesel banh mi artisan pour-over Austin Intelligentsia authentic chia aesthetic sartorial. Ennui twee bespoke Blue Bottle Godard. Irony gentrify actually, quinoa Tumblr locavore small batch four loko PBR&B cray raw denim Vice. Fingerstache cornhole meh keffiyeh, Kickstarter synth squid bespoke lo-fi viral ethnic McSweeney's."




benchmarks : [Benchmark]
benchmarks = [ staticRender "Left" <| leftAligned copy
             , staticRender "Right" <| rightAligned copy
             , staticRender "Centered" <| centered copy
             , staticRender "Justified" <| justified copy
             ]
             --[ render "alignment" (\f -> f copy) [ leftAligned
             --                                    , rightAligned
             --                                    , centered
             --                                    , justified]
             --]

extraBenchmarks : [Benchmark]
extraBenchmarks = foldr (\a b -> b ++ repeat 3 a) [] benchmarks


main : Signal Element
main = run extraBenchmarks
