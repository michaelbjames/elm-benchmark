module Perf.LineGraph where

import Perf.Types (..)
import Debug (log)

type Coordinate = { x:Float, y:Float }

radius = 5
width  = 960
height = 500
margin = { top = 75, left = 0, right = 75, bottom = 0 }
dims   = { height = height - margin.top - margin.bottom
         , width  = width - margin.left - margin.right }

types = ["Avenir, Futura, Times"]

scaleResults : Float -> [Time] -> [Float]
scaleResults maxTime times =
    let factor = dims.height / maxTime
        adjust y = (y * factor) + margin.bottom
    in  map adjust times


spaceOut : Int -> [Float]
spaceOut n =
    let base = [1..n]
        adjust x = (toFloat x / toFloat n * dims.width) + margin.left
    in map adjust base

place : (Float,Float) -> Form -> Form
place (x,y) = move (x - (dims.width / 2), y - (dims.height / 2))

graphResult : Result -> Element
graphResult result =
    let maxTime = maximum result.times
        scaled = scaleResults maxTime result.times
        numResults = length result.times
        xcoordinates = log "xs" <| spaceOut numResults
        centers = zipWith (\x y -> {x = x, y = y}) xcoordinates scaled
        datapoint ({x,y}, time) = group
            [ circle radius |> filled red |> place (x,y)
            , show time |> toText |> typeface types
                        |> centered |> toForm |> place (x + 15, y + 15)
                        |> rotate (degrees 30)
            ]
        datapoints = map datapoint <| zip centers result.times
        axes = group
            [ segment (-dims.width / 2, -dims.height / 2)
                      ( dims.width / 2, -dims.height / 2)
                      |> traced (solid black)
            , segment (-dims.width / 2, -dims.height / 2)
                      (-dims.width / 2,  dims.height / 2)
                      |> traced (solid black)
            , show result.name |> toText |> typeface types
                      |> centered |> toForm |> move (0, -(dims.height / 2))
            ]
        forms = datapoints ++ [axes]
    in collage width height forms


showResults : [Result] -> Element
showResults results = map graphResult results
                    |> intersperse (spacer width 5 |> color blue)
                    |> flow down
