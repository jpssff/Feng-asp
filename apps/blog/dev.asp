<!--#include virtual="/bin/lib/__inc.asp"-->
<!--#include file="dev/__inc.asp"-->
<% 
if(F.server('SERVER_NAME') == 'localhost'){
    F.cache.remove();
}
bind(getController('blog'));
run();
%>
