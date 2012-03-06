<%
//文件夹类
F.Folder = function(path){
    this.path = '';
    if(F.isString(path)){
        this.setPath(path);
    }
};

F.Folder.prototype = {
    //获取fso
    fso: function(){
        return F.fso();
    },

    //设置路径
    setPath: function(path){
        this.path = (path.indexOf(':') > -1) ? path : Server.MapPath(path);
        return this;
    },

    //返回路径
    getPath: function(){
        return this.path;
    },

    //获取文件夹名称
    getName: function(){
        return this.fso().GetFolder(this.path).Name;
    },

    //是否存在
    exist: function(path){
        return this.fso().FolderExists(path || this.path);
    },

    //获取文件夹的相关信息
    getInfo: function(){
        var f = this.fso().GetFolder(this.path);
        var fso = this.fso(), path = this.path;
        return {
            'AbsolutePathName' : fso.GetAbsolutePathName(path),
            'DateCreated' : new Date(f.DateCreated),
            'DateLastAccessed' : new Date(f.DateLastAccessed),
            'DateLastModified' : new Date(f.DateLastModified),
            'Drive' : String(f.Drive),
            'IsRootFolder' : Boolean(f.IsRootFolder),
            'Name' : f.Name,
            'ParentFolder' : String(f.ParentFolder),
            'Path' : String(f.Path),
            'ShortName' : f.ShortName,
            'ShortPath' : f.ShortPath,
            'Size' : f.Size,
            'Type' : f.Type
        }
    },

    //根据路径递归创建
    create: function(path){
        var ps = (this.path || path).split(':');
        var fs = ps[1].split(/\\|\//);
        var tmp = ps[0] + ':';
        do{
            tmp += '\\' + fs.shift();
            if(!this.exist(tmp)){
                this.fso().CreateFolder(tmp);
            }
        }while(fs.length && fs[0])
        return this;
    },

    //在文件夹中创建文件
    createFile: function(name, content){
        var f = new F.File(this.path + '/' + name);
        if(!f.exist()){
            f.create();
            if(content){
                f.setText(content);
            }
        }
    },

    //删除路径
    remove: function(path){
        if(this.exist(path)){
            this.fso().DeleteFolder(this.path || path);
        }
        return this;
    },

    //清空文件夹
    empty: function(){
        this.folders().forEach(function(folder){
            folder.remove();
        });
        this.files().forEach(function(file){
            file.remove();
        });
        return this;
    },

    //获取文件夹名称
    getFolderName: function(){
        return this.fso().GetFolder(this.path).Name;
    },

    //改名
    rename: function(name){
        name = name.trim();
        if(name!=='' && this.getFolderName()!==name){
            var f = this.fso().GetFolder(this.path);
            f.Name = name;
            this.path = f.Path;
        }
        return this;
    },

    //获取所有的文件
    map: function(enumForder, filter, fn){
        var res = [];
        var fo = this.fso().GetFolder(this.path);
        var fc = new Enumerator(enumForder(fo));
        if(filter instanceof RegExp){
            var re = filter;
            filter = function(f){
                return re.test(f);
            }
        }else if(F.isString(filter) || F.isNumber(filter)){
            var s = String(filter);
            filter = function(f){
                return f.indexOf(s) > -1;
            }
        }
        if(typeof filter !== "function"){
            filter = function(){return true;}
        }
        for (; !fc.atEnd(); fc.moveNext()){
            var f = fc.item().Path;
            if(filter(f)){
                res.push(fn(f));
            }
        }
        return res;
    },

    //返回子目录数组
    folders: function(filter){
        return this.map(function(forder){
            return forder.SubFolders;
        }, filter, function(path){
            return new F.Folder(path);
        });
    },

    //递归处理，返回所有的目录数组
    allFolders: function(filter){
        var res = [], fs = this.folders(filter), fn = arguments.callee;
        res = res.concat(fs);
        fs.forEach(function(forder){
            res = res.concat(fn.call(forder, filter));
        });
        return res;
    },

    //返回文件数组
    files: function(filter){
        return this.map(function(forder){
            return forder.files;
        }, filter, function(path){
            return new F.File(path);
        });
    },

    //递归处理，返回所有的目录数组
    allFiles: function(filter){
        var res = [], fs = this.folders(), fn = arguments.callee;
        fs.forEach(function(folder){
            res = res.concat(folder.files(filter));
        });
        fs.forEach(function(forder){
            res = res.concat(fn.call(forder, filter));
        });
        return res;
    },

    //销毁示例资源
    dispose: function(){
        this.path = null;
    }
};




// vim:ft=javascript
%>
