<%
F.namespace('F.ajax');

F.ajax.request = function(option){
    option = F.extend({
        method:'GET',
        success: function(){},
        fail: function(){},
        dataType: 'text',
        charset: 'utf-8'
    }, option);
    var http = F.http(true);
    http.onreadystatechange = function(){
        if(http.readyState == 4){
            if (http.status === 200) {
                var types = {
                    'xml' : 'responseXML',
                    'text' : 'responseText',
                    'body' : 'responseBody',
                    'stream' : 'responseStream'
                };
                if (option.dataType == 'xml') {
                    var charset = option.charset;
                    var ss = http.responseText.match(/encoding="([a-zA-Z\-0-9]+)"/);
                    if(ss.length > 1){
                        charset = ss[1];
                    }
                    var body = http.responseBody;
                    var str = new F.Binary(body).toString(charset);
                    option.success(F.Xml.fromString(str));
                }else if(option.dataType == 'text'){
                    var headers = F.parseHeaders(http.getAllResponseHeaders());
                    if (headers['Content-Type']) {
                        var charset = 'utf-8';
                        var text;
                        try{
                            var ss = headers['Content-Type'].split('set=');
                            text = http.responseText;
                            if (ss.length == 2) {
                                charset = ss[1];
                            };
                        }catch(e){}
                        text = new F.Binary(http.responseBody).toString(charset);
                        option.success(text);
                    };
                }else{
                    option.success(http[types[option.dataType]]);
                }
            }else{
                option.fail(http.status);
            }
            http = null;
        }
    }
    http.open(option.method, option.url, false);
    http.send(option.data || null);
};

F.ajax.load = function(method, url, fn, type, data){
    F.ajax.request({
        method:method,
        url:url,
        success:fn, 
        dataType:type,
        data:data
    });
};

F.ajax.get= function(url, fn, type){
    F.ajax.request({
        url:url,
        success:fn, 
        dataType:type
    });
};


// vim:ft=javascript
%>
