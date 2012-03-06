<%

F.MsJetConnection = function(dataPath){
    F.Connection.call(this);

    this._dataSource = Server.MapPath(dataPath);
    this._connectionString = 
        "Provider=Microsoft.Jet.OLEDB.4.0; " +
		"Data source=" + this._dataSource + "; " +
		"User Id=admin; Password=;";
};
F.inherits(F.MsJetConnection, F.Connection);

F.MsJetConnection.prototype.repair = function(){
    var needOpen = false;
    if(this._isOpen){
        needOpen = true;
        this.close();
    }
    var engine = new ActiveXObject("JRO.JetEngine");
    var fso = F.fso();
    var mdb = this._dataSource;
    var tmp = mdb + ".tmp";
    var bak = mdb + ".bak";
    fso.CopyFile(mdb, bak);
    if (fso.FileExists(tmp)) fso.DeleteFile(tmp);
    engine.CompactDatabase(
        "Provider=Microsoft.Jet.OLEDB.4.0; Data source=" + mdb + "; User Id=admin; Password=;",
        "Provider=Microsoft.Jet.OLEDB.4.0; Data source=" + tmp + "; User Id=admin; Password=;");
    if (fso.FileExists(mdb)) fso.DeleteFile(mdb);
    fso.MoveFile(tmp, mdb);
    fso = null;
    engine = null;
    if(needOpen){
        this.open();
    }
};

// vim:ft=javascript
%>
