<%
// 缓存操作
F.namespace('F.cache');

//设置
F.cache.set = function(name, value) {
    Application.Lock();
    Application(name) = value;
    Application.UnLock();
};

//获取
F.cache.get = function(name) {
    var value = Application(name);
    return value;
};

//删除name或者全部
F.cache.remove = function(name) {
    Application.Lock();
    if (name) {
        Application.Contents.Remove(name);
    } else {
        Application.Contents.RemoveAll();
    }
    Application.UnLock();
};

//遍历
F.cache.each = function(fn){
    var s = new Enumerator(Application.Contents);
    for(;!s.atEnd();s.moveNext()){
        var k = s.item();
        fn.call(null, k, Application(k));
    }
};

//缓存目录
F.cache._path = 'cache';

//缓存文件对象
F.cache._file = null;

//获得缓存的文件内容
F.cache.getFileText = function(){
    var file = this._getFileObject();
    if(file.exist()){
        return file.getText();
    }
    return null;
};

//设置缓存
F.cache.setFileText = function(key, html){
    if(html === undefined){
        html = key;
        key = undefined;
    }
    var file = this._getFileObject(key);
    file.setText(html);
};

//删除缓存
F.cache.removeFile = function(key){
    var file = this._getFileObject(key);
    file.remove();
};

//是否存在文件缓存
F.cache.existFile = function(key){
    var file = this._getFileObject(key);
    return file.exist();
};

//返回缓存文件的更新时间
F.cache.time = function(key){
    var file = this._getFileObject(key);
    return new Date(file.fso.GetFile(file.path).DateLastModified);
};

//删除所有缓存文件
F.cache.removeAllFiles = function(){
    var file = new F.File();
    file.fso.DeleteFolder(server.MapPath(F.cache._path), true);
    file.fso.CreateFolder(server.MapPath(F.cache._path));
};

//获取文件对象
F.cache._getFileObject = function(key){
    if(!this._file){
        var fileKey = key === undefined ? F.string.base64Encode(F.server('QUERY_STRING')) : key;
        this._file = new F.File(F.cache._path + '/' + fileKey);
    }
    return this._file;
};

//遍历所有缓存文件
F.cache.eachFile = function(fn){
    var folder = new F.Folder(F.cache._path);
    folder.files().forEach(function(file){
        fn.call(file, file);
    });
};

// vim:ft=javascript
%>
