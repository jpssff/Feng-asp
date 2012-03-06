<%
F.namespace('F.ajax');

F.ajax.load = function(method, url, fn, type, data){
    var http = xml_http();
    http.onreadystatechange = function(){
        if(http.readyState == 4 && http.status === 200){
            var types = {
                'xml' : 'responseXML',
                'text' : 'responseText',
                'body' : 'responseBody',
                'stream' : 'responseStream'
            };
            type = type || 'text';
            fn(http[types[type]]);
            http = null;
        }
    }
    http.open(method, url, false);
    http.send(data ? data : null);

    function xml_http(){
        var xv = [".6.0", ".5.0", ".4.0", ".3.0", ".2.6", ""];
        for (var i = 0; i < xv.length; i++) {
            try {
                return new ActiveXObject("msxml2.xmlHttp" + xv[i]);
            } catch (ex) { }
        }
    }
};

F.ajax.get= function(url, fn, type){
    F.ajax.load('GET', url, fn, type);
};


// vim:ft=javascript
%>
