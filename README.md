elm-benchmark
=============

Elm code benchmarking suite


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

####Tests:
These iterations are without name and meaning, they are just arrays of
functions waiting to be executed. So we need container for these iterations.
Thus we will have a `Test` with a description of the computation contained
within the form of `[iteration]`

####Results:
We eventually want the results of our tests. We want that numeric value
of our function. We want the time taken for a `Test` to complete, along
with the information about what the test did.