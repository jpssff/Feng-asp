<%
F.namespace('F.session');
/// Session操作
F.session.get = function(name) {
    return Session(name);
};

F.session.set = function(name, value) {
    Session(name) = value;
};

F.session.remove = function(name) {
    if (name !== undefined) {
        Session.Contents.Remove(name);
    } else {
        Session.Contents.RemoveAll();
    }
};

F.session.each = function(fn){
    var s = new Enumerator(Session.Contents);
    for(;!s.atEnd();s.moveNext()){
        var k = s.item();
        fn.call(null, k, Session(k));
    }
};


// vim:ft=javascript
%>
