!function() {
    window.appHost = {
        version: "1.5.1"
    };
    
    var callbackPool = {};
    var ack_no = 1;
    //同步方式，appHost.invokeSync('getDataWithParamCallback',{"a":"wl"})
    window.appHost.invokeSync = function(_action, _data) {
        var fullParam = {
            action: _action,
            param: _data
        };
        var param = JSON.stringify(fullParam);
        return window.prompt(param);
    }
    //默认是异步方式，appHost.invoke('getDataWithParamCallback',{"a":"wl"},function(a){console.log(a)})
    window.appHost.invoke = function(_action, _data, _callback) {
        var rndKey = 'cbk_' + new Date().getTime();
        var fullParam = {
            action: _action,
            param: _data
        };
        var func = null;
        if(typeof _data == "function")
        {
            func = _data;
            delete fullParam.param;
        }
        else if(typeof _callback == "function")
        {
            func = _callback;
        }
        
        if (func) { //如果有回调函数。
            var rndKey = 'cbk_' + ack_no++;
            fullParam.callbackKey = rndKey;
            callbackPool[rndKey] = func;
        }

        window.webkit.messageHandlers.kAHScriptHandlerName.postMessage(fullParam)
    }
    var reqs = {};
    window.appHost.on = function(_action, _callback) {
        reqs[_action + ""] = _callback;
    }
    window.appHost.__fire = function(_action, _data) {
        var func = reqs[_action + ""];
        if (typeof func == 'function') {
            var respCallback = null;
            var callBackId = _data['cbk'];
            if (typeof callBackId != "undefined")
            {
                respCallback = function(data)
                {
                    var fullParam = 
                    {
	                    action: callBackId,
	                    param:data
                    };
                    window.webkit.messageHandlers.kAHScriptHandlerName.postMessage(fullParam)
                }
            }
            func(_data, respCallback);
        }
    }
    window.appHost.__callback = function(_callbackKey, _param) {
        var func = callbackPool[_callbackKey];
        if (typeof func == 'function') {
            func(_param);
            // 释放,只用一次
            delete callbackPool[_callbackKey];
        }
    }
}(window);
