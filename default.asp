<!--#include file="bin/lib/__inc.asp"-->
<%
bind({
    'index': function(){
        F.cache.remove();
        var apps = new F.Folder("apps").folders().map(function(f){
            return f.getName()
        });
        assign('page_title', '项目管理');
        assign('api_doc', F.desc([F, "F"]));
        assign('apps', apps);
        display("bin/template/default.html");
    },

    'build': function(){
        var app = F.get('app');
        var file = new F.File('apps/'+app+'/dev.asp');
        if(file.exist()){
            F.aspmin(file.path, file.path.replace('dev.asp', 'default.asp'));
            F.go('apps/' + app);
        }else{
            die('不存在：' + file.path);
        }
    }
});
// 入口函数
run();
// vim:ft=javascript
%>

