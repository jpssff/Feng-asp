<%
//管理员部分
bind('admin', {
    _init: function(){
        getController('blog')._init();
        if(F.get('a') !== 'login'){
            if(!F.User.isLogin()){
                F.go('?r=admin&a=login');
            }
        }
        if(F.isAjax()){
            F.header('Content-Type', 'application/json');
        }
    },

    _db: getController('blog')._db,

    _TEXT_TYPE : getController('blog')._TEXT_TYPE,

    index: function(){
        F.go('?r=blog');
    },

    login: function(q, p){
        assign('error', '');
        if(F.isGet()){
            var url = '?r=blog';
            var ref = F.server('HTTP_REFERER');
            if(ref && ref.indexOf(F.server('HTTP_HOST')) !== -1){
                url = ref;
            }
            assign('url', url);
            assign('page_title', '用户登录');
            display('bin/template/login.html');
        }else{
            var name = p.name;
            var password = p.password;
            var url = p.url || '?r=blog';
            assign('url', url);
            var isRemember = p.remember == 'on';
            if(name !== "" && password !== ""){
                var db = this._db();
                var user = new F.User();
                if(user.checkLogin(name, password, true)){
                    db.close();
                    if (isRemember) {
                        var exprire =new Date(new Date().getTime()+1000*3600*24*30); 
                        F.cookie.set('password', F.md5(password), exprire);
                        F.cookie.set('name', name, exprire);
                    };
                    F.go(url);
                }
                db.close();
            }
            assign('error', '用户名或密码不正确');
            display('bin/template/login.html');
        }
    },

    logout: function(){
        if(F.User.isLogin()){
            F.User.logout();
            F.cookie.remove('name');
            F.cookie.remove('password');
        }
        F.go('?r=blog');
    },

    add: function(){
        var me = this;
        assign('draft', null);
        var db = this._db();
        var m_tags_relatiion = db.model('tags_relation');
        if(F.isGet()){
            display('bin/template/add.html');
        }else{
            var title = F.post('title');
            var content = F.post('content');
            var tagidsString = F.post('tagid');
            var tagids = [];
            if(tagidsString){
                tagids = tagidsString.split(/,\s+/);
            }
            if(!title || !content){
                error('缺少标题或内容');
            }else{
                try{
                    var model = db.model('posts');
                    model.insert({
                        title       : title,
                        content     : content,
                        author      : 'WiFeng',
						text_type   : me._TEXT_TYPE.MAKRDOWN,
                        tags        : tagids.join('|'),
                        create_time : parseInt(new Date().getTime()/1000),
                        update_time : parseInt(new Date().getTime()/1000),
                        view_number : 0
                    });
                    var post = model.find('','id','id desc');
                    var id = post.id;
                    var tagModel = db.model('tags');
                    tagids.forEach(function(t, i){
                        m_tags_relatiion.insert({tid:t, pid:id});
                        tagModel.update('id='+t, {pcount:m_tags_relatiion.count('tid='+t)});
                    });
                    db.model('drafts').del('id=' + F.post('draft_id'));
                    db.close();
                }catch(e){
                    error('数据库错误:' + e.message);
                }
                F.cache.remove();
                F.go('?r=blog&a=view&id=' + post.id);
            }
        }
    },

    //编辑文章
    edit: function(){
        var id = parseInt(F.get('id'));
        if(isNaN(id)){
            error('参数无效。');
        }
        var db = this._db();
        var model = db.model('posts');
        var post = model.find('id=' + id);
        if(!post){
            error('没有这篇文章');
        }
        if(F.isGet()){
            var draft = db.model('drafts').find('id=' + id);
            assign('draft', draft);
            var _tagids = db.model('tags_relation').findAll('pid='+id, 'tid');
            var tagids = {};
            _tagids.forEach(function(v){tagids[v.tid] = true;});
            assign('tagids', tagids);
            db.close();
            assign('post', post);
            display('bin/template/add.html');
        }else{
            delete post.id;//因为id是主键，所以不能更新此字段
            post.title = F.post('title');
            post.content = F.post('content');
            post.update_time = parseInt(new Date().getTime()/1000);
            var tagidsString = F.post('tagid');
            var tagids = [];
            if(tagidsString){
                tagids = tagidsString.split(/,\s+/);
            }
            if(!post.view_number){
                post.view_number = 0;
            }
			post.tags = tagids.join('|');
            post.text_type = this._TEXT_TYPE.MAKRDOWN;
            try{
                model.update('id=' + id, post);
                db.model('drafts').del('id=' + id);
                var m_tags_relatiion = db.model('tags_relation');
                var oldTags = m_tags_relatiion.findAll('pid=' + id);
				var oldMap = {};
				oldTags.forEach(function(t, i){
					oldMap[t.tid] = true;
			    });
                var tagModel = db.model('tags');
                //删除旧tag并添加新tag
                tagids.forEach(function(t, i){
					if(t in oldMap){
						delete oldMap[t];
					}else{
						m_tags_relatiion.insert({tid:t, pid:id});
                        tagModel.update('id='+t, {pcount:m_tags_relatiion.count('tid='+t)});
					}
                });
				for(var t in oldMap){
					m_tags_relatiion.del({tid:t, pid:id});
                    tagModel.update('id='+t, {pcount:m_tags_relatiion.count('tid='+t)});
				}
                db.close();
            }catch(e){
                error('数据库错误:' + e.message);
            }
            F.cache.remove();
            F.go('?r=blog&a=view&id=' + id);
        }
    },

    //预览效果
    preview: function(){
        if(!F.isPost()){
            echo({status:1, msg:'提交方式出错'});
        }
        var content = F.post('content');
        echo({status:0, content:F.markdown(content)});
    },

    //压缩数据库
    repair: function(){
        var f = new F.File(F.dataPath);
        var msg = '<p>压缩前字节数：' + f.getSize();
        try{
            this._db().repair();
        }catch(e){
            echo({status:1, msg:e.message});
            die();
        }
        msg += ('<p>压缩后字节数：' + f.getSize());
        echo({status:0, msg:msg});
    },

    //导出xml
    xml: function(){
        var name = F.date.format(new Date(),'yyyy-MM-dd_HH-mm-ss') + '.xml'
        var db = this._db();
        db.tableNames().forEach(function(v){
            db.model(v).exportXml(name);
        });
        db.close();
        var f = new F.File(name);
        f.send();
        f.remove();
    },

    //导出sql文件
    sql: function(){
        var name = F.date.format(new Date(), 'yyyy-MM-dd_HH-mm-ss') + '.sql';
        var db = this._db();
        db.tableNames().forEach(function(v){
            db.model(v).exportSql(name);
        });
        db.close();
        var f = new F.File(name);
        f.send();
        f.remove();
    },

    //清空缓存
    removecache: function(){
        F.cache.remove();
        echo({status:0, msg:'完成'});
    },

    file: function(){
        var path = F.get('path') || '.';
        var isFile = F.get('type') === 'file';
        var say = function(obj, statusCode){
            var a = {status: statusCode || 0};
            obj = obj || {};
            for(var i in obj){
                a[i] = obj[i];
            }
            die(F.json.stringify(a));
        };
        if(F.isAjax()){
            if(F.isGet()){
                if(isFile){
                    var f = new F.File(path);
                    if(f.exist()){
                        say({content:f.getText()});
                    }else{
                        say({'msg':'文件不存在'}, 1);
                    }
                }else{
                    var folder = new F.Folder(path);
                    if(folder.exist()){
                        var data = {
                            'folders' : folder.folders(),
                            'files': folder.files()
                        };
                        say(data);
                    }else{
                        say({'msg':'文件夹不存在'}, 1);
                    }
                }
            }else if(F.isPost()){
                var action = F.get('action') || 'save';
                if(action === 'save'){
                    var f = new F.File(path);
                    if(f.exist()){
                        f.setText(F.post('content'));
                        say();
                    }else{
                        say({'msg':'文件不存在'}, 1);
                    }
                }else if(action === 'remove'){
                    var f;
                    if(isFile)
                        f= new F.File(path);
                    else
                        f = new F.Folder(path);
                    if(f.exist()){
                        try{
                            f.remove();
                            say();
                        }catch(e){
                            say({msg:e.message}, 1);
                        }
                    }else{
                        say({msg:'文件或文件夹不存在'}, 1);
                    }
                }else if(action === 'create'){
                    var f, name = F.post('name');
                    if(name.trim() === ''){
                        say({msg:'请输入名称'}, 1);
                    }
                    if(isFile)
                        f = new F.File(path + '/' + name);
                    else
                        f = new F.Folder(path + '/' + name);
                    if(f.exist()){
                        say({msg:'文件或文件夹已存在'}, 1);
                    }else{
                        try{
                            f.create();
                            say();
                        }catch(e){
                            say({msg:e.message}, 1);
                        }
                    }
                }
            }
        }else{
            var f = new F.Folder('.');
            assign('path', f.path);
            display('bin/template/file.html');
        }
    },

    //tag操作
    tag: function(){
        var _this = this;
        var db = this._db();
        var action = F.get('action') || 'list';
        var m = db.model('tags');
        var ms = {
            'list' : function(){
                echo(_this._tags);
            },
            'add' : function(){
                var name = (F.post('name')||'').trim();
				if(m.find({name:name})){
					echo({status:1, msg:'已经有这个名字的标签了'});
				}else{
					if(name.length > 0){
						m.insert({name:name});
						var tag = m.find('', 'id, name', 'id desc')
						echo({status:0, tag:{name:tag.name, id:tag.id}});
                        F.cache.remove('tags');
					}else{
						echo({status:1, msg:'缺少名称'});
					}
				}
            },
            'save': function(){
                var name = (F.post('name')||'').trim();
                var id = parseInt(F.post('id')) || 0;
                if(id && name !== ''){
                    m.update('id=' + id, {name:name});
                    echo({status:0});
                }else{
                    echo({status:1, msg:'参数错误'});
                }
            },
            'remove': function(){
                var id = parseInt(F.post('id')) || 0;
                if(id){
                    var r = db.model('tags_relation');
                    if(r.find('tid='+id)){
                        echo({status:1, msg:'还有文章使用此标签'});
                    }else{
                        m.del('id=' + id);
                        echo({status:0});
                        F.cache.remove('tags');
                    }
                }else{
                    echo({status:1, msg:'参数错误'});
                }
            }
        };
        if(F.isAjax()){
            if(action in ms){
                ms[action]();
            }else{
                echo({status:1, msg:'缺少操作参数'});
            }
        }else{
            assign('tags_table', m.html(null, null, null, null, {
                cols:[
                    {
                        th : '编辑',
                        td : function(row){
                            return '<a href="#" class="t-edit" data-id="'+row.id+'">编辑</a>';
                        }
                    },
                    {
                        th : '删除',
                        td : function(row){
                            return '<a href="#" class="t-del" data-id="'+row.id+'">删除</a>';
                        }
                    }
                ]
            }));
            display('bin/template/tag.html');
        }
        db.close();
    },

    comment: function(){
        var id = parseInt(F.get('id')) || 0;
        var action = F.get('action');
        var db = this._db();
        var m = db.model('comments');
        if(F.isGet()){
            assign('comment_html', m.html(null, null, null, null, {
                cols:[
                    {
                        th : '删除',
                        td : function(row){
                            return '<a href="#" class="c-del" data-id="'+row.id+'">删除</a>';
                        }
                    }
                ]
            }));
            display('bin/template/comment.html');
        }else{
            var as = {
                del:function(){
                    var pid = m.find('id='+id).pid;
                    m.del('id=' + id);
                    db.model('posts').update('id='+pid, {comment_number:m.count('pid='+pid)});
                    echo('{"status":0}');
                }
            };
            if(action in as)
                as[action]();
        }
        db.close();
    },

    autosave: function(){
        var id = parseInt(F.post('id'));
        if(!F.isPost() || isNaN(id)){
            die({"status":0, "msg":"status ok"});
        }
        var title = F.post('title');
        var content = F.post('content');
        var re = {status:0};
        try{
            var m = this._db().model('drafts');
            var time = F.date.unixTime();
            if(m.find('id=' + id)){
                m.update('id=' + id, {
                    title:title,
                    content:content,
                    update_time:time
                });
            }else{
                m.insert({
                    id : id,
                    title: title,
                    content: content,
                    update_time:time
                });
            }
            this._db().close();
        }catch(e){
            re.status = 1;
            re.msg = e.message;
            die(re);
        }
        echo(re);
    },

    draftlist: function(){
        var list;
        var db = this._db();
        var m = db.model('drafts');
        list = m.findAll('id>' + 1e8, 'id,title,update_time');
        list.forEach(function(v){
            v.update_time = F.date.toISOString(F.date.fromUnixTime(v.update_time));
        });
        db.close();
        echo(list);
    },

    draft: function(){
        var db = this._db();
        var m = db.model('drafts');
        var d = m.find('id=' + F.get('id'));
        db.close();
        echo(d);
    },

    runsql: function(){
        var db = this._db();
        if(F.isPost()){
            var sql = F.post('sql').trim();
            var re;
            try{
                if(/^select/.test(sql)){
                    re = db.getJson(sql);
                }else{
                    db.execute(sql);
                    re = sql + ' --- ' + 'ok!'
                }
            }catch(e){
                re = e.message;
            }finally{
                db.close();
            }
            echo(F.json.stringify(re));
        }else{
            assign('page_title', '执行sql');
            var tables = db.tableNames();
            assign('tables', tables);
            var sqls = [];
            tables.forEach(function(t){
                sqls.push(db.model(t).getCreateSql());
            });
            assign('sqls', sqls);
            db.close();
            display('bin/template/sql.html');
        }
    },

    //修正数据库数据错误
    fix: function(){
        try{
            var db = this._db();

            var tags = db.model('tags');
            var tags_relation = db.model('tags_relation');

            //修正标签数目
            tags.findAll().forEach(function(v, i){
                var t = v.id;
                tags.update('id='+t, {pcount:tags_relation.count('tid='+t)});
            });

            db.close();
            F.cache.remove();
            echo({status:0, msg:'操作完成'});
        }catch(e){
            echo({status:1, msg:e.message});
        }
    },

    x: function(){
        error('ok');
        var me = this;
        var db = this._db();
        var model = db.model('posts');
        var data = new F.File('data.xml').getText();
        var titles = data.match(/<title>(\w|\W)+?<\/title>/g);
        titles.forEach(function(t, i){
            titles[i] = t.replace('<title>', '').replace('</title>', '');
        });
        titles.shift();
        //log(titles)

        var contents = data.match(/<content:encoded><\!\[CDATA\[(\w|\W)+?\]\]/g);
        contents.forEach(function(v, i){
            contents[i] = v.slice(26).slice(0, -2);
        });
        //log(contents);

        var dates = data.match(/<pubDate>(\w|\W)+?<\/pubDate>/g);
        dates.forEach(function(v, i){
            dates[i] = v.slice(9).slice(0, -10);
            dates[i] = new Date(dates[i]);
        });
        //log(dates);

        titles.forEach(function(v, i){
            model.insert({
                title:titles[i],
                content : contents[i],
                create_time : dates[i].getTime()/1000,
                author : 'wifeng',
                text_type : me._TEXT_TYPE.OLD
            });
            log(i)
        });
        db.close();
    }

});

// vim:ft=javascript
%>

