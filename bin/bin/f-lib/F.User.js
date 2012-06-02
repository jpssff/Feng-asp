

F.User = function(id, connection){
    this.id = null;
    this.name = null;
    this.password = null;
    this.group = F.User.GROUP.GUEST;
    this.config = F.User.config;
    this._allInfo = null; //用户的所有信息
    if(!F.User.connection){
        F.User.connection = connection || F.Connection.last;
        F.User.model = F.User.connection.model(this.config.tableName);
    }
    if(id !== undefined){
        this.getById(id);
    }
};

F.User.connection = null;
F.User.model = null;

F.User.prototype = {
    isGuest: function(){
        return this.group === F.User.GROUP.GUEST;
    },

    isMember: function(){
        return this.group > F.User.GROUP.GUEST;
    },

    isAdmin: function(){
        return this.group === F.User.GROUP.ADMIN;
    },

    getById: function(id){
        return this.getBy('id', id);
    },

    getByName: function(name){
        return this.getBy('name', name);
    },

    getBy: function(key, value){
        if(F.isString(value)){
            value = String(value).trim();
        }
        if(value === undefined || value == '' || value == '*')
            return this;
        var info = this.getInfoBy(key, value);
        if(info){
            this._allInfo = info;
            this.id = info[this.config['id']];
            this.name = info[this.config['name']];
            this.password = info[this.config['password']];
            this.group = info[this.config['group']];
        }
        return this;
    },

    getInfoBy: function(key, value){
        var w = {};
        w[this.config[key]] = value;
        return F.User.model.find(w);
    },

    existId: function(id){
        return !! this.getInfoBy('id', id);
    },

    existName: function(name){
        return !! this.getInfoBy('name', name);
    },

    check: function(name, password, isMd5){
        var info = this.getInfoBy('name', name);
        if(info){
            if(isMd5){
                password = F.md5(password);
            }
            if(info[this.config.password] === password){
                return true;
            }
        }
        return false;
    },

    checkLogin: function(name, password, isMd5){
        name = name.trim().replace(/\s/g, '').replace(/[,"'.*%-+&<>=]+/g, '');
        password = password.replace(/\W/g, '');
        if(this.check(name, password, isMd5)){
            Session.CodePage = 65001;
            Session.LCID = 2052;
            Session.Timeout = 60;
            F.session.set('F_User_login_ok', 1);
            return true;
        }
        return false;
    },

    logout: function(){
        F.User.logout();
    },

    isLogin: function(){
        return F.User.isLogin();
    }
};

F.User.isLogin = function(){
    return !! F.session.get('F_User_login_ok');
};

F.User.logout = function(){
    F.session.remove('F_User_login_ok');
}


//用户组别,根据权限大小定义组别的整数值
F.User.GROUP = {
    'GUEST' : 0,
    'MEMBER' : 1,
    'ADMIN' : 100
};

//数据库表的配置
F.User.config = {
    'tableName' : 'users',
    'id' : 'id',
    'name' : 'user_name',
    'group' : 'user_group',
    'password' : 'user_password'
};

// vim:ft=javascript

