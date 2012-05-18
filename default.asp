<!--#include file="bin/lib/__inc.asp"-->
<%
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
