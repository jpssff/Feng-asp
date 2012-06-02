
//xml操作类
//可以抓取xml并自动判断编码
//可以转成json格式

F.Xml = function(input){
    this.input = input;
    this.xml = null;
    this.obj = null;
    if(F.isObject(input)){
        this.obj = input;
        this.xml = input.xml;
    }else if(F.isString(input)){
        this.xml = input;
        this.obj = F.Xml.fromString(input);
    }
};

F.Xml.prototype = {
    toJson: function(){
        //return F.Xml.parseXMLNode(node || this.obj);

        // Create the return object
        var xml = this.obj;
        var obj = {};
        if (xml.nodeType == 1) { // element
            // do attributes
            if (xml.attributes.length > 0) {
                obj["@attributes"] = {};
                for (var j = 0; j < xml.attributes.length; j++) {
                    var attribute = xml.attributes.item(j);
                    obj["@attributes"][attribute.nodeName] = attribute.nodeValue;
                }
            }
        } else if (xml.nodeType == 3) { // text
            obj = xml.nodeValue;
        }

        // do children
        if (xml.childNodes) {
            for(var i = 0; i < xml.childNodes.length; i++) {
                var item = xml.childNodes.item(i);
                var nodeName = item.nodeName;
                if (typeof(obj[nodeName]) == "undefined") {
                    if (nodeName === '#cdata-section' || nodeName === '#text') {
                        obj = item.nodeValue;
                    }else{
                        obj[nodeName] = new F.Xml(item).toJson();
                    }
                } else {
                    if (typeof(obj[nodeName].length) == "undefined") {
                        var old = obj[nodeName];
                        obj[nodeName] = [];
                        obj[nodeName].push(old);
                    }
                    obj[nodeName].push(new F.Xml(item).toJson());
                }
            }
        }
        return obj;
    },

    load: function(url){
        var _this = this;
        F.ajax.get(url, function(xml){
            _this.obj = xml;
            _this.xml = xml.xml;
        },'xml');
        return _this;
    },

    toString: function(){
        return this.xml;
    }
};

F.Xml.fromString = function(xml) {
    var obj = {};
    var xmlDOM = new ActiveXObject("Microsoft.XMLDOM");
    xmlDOM.async = false;
    xmlDOM.validateOnParse = false;
    if(xml.trim().indexOf('<?xml') !== 0){
        xml = '<__root>' + xml + '</__root>';
    }
    var success = xmlDOM.loadXML(xml);
    if (success) {
        obj = xmlDOM.documentElement;
    }
    xmlDOM = null;
    return obj;
};

// vim:ft=javascript

