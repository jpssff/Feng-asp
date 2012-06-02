

F.namespace('F.number');

//补零
F.number.pad = function (source, length) {
    var pre = "",
        negative = (source < 0),
        string = String(Math.abs(source));

    if (string.length < length) {
        pre = (new Array(length - string.length + 1)).join('0');
    }

    return (negative ?  "-" : "") + pre + string;
};


// vim:ft=javascript

