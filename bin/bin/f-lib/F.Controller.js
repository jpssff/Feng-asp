

F.Controller = function(){

};


F.Controller.prototype = {
    getName: function(){
        return F.get('r') || 'site';
    },

    getActionName: function(){
        return F.get('a') || 'index';
    }
};



// vim:ft=javascript

