## 0.2.0

#### Improvements
    * Type signatures are without `()`s now!
    * Control over imports. End user only needs to import Perf.Benchmark 
    * Added more rendering benchmarks to Flow and Text

#### Breaking Changes
    * Removed `logicFunction: a -> ()`.
    * Hidden `inputMap: (a -> b) -> [a] -> [() -> b]`