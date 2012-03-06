<%

F.Upload = function(){
    if(!F.isPost()) throw new Error("Not Post Method!");
    this.totalBytes = Request.TotalBytes;
    this.files = [];
    this.hash = {};
    this._stream = new ActiveXObject("ADODB.Stream");
    this._tempStream = new ActiveXObject("ADODB.Stream");
    this.read();
};


F.Upload.prototype = {

    //读取上传数据
    read: function(){
        var s = this._stream;
        var t = this._tempStream;
        //读取二进制流
        s.Type = 1;
        s.Mode = 3;
        s.Open();
        s.Write(Request.BinaryRead(this.totalBytes));
        //再转成字符串分析
        s.Position = 0;
        s.Type = 2;
        s.Charset = 'ASCII';

        //使用ascii码读取，方便计算字节数
        var content = s.readText(-1),
        head = content.substring(0, content.indexOf('\r\n')),
        headLen = head.length,
        headList = [],
        separator = '\r\n\r\n';

        //抽取报头
        var pos = 0;
        while(pos != -1){
            headList.push({
                start: pos + headLen,
                len: content.indexOf(separator, pos) - headLen - pos
            });
            pos = content.indexOf(head, pos + 1);
        }

        //下面不再需要这个大的字符串
        content = null;

        //取出各个文件的信息
        var regInfo = /name="([^'"]+)";\s*filename="([^'"]+)"\s*Content-Type:\s*([^\s]+)/i;
        var files = this.files,
        hash = this.hash;
        for(var i=0; i<headList.length; i++){
            if(headList[i].len < 1){
                continue;
            }
            var temp = this.readHead(headList[i].start, headList[i].len);
            var info = regInfo.exec(temp);
            if(info && info.length > 0){
                var f = {
                    fieldName: info[1],
                    fileName: info[2],
                    extensionName: info[2].match(/\.(\w+)$/)[1],
                    baseName: info[2].replace(/\.\w+$/, ''),
                    contentType: info[3],
                    dataPosition: headList[i].start + headList[i].len + 4,
                    dataSize: headList[i+1].start - headList[i].start - headList[i].len - headLen - 6
                };
                files.push(f);
                hash[info[1]] = f;
            }
        }
    },

    //读取文件头
    readHead: function(start, len){
        var s = this._stream;
        var t = this._tempStream;
        var text;
        // 复制指定数据段到临时读取器
        t.Type = 1;
        try {
            t.Open();
            s.Position = start;
            s.CopyTo(t, len);

            t.Position = 0;			
            t.Type = 2;				
            t.Charset = "utf-8";	

            text = t.readText(-1);	
        } catch (e) {
            throw e;
        } finally {
            t.close();
        }
        return text;
    },

    //取表单元素名的映射
    getHash: function(){
        return this.hash;
    },

    //获取所有文件数组
    getFiles: function(){
        return this.files;
    },

    //根据表单name或数组下标得到对应文件信息
    getFile: function(name){
        if(F.isNumber(name)){
            return this.files[name];
        }
        return this.hash[name];
    },

    //保存文件到路径
    saveToFile: function(name, path){
        var f = this.getFile(name);
        if(path === undefined){
            path = f.fileName;
        }
        if(path.indexOf(':') === -1){
            path = Server.MapPath(path);
        }
        var folder = new F.Folder(path.replace(/(\\|\/)[^\\\/]+$/, ''));
        if(!folder.exist()){
            folder.create();
        }
        var s = this._stream;
        var t = this._tempStream;
        t.Type = 1;
        t.Open();
        s.Position = 0;
        s.Position = f.dataPosition;
        s.CopyTo(t, f.dataSize);
        t.SaveToFile(path, 2);
        t.Close();
    },

    //保存到某个目录，如果目录不存在，会递归创建
    saveAllTo: function(folder){
        var path = folder.indexOf(':') === -1 ? Server.MapPath(folder) : folder;
        var last = path.slice(-1);
        path = (last === '/' || last === '\\') ? path : path + '/';
        var folder = new F.Folder(path);
        if(!folder.exist()){
            folder.create();
        }
        for(var i=0; i<this.files.length; i++){
            this.saveToFile(i, path + this.files[i].fileName);
        }
    },

    //释放资源
    dispose: function(){
        if(this._stream.State !== 0){
            this._stream.Close();
            this._stream = null;
        }
        if(this._tempStream.State !== 0){
            this._tempStream.Close();
            this._stream = null;
        }
    }
};








// vim:ft=javascript
%>
