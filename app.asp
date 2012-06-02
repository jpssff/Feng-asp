<!--#include file="bin/bin/__inc.xml"-->
<script runat="server" language="javascript">
app.on('/', function(){F.go('?index')});
app.on('/x', 'asdad');
app.on('/a', function(){echo(new Date - __date)});
app.on('/a/b', function(){log(F.get())});
app.on('/a/:key/:id', function(p){log(p);});
app.on({
    'index': function(q){
        F.cache.remove();
        var apps = new F.Folder("bin/apps").folders().map(function(f){
            return f.getName()
        });
        assign('page_title', 'Project and API');
        assign('api_doc', F.desc([F, "F"]));
        assign('apps', apps);
        display("bin/template/default.html");
    }
});
app.init();
// vim:ft=javascript
</script>
