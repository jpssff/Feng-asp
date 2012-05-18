<%@LANGUAGE="JavaScript" CODEPAGE="65001"%>
<%
var START = new Date().getTime();
//输出编码
Response.Charset = "utf8";
//是否是调试状
var DEBUG_MODE = true;
%>
<!--#include file="prototype/__inc.asp"-->
<!--#include file="F.asp"-->
<!--#include file="F.string.asp"-->
<!--#include file="F.number.asp"-->
<!--#include file="F.date.asp"-->
<!--#include file="F.json.asp"-->
<!--#include file="F.session.asp"-->
<!--#include file="F.ajax.asp"-->
<!--#include file="F.cache.asp"-->
<!--#include file="F.cookie.asp"-->
<!--#include file="F.Connection.asp"-->
<!--#include file="F.ExcelConnection.asp"-->
<!--#include file="F.MsJetConnection.asp"-->
<!--#include file="F.MsSqlConnection.asp"-->
<!--#include file="F.File.asp"-->
<!--#include file="F.Folder.asp"-->
<!--#include file="F.Model.asp"-->
<!--#include file="F.Upload.asp"-->
<!--#include file="F.User.asp"-->
<!--#include file="F.Xml.asp"-->
<!--#include file="F.Binary.asp"-->
<%

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

var bind = function(ctrl, actions){
    if(typeof ctrl === 'object'){
        actions = ctrl;
        ctrl = "site";
    }
    var controllers = F._controllers || (F._controllers = {});
    var controller = controllers[ctrl] || (controllers[ctrl] = {}); 
    F.extend(controller, actions);
};

var getController = function(ctrl){
    return F._controllers[ctrl];
};

var run = function(){
    var q = F.get();
    var p = F.post();
    var controllers = F._controllers || (F._controllers = {});
    var ctrl = q.r || 'site';
    var action = q.a || 'index';
    var fn = function(){
        if('_init' in controllers[ctrl]){
            controllers[ctrl]._init(q, p);
        }
        controllers[ctrl][action](q, p);
    };
    if(ctrl in controllers){
        if(action in controllers[ctrl] && action.substring(0,1) !== '_'){
            if(DEBUG_MODE){
                fn();
            }else{
                try{
                    fn();
                }catch(e){
                    error('抱歉，出错了。信息：' + e.message);
                }
            }
        }else{
            error('您要查看的页面被禁止访问');
        }
    }else{
        error('未知的控制参数');
    }
};

// vim:ft=javascript
%>
