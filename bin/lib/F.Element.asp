<%

F.Element = function(tag, attrs){
    this.tagName = tag || 'div';
    this.id = '';
    this.classNames = [];
    this.attributes = {};
    this.style = {};
    this.innerHTML = '';

    if(F.isObject(attrs)){
        for(var i in attrs){
            this.attributes[i] = attrs[i];
        }
    }
};


F.Element.prototype = {
    addClass:
};


// vim:ft=javascript
%>

