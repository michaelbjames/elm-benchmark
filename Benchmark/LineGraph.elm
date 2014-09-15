module Benchmark.LineGraph (showResults) where

import Benchmark.Types (..)

type Coordinate = { x:Float, y:Float }

radius = 5
h = 500
height = toFloat h
margin = { top = 75.0, left = 50.0, right = 75.0, bottom = 75.0 }


types = ["Avenir, Futura, Times"]

graphResult : Int -> Result -> Element
graphResult w result =
    let width  = toFloat w
        dims   = { height = height - margin.top - margin.bottom
                 , width  = width - margin.left - margin.right }

         {-| Scale the Y values to all fit within the graph area -}
        scaleResults : [Time] -> [Float]
        scaleResults times =
            let maxTime = maximum times
                factor = if maxTime == 0 then 0 else dims.height / maxTime
                adjust y = (y * factor) + margin.bottom
            in  map adjust times

        {-| Equally space N points along the X axis line -}
        spaceOut : Int -> [Float]
        spaceOut n =
            let base = [1..n]
                adjust x = (toFloat x / toFloat n * dims.width) + margin.left
            in map adjust base

        {-| Reorient our points to use the Elm coordinate system 
            e.g., (0,0) -> (-width/2, -height/2)
        -}
        fitPoints : [(Float, Float)] -> [(Float, Float)]
        fitPoints points =
            let fit (x,y) = (x - (width / 2), y - (height / 2))
            in  map fit points

        scaled = scaleResults result.times
        numPoints = length result.times
        xcoordinates = spaceOut numPoints
        centers = zip xcoordinates scaled
        {-| Recenter our points from the origin being in the bottom left
            to elm's origin in the center of the collage
        -}
        centerOriginPoints = fitPoints centers
        datapoint ((x,y), time) = circle radius |> filled red |> move (x,y)
        datatime  ((x,y), time) =
            show time |> toText |> typeface types
                      |> centered |> toForm |> move (x + 15, y + 15)
                      |> rotate (degrees 30)
        -- Circles
        datapoints = group <| map datapoint <| zip centerOriginPoints result.times
        -- Times
        datatimes  = group <| map datatime  <| zip centerOriginPoints result.times
        axes = group
            [ segment (-width / 2 + margin.left,  -height / 2 + margin.bottom) -- X axis
                      ( width / 2 - margin.right, -height / 2 + margin.bottom)
                      |> traced (solid black)
            , segment (-width / 2 + margin.left, -height / 2 + margin.bottom) -- Y axis
                      (-width / 2 + margin.left,  height / 2 - margin.top)
                      |> traced (solid black)
            , show result.name |> toText |> typeface types -- Test name
                      |> centered |> toForm |> move (0, -(dims.height / 2) - 20)
            , "milliseconds" |> toText |> typeface types |> centered |> toForm
                      |> move (-width /2 + margin.left - 15 , 0) |> rotate (degrees 90)
            ]
        lines = path centerOriginPoints
              |> traced {defaultLine | color <- lightRed, join <- Smooth }
        forms = [ axes
                , lines
                , datapoints
                , datatimes  -- Order matter, this sits on top
                ]
    in collage w h forms


showResults : Int -> [Result] -> Element
showResults width results = map (graphResult width) results
                    |> intersperse (spacer width 10 |> color darkGrey)
                    |> flow down
