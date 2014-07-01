module Perf.BarGraph (showResults) where

import Perf.Types (..)
import D3(..)

type Result = { name:String, times:[Time] }

size   = 600
margin = { top = 10, left = 10, right = 10, bottom = 10 }
dims   = { height = size - margin.top - margin.bottom
         , width  = size - margin.left - margin.right }

type Dimensions = { height : Float, width : Float }
type Margins = { top : Float, left : Float, right : Float, bottom : Float }

barHeight = 20
dataLength = 15
barWidth = round (dims.width / dataLength)

svg : Dimensions -> Margins -> Selection a
svg ds ms =
  static "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. static "g"
     |. str attr "transform" (translate margin.left margin.top)

bar : Widget [(Float,Time)] (Float, Float)
bar =
  selectAll "g"
  |= id
     |- enter <.>
        (append "g"
           |. fun attr "transform" (\(x,y) i -> translate (i * barWidth) 0)
        |^ append "rect"
           |. fun attr "width" (\(x,y) i -> show (barWidth - 1) ++ "px")
           |. fun attr "height" (\(x,y) i -> (show 0) ++ "px")
           |. fun attr "y" (\(x,y) i -> (show (dims.height))++"px")
           |. str attr "fill" "steelblue"
           |. transition
              |. fun attr "y" (\(x,y) i -> (show (dims.height - (yScale y)))++"px")
              |. fun attr "height" (\(x,y) i -> (show (yScale y)) ++ "px")
              |. delay (\(x,y) i -> round <| (sqrt (toFloat i)) * 60)
        |^ append "text"
           |. fun attr "x" (\(x,y) i -> show (toFloat barWidth / 2) ++ "px")
           |. str attr "y" "0px"
           |. str attr "font-family" "Gotham"
           |. str attr "font-size" "8pt"
           |. str attr "fill" "white"
           |. str attr "text-anchor" "end"
           |. str attr "dy" ".75em"
           |. transition
              |. fun attr "y" (\(x,y) i -> (show (dims.height - (yScale y) + 3))++"px")
              |. delay (\(x,y) i -> round <| (sqrt (toFloat i)) * 60)
              |. text (\(x,y) i -> show y))

{-| Create a function that will linearly scale between a start and end number
  let celciusToFarenheit = linearScale (0,32) (100,212)
  in  celciusToFarenheit 50 -- Returns 122

-}
linearScale : (Float,Float) -> (Float,Float) -> (Float -> Float)
linearScale (d1,r1) (d2,r2) = (\x -> r1 + ((r2 - r1) * (x - d1) / (d2 - d1)))


translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

vis dims margin =
  svg dims margin
  |. embed bar


--main : Signal Element
--main = render dims.height dims.width (vis dims margin) <~ constant timeData

yScale = linearScale ((\(_,r) -> (r,0))(head timeData)) ((\(_,r) -> (r,dims.height)) (last timeData))

timeData = map (\x -> (x,x*x)) [1..dataLength]

graphResult : Int -> {name:String, times:[Time]} -> Element
graphResult width result =
    let dims = {dims | width <- toFloat width - margin.left - margin.right}
        addIndex : [Time] -> [(Float,Time)]
        addIndex times = zipWith (\l r -> (toFloat l,r)) [1..length times] times
        numberedResults = {result | times <- addIndex result.times}
    in  render dims.height dims.width (vis dims margin) numberedResults.times

showResults : Int -> [{name:String, times:[Time]}] -> Element
showResults width results =
    map (graphResult width) results
    |> intersperse (spacer width 10 |> color darkGray)
    |> flow down

