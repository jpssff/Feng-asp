var __date = new Date().getTime();
//输出编码
Response.Charset = "utf8";
//是否是调试状
var DEBUG_MODE = true;

var echo = function(){
    for(var i=0, l=arguments.length; i<l; i++){
        if(typeof arguments[i] === 'object'){
            Response.Write(F.json.stringify(arguments[i]));
        }else{
            Response.Write(arguments[i]);
        }
    }
};

var die = function(){
    echo.apply(this, arguments);
    Response.End();
};

var log = function(s){
    echo('<pre style="background:#eee;padding:3px;margin:3px 0;font-size:12px;">',
        F.encodeHTML(F.formatJSON(F.json.stringify({DATA:arguments.length > 0 ? s : __template_data}).slice(8, -1))),
    '</pre>');
    Response.Flush();
};

var __template_data = {
    "page_title" : "标题"
};

var assign = function(key, value){
    __template_data[key] = value;
};

var display = function(tpl, data){
    var html = F.fetch(tpl, data || __template_data, {checkFile:false});
    echo(html);
    return html;
};

var error = function(msg){
    //die("出现错误：" + (msg || "未知"));
};

var debug = function(a, e){
    if(arguments.length === 1){
        e = a;
        a = debug;
    }
    if(DEBUG_MODE){
        var err;
        if(e instanceof Error){
            err = e; 
        }else{
            err = new Error();
            var s = Array.prototype.slice.call(arguments, 1);
            for(var i=0; i<s.length; i++){
                err['message'+i] = s[i]
            }
        }
        var msg = '';
        msg += ('<div style="color:#d00;"><b>DEBUG:</b>');
        msg += ('<pre>' + F.encodeHTML(a.callee.toString()) + '</pre>');
        msg += F.json.stringify(err);
        msg += ('</div>');
        error(msg);
    }else{
        error();
    }
};

// vim:ft=javascript
