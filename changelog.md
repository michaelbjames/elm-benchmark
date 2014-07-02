### 0.3.0

#### Notes
    * Elm version requirement version bumped to `0.12.3`
    * We break apart the benchmarks into Benchmarks and Benchmark.DeferredSetup

#### Improvements
    * Better documentation
    * Easier future additions with a module scheme (Benchmark/etc)
    * Sheltered most files in Benchmark namespace

#### Breaking Changes
    * `staticRender` is now `renderStatic`
    * No more `logicSetup`
    * `lazyLogic` is now `DS.logic`
    * `renderSetup` is now `DS.render`
    * `renderSetup` is now like `lazyLogic` but for rendering
    * No longer using the Perf namespace



## 0.2.0

#### Improvements
    * Type signatures are without `()`s now!
    * Control over imports. End user only needs to import Perf.Benchmark 
    * Added more rendering benchmarks to Flow and Text

#### Breaking Changes
    * Removed `logicFunction: a -> ()`.
    * Hidden `inputMap: (a -> b) -> [a] -> [() -> b]`