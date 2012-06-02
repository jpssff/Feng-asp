(function(){

// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/keys
Object.keys = function(o){
    if (o !== Object(o))
        throw new Error('Object.keys called on non-object');
    var ret=[],p;
    for(p in o) if(Object.prototype.hasOwnProperty.call(o,p)) ret.push(p);
    return ret;
}

Object.values = function(o) {
    var a = [];
    Object.each(o, function(n, val) {
        a.push(val);
    });
    return a;
};

Object.exists = function(o, n) {
    return Object.prototype.hasOwnProperty.call(o, n);
};

Object.each = function(o, f) {
    var i = 0;
    for (var n in o) if (Object.exists(o, n)) if (f.call(o, n, o[n],(i++)) === false) break;
    return o;
};

Object.vartype = function(obj, /**String|Array=*/ list) {
    if (list) {
        list = (list instanceof Array) ? list : String(list).split(/\s+/);
        return list.exists(Object.vartype(obj));
    }
    var type = (obj === null) ? 'null' : typeof obj;
    if (obj instanceof Object) {
        return Object.prototype.toString.call(obj).slice(8, -1).toLowerCase();
    }
    return (type == 'object') ? 'unknown' : type;
};

Object.vartype = function(obj, /**String|Array=*/ list) {
    if (list) {
        list = (list instanceof Array) ? list : String(list).w();
        return list.exists(Object.vartype(obj));
    }
    var type = (obj === null) ? 'null' : typeof obj;
    if (obj instanceof Object) {
        return Object.prototype.toString.call(obj).slice(8, -1).toLowerCase();
    }
    return (type == 'object') ? 'unknown' : type;
};


// vim:ft=javascript
})();
