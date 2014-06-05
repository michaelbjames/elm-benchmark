Elm.Native.BenchExec = {};
Elm.Native.BenchExec.make = function(elm) {

    elm.Native = elm.Native || {};
    elm.Native.BenchExec = elm.Native.BenchExec || {};
    if (elm.Native.BenchExec.values) return elm.Native.BenchExec.values;

    var Signal = Elm.Signal.make(elm);
    var Utils = Elm.Native.Utils.make(elm);
    var node = elm.display === ElmRuntime.Display.FULLSCREEN ? document : elm.node;


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
            var t1 = Date.now();
            f();
            var t2 = Date.now();
            times.push(t2 - t1);
        }
        return List.fromArray(times)
    }

    elm.addListener([],node, 'framecomplete', function nextFrame(e){
        // Do something?
    });

    /*
    | viewTimeTrial : [() -> Element] -> Signal Element
    | 
    | 
    */
    function viewTimeTrial(fs) {
        var newElement = Elm.Graphics.Element.make(elm).newElement;
        var Render = ElmRuntime.use(ElmRuntime.Render.Element);
        var arrfs = List.toArray(fs);
        var times = [];

        if(arrfs.length < 1) {
            console.log("No benchmarks!");
            // More needs to be added. We still need a constant signal
            // that displays such a failure message
            return;
        }

        // Make a new element from the first function in fs
        // We then want to use our wrappers for render and update so we can
        // make the appropriate timings and update our Signal Element
        var first = arrfs[0](Utils.Tuple0);
        A3(newElement, 100,100, {
            ctor: 'Custom',
            type: 'div',
            render: benchRender,
            update: benchUpdate,
            model: {element:first, times:[], total:arrfs.length}
        });


        function benchRender(model) {
            var t1 = Date.now();

            Render.render(model.element);
            
            var t2 = Date.now();
            var timeDelta = t2 - t1;
            model.times.push(timeDelta);
        }

        // Should I insert the next model myself here?
        // Notify here, too?
        function benchUpdate(node, oldModel, newModel) {
            var t1 = Date.now();

            Render.update(node,oldModel,newModel);

            var t2 = Date.now();
            var timeDelta = t2 - t1;
            newModel.times.push(timeDelta);
        }

        // We need to return a signal but we also need state over the
        // course of the function's life.
        return A2(Signal.foldp, step, state, input);
    }

    return elm.Native.BenchExec.values = {
        logicTimeTrial : logicTimeTrial,
        viewTimeTrial  : viewTimeTrial
    };
};