

F.ExcelConnection = function(dataPath, hasHeader){
    F.Connection.call(this);

    this._hasHeader = hasHeader;
    this._dataSource = Server.MapPath(dataPath);
    this._connectionString = 
        'Provider=Microsoft.Jet.OLEDB.4.0; ' +
		'Data source=' + this._dataSource + '; ' +
		'User Id=admin; Password=; ' +
		'Extended Properties="Excel 8.0;HDR=' + (this.header ? 'Yes' : 'No')+ '";';
};
F.inherits(F.ExcelConnection, F.Connection);


// vim:ft=javascript


