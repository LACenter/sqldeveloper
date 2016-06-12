////////////////////////////////////////////////////////////////////////////////
// Unit Description  : globals Description
// Unit Author       : LA.Center Corporation
// Date Created      : February, Thursday 18, 2016
// -----------------------------------------------------------------------------
//
// History
//
//
////////////////////////////////////////////////////////////////////////////////

var
    _rootdir: string = '';
    _sqlFile: string = '';
    _dbtree: TTreeView = nil;
    _xml: TXMLDataset = nil;

procedure _registerDB(name, type, serverhost, dbname, user, pass, params: string);
begin
    _xml.Append;
    _xml.Field('cname').AsString := name;
    _xml.Field('type').AsString := type;
    _xml.Field('host').AsString := serverhost;
    _xml.Field('dbname').AsString := dbname;
    _xml.Field('user').AsString := user;
    _xml.Field('pass').AsString := pass;
    _xml.Field('params').AsString := params;
    _xml.SaveToXMLFile(_xml.FileName);

    _populateTree;
end;

procedure _removeDB(name: string);
begin
    _xml.Close;
    _xml.LoadFromXMLFile(_xml.FileName);

    while not _xml.Eof do
    begin
        if _xml.Field('cname').AsString+' ('+_xml.Field('type').AsString+')' = name then
        begin
            _xml.Delete;
            _xml.SaveToXMLFile(_xml.FileName);
            if _dbtree.Selected.Data <> nil then
            begin
                try
                    _dbtree.Selected.Data.Free;
                except end;
            end;
            _dbtree.Selected.Delete;
            break;
        end;
        _xml.Next;
    end;
end;

procedure _populateTree();
var
    node: TTreeNode;
    i: int;
begin
    for i := 0 to _dbtree.Items.Count -1 do
    begin
        if _dbtree.Items.Item[i].Data <> nil then
            try
                _dbtree.Items.Item[i].Data.free;
            except end;
    end;

    _dbtree.Items.BeginUpdate;
    _dbtree.Items.Clear;

    _xml.Close;
    _xml.LoadFromXMLFile(_xml.FileName);

    while not _xml.Eof do
    begin
        node := _dbtree.Items.Add(_xml.Field('cname').Text+' ('+_xml.Field('type').Text+')');
        node.ImageIndex := 1;
        node.SelectedIndex := node.ImageIndex;
        node.HasChildren := true;
        _xml.Next;
    end;

    _dbtree.Items.EndUpdate;
end;

function _testConnection(type, serverhost, dbname, user, pass, params: string): bool;
begin
    case type of
        'LA.Live Database':     result := (_connectLiveDB(serverhost, dbname, user, pass) <> nil);
        'Firebird (InterBase)': result := (_connectFirebird(serverhost, dbname, user, pass, params) <> nil);
        'MS SQL Server':        result := (_connectMsSQL(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 40':             result := (_connectMySQL40(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 41':             result := (_connectMySQL41(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 50':             result := (_connectMySQL50(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 51':             result := (_connectMySQL51(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 55':             result := (_connectMySQL55(serverhost, dbname, user, pass, params) <> nil);
        'MySQL 56':             result := (_connectMySQL56(serverhost, dbname, user, pass, params) <> nil);
        'ODBC':                 result := (_connectODBC(dbname, user, pass, params) <> nil);
        'Oracle':               result := (_connectOracle(serverhost, dbname, user, pass, params) <> nil);
        'PostgreSQL':           result := (_connectPostgreSQL(serverhost, dbname, user, pass, params) <> nil);
        'SQLite':               result := (_connectSQlite(dbname) <> nil);
        'Sybase':               result := (_connectSybase(serverhost, dbname, user, pass, params) <> nil);
    end;
end;

function _connectLiveDB(serverhost, dbname, user, pass: string): TLASQLConnection;
var
    conn: TLASQLConnection;
begin
    try
        conn := TLASQLConnection.Create(nil);
        conn.AutoWaitCursor := true;
        conn.PublicKey := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        if conn.Connect then
            result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        result := nil;
    end;
end;

function _connectFirebird(serverhost, dbname, user, pass, params: string): TIBConnection;
var
    conn: TIBConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TIBConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMsSQL(serverhost, dbname, user, pass, params: string): TMSSQLConnection;
var
    conn: TMSSQLConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TMSSQLConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL40(serverhost, dbname, user, pass, params: string): TMySQL40Connection;
var
    conn: TMySQL40Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL40Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL41(serverhost, dbname, user, pass, params: string): TMySQL41Connection;
var
    conn: TMySQL41Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL41Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL50(serverhost, dbname, user, pass, params: string): TMySQL50Connection;
var
    conn: TMySQL50Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL50Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL51(serverhost, dbname, user, pass, params: string): TMySQL51Connection;
var
    conn: TMySQL51Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL51Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL55(serverhost, dbname, user, pass, params: string): TMySQL55Connection;
var
    conn: TMySQL55Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL55Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectMySQL56(serverhost, dbname, user, pass, params: string): TMySQL56Connection;
var
    conn: TMySQL56Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TMySQL56Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectODBC(dbname, user, pass, params: string): TODBCConnection;
var
    conn: TODBCConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TODBCConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectOracle(serverhost, dbname, user, pass, params: string): TOracleConnection;
var
    conn: TOracleConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TOracleConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectPostgreSQL(serverhost, dbname, user, pass, params: string): TPQConnection;
var
    conn: TPQConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TPQConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectSQlite(dbname: string): TSQLite3Connection;
var
    conn: TSQLite3Connection;
    tran: TSQLTransaction;
begin
    try
        conn := TSQLite3Connection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.DatabaseName := dbname;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectSybase(serverhost, dbname, user, pass, params: string): TSybaseConnection;
var
    conn: TSybaseConnection;
    tran: TSQLTransaction;
begin
    try
        conn := TSybaseConnection.Create(nil);
        tran := TSQLTransaction.Create(nil);
        conn.Transaction := tran;
        conn.HostName := serverhost;
        conn.DatabaseName := dbname;
        conn.UserName := user;
        conn.Password := pass;
        conn.Params.Text := params;
        conn.LoginPrompt := false;
        conn.Open;
        result := conn;
    except
        MsgError('Error', ExceptionMessage);
        conn.free;
        tran.free;
        result := nil;
    end;
end;

function _connectToDB(node: TTreeNode): bool;
var
    type: string;
begin
    _xml.Close;
    _xml.LoadFromXMLFile(_xml.FileName);

    while not _xml.Eof do
    begin
        if _xml.Field('cname').AsString+' ('+_xml.Field('type').AsString+')' = Node.Text then
        begin
            try
                type := _xml.Field('type').AsString;
                case type of
                    'LA.Live Database':     Node.Data := _connectLiveDB(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString);
                    'Firebird (InterBase)': Node.Data := _connectFirebird(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MS SQL Server':        Node.Data := _connectMsSQL(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 40':             Node.Data := _connectMySQL40(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 41':             Node.Data := _connectMySQL41(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 50':             Node.Data := _connectMySQL50(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 51':             Node.Data := _connectMySQL51(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 55':             Node.Data := _connectMySQL55(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'MySQL 56':             Node.Data := _connectMySQL56(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'ODBC':                 Node.Data := _connectODBC(_xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'Oracle':               Node.Data := _connectOracle(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'PostgreSQL':           Node.Data := _connectPostgreSQL(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                    'SQLite':               Node.Data := _connectSQlite(_xml.Field('dbname').AsString);
                    'Sybase':               Node.Data := _connectSybase(_xml.Field('host').AsString, _xml.Field('dbname').AsString, _xml.Field('user').AsString, _xml.Field('pass').AsString, _xml.Field('params').AsString);
                end;
            except
                Node.Data := nil;
                MsgError('Error', ExceptionMessage);
            end;
            break;
        end;
        _xml.Next;
    end;
    result := (Node.Data <> nil);
end;

procedure _populateDB(Node: TTreeNode);
var
    item: TTreeNode;
begin
    if Node.Data.ClassName = 'TLASQLConnection' then
    begin
        item := _dbtree.Items.AddChild(Node, 'Indices');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;

        item := _dbtree.Items.AddChild(Node, 'Tables');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;

        item := _dbtree.Items.AddChild(Node, 'Triggers');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;

        item := _dbtree.Items.AddChild(Node, 'Views');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;
    end
        else
    begin
        item := _dbtree.Items.AddChild(Node, 'Procedures');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;

        item := _dbtree.Items.AddChild(Node, 'Tables');
        item.ImageIndex := 19;
        item.SelectedIndex := item.ImageIndex;
        item.HasChildren := true;
        item.Data := Node.Data;
    end;
end;

procedure _populateTables(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    if Node.Data.ClassName = 'TLASQLConnection' then
        TLASQLConnection(Node.Data).getTables(str)
    else
        TSQLConnection(Node.Data).GetTableNames(str);

    for i := 0 to str.Count -1 do
    begin
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 2;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
        item.HasChildren := true;
    end;

    str.free;
end;

procedure _populateProcs(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    TSQLConnection(Node.Data).GetProcedureNames(str);

    for i := 0 to str.Count -1 do
    begin
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 4;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
    end;

    str.free;
end;

procedure _populateViews(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    TLASQLConnection(Node.Data).getViews(str);

    for i := 0 to str.Count -1 do
    begin
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 21;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
    end;

    str.free;
end;

procedure _populateIndexes(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    TLASQLConnection(Node.Data).getIndexes(str);

    for i := 0 to str.Count -1 do
    begin
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 5;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
    end;

    str.free;
end;

procedure _populateTriggers(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    TLASQLConnection(Node.Data).getTriggers(str);

    for i := 0 to str.Count -1 do
    begin
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 4;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
    end;

    str.free;
end;

procedure _populateColumns(Node: TTreeNode);
var
    str: TStringList;
    i: int;
    item: TTreeNode;
begin
    str := TStringList.Create;
    if Node.Data.ClassName = 'TLASQLConnection' then
        TLASQLConnection(Node.Data).getFieldsOf(Node.Text, str)
    else
        TSQLConnection(Node.Data).GetFieldNames(Node.Text, str);

    for i := 0 to str.Count -1 do
    begin
        if Pos('=', str.Strings[i]) > 0 then
        item := _dbtree.Items.AddChild(Node, str.Names[i]+' [ '+str.ValueByIndex(i) + ' ]')
        else
        item := _dbtree.Items.AddChild(Node, str.Strings[i]);
        item.ImageIndex := 3;
        item.SelectedIndex := item.ImageIndex;
        item.Data := Node.Data;
    end;

    str.free;
end;

function _extactSQL(Node: TTreeNode): string;
var
    str: TStringList;
begin
    str := TStringList.Create;
    case Node.ImageIndex of
        2: str.Text := TLASQLConnection(_dbtree.Selected.Data).getTableSQL(_dbtree.Selected.Text);
        4: str.Text := TLASQLConnection(_dbtree.Selected.Data).getTriggerSQL(_dbtree.Selected.Text);
        5: str.Text := TLASQLConnection(_dbtree.Selected.Data).getIndexSQL(_dbtree.Selected.Text);
        21: str.Text := TLASQLConnection(_dbtree.Selected.Data).getViewSQL(_dbtree.Selected.Text);
    end;
    result := str.Text;
    str.Free;
end;

//<events-code> - note: DESIGNER TAG => DO NOT REMOVE!

//globals initialization constructor
constructor
begin
    //adjust ModalDimmed Rect
    if IsWindowsXP then
    begin
        AdjustDimOffsetLeft(-9);
        AdjustDimOffsetWidth(9);
    end;
    if IsWindowsVista or IsWindows7 then
    begin
        AdjustDimOffsetLeft(-8);
        AdjustDimOffsetWidth(16);
        AdjustDimOffsetHeight(8);
    end;
    if Linux then
    begin
        AdjustDimOffsetLeft(-1);
        AdjustDimOffsetTop(-1);
        AdjustDimOffsetWidth(4);
        AdjustDimOffsetHeight(2);
    end;

    _rootdir := UserDir+'LA.SQL Developer'+DirSep;
    ForceDir(_rootdir);
    //create xml dataset for registering databases
    _xml := TXMLDataset.Create(nil);
    _xml.FileName := _rootdir+'regdb.xml';
    if not FileExists(_xml.FileName) then
    begin
        _xml.FieldDefs.Add('cname', ftString, 30);
        _xml.FieldDefs.Add('type', ftString, 30);
        _xml.FieldDefs.Add('host', ftString, 100);
        _xml.FieldDefs.Add('dbname', ftString, 30);
        _xml.FieldDefs.Add('user', ftString, 30);
        _xml.FieldDefs.Add('pass', ftString, 30);
        _xml.FieldDefs.Add('params', ftString, 1000);
        _xml.Active := true;
        _xml.SaveToXMLFile(_xml.FileName);
    end;
end.
