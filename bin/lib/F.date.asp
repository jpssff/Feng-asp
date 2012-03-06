<%
F.namespace('F.date');

//格式化日期
F.date.format = function (source, pattern) {
    if ('string' != typeof pattern) {
        return source.toString();
    }

    function replacer(patternPart, result) {
        pattern = pattern.replace(patternPart, result);
    }
    
    var pad     = F.number.pad,
        year    = source.getFullYear(),
        month   = source.getMonth() + 1,
        date2   = source.getDate(),
        hours   = source.getHours(),
        minutes = source.getMinutes(),
        seconds = source.getSeconds();

    replacer(/yyyy/g, pad(year, 4));
    replacer(/yy/g, pad(parseInt(year.toString().slice(2), 10), 2));
    replacer(/MM/g, pad(month, 2));
    replacer(/M/g, month);
    replacer(/dd/g, pad(date2, 2));
    replacer(/d/g, date2);

    replacer(/HH/g, pad(hours, 2));
    replacer(/H/g, hours);
    replacer(/hh/g, pad(hours % 12, 2));
    replacer(/h/g, hours % 12);
    replacer(/mm/g, pad(minutes, 2));
    replacer(/m/g, minutes);
    replacer(/ss/g, pad(seconds, 2));
    replacer(/s/g, seconds);

    return pattern;
};

//取“国际标准”的时间格式
F.date.toISOString = function(date){
    var date = date || new Date();
    return F.date.format(date, 'yyyy-MM-dd HH:mm:ss');
};

//unix时间戳
F.date.unixTime = function(date){
    date = date || new Date();
    return Math.ceil(date.getTime()/1000);
};

//从unix时间戳中还原事件
F.date.fromUnixTime = function(time){
    time = parseInt(time);
    return new Date(time * 1000);
};

// vim:ft=javascript
%>
