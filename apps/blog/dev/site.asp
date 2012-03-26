<%
//博客
bind('blog',{
    _db: function(){
        if(this.__db){
            return this.__db;
        }
        this.__db = new F.MsJetConnection(F.dataPath).open();
        var tags;
        if(tags = F.cache.get('tags')){
            tags = F.json.parse(tags);
        }else{
            tags = this.__db.model('tags').findAll();
            tags.sort(function(t1, t2){
                if([t1.name, t2.name].sort()[0] == t1.name){
                    return -1;
                }
                return 1;
            });
            F.cache.set('tags', F.json.stringify(tags));
        }
        this._tags = tags;
        //所有标签
        assign('tags', tags);
        var tagNames = this._tagNames = {};
        tags.forEach(function(v, i){
            tagNames[v.id] = v.name;
        });
        //标签名
        assign('tagNames', tagNames);
        var _tags = tags.slice();
        _tags.sort(function(t1, t2){
            return (t2.pcount||0) - (t1.pcount||0);
        });
        //top5分类
        assign('tagTops', _tags.slice(0, 10));
        return this.__db;
    },

    _init: function(){
        var ACTION = F.get('a') || 'index';
        var isLogin = F.User.isLogin();
        if (!isLogin) {
            var name = F.cookie.get('name');
            var password = F.cookie.get('password');
            if (name && password) {
                var db = this._db();
                var user = new F.User();
                if (user.checkLogin(name, password)) {
                    isLogin = true;
                };
            };
        };
        assign('is_login', isLogin);
        assign('is_loginpage', ACTION === 'login');
        assign('is_home', ACTION === 'index');
        assign('is_view', ACTION === 'view');
        assign('is_add', ACTION === 'add');
        assign('is_edit', ACTION === 'edit');
        assign('is_file', ACTION === 'file');
        assign('is_comment', ACTION === 'comment');
        assign('is_runsql', ACTION === 'runsql');
        assign('is_tag', ACTION === 'tag');
        assign('is_cate', ACTION === 'cate');
    },

    _TEXT_TYPE:{
        MAKRDOWN: 1,
        OLD:0,
        HTML:2
    },

    _setPostHtml: function(post){
        //如果是markdown语法
        if(post.text_type === this._TEXT_TYPE.MAKRDOWN){
            post.content = F.markdown(post.content);
        }
        //以前的blog数据
        else{
            post.content = post.content.replace(/<pre(\w|\W)+?>((\w|\W)+?)<\/pre>/g, function(a, b, c){
                return '<pre>' + F.encodeHTML(c) + '</pre>';
            });

            var index = post.content.indexOf('<pre');
            if(index === -1){
                post.content = post.content.replace(/\n/g, '<br>');
            }else{
                var start = 0;
                while(index !== -1){
                    var p1 = post.content.slice(start, index).replace(/(\r?\n)+/g, '<br>');
                    post.content = post.content.slice(0, start) + p1 + post.content.slice(index);
                    start = post.content.indexOf('</pre>', index + 1);
                    index = post.content.indexOf('<pre', start);
                }
            }
        }
    },

    //首页
    index: function(){
        var _this = this;
        var db = this._db();
        var model = db.model('posts');
        var page = parseInt(F.get('page')) || 1;
        list = model.page(page, '', '*', 5, 'id desc', {params:'r=blog'});
        list.data.forEach(function(p, i){
            _this._setPostHtml(p);
            if(p.tags === null){
                p.tags = [];
            }else{
                p.tags = p.tags.split('|');
            }
        });
        db.close();
        assign('list', list);
        assign('page_title', '首页');
        display('bin/template/index.html');
    },

    //tag列表页
    cate: function(){
        var _this = this;
        var db = this._db();
        var model = db.model('posts');
        var cid = parseInt(F.get('c')) || 1;
        var page = parseInt(F.get('page')) || 1;
        list = model.page(page, 'id in (select tags_relation.pid from tags_relation where tags_relation.tid='+cid+')','*', 5, 'id desc', {params:'r=blog&a=cate&c='+cid});
        if(list.data.length == 0){
            error('没有文章');
        }
        list.data.forEach(function(p, i){
            _this._setPostHtml(p);
            if(p.tags === null){
                p.tags = [];
            }else{
                p.tags = p.tags.split('|');
            }
        });
        db.close();
        assign('cid', cid);
        assign('list', list);
        assign('page_title', this._tagNames[cid]);
        display('bin/template/index.html');
    },

    //文章查看
    view: function(){
        var id = parseInt(F.get('id')) || 0;
        var post = F.cache.get(id);
        var db = this._db();
        var model = db.model('posts');
        post = model.find('id='+id);
        if(!post){
            error('没有找到文章');
        }
        this._setPostHtml(post);

        var tags = this._tags;
        db.close();

		post.tags = post.tags ? post.tags.split('|') : [];
        assign('post', post);
        assign('page_title', post.title);
        display('bin/template/view.html');
    }
});
// vim:ft=javascript
%>

