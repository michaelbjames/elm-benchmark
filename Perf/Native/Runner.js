Elm.Native.Runner = {};
Elm.Native.Runner.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.Runner = elm.Native.Runner || {};
    if (elm.Native.Runner.values) return elm.Native.Runner.values;

    var Signal     = Elm.Signal.make(elm);
    var Utils      = Elm.Native.Utils.make(elm);
    var ListUtils  = Elm.Native.List.make(elm);
    var Element    = Elm.Graphics.Element.make(elm);
    var Renderer   = ElmRuntime.Render.Element();
    var Dimensions = Elm.Native.Window.make(elm).dimensions;
    var now        = (function() {
        // Returns the number of milliseconds elapsed since either the browser navigationStart event or
        // the UNIX epoch, depending on availability.
        // Where the browser supports 'performance' we use that as it is more accurate (microsoeconds
        // will be returned in the fractional part) and more reliable as it does not rely on the system time.
        // Where 'performance' is not available, we will fall back to Date().getTime().
        // http://dvolvr.davidwaterston.com/2012/06/24/javascript-accurate-timing-is-almost-here/        
        var performance = window.performance || {};      
        performance.now = (function() {
            return performance.now    ||
            performance.webkitNow     ||
            performance.msNow         ||
            performance.oNow          ||
            performance.mozNow        ||
            function() { return new Date().getTime(); };
        })();
        return Math.round(performance.now()*10);
    }); 

    /* runMany : [Benchmark] -> Signal Either Element Time
     |
     | For rendering tests we have to be clever. We need an element to get to
     | screen. We instrument the element such that it notifies our signal and
     | consequently updates the foldp upon being rendered or updated.
     | Thanks to evancz for the advice on this!
     |
     | For pure tests we still have to return an element, so it's blank. We
     | also do not need this rendering trick as the functions are pure thunks.
     | We asynchronously run the pure function while timing it. When it
     | completes, it notifies the signal.
     |
     | When the signal is notified it recieves either a delta time or a
     | timestamp, distinguished by the type of deltaObject. After it is
     | appropriately placed in the results, the function grabs the next function
     | in the current benchmark (either a logic or a view benchmark). If there
     | are no more thunks left in the current benchmark, then the foldp goes on
     | to the next set of functions. This continues until we run out of
     | benchmarks at which point we display the results of all benchmarks.
     |
     | This is intentionally a monolithic function. The hope is to clean this
     | up when we need more functionality and when more features have been
     | added to Elm. It is possible that Commands will help.
     */
    function runMany(benchmarks){
        var bms = ListUtils.toArray(benchmarks);
        var totalBenchmarks = bms.length;
        var bmIndex   = 0;
        var index     = 0;
        var deltas = Signal.constant(-1);
        var w = Dimensions.value._0;
        var h = Dimensions.value._1;
        var emptyElem = Element.empty;
        
        var results = [];
        var currentFunctions = ListUtils.toArray(bms[bmIndex]._1);
        if (currentFunctions.length < 1) {
            console.log("One of your benchmarks didn't have any functions to\
run. This is a fatal error.");
            return;
        }
        var currentFunctionType = bms[bmIndex].ctor;
        results[bmIndex] = {_:{}};
        results[bmIndex].name = bms[bmIndex]._0;
        results[bmIndex].times = [];

        var startTime = now();

        // time -> Element -> Element
        function bmStep (deltaObject, _) {
            var doWork = true;
            if(deltaObject.ctor === 'Pure') {
                // This method fo rounding staves off floating point errors
                results[bmIndex].times.push(deltaObject.time / 10);
            } else if(deltaObject.ctor === 'Rendering') {
                results[bmIndex].times.push((now() - deltaObject.time) / 10);
            }
            if(index >= currentFunctions.length) {
                results[bmIndex].times = ListUtils.fromArray(results[bmIndex].times);
                index = 0;
                bmIndex++;
                if(bmIndex >= totalBenchmarks) {
                    console.log(now() - startTime);
                    return { ctor : 'Right'
                           , _0   : ListUtils.fromArray(results)
                           }
                }
                // On to the next round of thunks, do a blank element
                doWork = false;
                results.push({_:{}});
                results[bmIndex].name = bms[bmIndex]._0;
                results[bmIndex].times = [];
                currentFunctions = ListUtils.toArray(bms[bmIndex]._1);
                currentFunctionType = bms[bmIndex].ctor;
            }
            // insert a blank sheet between sets of thunks
            if(!doWork) {
                setTimeout(function(){
                    elm.notify(deltas.id,{});
                },0);
                return { ctor : 'Left'
                       , _0   : emptyElem
                       }
            }
            if(currentFunctionType === 'Logic') {
                timeFunction(currentFunctions[index++]);
                return { ctor : 'Left'
                       , _0   : emptyElem
                       }
            } else if (currentFunctionType === 'Render'){
                var elem = instrumentedElement(currentFunctions[index++]);
                return { ctor : 'Left'
                       , _0   : elem
                       }
            }
        }

        var bmBaseState;
        if(currentFunctionType === 'Logic') {
            bmBaseState = { ctor : 'Left'
                          , _0   : emptyElem
                          }
            setTimeout(function() {
                elm.notify(deltas.id, -1);
            },100); // Need time for the fold to get hooked up
        } else {
            var elem = instrumentedElement(currentFunctions[index++]);
            bmBaseState = { ctor : 'Left'
                          , _0   : elem
                          }
        }
        var accumulation = A3( Signal.foldp, F2(bmStep), bmBaseState, deltas);


        // type Model = { thunk : () -> Element, cachedElement : Element }
        // model : Model
        // render : Model -> DOM
        // update : DOM -> Model -> Model -> ()

        function instrumentedElement(thunk) {
           return A3(Element.newElement, w, h,
                    { ctor: 'Custom'
                    , type: 'customBenchmark'
                    , render: benchRender
                    , update: benchUpdate
                    , model: thunk
                    }); 
        }

        function benchRender(thunk) {
            var t1           = now();
            var newRendering = Renderer.render(thunk(Utils.Tuple0));
            var deltaObject  = { ctor: 'Rendering'
                               , time: t1
                               };
            setTimeout(function() { elm.notify(deltas.id, deltaObject); }, 0);
            return newRendering
        }

        function benchUpdate(node, oldThunk, newThunk) {
            var t1           = now();
            var oldModel     = oldThunk(Utils.Tuple0);
            var newModel     = newThunk(Utils.Tuple0);
            var newRendering = Renderer.update(node, oldModel, newModel);
            var deltaObject  = { ctor: 'Rendering'
                               , time: t1
                               };
            setTimeout(function() { elm.notify(deltas.id, deltaObject); }, 0);
        }

        function timeFunction(f) {
            var t1 = now();
            f(Utils.Tuple0);
            var t2 = now();
            var deltaObject = { ctor: 'Pure'
                              , time: t2 - t1}
            setTimeout(function() {
                elm.notify(deltas.id, deltaObject);
            },0);
        };

        return accumulation;
    }

    return elm.Native.Runner.values =
        { runMany   : runMany
        };
};