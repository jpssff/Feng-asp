<%
//xml操作类
F.Xml = function(input){
    this.input = input;
    this.xml = null;
    this.obj = null;
    if(F.isObject(input)){
        this.obj = input;
        this.xml = input.xml;
    }else if(F.isString(input)){
        this.xml = input;
        this.obj = F.Xml.parseXMLString(input);
    }
};

F.Xml.prototype = {
    toJson: function(node){
        return F.Xml.parseXMLNode(node || this.obj);
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

F.Xml.parseXMLNode = function(node) {
    var obj = {};
    var element = node.firstChild;
    while (element) {
        if (element.nodeType === 1) {
            var name = element.nodeName;
            var sub = F.Xml.parseXMLNode(element)
            sub.nodeValue = "";
            sub.xml = element.xml;
            sub.toString = function() { return this.nodeValue; };
            sub.toXMLString = function() { return this.xml; }
            // get attributes
            if (element.attributes) {
                for (var i=0; i<element.attributes.length; i++) {
                    var attribute = element.attributes[i];
                    sub[attribute.nodeName] = attribute.nodeValue;
                }
            }
            // get nodeValue
            if (element.firstChild) {
                var nodeType = element.firstChild.nodeType;
                if (nodeType === 3 || nodeType === 4) {
                    sub.nodeValue = element.firstChild.nodeValue;
                }
            }
            // node already exists?
            if (obj[name]) {
                // need to create array?
                if (!obj[name].length) {
                    var temp = obj[name];
                    obj[name] = [];
                    obj[name].push(temp);
                }
                // append object to array
                obj[name].push(sub);
            } else {
                // create object
                obj[name] = sub;
            }
        }
        element = element.nextSibling;
    }
    return obj;
};


F.Xml.parseXMLString = function(xml) {
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
%>
