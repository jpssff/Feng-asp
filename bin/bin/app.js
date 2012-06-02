//app入口函数
var app = function() {};

//用来缓存各种路径规则
app.rules = {};

//应用入口
app.init = function() {
    app.handle();
    log(new Date - __date);
};

//根据path选取对应的函数执行
app.handle = function() {
    var path = app.getPath();
    var q = false;
    for (var rule in app.rules) {
        if (q = app.checkPathRule(path, rule)) {
            app.run(path, rule, q);
            return;
        };
    }
    app.s404();
};

//根据querystring返回路径
//后期可以通过修改此函数来多样化url
app.getPath = function(query) {
    var query = F.server('QUERY_STRING');
    query = app.fixPath(query);
    return query;
};

//返回格式统一个path
app.fixPath = function(path) {
    var s = '/';
    if (path === '' || path === s) {
        return s;
    };
    while (path.length > 1 && path.charAt(path.length - 1) === s) {
        path = path.slice(0, - 1);
    };
    if (path.charAt(0) !== s) {
        path = s + path;
    };
    return path;
};

//path是否符合规则
app.checkPathRule = (function() {
    var pdata = {};
    var rdata = {};
    return function(path, rule) {
        if (path === rule) {
            return true;
        };
        var ps = pdata[path] || (pdata[path] = path.split('/'));
        var rs = rdata[rule] || (rdata[rule] = rule.split('/'));
        if (ps.length !== rs.length) {
            return false;
        };
        var d = {};
        for (var i = 0; i < ps.length; i++) {
            var r = rs[i], p = ps[i];
            if (r === p) {
                continue;
            }
            if (r !== '' && r.charAt(0) === ':') {
                d[r.slice(1)] = p;
                continue;
            }
            if (p !== r) {
                return false;
            };
        };
        return d;
    };
})();

//执行某个规则
app.run = function(path, rule, q) {
    var method = F.server('REQUEST_METHOD').toLowerCase();
    var m = app.rules[rule];
    var t = typeof m;
    if (t === 'function' && method === 'get') {
        m.call(null, q);
    } else if (t === 'object') {
        if (method in m) {
            var mt = typeof m[method];
            if (mt === 'function') {
                m[method].call(null, q);
            } else if (mt === 'string') {
                echo(m[method]);
            }
        }
        else {
            app.s404();
        }
    } else if (t === 'string') {
        echo(m);
    } else {
        app.s404();
    }
};

//404错误
app.s404 = function() {
    Response.Status = "404 Not Found";
    echo('<h1>404 Not Found</h1>');
    for (var i in app.rules) {
        log(i);
    }
};

//绑定
app.on = function(rule, res) {
    var t = typeof rule;
    if (t === 'string') {
        rule = app.fixPath(rule);
        app.rules[rule] = res;
    } else if (t === 'object') {
        for (var r in rule) {
            app.on(r, rule[r]);
        }
    }
};

