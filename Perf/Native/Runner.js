Elm.Native.Runner = {};
Elm.Native.Runner.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.Runner = elm.Native.Runner || {};
    if (elm.Native.Runner.values) return elm.Native.Runner.values;

    var Signal = Elm.Signal.make(elm);
    var Utils  = Elm.Native.Utils.make(elm);
    var node   = elm.display === ElmRuntime.Display.FULLSCREEN ? document : elm.node;
    var now    = (function() {
 
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
    | runLogic : [() -> ()] -> [Time]
    | We only want to find the time it takes to execute our input function.
    | Right now there is no nice way of doing this in elm so we much look to JS
    | for help.
    | Note: Date.now() is millisecond resolution but window.performance.now()
    |       is µsec resolution. However, it is not implemented in every browser,
    |       looking at you Safari.
    */

    function runLogic(fs) {

        var arrfs = List.toArray(fs);
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
    | runView : [() -> Element] -> Signal (Element, Time)
    | 
    | 
    */
    function runView(fs) {
        var Element = Elm.Graphics.Element.make(elm);
        var Utils = ElmRuntime.use(ElmRuntime.Render.Utils);
        var functionArray = Utils.fromList(fs);
        var Renderer = ElmRuntime.Render.Element();

        var rendering = Signal.constant(A2(Element.spacer, 500, 500));
        A2( Signal.lift, function(a) {
            console.log("Rendering:");
            console.log(a || "make this go away someday:" );
        }, rendering);

        var deltas = Signal.constant(0);
        A3( Signal.foldp, F2(function(step,state) {
            console.log("Step:");
            console.log(step);
            console.log("State:");
            console.log(state);
            step
            setTimeout(function() {
                console.log("delta notifying rendering");
                elm.notify(rendering.id, step);
            }, 1000);
        }), 0, deltas);

        function makeNextStep (model) {
           return A3(Element.newElement, 500, 400,
                    {ctor: 'Custom',
                    type: 'customBenchmark',
                    render: benchRender,
                    update: benchUpdate,
                    model: model
                    }); 
        }

        function benchRender(model) {
            console.log("benchRender");
            var step = makeNextStep(model);
            // time and call render
            // render(model.element);
            setTimeout(function() {
                elm.notify(rendering.id, step);
                elm.notify(deltas.id,step);
            }, 1000);
            // creates a new DOM element and returns it
            return Renderer.render(model(Utils._Tuple0));
        }

        function benchUpdate(node, oldModel, newModel) {
            console.log("benchUpdate");
            var step = makeNextStep(newModel);
            // time and call update
            setTimeout(function() {
                elm.notify(rendering.id, step);
                elm.notify(deltas.id,step);
            }, 1000);
        }

        setTimeout(function() {
            console.log("setTimeout");
            var step = makeNextStep(functionArray[0]);
            // elm.notify(rendering.id, step);
            elm.notify(deltas.id,step);
        }, 1000);

        return deltas;
    }

    return elm.Native.Runner.values =
        { runLogic : runLogic
        , runView  : runView
        };
};