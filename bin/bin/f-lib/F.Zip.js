
////////   对JSZip引用  /////////
/**
* Zip类，虽然可以运行。但实际上不实用。压缩需要时间太长。保存到文件太费时间。
*/
F.Zip = function(){
    this.zip = new JSZip('DEFLATE');
};

F.Zip.prototype = {
    /**
        zip.add("Hello.txt", "Hello World\n");
        zip.add("smile.gif", "R0lGODdhBQAFAIACAAAAAP/eACwAAAAABQAFAAACCIwPkWerClIBADs=", {base64: true});
        zip.add("magic.txt", "U2VjcmV0IGNvZGU=", {base64: true, binary: false});
        zip.add("Xmas.txt", "Ho ho ho !", {date : new Date("December 25, 2007 00:00:01")});
        zip.add("animals.txt", "dog,platypus\n").add("people.txt", "james,sebastian\n");
    */ 
    add: function(name, data, options){
        return this.zip.add(name, data, options);
    },

    folder: function(name){
        return this.zip.folder(name);
    },

    find: function(needle){
        return this.zip.find(needle);
    },

    remove: function(name){
        return this.zip.remove(name);
    },

    generate: function(asBytes){
        return this.zip.generate(asBytes);
    },

    //path必须是相对路径
    addFile: function(path){
        var file = new F.File(path);
        return this.add(path, file.getBase64String(), {base64:true});
    },

    //将zip文件保存到文件
    saveToFile: function(name){
        var content = this.generate();
        var file = new F.File(name);
        file.setBase64String(content);
    }
};

// vim:ft=javascript

