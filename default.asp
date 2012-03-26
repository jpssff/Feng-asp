<!--#include file="bin/lib/__inc.asp"-->
<%
function startTrace(){
    if (Function.__fs) {
        return;
    };
    var fs = Function.__fs = [];
    var rec = function(c){
        if (c !== rec) {
            fs.push(c);
        };
    };
    var p = Function.prototype;
    var c = p._constructor = p.constructor;
    var nc = function(){
        rec(c);
        c.apply(this, arguments);
    };
    p.constructor = function(){
        log('xxxx');
    };
}

bind({
    'index': function(q){
        F.cache.remove();
        var apps = new F.Folder("apps").folders().map(function(f){
            return f.getName()
        });
        assign('page_title', 'Project and API');
        assign('api_doc', F.desc([F, "F"]));
        assign('apps', apps);
        display("bin/template/default.html");
    },

    'build': function(q){
        var app = q.app;
        var file = new F.File('apps/'+app+'/dev.asp');
        if(file.exist()){
            F.aspmin(file.path, file.path.replace('dev.asp', 'default.asp'));
            F.go('apps/' + app);
        }else{
            die('not exist：' + file.path);
        }
    }
});
// start the app
run();
// vim:ft=javascript
%>
