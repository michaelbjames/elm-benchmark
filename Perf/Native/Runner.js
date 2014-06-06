Elm.Native.Runner = {};
Elm.Native.Runner.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.Runner = elm.Native.Runner || {};
    if (elm.Native.Runner.values) return elm.Native.Runner.values;

    var Signal    = Elm.Signal.make(elm);
    var Utils     = Elm.Native.Utils.make(elm);
    var ListUtils = Elm.Native.List.make(elm);
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
    | runLogic : [() -> ()] -> Signal [Time]
    | We only want to find the time it takes to execute our input function.
    | Right now there is no nice way of doing this in elm so we much look to JS
    | for help.
    */
    function runLogic(fs) {

        var functionArray = ListUtils.toArray(fs);
        var times = [];

        for(f in arrfs) {
            var t1 = now();
            f();
            var t2 = now();
            times.push(t2 - t1);
        }
        return List.fromArray(times)
    }

    /*
    | runView : [() -> Element] -> Signal (Element, [Time])
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
    function runView(fs) {
        var Element = Elm.Graphics.Element.make(elm);
        var functionArray = ListUtils.toArray(fs);
        var Renderer = ElmRuntime.Render.Element();
        var index = 0;
        var results = [];
        var w = 500, h = 500;

        // This foldp is what keeps the cycle going. When it gets a new
        // timeDelta, it sets up another wrapped element to be given back
        // to Elm and timed (which will notify this foldp again)
        var deltas = Signal.constant(0);
        var rendering = A3( Signal.foldp, F2(function(delta,state) {
            results.push(delta);
            if (index >= functionArray.length) {
                // We have one extra 0 in the front of our array
                results.shift();
                return Utils.Tuple2( A2 (Element.spacer, 0, 0)
                                   , ListUtils.fromArray(results)
                                   );
            };
            return Utils.Tuple2( instrumentedElement(functionArray[index++])
                               , ListUtils.fromArray(results));
        }), Utils.Tuple2( A2( Element.spacer, 0, 0 )
                        , ListUtils.fromArray(results)
                        ), deltas);

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

        setTimeout(function() {
            elm.notify(deltas.id,0);
        },0);

        return rendering;
    }



    return elm.Native.Runner.values =
        { runLogic : runLogic
        , runView  : runView
        };
};