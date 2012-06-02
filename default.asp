<!--#include file="bin/bin/__inc.xml"-->
<script runat="server" language="javascript">
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
</script>
<!--#include file="bin/apps/blog/bin/__inc.xml"-->
<script runat="server" language="javascript">
if(F.server('SERVER_NAME') == 'localhost'){
    F.cache.remove();
}
bind(getController('blog'));
run();
</script>
