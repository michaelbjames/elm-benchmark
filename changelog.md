### 0.3.0

#### Notes
    * Elm version requirement version bumped to `0.12.3`
    * We break apart the benchmarks into the basic and advanced ones

#### Improvements
    * Better documentation

#### Breaking Changes
    * `staticRender` is now `renderStatic`
    * No more `logicSetup`
    * `lazyLogic` is now `logicWithDeferedInput`
    * `renderSetup` is now `renderWithSetup`



## 0.2.0

#### Improvements
    * Type signatures are without `()`s now!
    * Control over imports. End user only needs to import Perf.Benchmark 
    * Added more rendering benchmarks to Flow and Text

#### Breaking Changes
    * Removed `logicFunction: a -> ()`.
    * Hidden `inputMap: (a -> b) -> [a] -> [() -> b]`