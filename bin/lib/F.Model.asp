<%
//tableName: 需要操作的表名
//connection: F.Connection实例
F.Model = function(tableName, connection){
    this.tableName = tableName;
    this.connection = connection;
    //获取schema约束条件
    this._constraints = [null, null, this.tableName];
    //主键
    this._primaryKey = null;
    //字段属性
    this.fields = null;
};

F.Model.prototype = {

    //获取表的主键
    pk: function(){
        if(this._primaryKey){
            return this._primaryKey;
        }else{
            var rs = this.connection.getSchema(28, this._constraints);
            if(rs.Eof){
                return null;
            }else{
                this._primaryKey = rs('COLUMN_NAME').Value;
                return this._primaryKey;
            }
        }
    },

    //获取表的字段属性
    fieldsType: function(){
        var r = {};
        var rs = this.connection.getSchema(4, this._constraints);
        var name, type;
        var Type = F.Model.AdoDataType;
        //die(this.connection.getHtmlTable(rs));
        while(!rs.Eof){
            type = rs('DATA_TYPE').Value;
            name = rs('COLUMN_NAME').Value;
            r[name] = {
                type: type,
                desc: Type[type].name,
                base: Type[type].type,
                isNullable: Boolean(rs('IS_NULLABLE').Value),
                hasDefault: Boolean(rs('COLUMN_DEFAULT').Value),
                defaultValue: rs('COLUMN_DEFAULT').Value,
                flags: rs('COLUMN_FLAGS').Value,
                maxLength: rs('CHARACTER_MAXIMUM_LENGTH').Value,
                numPrecision: rs('NUMERIC_PRECISION').Value
            };
            rs.MoveNext();
        }
        rs.Close();
        rs = null;
        return r;
    },

    getCreateSql: function(){
        var pk = this.pk();
        var fields = this.fieldsType();
        var sql = ['CREATE TABLE ' + this.tableName + '('];
        var conn = this.connection;
        for(var f in fields){
            var field = fields[f];
            var type = conn.getTypeString(field.type, field.flags);
            sql.push('[' + f, '] ' + type);
            if(String(field.maxLength) !== 'null' && field.maxLength > 0){
                sql.push('(' + field.maxLength + ')');
            }
            if(pk === f){
                sql.push(' PRIMARY KEY');
            }
            if(!field.isNullable){
                sql.push(' NOT NULL');
            }
            sql.push(',');
        }
        sql.pop();
        sql.push(');');
        return sql.join('');
    },

    //统计数量
    count: function(where){
        where = this._getWhereString(where);
        var sql = 'select count(*) from ' + this.tableName + where;
        return this.connection.executeScalar(sql);
    },

    //分页，可以满足基本的使用
    page: function(page, where, fields, count, order, linkopt){
        var p = {},
        where = this._getWhereString(where);
        pk = this.pk(),
        count = count || 10,
        fields = fields || '*',
        order = ' order by ' + (order ? order : pk),
        currentPage = parseInt(page || 1);
        var linkCount = count || 10;
        linkopt = linkopt || {};
        var params = linkopt.params;
        var pt = typeof params;
        if(pt === 'string'){
            if(pt.charAt(0) === '&')
                params = params.slice(0);
        }else if(pt === 'object'){
            var ptemp = [];
            for(var i in params){
                ptemp.push(i + '=' + params[i]);
            }
            params = ptemp.join('&');
        }
        if(params === undefined){
            params = '';
        }else{
            params = '&' + params;
        }

        var sql = 'select * from ' + this.tableName + where + order;
        var rs = this.connection.getRecordSet(sql);

        var total = rs.RecordCount;
        var totalPage = Math.ceil(total/count);
        if(isNaN(currentPage) || currentPage < 1){
            currentPage = 1;
        }else if(currentPage > totalPage){
            currentPage = totalPage;
        }

        rs.PageSize = count;
        if(rs.PageCount < page){
            page = rs.PageCount;
        }
        var data = [], index = 0;
        var l = rs.Fields.Count;
        var fieldsName = [];
        for(var i=0; i<l; i++){
            fieldsName.push(rs.Fields(i).Name);
        }

        if(rs.PageCount > 0){
            rs.AbsolutePage = page;
            while(index < count && !rs.Eof){
                var row = {};
                for(var i=0; i<l; i++){
                    row[fieldsName[i]] = rs(fieldsName[i]).Value;
                }
                data.push(row);
                rs.MoveNext();
                index ++;
            }
        }

        var numbers = [], half = Math.ceil(linkCount/2), i = 0, 
        maxNum = (currentPage+half)<totalPage ? currentPage + half : totalPage;
        while(i++ < linkCount){
            if(maxNum > 0){
                numbers.unshift(maxNum);
            }
            maxNum --;
        }
        var links = [];
        if(totalPage > 0){
            if(currentPage === 1){
                links.push('<li class="prev disabled"><a href="#">首页</a></li>');
                links.push('<li class="disabled"><a href="#">« 上页</a></li>');
            }else{
                links.push('<li><a href="?page=1'+params+'">首页</a></li>');
                links.push('<li><a href="?page='+(currentPage-1)+params+'">« 上页</a></li>');
            }
            numbers.forEach(function(v, i){
                if(v === currentPage){
                    links.push('<li class="active"><a href="#">', v, '</a></li>');
                }else{
                    links.push('<li><a href="?page=', v, params, '">', v, '</a></li>');
                }
            });
            if(currentPage === totalPage){
                links.push('<li class="disabled"><a href="#">下页 »</a></li>');
                links.push('<li class="next disabled"><a href="#">尾页</a></li>');
            }else{
                links.push('<li><a href="?page=', (currentPage+1), params, '">下页 »</a></li>');
                links.push('<li class="next"><a href="?page=', totalPage, params, '">尾页</a></li>');
            }
        }
        var r = {
            'total' : totalPage,
            'current' : currentPage,
            'count' : count,
            'isFirst' : currentPage === 1,
            'isLast' : currentPage === total,
            'hasPrev': currentPage > 1,
            'hasNext': currentPage < totalPage,
            'data' : data,
            'numbers' :  numbers,
            'links' : links.join('')
        };
        return r;
    },

    //查找符合条件的全部结果
    findAll: function(where, fields, order, limit, isRecordSet){
        where = this._getWhereString(where);
        fields = fields || '*';
        order = order ? ' order by ' + order : '';
        limit = isNaN(parseInt(limit)) ? '' : 'top ' + limit + ' ';
        var sql = 'select ' + limit + fields + ' from ' + this.tableName + where + order; 
        var rs = this.connection.execute(sql);
        return isRecordSet ? rs : this.connection.getJson(sql);
    },

    //查找一个符合条件的数据
    find: function(where, fields, order){
        var r = this.findAll(where, fields, order, 1);
        return r.length == 1 ? r[0] : null;
    },

    //插入数据
    insert: function(values){
        this.connection.insert(this.tableName, values);
    },

    //更新数据,先查找需要修改的，改成第二个参数的数据
    update: function(where, values){
        var sql = 'select * from ' + this.tableName + this._getWhereString(where);
        this.connection.update(sql, values);
    },

    //删除数据
    del: function(where){
        var sql = 'delete from ' + this.tableName + this._getWhereString(where);
        this.connection.execute(sql);
    },

    //得到表的html
    html: function(where, fields, order, limit, opt){
        return this.connection.getHtmlTable(this.findAll(where, fields, order, limit, 1), opt);
    },

    //导出到xml文件
    exportXml: function(fileName){
        var file = new F.File(fileName);
        var step = 50, i = 0;
        var fields = this.fieldsType();
        var rs = this.findAll('', '*', '', '', true);
        var xml = ['<' , this.tableName , '>\n'];
        if(!file.exist()){
            file.create();
        }
        while(!rs.Eof){
            i++;
            xml.push('\t<item>\n');
            for(var i in fields){
                xml.push('\t\t<', i, '><![CDATA[', String(rs(i).Value), ']]></', i, '>\n'); 
            }
            xml.push('\t</item>\n');
            if(i % step === 0){
                file.appendText(xml.join(''));
                xml = [];
            }
            rs.MoveNext();
        }
        rs.Close();
        rs = null;
        xml.push('</', this.tableName, '>\n');
        file.appendText(xml.join(''));
    },

    //导出sql
    exportSql: function(fileName){
        var file = new F.File(fileName);
        var step = 50, i = 0;
        var fields = this.fieldsType();
        var rs = this.findAll('', '*', '', '', true);
        var createSql = this.getCreateSql();
        if(!file.exist()){
            file.create();
        }
        file.appendText(createSql + '\n');
        var sql = [];
        while(!rs.Eof){
            i++;
            sql.push('insert into ', this.tableName, '(');
            var keys = [];
            var values = [];
            for(var i in fields){
                if(rs(i).Value === null){
                    continue;
                }
                keys.push('['+i+']');
                if(fields[i].base === 'number' || fields[i].base === 'boolean'){
                    values.push(rs(i).Value || 0);
                }else{
                    values.push("'" + String(rs(i).Value).replace(/\r?\n/g, '__RN__').replace(/'/g, "''") + "'"); 
                }
            }
            sql.push(keys.join(','), ') values(');
            sql.push(values.join(','), ');\n');
            if(i % step === 0){
                file.appendText(sql.join(''));
                sql = [];
            }
            rs.MoveNext();
        }
        rs.Close();
        rs = null;
        file.appendText(sql.join(''));
    },

    //内部函数，用来获取where语句
    _getWhereString: function(where){
        if(where === undefined || where === null){
            where = '';
        }else if(F.isArray(where)){
            where = where.join(' and ');
        }else if(F.isNumber(where)){
            where = this.pk() + '=' + where; 
        }else if(F.isObject(where)){
            if(!this.fields){
                this.fields = this.fieldsType();
            }
            var w = '', fields = this.fields;
            for(var col in where){
                if(col in fields){
                    var s = String(where[col]);
                    w += 'and ' + col + '=';
                    if(fields[col].base === 'text'){
                        w += "'" + s.replace(/'/g, "''") + "'";
                    }else{
                        w += s;
                    }
                }
            }
            where = w.slice(4);
        }
        return where === '' ? '' : ' where ' + where;
    }

};

//基本类型
F.Model.BaseType = {
    'unknown' : 0,
    'number'  : 1,
    'date'    : 2,
    'boolean' : 3,
    'text'    : 4
};

//ado数据类型
F.Model.AdoDataType = {
		0:		{ name: "adEmpty", type: 'unknown' },
		10:		{ name: "adError", type: 'unknown' },
		11:		{ name: "adBoolean", type: 'boolean' },
		128:	{ name: "adBinary", type: 'unknown' },
		129:	{ name: "adChar", type: 'text' },
		12:		{ name: "adVariant", type: 'unknown' },
		130:	{ name: "adWChar", type: 'text' },
		131:	{ name: "adNumeric", type: 'number' },
		132:	{ name: "adUserDefined", type: 'unknown' },
		133:	{ name: "adDBDate", type: 'date' },
		134:	{ name: "adDBTime", type: 'date' },
		135:	{ name: "adDBTimeStamp", type: 'date' },
		136:	{ name: "adChapter", type: 'unknown' },
		137:	{ name: "adDBFileTime", type: 'date' },
		138:	{ name: "adPropVariant", type: 'unknown' },
		139:	{ name: "adVarNumeric", type: 'number' },
		13:		{ name: "adIUnknown", type: 'unknown' },
		14:		{ name: "adDecimal", type: 'number' },
		16:		{ name: "adTinyInt", type: 'number' },
		17:		{ name: "adUnsignedTinyInt", type: 'number' },
		18:		{ name: "adUnsignedSmallInt", type: 'number' },
		19:		{ name: "adUnsignedInt", type: 'number' },
		200:	{ name: "adVarChar", type: 'text' },
		201:	{ name: "adLongVarChar", type: 'text' },
		202:	{ name: "adVarWChar", type: 'text' },
		203:	{ name: "adLongVarWChar", type: 'text' },
		204:	{ name: "adVarBinary", type: 'unknown' },
		205:	{ name: "adLongVarBinary", type: 'unknown' },
		20:		{ name: "adBigInt", type: 'number' },
		21:		{ name: "adUnsignedBigInt", type: 'number' },
		2:		{ name: "adSmallInt", type: 'number' },
		3:		{ name: "adInteger", type: 'number' },
		4:		{ name: "adSingle", type: 'number' },
		5:		{ name: "adDouble", type: 'number' },
		64:		{ name: "adFileTime", type: 'date' },
		6:		{ name: "adCurrency", type: 'number' },
		72:		{ name: "adGUID", type: 'unknown' },
		7:		{ name: "adDate", type: 'date' },
		8192:	{ name: "adArray", type: 'unknown' },
		8:		{ name: "adBSTR", type: 'unknown' },
		9:		{ name: "adIDispatch", type: 'unknown' }
};

// vim:ft=javascript
%>
