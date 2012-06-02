
//数据库连接基类
F.Connection = function(){
    F.Connection.last = this;
    this._connectionString = '';
    this._connection = null;
    this._isOpen = false;
};

//最后创建的连接
F.Connection.last = null;


F.Connection.prototype = {
    //连接是否打开
    isOpen: function(){
        return this._isOpen;
    },

    //打开连接
    open: function(){
        try{
            this._connection = new ActiveXObject("ADODB.Connection");
            this._connection.ConnectionString = this._connectionString;
            this._connection.Open();
            this._isOpen = true;
            return this;
        }catch(e){
            throw new Error('Connection open Error!');
        }
    },

    //关闭连接
    close: function(){
        try{
            this._connection.Close();
            this._connection = null;
            this._isOpen = false;
            return this;
        }catch(e){
            throw new Error('Connection close Error!');
        }
    },

    //得到对应表的数据模型
    model: function(tableName){
        return new F.Model(tableName, this);
    },

    //执行sql
    execute: function(sql){
        try{
            return this._connection.Execute(sql);
        }catch(e){
            e.sql = sql;
            throw e;
        }
    },

    //获取单个值
    executeScalar: function(sql){
        var rs = this.getRecordSet(sql), r;
        if(! rs.Eof){
            r = rs(0).Value;
            rs.Close();
        }else{
            throw new Error('No Result.');
        }
        return r;
    },

    //开始事务
    beginTrans: function(){
        this._connection.BeginTrans();
    },

    //回滚事务
    rollBackTrans: function(){
        this._connection.RollBackTrans();
    },

    //提交事务
    commitTrans: function(){
        this._connection.CommitTrans();
    },

    //获取记录集
    getRecordSet: function(sql, cursorType, lockType){
        cursorType = cursorType || 1;
        lockType = lockType || 1;
        var rs = new ActiveXObject("ADODB.RecordSet");
        rs.Open(sql, this._connection, cursorType, lockType);
        return rs;
    },

    //获取json对象
    getJson: function(rs){
        if(typeof rs == 'string'){
            rs = this.getRecordSet(rs);
        }
        var fieldsCount = rs.Fields.Count;
        var json = [], fields = [];
        for(var i=0; i<fieldsCount; i++){
            fields.push(rs.Fields(i).Name);
        }
        var l = fields.length;
        while(!rs.Eof){
            var row = {};
            for(var i=0; i<l; i++){
                row[fields[i]] = rs(fields[i]).Value;
            }
            json.push(row);
            rs.MoveNext();
        }
        rs.Close();
        return json;
    },

    //向表中插入一条记录
    insert: function(tableName, values){
        var rs = this.getRecordSet('select * from ' + tableName + ' where 1=2;', 1, 2);
        rs.AddNew();
        for(var i in values){
            rs(i) = values[i];
        }
        rs.Update();
        rs.Close();
    },

    //更新记录集数据
    update: function(rs, values){
        if(typeof rs == 'string'){
            rs = this.getRecordSet(rs, 2, 3);
        }
        while(!rs.Eof){
            for(var i in values){
                rs(i) = values[i];
            }
            rs.Update();
            rs.MoveNext();
        }
        rs.Close();
    },

    //获取表名数组
    tableNames: function(schemaName){
        return this.getSchemaNames('TABLE', 20, schemaName);
    },

    //获取视图名数组
    viewNames: function(schemaName){
        return this.getSchemaNames('VIEW', 20, schemaName);
    },

    //返回记录集的表格html
    //opt 表格参数
    //opt.cols  表格后增加的列，数组。元素形式 {th:'表头', td:function(){return 'x'}}
    //opt.caption 表格摘要
    //opt.nohead 不显示表头
    //opt.emptyString 没有数据时的文本
    //opt.attr
    getHtmlTable: function(rs, opt){
        opt = opt || {};
        var cols = opt.cols || [];
        if(typeof rs == 'string'){
            rs = this.execute(rs);
        }
        var html = ['<table cellspacing="0"',opt.attr && (' '+opt.attr)||'','>\n'];
        var fields = [];
        for (var e = new Enumerator(rs.Fields); !e.atEnd(); e.moveNext()) {
            fields.push(e.item().Name);
        }
        if(opt.caption){
            html.push('<caption>' + opt.caption + '</caption>\n');
        }
        if(!opt.nohead){
            html.push('<tr>\n');
            for(var i=0;i<fields.length;i++){
                html.push('<th>', fields[i], '</th>\n');
            }
            for(var i=0; i<cols.length; i++){
                html.push('<th>', cols[i].th, '</th>\n');
            }
        }
        html.push('</tr>\n');
        var rowIndex = 0, fieldsLength = fields.length, 
            temp = {}, i, columnCount = fieldsLength + cols.length;
        while(!rs.Eof){
            rowIndex ++;
            html.push('<tr>');
            for (i=0; i<fieldsLength; i++) {
                var value = rs(fields[i]).Value;
                switch(typeof value){
                case 'object':
                    if(! value){
                        value = '[Null]';
                    }else{
                        value = '[Object]';
                    }
                    break;
                case 'date':
                    value = new Date(value).toLocaleString();
                    break;
                case 'string':
                    value = value.length == 0 ? '[Empty]' : 
                    F.encodeHTML(value.length > 50 ? value.substr(0, 50) + '...' : value);
                    break;
                case 'unkonwn':
                    value = '[Binary]';
                    break;
                case 'number':
                    value = String(value);
                    break;
                }
                html.push('<td>',value, '</td>\n');
                temp[fields[i]] = value;
            }
            for(i=0; i<cols.length; i++){
                html.push('<td>', typeof cols[i]['td'] === 'function' ?
                    cols[i]['td'](temp) : cols[i]['td'], '</td>\n');
            }
            html.push('</tr>\n');
            if(rowIndex > 999){
                break;
            }
            rs.MoveNext();
        }
        rs.Close();
        if(rowIndex === 0){
            html.push('<tr><td colspan="'+columnCount+'">', opt.emptyString||'没有数据', '</td><tr>');
        }
        html.push('</table>');
        return html.join('');
    },

    //查询schema
    getSchemaNames: function(type, queryType, schemaName){
        var names = [];
        var constraints = [];
        if (schemaName) constraints[1] = schemaName;
        constraints[3] = type;
        var rs = this.getSchema(queryType, constraints);
        while (!rs.Eof) {
            names.push(rs(2).Value);
            rs.MoveNext();
        }
        rs.Close();
        return names;
    },

    //获取schema
    getSchema: function(queryType, constraints){
        return this._connection.OpenSchema(queryType, constraints);
    },

    //表格打印schema
    getSchemaHtml: function(queryType, constraints){
        return this.getHtmlTable(this.getSchema(queryType, constraints), {attr:'border=1'});
    },

    //执行sql文件
    //注意：sql文件必须是每行一条语句
    sourceSql: function(fileName){
        var f = new F.File(fileName);
        var conn = this._connection;
        f.forEachLine(function(sql){
            sql && conn.execute(sql.replace(/__RN__/g, '\n'));
        });
    },

    //获取ado数据类型对应的字符描述
    getTypeString: function(adoType, flags){
        var map = {
            11 : 'BOOLEAN',
            128 : 'BINARY',
            129 : 'VARCHAR',
            130 : 'VARCHAR',
            131 : 'DECIMAL',
            133 : 'DATETIME',
            134 : 'DATETIME',
            135 : 'DATETIME',
            137 : 'DATETIME',
            139 : 'DECIMAL',
            14 : 'DECIMAL',
            16 : 'TINYINT',
            17 : 'SMALLINT',
            18 : 'SMALLINT',
            19 : 'INTEGER',
            200 : 'VARCHAR',
            201 : 'TEXT',
            202 : 'VARCHAR',
            203 : 'TEXT',
            20 : 'INTEGER',
            21 : 'INTEGER',
            2 : 'SMALLINT',
            3 : 'INTEGER',
            4 : 'REAL',
            5 : 'FLOAT',
            64 : 'DATETIME',
            6 : 'FLOAT',
            7 : 'DATETIME',
            72: 'UNIQUEIDENTIFIER'
        };
        var t = map[adoType];
        //针对access的特殊处理
        if(t === 'VARCHAR' && flags === 234){
            t = 'TEXT';
        }else if(flags === 90 && adoType === 3){
            t = 'AUTOINCREMENT';
        }
        return t || 'TEXT';
    }
};

// vim:ft=javascript

