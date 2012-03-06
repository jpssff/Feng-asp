<%
//博客
bind('site',{
    index: function(){
        assign('name', 'Tom');
        display('bin/template/index.html');
    }
});
// vim:ft=javascript
%>

