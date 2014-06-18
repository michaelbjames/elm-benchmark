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

fitPoints : [(Float, Float)] -> [(Float, Float)]
fitPoints points =
    let fit (x,y) = (x - (dims.width / 2), y - (dims.height / 2))
    in  map fit points

graphResult : Result -> Element
graphResult result =
    let maxTime = maximum result.times
        scaled = scaleResults maxTime result.times
        numResults = length result.times
        xcoordinates = spaceOut numResults
        centers = zip xcoordinates scaled
        centerOriginPoints = fitPoints centers
        datapoint ((x,y), time) = group
            [ show time |> toText |> typeface types
                        |> centered |> toForm |> move (x + 15, y + 15)
                        |> rotate (degrees 30)
            , circle radius |> filled red |> move (x,y)
            ]
        datapoints = map datapoint <| zip centerOriginPoints result.times
        axes = group
            [ segment (-dims.width / 2, -dims.height / 2) -- X axis
                      ( dims.width / 2, -dims.height / 2)
                      |> traced (solid black)
            , segment (-dims.width / 2, -dims.height / 2) -- Y axis
                      (-dims.width / 2,  dims.height / 2)
                      |> traced (solid black)
            , show result.name |> toText |> typeface types -- Test name
                      |> centered |> toForm |> move (0, -(dims.height / 2) - 20)
            ]
        lines = path centerOriginPoints
              |> traced {defaultLine | color <- lightRed, join <- Smooth}
        forms = [axes, lines] ++ datapoints
    in collage width height forms


showResults : [Result] -> Element
showResults results = map graphResult results
                    |> intersperse (spacer width 5 |> color blue)
                    |> flow down
