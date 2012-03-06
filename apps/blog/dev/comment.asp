<%
//用于测试
bind('comment', {
    _db: function(){
        return F.controller.blog._db();
    },

    index: function(){
        echo('ok');
    },

    //添加评论
    add: function(){
        if(F.isAjax() && F.isPost()){
            var name = F.post('name');
            var content = F.post('content');
            var pid = parseInt(F.post('id'));
            if(name.length>0 && name.length<21 && content.length>10 && content.length<501 && pid){
                var ip = F.ip();
                var time = parseInt(new Date().getTime()/1000);
                try{
                    var db = this._db();
                    var m = db.model('comments');
                    m.insert({
                        author:name, 
                        content:content,
                        ip:ip,
                        time:time,
                        pid:pid
                    });
                    db.model('posts').update('id='+pid, {'comment_number':m.count('pid='+pid)});
                    db.close();
                    echo({"status":0});
                }catch(e){
                    echo({"status":1, "msg":"数据库错误"});
                }
            }else{
                echo({"status":1, "msg":"数据不合法"});
            }
        }else{
            echo({"status":1, "msg":"非法提交"});
        }
    }
});
// vim:ft=javascript
%>

