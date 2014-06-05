Elm.Native.BenchExec = {};
Elm.Native.BenchExec.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.BenchExec = elm.Native.BenchExec || {};
    if (elm.Native.BenchExec.values) return elm.Native.BenchExec.values;

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
    | logicTimeTrial : [() -> ()] -> [Time]
    | We only want to find the time it takes to execute our input function.
    | Right now there is no nice way of doing this in elm so we much look to JS
    | for help.
    | Note: Date.now() is millisecond resolution but window.performance.now()
    |       is µsec resolution. However, it is not implemented in every browser,
    |       looking at you Safari.
    */

    function logicTimeTrial(fs) {

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
    | viewTimeTrial : [() -> Element] -> Signal Element
    | 
    | 
    */
    function viewTimeTrial(fs) {
        var Element = Elm.Graphics.Element.make(elm);
        var Utils = ElmRuntime.use(ElmRuntime.Render.Utils);


        var rendering = Signal.constant(A2(Element.spacer, 500, 500));
        A2( Signal.lift, function() {
            console.log("make this go away someday");
        }, rendering);

        function makeNewFrame (model) {
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
            var frame = makeNewFrame({})
            setTimeout(function() {
                elm.notify(rendering.id, frame);
            }, 1000);
            return Utils.newElement('div');
        }

        function benchUpdate(node, oldModel, newModel) {
            console.log("benchUpdate");
            var frame = makeNewFrame({});
            setTimeout(function() {
                elm.notify(rendering.id, frame);
            }, 1000);
        }

        setTimeout(function() {
            var frame = makeNewFrame({});
            elm.notify(rendering.id, frame);
        }, 1000);

        return rendering;
        // // notify of updates

        // // Make a new element from the first function in fs
        // // We then want to use our wrappers for render and update so we can
        // // make the appropriate timings and update our Signal Element
        // var first = arrfs[0](Utils.Tuple0);
        // A3(newElement, 100,100, {
        //     ctor: 'Custom',
        //     type: 'div',
        //     render: benchRender,
        //     update: benchUpdate,
        //     model: { element : first
        //            , times : []
        //            , total : arrfs.length
        //            , completed : 0
        //            }
        // });


        // function benchRender(model) {
        //     var t1 = Date.now();

        //     Render.render(model.element);
            
        //     var t2 = Date.now();
        //     var timeDelta = t2 - t1;
        //     model.times.push(timeDelta);
        // }

        // // Should I insert the next model myself here?
        // // Notify here, too?
        // function benchUpdate(node, oldModel, newModel) {
        //     var t1 = Date.now();

        //     Render.update(node,oldModel,newModel);

        //     var t2 = Date.now();
        //     var timeDelta = t2 - t1;
        //     newModel.times.push(timeDelta);
        // }

        // // We need to return a signal but we also need state over the
        // // course of the function's life.
        // return A2(Signal.foldp, step, state, input);
    }

    return elm.Native.BenchExec.values = {
        logicTimeTrial : logicTimeTrial,
        viewTimeTrial  : viewTimeTrial
    };
};