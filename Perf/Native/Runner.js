Elm.Native.Runner = {};
Elm.Native.Runner.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.Runner = elm.Native.Runner || {};
    if (elm.Native.Runner.values) return elm.Native.Runner.values;

    var Signal    = Elm.Signal.make(elm);
    var Utils     = Elm.Native.Utils.make(elm);
    var ListUtils = Elm.Native.List.make(elm);
    var Element   = Elm.Graphics.Element.make(elm);
    var Renderer  = ElmRuntime.Render.Element();
    var now       = (function() {
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
        return performance.now();
    }); 



    /*
    | runLogic : [() -> ()] -> Signal Element
    | We only want to find the time it takes to execute our input function.
    | Right now there is no nice way of doing this in elm so we much look to JS
    | for help.
    | To remain responsive we use timeouts that call the foldp to begin running
    | the next function. We can return and build up a growing list of how long
    | these functions take.
    */
    function runLogic(fs) {

        var functionArray = ListUtils.toArray(fs);
        var index = 0;
        var results = [];

        function step(delta, state) {
            if(delta >= 0) { results.push(delta) };
            if(index >= functionArray.length) {
                console.log(results);
                return A2( Element.spacer, 0, 0);
            }
            timeFunction(functionArray[index++]);
            return A2( Element.spacer, 0, 0);
        }
        var baseState = A2( Element.spacer, 0, 0);
        var deltas = Signal.constant(-1);
        var times = A3( Signal.foldp, F2(step), baseState, deltas);

        function timeFunction(f) {
            var t1 = now();
            f(Utils.Tuple0);
            var t2 = now();
            setTimeout(function() {
                elm.notify(deltas.id, t2 - t1);
            },0);
        };

        // yes, yes, I know. This is way more convenient.
        setTimeout(function() {
            elm.notify(deltas.id,-1);
        },0);

        return times;
    }

    /*
    | runView : [() -> Element] -> Signal Element
    | We execute the thunks in a given space and return a signal of a visual
    | place for them and the ever growing list of how long each element took
    | to be generated
    | We are forced to hook into the render's calls (render & update) so we
    | can get a mesurement of how long they take. A call to one of the wrappers
    | causes the rendering foldp to add another time and element, starting
    | the whole process again
    |
    | TODO: * Do we need to time the entire loop?
    |       * How should we decide how much screen space to allocate to render?
    */
    function runRender(fs) {
        var functionArray = ListUtils.toArray(fs);
        
        var index = 0;
        var results = [];
        var w = 500, h = 500;

        // This foldp is what keeps the cycle going. When it gets a new
        // timeDelta, it sets up another wrapped element to be given back
        // to Elm and timed (which will notify this foldp again)
        var deltas = Signal.constant(-1);

        function step(delta,state) {
            if(delta >= 0) { results.push(delta) };
            if (index >= functionArray.length) {
                console.log(results);
                return A2( Element.spacer, 0, 0 );
            };
            return instrumentedElement(functionArray[index++]);
        }

        var baseState = instrumentedElement(functionArray[index++]);

        var rendering = A3( Signal.foldp, F2(step), baseState, deltas );

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
            var t2           = now();
            setTimeout(function() { elm.notify(deltas.id, t2 - t1); }, 0);
            return newRendering
        }

        function benchUpdate(node, oldThunk, newThunk) {
            var t1           = now();
            var oldModel     = oldThunk(Utils.Tuple0);
            var newModel     = newThunk(Utils.Tuple0)
            var newRendering = Renderer.update(node, oldModel, newModel);
            var t2           = now();
            setTimeout(function() { elm.notify(deltas.id, t2 - t1); }, 0);
        }


        return rendering;
    }
    // runMany : [Benchmark] -> Signal Element
    function runMany(benchmarks){
        var bms = ListUtils.toArray(benchmarks);
        var totalBenchmarks = bms.length;
        var bmIndex   = 0;
        var index     = 0;
        var deltas = Signal.constant(-1);
        var w = 500, h = 500;
        
        var results = [[]];
        var currentFunctions = ListUtils.toArray(bms[bmIndex]._1);
        var currentFunctionType = bms[bmIndex].ctor;

        // time -> Element -> Element
        function bmStep (delta, state) {
            if(delta >= 0) results[bmIndex].push(delta);
            if(index >= currentFunctions.length) {
                index = 0;
                bmIndex++;
                if(bmIndex >= totalBenchmarks) {
                    console.log(results);
                    return A2(Element.spacer, 0, 0);
                }
                results.push([]);
                currentFunctions = ListUtils.toArray(bms[bmIndex]._1);
                currentFunctionType = bms[bmIndex].ctor;
            }
            if(currentFunctionType === 'Logic') {
                timeFunction(currentFunctions[index++]);
                return A2( Element.spacer, 0, 0);
            }
            else
                return instrumentedElement(currentFunctions[index++]);
        }

        var bmBaseState;
        if(currentFunctionType === 'Logic') {
            bmBaseState = A2( Element.spaver, 0, 0);
            setTimeout(function() {
                elm.notify(deltas.id, -1);
            },100); // Need time for the fold to get hooked up
        } else {
            bmBaseState = instrumentedElement(currentFunctions[index++]);
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
            var t2           = now();
            setTimeout(function() { elm.notify(deltas.id, t2 - t1); }, 0);
            return newRendering
        }

        function benchUpdate(node, oldThunk, newThunk) {
            var t1           = now();
            var oldModel     = oldThunk(Utils.Tuple0);
            var newModel     = newThunk(Utils.Tuple0)
            var newRendering = Renderer.update(node, oldModel, newModel);
            var t2           = now();
            setTimeout(function() { elm.notify(deltas.id, t2 - t1); }, 0);
        }

        function timeFunction(f) {
            var t1 = now();
            f(Utils.Tuple0);
            var t2 = now();
            setTimeout(function() {
                elm.notify(deltas.id, t2 - t1);
            },0);
        };

        return accumulation;
    }

    return elm.Native.Runner.values =
        { runLogic  : runLogic
        , runRender : runRender
        , runMany   : runMany
        };
};