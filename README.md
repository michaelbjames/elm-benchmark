elm-benchmark
=============

Elm code benchmarking suite

###How to use this library:
First: import what you'll need
```elm
import Perf.Runner (..)
import Perf.Benchmark (..)
import Perf.Types (..)
```


###Design:

####What we want to do:
We want to run a snippet of code and get a numeric value of how it performs.
We want to be able to run the same snippet of code on varying inputs to
simulate a section of a real world application (i.e., how does performance
change as a function of time or window dimensions).

####The atom of computation:
At the heart of benchmarking a set of inputs is the execution of one input.
Subatomically is the function itself without input, but it may be best to
think of our atom as a saturated function waiting to be executed.

#####Hydrogen & Helium:
There are two different kinds of atoms in this benchmarking suite.
One is for pure functions `() -> ()`. We want to know how fast Elm will
execute a snippet of code that require no rendering.
Then there are ones that create a visual effect `() -> Element`.
These require the renderer to bring the elements to life.

####Results:
We eventually want the results of our tests. We want that numeric value
of our function. We want the time taken for a `Benchmark` to complete, along
with the information about what the test did.

####Running the tests:
#####Pure Functions:
Pure functions are easy to test. They do not have side effects. They do not render to the screen. We can simply time the function and see how long it takes to run.
#####Rendering Functions:
We need a strategy to fully render the functions while also allowing us to cleanly display the results. There are two obvious strategies:
1. Render the function in a 1px area. We squish the output to a tiny size.
2. Render the function in a hidden area.
3. Render on screen in a predefined area
We choose #3.